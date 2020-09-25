package com.sclouds.mouselive.views;

import android.annotation.SuppressLint;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;

import com.google.gson.Gson;
import com.sclouds.basedroid.BaseAdapter;
import com.sclouds.basedroid.BaseMVVMActivity;
import com.sclouds.basedroid.LogUtils;
import com.sclouds.basedroid.ToastUtil;
import com.sclouds.datasource.bean.Room;
import com.sclouds.datasource.bean.RoomUser;
import com.sclouds.datasource.bean.User;
import com.sclouds.datasource.business.pkg.BasePacket;
import com.sclouds.datasource.database.DatabaseSvc;
import com.sclouds.datasource.flyservice.funws.FunWSClientHandler;
import com.sclouds.datasource.flyservice.funws.FunWSSvc;
import com.sclouds.datasource.flyservice.http.FlyHttpSvc;
import com.sclouds.datasource.flyservice.http.network.BaseObserver;
import com.sclouds.datasource.hummer.HummerSvc;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.adapters.FakeMsgAdapter;
import com.sclouds.mouselive.adapters.VoiceUserAdapter;
import com.sclouds.mouselive.bean.FakeMessage;
import com.sclouds.mouselive.bean.PublicMessage;
import com.sclouds.mouselive.databinding.ActivityVoiceRoomBinding;
import com.sclouds.mouselive.utils.BluetoothMonitorReceiver;
import com.sclouds.mouselive.utils.RoomQueueAction;
import com.sclouds.mouselive.utils.SimpleSingleObserver;
import com.sclouds.mouselive.view.IRoomView;
import com.sclouds.mouselive.viewmodel.VoiceRoomViewModel;
import com.sclouds.mouselive.views.dialog.InputMessageDialog;
import com.sclouds.mouselive.views.dialog.ProgressTimeOutDialog;
import com.sclouds.mouselive.views.dialog.RoomLianMaiDialog;
import com.sclouds.mouselive.views.dialog.RoomMembersDialog;
import com.sclouds.mouselive.views.dialog.VoiceChangerDialog;
import com.sclouds.mouselive.views.dialog.VoiceUserMenuDialog;
import com.sclouds.mouselive.views.dialog.WaitingDialog;
import com.sclouds.mouselive.widget.RoomUserHeader;
import com.thunder.livesdk.ThunderNotification;
import com.trello.rxlifecycle3.android.ActivityEvent;

import org.jetbrains.annotations.NotNull;

import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.core.util.ObjectsCompat;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModel;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import io.reactivex.android.schedulers.AndroidSchedulers;

/**
 * 聊天室，主要实现多人连麦功能，支持上麦、下麦、踢人、单人禁言、单人禁麦、全局禁言、全局禁麦。
 *
 * @author Aslan chenhengfei@yy.com
 * @since 2020/03/01
 */
public class VoiceRoomActivity
        extends BaseMVVMActivity<ActivityVoiceRoomBinding, VoiceRoomViewModel>
        implements View.OnClickListener, IRoomView {
    private static final String TAG = "[View-VoiceRoom]";

    private BluetoothMonitorReceiver bleListenerReceiver = null;
    private VoiceUserAdapter mVoiceAdapter;
    private FakeMsgAdapter mMsgAdapter;

    private RoomUserHeader roomUserHeader;
    private Handler mHandler = new Handler();
    private boolean needBackground = true;

    private Room room;

    public static void startActivity(Context context, Room room) {
        Intent intent = new Intent(context, VoiceRoomActivity.class);
        intent.putExtra(LivingRoomActivity.EXTRA_ROOM, room);
        context.startActivity(intent);
    }

    @Override
    protected void initBundle(@Nullable Bundle bundle) {
        super.initBundle(bundle);
        assert bundle != null;
        room = bundle.getParcelable(LivingRoomActivity.EXTRA_ROOM);
    }

    @Override
    protected void initView() {
        mBinding.ivMembers.setOnClickListener(this);
        mBinding.ivLeave.setOnClickListener(this);

        mBinding.tvAllMicOff.setOnClickListener(this);

        mBinding.tvRoomName.setText("");
        updateNumView(0);

        mBinding.ivMenuMic.setOnClickListener(this);
        mBinding.ivVoice.setOnClickListener(this);
        mBinding.ivFadeback.setOnClickListener(this);
        mBinding.ivLog.setOnClickListener(this);
        mBinding.tvInput.setOnClickListener(this);
        mBinding.btMai.setOnClickListener(this);

        roomUserHeader = findViewById(R.id.ruhMaster);

        //房间信息列表
        LinearLayoutManager msgLLayoutManager = new LinearLayoutManager(
                this, LinearLayoutManager.VERTICAL, false);
        msgLLayoutManager.setStackFromEnd(true);
        mBinding.rvMsg.setLayoutManager(msgLLayoutManager);
        mMsgAdapter =
                new FakeMsgAdapter(this, DatabaseSvc.getIntance().getUser(), room.getROwner());
        mBinding.rvMsg.setAdapter(mMsgAdapter);
        mMsgAdapter.addItem(new FakeMessage(getString(R.string.office_notie),
                FakeMessage.MessageType.Top));

        //语音房参与人员列表
        RecyclerView.LayoutManager layoutManager = new GridLayoutManager(this,
                4);
        mBinding.rvRoomUser.setLayoutManager(layoutManager);
        mVoiceAdapter = new VoiceUserAdapter(this);
        mBinding.rvRoomUser.setAdapter(mVoiceAdapter);
        mVoiceAdapter.setOnItemClickListener(new BaseAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position) {
                RoomUser mine = mViewModel.getMine();
                if (mine == null) {
                    return;
                }

                if (mine.getRoomRole() == RoomUser.RoomRole.Spectator) {
                    return;
                }

                if (!mVoiceAdapter.haveUser(position)) {
                    return;
                }

                RoomUser user = mVoiceAdapter.getDataAtPosition(position);
                if (ObjectsCompat.equals(user, mine)) {
                    return;
                }
                showUserMenuDialog(user, position);
            }
        });

        mBinding.llMusic.setVisibility(View.GONE);
        mBinding.tvAllMicOff.setVisibility(View.GONE);
        mBinding.btMai.setVisibility(View.GONE);
        mBinding.ivMenuMic.setVisibility(View.GONE);
        mBinding.ivVoice.setVisibility(View.GONE);
        mBinding.ivFadeback.setVisibility(View.VISIBLE);
        mBinding.ivLog.setVisibility(View.VISIBLE);
    }

    @Override
    protected void initData() {
        super.initData();
        observeRequest();
        observeError();
        observeRoomInfo();
        observeConnection();
        observeRoomStats();
        registerBLEReceiver();

        setRoomInfo(room);
    }

    /**
     * 处理蓝牙逻辑
     */
    private void registerBLEReceiver() {
        // 初始化广播
        this.bleListenerReceiver = new BluetoothMonitorReceiver();
        IntentFilter intentFilter = new IntentFilter();
        // 监视蓝牙关闭和打开的状态
        intentFilter.addAction(BluetoothAdapter.ACTION_STATE_CHANGED);

        // 监视蓝牙设备与APP连接的状态
        intentFilter.addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED);
        intentFilter.addAction(BluetoothDevice.ACTION_ACL_CONNECTED);

        // 注册广播
        registerReceiver(this.bleListenerReceiver, intentFilter);
    }

    /**
     * 处理连麦请求
     */
    private void observeRequest() {
        mViewModel.observeRequest(this, new Observer<RoomQueueAction.Request>() {
            @Override
            public void onChanged(@Nullable RoomQueueAction.Request request) {
                closeChatRequestDailog();
                if (request == null) {
                    return;
                }

                onRequestChat(request.getRoomUser());
            }
        });
    }

    /**
     * 处理房间信息
     */
    private void observeRoomInfo() {
        mViewModel.mLiveDataRoomInfo.observe(this, new Observer<Room>() {
            @Override
            public void onChanged(@NonNull Room room) {
                if (mViewModel.isRoomOwner()) {
                    //房主需要处理闭麦逻辑
                    if (room.getRMicEnable()) {
                        mBinding.tvAllMicOff.setText(R.string.voice_all_mic_off);
                    } else {
                        mBinding.tvAllMicOff.setText(R.string.voice_all_mic_on);
                    }
                } else {
                    //观众需要处理禁言状态
                    RoomUser mine = mViewModel.getMine();
                    if (mine != null) {
                        if (mine.isNoTyping()) {
                            closeInputMessageDialog();

                            mBinding.tvInput.setEnabled(false);
                            mBinding.tvInput.setText(R.string.user_muting);
                        } else {
                            mBinding.tvInput.setEnabled(true);
                            mBinding.tvInput.setText(R.string.room_say_something);
                        }
                    }
                }

                //房间的一些基础显示信息
                mBinding.tvRoomName.setText(room.getRName());
                RoomUser owner = mViewModel.getOwnerUser();
                roomUserHeader.setOwnerUserInfo(owner);
                updateNumView(room.getRCount());

                //处理闭麦显示逻辑
                refreshMicView();

                //刷新上座列表数据
                mVoiceAdapter.notifyDataSetChanged();

                //处理成员列表数据刷新
                if (memberDialog != null && memberDialog.isShowing()) {
                    memberDialog.onMemberUpdated(mViewModel.getMembers());
                }
            }
        });
    }

    private WaitingDialog mConnectingDialog;

    private void showConnectingDialog() {
        if (mConnectingDialog != null && mConnectingDialog.isShowing()) {
            return;
        }

        mConnectingDialog = new WaitingDialog();
        mConnectingDialog.showWithMessage(getSupportFragmentManager(),
                getString(R.string.room_net_connting_message));
    }

    private void closeConnectingDialog() {
        if (mConnectingDialog != null && mConnectingDialog.isShowing()) {
            mConnectingDialog.dismiss();
            mConnectingDialog = null;
        }
    }

    /**
     * 处理网络状况
     */
    private void observeConnection() {
        mViewModel.mLiveDataConnection.observe(this, new Observer<Integer>() {
            @Override
            public void onChanged(Integer integer) {
                if (integer == FunWSClientHandler.ConnectState.CONNECT_STATE_RECONNECTING) {
                    showConnectingDialog();
                } else if (integer == FunWSClientHandler.ConnectState.CONNECT_STATE_CONNECTED) {
                    closeConnectingDialog();
                } else if (integer == FunWSClientHandler.ConnectState.CONNECT_STATE_LOST) {
                    closeConnectingDialog();
                    ToastUtil.showToast(VoiceRoomActivity.this, R.string.ws_disconnect);
                    mBinding.ivLeave.performClick();
                }
            }
        });
    }

    /**
     * 处理房间错误信息
     */
    private void observeError() {
        mViewModel.mLiveDataError.observe(this, new Observer<Integer>() {
            @Override
            public void onChanged(@Nullable Integer integer) {
                if (integer == null) {
                    return;
                }
                showJoinError(integer);
            }
        });
    }

    /**
     * 处理房间媒体RoomStats
     */
    private void observeRoomStats() {
        mViewModel.mLiveDataRoomStats.observe(this, new Observer<ThunderNotification.RoomStats>() {
            @Override
            public void onChanged(@NonNull ThunderNotification.RoomStats roomStats) {
                if (mBinding.infoMine.getVisibility() == View.VISIBLE) {
                    mBinding.infoMine.setRoomStats(roomStats);
                }
            }
        });
    }

    private void showJoinError(int error) {
        new AlertDialog.Builder(this)
                .setMessage(getString(R.string.join_room_fail, String.valueOf(error)))
                .setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        finish();
                    }
                })
                .show()
                .getButton(AlertDialog.BUTTON_POSITIVE).setTextColor(Color.BLUE);;
    }

    @Override
    protected int getLayoutResId() {
        return R.layout.activity_voice_room;
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.ivLeave) {
            closeChat();
            this.finish();
        } else if (id == R.id.ivMembers) {
            showMembersDialog();
        } else if (id == R.id.tvInput) {
            showInputMessageDialog();
        } else if (id == R.id.ivMenuMic) {
            mViewModel.toggleLocalMic();
        } else if (id == R.id.ivVoice) {
            showVoiceChangerDialog();
        } else if (id == R.id.ivFadeback) {
            gotoFeedback();
        } else if (id == R.id.ivLog) {
            toggleLog();
        } else if (id == R.id.tvAllMicOff) {
            toggleAllMicEnable();
        } else if (id == R.id.btMai) {
            if (mViewModel.isInChating()) {
                closeChat();
            } else {
                requestChat();
            }
        }
    }

    private void toggleAllMicEnable() {
        showLoading();
        boolean newValue = !mViewModel.isAllMicEnable();
        HummerSvc.getInstance().setAllMicEnable(newValue)
                .subscribeOn(AndroidSchedulers.mainThread())
                .compose(bindUntilEvent(ActivityEvent.DESTROY))
                .subscribe(new SimpleSingleObserver<Boolean>() {
                    @Override
                    public void onSuccess(Boolean aBoolean) {
                        setRoomMic(newValue, 0);
                    }
                });
    }

    private void setRoomMic(boolean enable, int errorcount) {
        Room room = mViewModel.getRoom();
        FlyHttpSvc.getInstance().setRoomMic(room.getRoomId(), room.getRType(), enable)
                .subscribeOn(AndroidSchedulers.mainThread())
                .compose(bindUntilEvent(ActivityEvent.DESTROY))
                .subscribe(new BaseObserver<String>(this) {
                    @Override
                    public void handleSuccess(@NonNull String data) {
                        hideLoading();
                    }

                    @Override
                    public void onError(Throwable e) {
                        super.onError(e);

                        if (errorcount < 5) {
                            setRoomMic(enable, errorcount + 1);
                        }
                    }
                });
    }

    private ProgressTimeOutDialog requestWaitingDialog = null;

    /**
     * 请求上麦
     */
    @SuppressLint("CheckResult")
    private void requestChat() {
        RoomUser mine = mViewModel.getMine();
        if (mine == null) {
            return;
        }

        Room room = mViewModel.getRoom();
        RoomUser owner = mViewModel.getOwnerUser();
        long targetUID = owner.getUid();
        long targetRID = owner.getRoomId();

        if (requestWaitingDialog == null) {
            requestWaitingDialog = new ProgressTimeOutDialog();
        }
        requestWaitingDialog
                .show(getSupportFragmentManager(), new ProgressTimeOutDialog.IProgressCallback() {
                    @Override
                    public void onTimeUp() {
                        mViewModel.cancelChat(targetUID, targetRID);
                    }
                });

        FunWSSvc.getInstance()
                .sendChat(targetUID, targetRID, room.getRType())
                .observeOn(AndroidSchedulers.mainThread())
                .compose(bindUntilEvent(ActivityEvent.DESTROY))
                .subscribe(aType -> {
                    requestWaitingDialog.dismiss();

                    if (aType == BasePacket.EV_CC_CHAT_ACCEPT) {
                        mViewModel.onMemberChatStart(mine);
                    } else if (aType == BasePacket.EV_CC_CHAT_REJECT) {
                        ToastUtil.showToast(VoiceRoomActivity.this,
                                R.string.room_refult_lianmai_request);
                    } else if (aType == BasePacket.EV_SC_CHAT_LIMIT) {
                        ToastUtil.showToast(VoiceRoomActivity.this,
                                R.string.voice_refult_shangmai_fill);
                    }
                });
    }

    private void closeRequestChatWaitDialog() {
        if (requestWaitingDialog != null && requestWaitingDialog.getDialog() != null &&
                requestWaitingDialog.getDialog().isShowing()) {
            requestWaitingDialog.dismiss();
        }
    }

    /**
     * 请求下麦
     */
    @SuppressLint("CheckResult")
    private void closeChat() {
        RoomUser mine = mViewModel.getMine();
        if (mine == null) {
            return;
        }

        if (mViewModel.isInChating() == false) {
            return;
        }

        RoomUser target = mViewModel.getOwnerUser();
        long targetUID = target.getUid();
        long targetRID = target.getRoomId();
        FunWSSvc.getInstance()
                .handupChat(targetUID, targetRID)
                .observeOn(AndroidSchedulers.mainThread())
                .compose(bindUntilEvent(ActivityEvent.DESTROY))
                .subscribe(aBoolean -> {
                    hideLoading();

                    if (aBoolean) {
                        if (mViewModel.isRoomOwner()) {
                            //onCloseChating()只处理观众
                            mViewModel.onMemberChatStop(target);
                        } else {
                            //onCloseChating()只处理观众
                            mViewModel.onMemberChatStop(mine);
                        }
                    }
                });
    }

    private void closeChatRequestDailog() {
        if (dialogChatRequest != null && dialogChatRequest.getDialog() != null &&
                dialogChatRequest.getDialog().isShowing()) {
            dialogChatRequest.dismiss();
        }
    }

    private RoomLianMaiDialog dialogChatRequest;

    @MainThread
    private void showChatRequestDailog(RoomUser user) {
        if (dialogChatRequest == null) {
            dialogChatRequest = new RoomLianMaiDialog();
        }
        dialogChatRequest.showShangMai(user, getSupportFragmentManager(),
                new RoomLianMaiDialog.IMenuCallback() {
                    @Override
                    public void onCancel() {
                        mViewModel.refuseChat(user, dialogChatRequest);
                    }

                    @Override
                    public void onAgree() {
                        mViewModel.acceptChat(user, dialogChatRequest);
                    }

                    @Override
                    public void onRefuse() {
                        mViewModel.refuseChat(user, dialogChatRequest);
                    }
                });
    }

    private void showVoiceChangerDialog() {
        VoiceChangerDialog dialog = new VoiceChangerDialog();
        dialog.show(getSupportFragmentManager());
    }

    private RoomMembersDialog memberDialog = null;

    private void showMembersDialog() {
        RoomUser mine = mViewModel.getMine();
        if (mine == null) {
            return;
        }

        if (memberDialog == null) {
            memberDialog = new RoomMembersDialog();
        }
        memberDialog.show(getSupportFragmentManager(), mViewModel.getRoom(), mine,
                mViewModel.getMembers(), mViewModel.isAllNoTyping(),
                new RoomMembersDialog.IMemberMenuCallback() {
                    @Override
                    public void onAllMuteChanged(boolean isMute) {
                        mViewModel.toggleAllNoTyping(isMute);
                    }

                    @Override
                    public void onUserRoleChanged(RoomUser user) {
                        mViewModel.onUserRoleChanged(user);
                    }

                    @Override
                    public void onMuteChanged(RoomUser user) {
                        mViewModel.onMuteChanged(user, user.isNoTyping());
                    }

                    @Override
                    public void onKickout(RoomUser user) {
                        mViewModel.onKickout(user);
                        mVoiceAdapter.deleteItem(user);
                    }
                });
    }

    private void showUserMenuDialog(RoomUser target, int position) {
        RoomUser mine = mViewModel.getMine();
        if (mine == null) {
            return;
        }

        VoiceUserMenuDialog dialog = new VoiceUserMenuDialog();
        dialog.show(getSupportFragmentManager(), mViewModel.getRoom(), mine, target,
                new VoiceUserMenuDialog.IUserCallback() {
                    @Override
                    public void onUserMicEnableChanged(boolean isEnable) {
                        target.setMicEnable(isEnable);
                        mVoiceAdapter.notifyItemChanged(position);
                    }

                    @Override
                    public void onUserXiaMai() {
                        mViewModel.onMemberChatStop(target);
                    }
                });
    }

    private void gotoFeedback() {
        needBackground = false;
        FragmentActivity.startActivity(this, FeedbackFragment.class);
    }

    private void updateNumView(long num) {
        mBinding.tvWatcher.setText(getString(R.string.voice_wather, String.valueOf(num)));
    }

    private void setRoomInfo(@NonNull Room room) {
        mBinding.tvRoomName.setText(room.getRName());

        RoomUser owner = mViewModel.getOwnerUser();
        roomUserHeader.setOwnerUserInfo(owner);

        updateNumView(room.getRCount());

        RoomUser mine = mViewModel.getMine();
        if (mine != null) {
            mBinding.infoMine.setUser(mine);
        }

        if (mViewModel.isRoomOwner()) {
            mBinding.llMusic.setVisibility(View.VISIBLE);
            mBinding.tvAllMicOff.setVisibility(View.VISIBLE);
        } else {
            mBinding.llMusic.setVisibility(View.GONE);
            mBinding.tvAllMicOff.setVisibility(View.GONE);
        }

        onNomalStatus();
    }

    private Gson mGson = new Gson();
    private InputMessageDialog inputMessageDialog;
    private InputMessageDialog.ISendMessageCallback iSendMessageCallback =
            new InputMessageDialog.ISendMessageCallback() {
                @Override
                public void onSendMessage(String msg) {
                    User mine = mViewModel.getMine();
                    if (mine == null) {
                        return;
                    }
                    mMsgAdapter.addItem(new FakeMessage(mine, msg, FakeMessage.MessageType.Msg));
                    mBinding.rvMsg.smoothScrollToPosition(mMsgAdapter.getItemCount() - 1);

                    PublicMessage message =
                            new PublicMessage(mine.getNickName(), String.valueOf(mine.getUid()),
                                    msg,
                                    FakeMessage.MessageType.Msg);
                    HummerSvc.getInstance().sendChatRoomMessage(mGson.toJson(message)).subscribe();
                }
            };

    private void showInputMessageDialog() {
        RoomUser mine = mViewModel.getMine();
        if (mine == null) {
            return;
        }

        if (!mViewModel.isRoomOwner() && mine.isNoTyping()) {
            return;
        }

        if (inputMessageDialog == null) {
            inputMessageDialog = new InputMessageDialog(this);
        }
        inputMessageDialog.show(iSendMessageCallback);
    }

    private void closeInputMessageDialog() {
        if (inputMessageDialog != null) {
            inputMessageDialog.dismiss();
        }
    }

    private void toggleLog() {
        if (mBinding.infoMine.getVisibility() == View.VISIBLE) {
            mBinding.infoMine.setVisibility(View.GONE);
        } else {
            mBinding.infoMine.setVisibility(View.VISIBLE);
        }
    }

    @Override
    public void onSendMessage(@NonNull FakeMessage message) {
        mMsgAdapter.addItem(message);
        mBinding.rvMsg.smoothScrollToPosition(mMsgAdapter.getItemCount() - 1);
    }

    @Override
    public void onMemberJoin(@NotNull RoomUser user) {
        LogUtils.d(TAG, "onMemberJoin() called with: user = [" + user + "]");
        mMsgAdapter.addItem(new FakeMessage(user, getString(R.string.join_room),
                FakeMessage.MessageType.Join));
        mBinding.rvMsg.smoothScrollToPosition(mMsgAdapter.getItemCount() - 1);
    }

    @Override
    public void onMemberLeave(@NotNull RoomUser user) {
        LogUtils.d(TAG, "onMemberLeave() called with: user = [" + user + "]");
        if (ObjectsCompat.equals(user, mViewModel.getOwnerUser())) {
            //房主离开，直接退出房间
            ToastUtil.showToast(VoiceRoomActivity.this, R.string.room_owner_leave_tip);
            mBinding.ivLeave.performClick();
        } else {
            mMsgAdapter.addItem(new FakeMessage(user, getString(R.string.leave_room),
                    FakeMessage.MessageType.Join));
            mBinding.rvMsg.smoothScrollToPosition(mMsgAdapter.getItemCount() - 1);
        }
    }

    @Override
    public void onVideoStart(@NotNull RoomUser user) {

    }

    @Override
    public void onVideoStop(@NotNull RoomUser user) {

    }

    @Override
    public void onMemberMicStatusChanged(@NonNull RoomUser user) {
        LogUtils.d(TAG, "onMemberMicStatusChanged() called with: user = [" + user + "]");
        if (ObjectsCompat.equals(user, mViewModel.getOwnerUser())) {
            roomUserHeader.setOwnerUserInfo(user);
        } else {
            mVoiceAdapter.refreshUser(user);
        }
        refreshMicView();
    }

    @Override
    public void onPlayVolumeIndication(@NonNull RoomUser user) {
        if (ObjectsCompat.equals(user, mViewModel.getOwnerUser())) {
            roomUserHeader.setOwnerUserInfo(user);
        } else {
            mVoiceAdapter.refreshUser(user);
        }
    }

    @Override
    public void onNetworkQuality(@NonNull RoomUser user) {
        LogUtils.d(TAG, "onNetworkQuality() called with: user = [" + user + "]");
        if (mBinding.infoMine.getVisibility() == View.VISIBLE) {
            mBinding.infoMine.setNetworkInfo(user.getTxQuality(), user.getRxQuality());
        }
    }

    @Override
    public void onMuteChanged(@NonNull RoomUser user) {
        LogUtils.d(TAG, "onMuteChanged() called with: user = [" + user + "]");
        if (ObjectsCompat.equals(user, mViewModel.getMine())) {
            if (user.isNoTyping()) {
                mBinding.tvInput.setEnabled(false);
                mBinding.tvInput.setText(R.string.user_muting);
            } else {
                mBinding.tvInput.setEnabled(true);
                mBinding.tvInput.setText(R.string.room_say_something);
            }
        }

        //处理成员列表数据刷新
        if (memberDialog != null && memberDialog.isShowing()) {
            memberDialog.onMemberUpdated(mViewModel.getMembers());
        }
    }

    @Override
    public void onRoleChanged(@NonNull RoomUser user) {
        LogUtils.d(TAG, "onRoleChanged() called with: user = [" + user + "]");
        //处理成员列表数据刷新
        if (memberDialog != null && memberDialog.isShowing()) {
            memberDialog.onMemberUpdated(mViewModel.getMembers());
        }
    }

    @Override
    public void onMemberKicked(@NonNull RoomUser user) {
        LogUtils.d(TAG, "onMemberKicked() called with: user = [" + user + "]");
        if (ObjectsCompat.equals(user, mViewModel.getMine())) {
            ToastUtil.showToast(this, R.string.msg_kick_out_me);
            finish();
            return;
        }

        mMsgAdapter.addItem(new FakeMessage(user, getString(R.string.user_kick_out),
                FakeMessage.MessageType.Notice));
        mBinding.rvMsg.smoothScrollToPosition(mMsgAdapter.getItemCount() - 1);
    }

    private void onRequestChat(@NonNull RoomUser user) {
        LogUtils.d(TAG, "onRequestChat() called with: user = [" + user + "]");
        showChatRequestDailog(user);
    }

    @Override
    public void onMemberChatStart(@NonNull RoomUser user) {
        LogUtils.d(TAG, "onUserStartChat() called with: user = [" + user + "]");
        mVoiceAdapter.addItem(user);
        mMsgAdapter.addItem(new FakeMessage(user, getString(R.string.voice_shangmai_tip),
                FakeMessage.MessageType.Notice));
        mBinding.rvMsg.smoothScrollToPosition(mMsgAdapter.getItemCount() - 1);

        if (mViewModel.isFullChating()) {
            closeRequestChatWaitDialog();
        }

        if (ObjectsCompat.equals(user, mViewModel.getMine())) {
            onChatingStatus();
        }
    }

    @Override
    public void onMemberChatStop(@NonNull RoomUser user) {
        LogUtils.d(TAG, "onUserStopChat() called with: user = [" + user + "]");
        mVoiceAdapter.deleteItem(user);
        mMsgAdapter.addItem(new FakeMessage(user, getString(R.string.voice_xiamai_tip),
                FakeMessage.MessageType.Notice));
        mBinding.rvMsg.smoothScrollToPosition(mMsgAdapter.getItemCount() - 1);

        if (ObjectsCompat.equals(user, mViewModel.getMine())) {
            onNomalStatus();
        }
    }

    @Override
    public void onMessage(@NonNull FakeMessage message) {
        mMsgAdapter.addItem(message);
        mBinding.rvMsg.smoothScrollToPosition(mMsgAdapter.getItemCount() - 1);
    }

    @Override
    protected VoiceRoomViewModel iniViewModel() {
        return new ViewModelProvider(this, new ViewModelProvider.Factory() {
            @NonNull
            @Override
            public <T extends ViewModel> T create(@NonNull Class<T> modelClass) {
                //noinspection unchecked
                return (T) new VoiceRoomViewModel(getApplication(), VoiceRoomActivity.this, room);
            }
        }).get(VoiceRoomViewModel.class);
    }

    private void onNomalStatus() {
        if (mViewModel.isRoomOwner()) {
            mBinding.ivMenuMic.setVisibility(View.VISIBLE);
            mBinding.ivVoice.setVisibility(View.VISIBLE);
            mBinding.btMai.setVisibility(View.GONE);
        } else {
            mBinding.ivMenuMic.setVisibility(View.GONE);
            mBinding.ivVoice.setVisibility(View.GONE);
            mBinding.btMai.setVisibility(View.VISIBLE);
            mBinding.btMai.setText(R.string.voice_user_mai_up);
            mBinding.btMai.setBackground(getResources().getDrawable(R.mipmap.ic_voice_mai_up));
        }
    }

    private void onChatingStatus() {
        if (mViewModel.isRoomOwner()) {
            mBinding.ivMenuMic.setVisibility(View.VISIBLE);
            mBinding.ivVoice.setVisibility(View.VISIBLE);
            mBinding.btMai.setVisibility(View.GONE);
        } else {
            mBinding.ivMenuMic.setVisibility(View.VISIBLE);
            mBinding.ivVoice.setVisibility(View.VISIBLE);
            mBinding.btMai.setVisibility(View.VISIBLE);
            mBinding.btMai.setText(R.string.voice_user_mai_down);
            mBinding.btMai.setBackground(getResources().getDrawable(R.mipmap.ic_voice_mai_down));
        }
    }

    private void refreshMicView() {
        RoomUser mine = mViewModel.getMine();
        if (mine == null) {
            return;
        }

        if (mViewModel.isRoomOwner()) {
            //房主只要关心本地
            mBinding.ivMenuMic.setEnabled(true);
            if (mine.isSelfMicEnable()) {
                mBinding.ivMenuMic.setImageResource(R.mipmap.ic_room_mic_on);
            } else {
                mBinding.ivMenuMic.setImageResource(R.mipmap.ic_room_mic_off);
            }
        } else {
            //观众优先级
            //1：被房主关闭
            //2：本地关闭
            //3：打开
            if (mine.isMicEnable() == false) {
                mBinding.ivMenuMic.setEnabled(false);
                mBinding.ivMenuMic.setImageResource(R.mipmap.ic_room_all_mic_off);
            } else if (mine.isSelfMicEnable() == false) {
                mBinding.ivMenuMic.setEnabled(true);
                mBinding.ivMenuMic.setImageResource(R.mipmap.ic_room_mic_off);
            } else {
                mBinding.ivMenuMic.setEnabled(true);
                mBinding.ivMenuMic.setImageResource(R.mipmap.ic_room_mic_on);
            }
        }
    }

    @Override
    public void onBackPressed() {
        //屏蔽手势返回以及虚拟返回键，必须通过右上角关闭按钮退出房间
    }

    private Runnable mRunnableBackground = new Runnable() {
        @Override
        public void run() {
            User mine = mViewModel.getMine();
            if (mine == null) {
                return;
            }
            PublicMessage message =
                    new PublicMessage(mine.getNickName(), String.valueOf(mine.getUid()),
                            getString(R.string.owner_leave_monment),
                            FakeMessage.MessageType.Notice);
            HummerSvc.getInstance().sendChatRoomMessage(mGson.toJson(message)).subscribe();
        }
    };

    @Override
    protected void onStop() {
        super.onStop();
        if (needBackground && mViewModel.isRoomOwner()) {
            mHandler.postDelayed(mRunnableBackground, 1000L);
        }
        needBackground = true;
    }

    @Override
    protected void onDestroy() {
        hideLoading();
        mBinding.llMusic.stopMusic();
        closeInputMessageDialog();
        unregisterReceiver(bleListenerReceiver);
        mHandler.removeCallbacks(mRunnableBackground);
        super.onDestroy();
    }
}
