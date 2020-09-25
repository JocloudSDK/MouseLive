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

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.gson.Gson;
import com.sclouds.basedroid.BaseMVVMActivity;
import com.sclouds.basedroid.LogUtils;
import com.sclouds.basedroid.ToastUtil;
import com.sclouds.datasource.bean.Anchor;
import com.sclouds.datasource.bean.Room;
import com.sclouds.datasource.bean.RoomUser;
import com.sclouds.datasource.bean.User;
import com.sclouds.datasource.business.pkg.BasePacket;
import com.sclouds.datasource.database.DatabaseSvc;
import com.sclouds.datasource.flyservice.funws.FunWSClientHandler;
import com.sclouds.datasource.flyservice.funws.FunWSSvc;
import com.sclouds.datasource.hummer.HummerSvc;
import com.sclouds.datasource.thunder.ThunderSvc;
import com.sclouds.magic.MagicView;
import com.sclouds.magic.manager.MagicEffectManager;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.adapters.FakeMsgAdapter;
import com.sclouds.mouselive.adapters.LiveAdapter;
import com.sclouds.mouselive.bean.FakeMessage;
import com.sclouds.mouselive.bean.PublicMessage;
import com.sclouds.mouselive.databinding.ActivityLivingRoomBinding;
import com.sclouds.mouselive.utils.BluetoothMonitorReceiver;
import com.sclouds.mouselive.utils.RoomQueueAction;
import com.sclouds.mouselive.utils.SimpleSingleObserver;
import com.sclouds.mouselive.view.IRoomView;
import com.sclouds.mouselive.viewmodel.LivingRoomViewModel;
import com.sclouds.mouselive.views.dialog.InputMessageDialog;
import com.sclouds.mouselive.views.dialog.ProgressTimeOutDialog;
import com.sclouds.mouselive.views.dialog.RoomLianMaiDialog;
import com.sclouds.mouselive.views.dialog.RoomMembersDialog;
import com.sclouds.mouselive.views.dialog.RoomPKMembersDialog;
import com.sclouds.mouselive.views.dialog.RoomSharpnessDialog;
import com.sclouds.mouselive.views.dialog.WaitingDialog;
import com.sclouds.mouselive.widget.LiveDecoration;
import com.thunder.livesdk.ThunderNotification;
import com.trello.rxlifecycle3.android.ActivityEvent;

import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.core.util.ObjectsCompat;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModel;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import io.reactivex.android.schedulers.AndroidSchedulers;

/**
 * 视频直播房
 * 1. 支持单人主播 RTC 或 CDN 视频直播和观众观看直播功能
 * 2. 支持 2 人同房间视频连麦功能，支持 2 人跨房间视频 PK 连麦功能
 * 3. 支持主播直播切换镜头、镜像播放、视频档位切换和美颜魔法玩法
 * 4. 支持管理员单人禁言、全局禁言和踢人功能
 * 5. 支持聊天和意见反馈功能
 *
 * @author chenhengfei@yy.com
 * @since 2020/03/01
 */
public class LivingRoomActivity
        extends BaseMVVMActivity<ActivityLivingRoomBinding, LivingRoomViewModel>
        implements View.OnClickListener, IRoomView {

    public static final String EXTRA_ROOM = "room";
    private static final String TAG = "[View-LiveRoom]";

    private BluetoothMonitorReceiver bleListenerReceiver = null;
    private FakeMsgAdapter mMsgAdapter;

    private LiveAdapter mLiveAdapter;
    private LinearLayoutManager linearLayoutManager = new LinearLayoutManager(this,
            LinearLayoutManager.VERTICAL, false);
    private GridLayoutManager gridLayoutManager = new GridLayoutManager(this, 2);

    private boolean isShowInfo = false;
    private Handler mHandler = new Handler();
    private boolean needBackground = true;
    private boolean landscape = false;

    private Room room;
    private MagicView mMagicView = null;

    public static void startActivity(Context context, Room room) {
        Intent intent = new Intent(context, LivingRoomActivity.class);
        intent.putExtra(EXTRA_ROOM, room);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    protected void initBundle(@Nullable Bundle bundle) {
        super.initBundle(bundle);
        assert bundle != null;
        room = bundle.getParcelable(EXTRA_ROOM);
    }

    @Override
    protected void initView() {
        mBinding.ivMembers.setOnClickListener(this);
        mBinding.ivLeave.setOnClickListener(this);
        mBinding.btClose.setOnClickListener(this);
        mBinding.btClose.setVisibility(View.GONE);
        mBinding.ivPublishMode.setOnClickListener(this);

        mBinding.tvRoomName.setText("");
        mBinding.tvWatcher.setText("");

        mBinding.tvInput.setOnClickListener(this);

        mBinding.infoMine.setVisibility(View.GONE);
        mBinding.infoOwen.setVisibility(View.GONE);
        mBinding.infoLink.setVisibility(View.GONE);

        mBinding.llMoreMenu.setVisibility(View.GONE);
        mBinding.tvCamera.setOnClickListener(this);
        mBinding.llMoreMenu.setOnClickListener(this);
        mBinding.tvSharpnessr.setOnClickListener(this);
        mBinding.tvMirror.setOnClickListener(this);
        mBinding.tvFace.setOnClickListener(this);

        mBinding.ivMenuMic.setOnClickListener(this);
        mBinding.ivPK.setOnClickListener(this);
        mBinding.ivLianMai.setOnClickListener(this);
        mBinding.ivSetting.setOnClickListener(this);
        mBinding.ivFadeback.setOnClickListener(this);
        mBinding.ivLog.setOnClickListener(this);

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

        //视频
        mBinding.rvPreview.addItemDecoration(new LiveDecoration(this));
        mBinding.rvPreview.setLayoutManager(linearLayoutManager);
        mLiveAdapter = new LiveAdapter(this, room.ROwner);
        mBinding.rvPreview.setAdapter(mLiveAdapter);

        mViewModel.setSurfaceHolder(mBinding.cdnView.getHolder());

        mBinding.ivMenuMic.setVisibility(View.GONE);
        mBinding.ivPK.setVisibility(View.GONE);
        mBinding.ivLianMai.setVisibility(View.GONE);
        mBinding.ivSetting.setVisibility(View.GONE);
        mBinding.ivFadeback.setVisibility(View.VISIBLE);
        mBinding.ivLog.setVisibility(View.VISIBLE);
        mBinding.llMoreMenu.setVisibility(View.GONE);
        mBinding.btClose.setVisibility(View.GONE);
    }

    @Override
    protected void initData() {
        super.initData();
        observeRequest();
        observeError();
        observeRoomInfo();
        observeConnection();
        observeRoomStats();
        observeCDNStats();
        observeVideoSizeChangedStats();
        registerBLEReceiver();

        if (room.getRPublishMode() == Room.RTC) {
            onLoadLiveStatus();
        } else {
            onLoadPlayertatus();
        }
        setRoomInfo(room);

        RoomUser owner = mViewModel.getOwnerUser();
        mLiveAdapter.addItem(owner);
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

                if (request.getType() == RoomQueueAction.TYPE_CHAT) {
                    onRequestChat(request.getRoomUser());
                } else if (request.getType() == RoomQueueAction.TYPE_PK) {
                    onRequestPK(request.getRoomUser());
                }
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
                if (isShowInfo) {
                    mBinding.infoOwen.setRoomInfo(String.valueOf(room.getRoomId()));
                }

                RoomUser mine = mViewModel.getMine();
                if (mine == null) {
                    return;
                }

                if (!mViewModel.isRoomOwner()) {
                    //观众需要处理禁言状态
                    if (mine.isNoTyping()) {
                        closeInputMessageDialog();

                        mBinding.tvInput.setEnabled(false);
                        mBinding.tvInput.setText(R.string.user_muting);
                    } else {
                        mBinding.tvInput.setEnabled(true);
                        mBinding.tvInput.setText(R.string.room_say_something);
                    }
                }

                //房间的一些基础显示信息
                updateNumView(room.getRCount());

                //处理闭麦显示逻辑
                refreshMicView();

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
            public void onChanged(@NonNull Integer integer) {
                if (integer == FunWSClientHandler.ConnectState.CONNECT_STATE_RECONNECTING) {
                    showConnectingDialog();
                } else if (integer == FunWSClientHandler.ConnectState.CONNECT_STATE_CONNECTED) {
                    closeConnectingDialog();
                } else if (integer == FunWSClientHandler.ConnectState.CONNECT_STATE_LOST) {
                    closeConnectingDialog();
                    ToastUtil.showToast(LivingRoomActivity.this, R.string.ws_disconnect);
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
                if (isShowInfo) {
                    if (mViewModel.isRoomOwner()) {
                        mBinding.infoOwen.setRoomStats(roomStats);
                    } else if (mViewModel.isInChating()) {
                        mBinding.infoLink.setRoomStats(roomStats);
                    } else {
                        mBinding.infoMine.setRoomStats(roomStats);
                    }
                }
            }
        });
    }

    /**
     * 处理 CDN 推流信息
     */
    private void observeCDNStats() {
        mViewModel.mLiveDataCDNStats.observe(this, new Observer<Integer>() {
            @Override
            public void onChanged(Integer integer) {
                if (integer == null) {
                    return;
                }
                showJoinError(integer);
            }
        });
    }

    /**
     * 处理 CDN 推流信息
     */
    private void observeVideoSizeChangedStats() {
        mViewModel.mVideoSizeChangedStats.observe(this, new Observer<Boolean>() {
            @Override
            public void onChanged(Boolean b) {
                LogUtils.d(TAG, "onVideoSizeChanged() called with: widht > height = [" + b + "]");
                landscape = b;
                if (mViewModel.isSomeOneInChating()) {
                    return;
                }
                ConstraintLayout.LayoutParams lp =
                        (ConstraintLayout.LayoutParams) mBinding.rvPreview.getLayoutParams();
                if (b) {
                    lp.bottomToBottom = ConstraintLayout.LayoutParams.UNSET;
                    lp.topToTop = ConstraintLayout.LayoutParams.UNSET;
                    lp.bottomToTop = R.id.guideline;
                    lp.topToBottom = R.id.layoutOwner;
                } else {
                    lp.bottomToBottom = ConstraintLayout.LayoutParams.PARENT_ID;
                    lp.topToTop = ConstraintLayout.LayoutParams.PARENT_ID;
                    lp.bottomToTop = ConstraintLayout.LayoutParams.UNSET;
                    lp.topToBottom = ConstraintLayout.LayoutParams.UNSET;
                }
                mBinding.rvPreview.setLayoutParams(lp);
            }
        });
    }

    /**
     * 直播方式
     */
    private void onLoadLiveStatus() {
        mBinding.ivPublishMode.setImageResource(R.mipmap.icon_rct);
        mBinding.cdnView.setVisibility(View.GONE);
        mBinding.rvPreview.setVisibility(View.VISIBLE);
        mBinding.ivPK.setVisibility(View.VISIBLE);
        mBinding.ivLianMai.setVisibility(View.VISIBLE);
    }

    /**
     * 云播放器方式
     */
    private void onLoadPlayertatus() {
        mBinding.ivPublishMode.setImageResource(R.mipmap.icon_cdn);
        if (mViewModel.isRoomOwner()) {
            mBinding.rvPreview.setVisibility(View.VISIBLE);
            mBinding.cdnView.setVisibility(View.GONE);
        } else {
            mBinding.rvPreview.setVisibility(View.GONE);
            mBinding.cdnView.setVisibility(View.VISIBLE);
        }
        mBinding.ivPK.setVisibility(View.GONE);
        mBinding.ivLianMai.setVisibility(View.GONE);
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
                .getButton(AlertDialog.BUTTON_POSITIVE).setTextColor(Color.BLUE);
    }

    @Override
    protected int getLayoutResId() {
        return R.layout.activity_living_room;
    }

    private void updateNumView(long num) {
        mBinding.tvWatcher.setText(String.valueOf(num));
    }

    private void setRoomInfo(@NonNull Room room) {
        RoomUser mine = mViewModel.getMine();
        if (mine == null) {
            return;
        }

        mBinding.tvRoomName.setText(room.getRName());
        updateNumView(room.getRCount());

        if (mViewModel.isRoomOwner()) {
            mBinding.infoOwen.setUser(mine);
        } else {
            RoomUser owner = mViewModel.getOwnerUser();
            mBinding.infoOwen.setUser(owner);
            mBinding.infoMine.setUser(mine);
        }
        refreshInfoView();

        RequestOptions requestOptions = new RequestOptions()
                .circleCrop()
                .placeholder(R.mipmap.default_user_icon)
                .error(R.mipmap.default_user_icon);
        Glide.with(mBinding.ivRoomOwner.getContext()).load(room.getROwner().getCover())
                .apply(requestOptions)
                .into(mBinding.ivRoomOwner);

        if (mViewModel.isRoomOwner()) {
            mBinding.ivLianMai.setVisibility(View.GONE);
            mBinding.ivMenuMic.setVisibility(View.VISIBLE);
            mBinding.ivPK.setVisibility(View.VISIBLE);
            mBinding.ivSetting.setVisibility(View.VISIBLE);
        } else {
            mBinding.ivLianMai.setVisibility(View.VISIBLE);
            mBinding.ivMenuMic.setVisibility(View.GONE);
            mBinding.ivPK.setVisibility(View.GONE);
            mBinding.ivSetting.setVisibility(View.GONE);
        }

        if (room.getRPublishMode() == Room.CDN) {
            mBinding.ivLianMai.setVisibility(View.GONE);
            mBinding.ivPK.setVisibility(View.GONE);
        }
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
        } else if (id == R.id.ivPK) {
            showPKMembersDialog();
        } else if (id == R.id.ivLianMai) {
            requestChat();
        } else if (id == R.id.ivSetting) {
            toggleMoreSettingDialog();
        } else if (id == R.id.ivFadeback) {
            gotoFeedback();
        } else if (id == R.id.ivLog) {
            toggleLog();
        } else if (id == R.id.btClose) {
            closeChat();
        } else if (id == R.id.tvCamera) {
            toggleCarmara();
        } else if (id == R.id.tvMirror) {
            toggleMirror();
        } else if (id == R.id.tvSharpnessr) {
            showSarpnessDialog();
        } else if (id == R.id.tvFace) {
            showEffectDialog();
        } else if (id == R.id.ivPublishMode) {
            clickPublishMode();
        }
    }

    private void clickPublishMode() {
        if (mViewModel.getRoom().getRPublishMode() == Room.RTC) {
            ToastUtil.showToast(this, R.string.room_publish_mode_rtc);
        } else if (mViewModel.getRoom().getRPublishMode() == Room.CDN) {
            ToastUtil.showToast(this, R.string.room_publish_mode_cdn);
        }
    }

    /**
     * 显示美颜特效窗口
     */
    public void showEffectDialog() {
        mBinding.llMoreMenu.setVisibility(View.GONE);

        if (!MagicEffectManager.getInstance().islicenseValid()) {
            ToastUtil.showToast(getApplicationContext(),
                    getApplicationContext().getResources().getString(com.sclouds.magic.R.string.magic_license_invalid));
            return;
        }

        if (null == mMagicView) {
            mMagicView = new MagicView.Builder().build();
        }
        if (!mMagicView.isVisible()) {
            mMagicView.show(getSupportFragmentManager(), "MagicView");
        }
    }

    /**
     * 关闭美颜特效窗口
     */
    public void closeEffectDialog() {
        if (null != mMagicView) {
            mMagicView.dismiss();
        }
        refreshInfoView();
    }

    private void toggleCarmara() {
        mViewModel.toggleCameraFont(!mViewModel.isCameraFont());
    }

    private void toggleMirror() {
        mViewModel.toggleVideoMirrorMode(!mViewModel.isMirrorMode());
    }

    private RoomSharpnessDialog sharpnessDialog;

    /**
     * 显示分辨率设置
     */
    private void showSarpnessDialog() {
        if (sharpnessDialog == null) {
            sharpnessDialog = new RoomSharpnessDialog();
        }
        sharpnessDialog.show(getSupportFragmentManager(),
                ThunderSvc.getInstance().getVideoConfig().publishMode,
                new RoomSharpnessDialog.ISharpnessCallback() {
                    @Override
                    public void onSharpnessCallback(int publishMode) {
                        mViewModel.toggleSarpness(publishMode);
                    }
                });
    }

    /**
     * 关闭清晰度设置
     */
    private void closeSarpnessDialog() {
        if (sharpnessDialog != null) {
            sharpnessDialog.dismiss();
        }
    }

    @SuppressLint("CheckResult")
    private void closeChat() {
        showLoading();
        RoomUser target = mViewModel.getChatingUser();
        if (target == null) {
            return;
        }

        long targetUID = target.getUid();
        long targetRID = target.getRoomId();
        FunWSSvc.getInstance()
                .handupChat(targetUID, targetRID)
                .observeOn(AndroidSchedulers.mainThread())
                .compose(bindUntilEvent(ActivityEvent.DESTROY))
                .subscribe(aBoolean -> {
                    hideLoading();

                    if (aBoolean) {
                        mViewModel.onMemberChatStop(target);
                    }
                });
    }

    private void gotoFeedback() {
        needBackground = false;
        FragmentActivity.startActivity(this, FeedbackFragment.class);
    }

    private void toggleMoreSettingDialog() {
        if (mBinding.llMoreMenu.getVisibility() == View.VISIBLE) {
            mBinding.llMoreMenu.setVisibility(View.GONE);
        } else {
            mBinding.llMoreMenu.setVisibility(View.VISIBLE);
        }
    }

    private Gson mGson = new Gson();
    private InputMessageDialog inputMessageDialog;
    private InputMessageDialog.ISendMessageCallback iSendMessageCallback =
            new InputMessageDialog.ISendMessageCallback() {
                @Override
                public void onSendMessage(String msg) {
                    RoomUser mine = mViewModel.getMine();
                    if (mine == null) {
                        return;
                    }

                    mMsgAdapter.addItem(new FakeMessage(mine, msg, FakeMessage.MessageType.Msg));
                    mBinding.rvMsg.smoothScrollToPosition(mMsgAdapter.getItemCount() - 1);

                    PublicMessage message =
                            new PublicMessage(mine.getNickName(), String.valueOf(mine.getUid()),
                                    msg, FakeMessage.MessageType.Msg);
                    HummerSvc.getInstance().sendChatRoomMessage(mGson.toJson(message)).subscribe(
                            new SimpleSingleObserver<Boolean>() {
                                @Override
                                public void onSuccess(Boolean aBoolean) {

                                }
                            });
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
                    }
                });
    }

    private void showPKMembersDialog() {
        RoomUser mine = mViewModel.getMine();
        if (mine == null) {
            return;
        }

        RoomPKMembersDialog dialog = new RoomPKMembersDialog();
        dialog.show(getSupportFragmentManager(), mViewModel.getRoom(), mine,
                new RoomPKMembersDialog.IPKCallback() {
                    @Override
                    public void onPK(Anchor user) {
                        dialog.dismiss();
                        requestPK(user);
                    }
                });
    }

    /**
     * 请求PK
     */
    @SuppressLint("CheckResult")
    private void requestPK(Anchor user) {
        Room room = mViewModel.getRoom();
        long targetUID = user.getAId();
        long targetRID = user.getARoom();

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
                        mViewModel.getUserSync(targetRID, targetUID)
                                .observeOn(AndroidSchedulers.mainThread())
                                .compose(bindToLifecycle())
                                .subscribe(new SimpleSingleObserver<RoomUser>() {
                                    @Override
                                    public void onSuccess(RoomUser user) {
                                        mViewModel.onMemberChatStart(user);
                                    }
                                });
                    } else if (aType == BasePacket.EV_CC_CHAT_REJECT) {
                        ToastUtil.showToast(LivingRoomActivity.this,
                                R.string.room_refult_lianmai_request);
                    } else if (aType == BasePacket.EV_SC_CHAT_LIMIT) {
                        ToastUtil.showToast(LivingRoomActivity.this,
                                R.string.room_in_lianmai_request);
                    }
                });
    }

    private RoomLianMaiDialog dialogChatRequest;

    @MainThread
    private void showChatRequestDailog(@NonNull RoomUser user) {
        if (dialogChatRequest == null) {
            dialogChatRequest = new RoomLianMaiDialog();
        }
        dialogChatRequest.showLianMai(user, getSupportFragmentManager(),
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

    private void closeChatRequestDailog() {
        if (dialogChatRequest != null && dialogChatRequest.getDialog() != null &&
                dialogChatRequest.getDialog().isShowing()) {
            dialogChatRequest.dismiss();
        }
    }

    @MainThread
    private void showPKRequestDailog(@NonNull RoomUser user) {
        if (dialogChatRequest == null) {
            dialogChatRequest = new RoomLianMaiDialog();
        }
        dialogChatRequest
                .showPK(user, getSupportFragmentManager(), new RoomLianMaiDialog.IMenuCallback() {
                    @Override
                    public void onCancel() {
                        mViewModel.refuseChat(user, dialogChatRequest);
                    }

                    @Override
                    public void onAgree() {
                        mViewModel.acceptPK(user, dialogChatRequest);
                    }

                    @Override
                    public void onRefuse() {
                        mViewModel.refusePK(user, dialogChatRequest);
                    }
                });
    }

    @Override
    public void onSendMessage(@NonNull FakeMessage message) {
        mMsgAdapter.addItem(message);
        mBinding.rvMsg.smoothScrollToPosition(mMsgAdapter.getItemCount() - 1);
    }

    @Override
    public void onMemberJoin(@NonNull RoomUser user) {
        LogUtils.d(TAG, "onMemberJoin() called with: user = [" + user + "]");
        mMsgAdapter.addItem(new FakeMessage(user, getString(R.string.join_room),
                FakeMessage.MessageType.Join));
        mBinding.rvMsg.smoothScrollToPosition(mMsgAdapter.getItemCount() - 1);
    }

    @Override
    public void onMemberLeave(@NonNull RoomUser user) {
        LogUtils.d(TAG, "onMemberLeave() called with: user = [" + user + "]");
        if (ObjectsCompat.equals(user, mViewModel.getOwnerUser())) {
            //房主离开，直接退出房间
            ToastUtil.showToast(LivingRoomActivity.this, R.string.room_owner_leave_tip);
            mBinding.ivLeave.performClick();
        } else {
            mMsgAdapter.addItem(new FakeMessage(user, getString(R.string.leave_room),
                    FakeMessage.MessageType.Join));
            mBinding.rvMsg.smoothScrollToPosition(mMsgAdapter.getItemCount() - 1);
        }
    }

    @Override
    public void onVideoStart(@NonNull RoomUser user) {
        LogUtils.d(TAG, "onVideoStart() called with: user = [" + user + "]");
        mLiveAdapter.refreshUser(user);
    }

    @Override
    public void onVideoStop(@NonNull RoomUser user) {
        LogUtils.d(TAG, "onVideoStop() called with: user = [" + user + "]");
        mLiveAdapter.refreshUser(user);
    }

    @Override
    public void onMemberMicStatusChanged(@NonNull RoomUser user) {
        LogUtils.d(TAG, "onMemberMicStatusChanged() called with: user = [" + user + "]");
        refreshMicView();
    }

    @Override
    public void onPlayVolumeIndication(@NonNull RoomUser user) {

    }

    @Override
    public void onNetworkQuality(@NonNull RoomUser user) {
        LogUtils.d(TAG, "onNetworkQuality() called with: user = [" + user + "]");
        if (isShowInfo) {
            RoomUser mine = mViewModel.getMine();
            if (mine == null) {
                return;
            }

            if (ObjectsCompat.equals(user, mViewModel.getOwnerUser())) {
                mBinding.infoOwen.setNetworkInfo(user.getTxQuality(), user.getRxQuality());
            } else if (ObjectsCompat.equals(user, mine)) {
                if (mViewModel.isInChating()) {
                    mBinding.infoLink.setNetworkInfo(user.getTxQuality(), user.getRxQuality());
                } else {
                    mBinding.infoMine.setNetworkInfo(user.getTxQuality(), user.getRxQuality());
                }
            } else if (mViewModel.isInChating(user)) {
                mBinding.infoLink.setNetworkInfo(user.getTxQuality(), user.getRxQuality());
            }
        }
    }

    @Override
    public void onMuteChanged(@NonNull RoomUser user) {
        LogUtils.d(TAG, "onMuteChanged() called with: user = [" + user + "]");
        RoomUser mine = mViewModel.getMine();
        if (mine == null) {
            return;
        }

        if (ObjectsCompat.equals(user, mine)) {
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
        RoomUser mine = mViewModel.getMine();
        if (mine == null) {
            return;
        }

        if (ObjectsCompat.equals(user, mine)) {
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
        LogUtils.d(TAG, "onMemberChatStart() called with: user = [" + user + "]");
        if (isShowInfo) {
            if (user.getRoomId() == mViewModel.getRoom().getRoomId()) {
                //同一个房间不需要显示房间号
                mBinding.infoLink.setRoomInfo(null);
            } else {
                mBinding.infoLink.setRoomInfo(String.valueOf(user.getRoomId()));
            }
        }
        mBinding.infoLink.setUser(user);
        mLiveAdapter.addItem(user);
        onLiveChatingStatus();
    }

    @Override
    public void onMemberChatStop(@NonNull RoomUser user) {
        LogUtils.d(TAG, "onMemberChatStop() called with: user = [" + user + "]");
        mLiveAdapter.deleteItem(user);
        onLiveNomalStatus();
    }

    @Override
    public void onMessage(@NonNull FakeMessage message) {
        mMsgAdapter.addItem(message);
        mBinding.rvMsg.smoothScrollToPosition(mMsgAdapter.getItemCount() - 1);
    }

    private void onRequestPK(@NonNull RoomUser user) {
        LogUtils.d(TAG, "onRequestPK() called with: user = [" + user + "]");
        showPKRequestDailog(user);
    }

    private ProgressTimeOutDialog requestWaitingDialog = null;

    /**
     * 请求连麦
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
                        ToastUtil.showToast(LivingRoomActivity.this,
                                R.string.room_refult_lianmai_request);
                    } else if (aType == BasePacket.EV_SC_CHAT_LIMIT) {
                        ToastUtil.showToast(LivingRoomActivity.this,
                                R.string.room_in_lianmai_request);
                    }
                });
    }

    private void closeRequestChatWaitDialog() {
        if (requestWaitingDialog != null && requestWaitingDialog.getDialog() != null &&
                requestWaitingDialog.getDialog().isShowing()) {
            requestWaitingDialog.dismiss();
        }
    }

    private void refreshInfoView() {
        mBinding.infoMine.setVisibility(View.GONE);
        mBinding.infoOwen.setVisibility(View.GONE);
        mBinding.infoLink.setVisibility(View.GONE);

        mBinding.infoMine.resetView();
        mBinding.infoOwen.resetView();
        mBinding.infoLink.resetView();

        if (isShowInfo) {
            mBinding.infoOwen.setVisibility(View.VISIBLE);

            if (mViewModel.isSomeOneInChating()) {
                mBinding.infoLink.setVisibility(View.VISIBLE);
            }

            if (!mViewModel.isRoomOwner()) {
                if (!mViewModel.isInChating()) {
                    mBinding.infoMine.setVisibility(View.VISIBLE);
                }
            }
        }
    }

    private void toggleLog() {
        if (isShowInfo) {
            isShowInfo = false;
        } else {
            isShowInfo = true;
        }
        refreshInfoView();
    }

    /**
     * 正常直播状态
     */
    private void onLiveNomalStatus() {
        ConstraintLayout.LayoutParams lp =
                (ConstraintLayout.LayoutParams) mBinding.rvPreview.getLayoutParams();
        if (landscape) {
            lp.bottomToBottom = ConstraintLayout.LayoutParams.UNSET;
            lp.topToTop = ConstraintLayout.LayoutParams.UNSET;
            lp.bottomToTop = R.id.guideline;
            lp.topToBottom = R.id.layoutOwner;
        } else {
            lp.bottomToBottom = ConstraintLayout.LayoutParams.PARENT_ID;
            lp.topToTop = ConstraintLayout.LayoutParams.PARENT_ID;
            lp.bottomToTop = ConstraintLayout.LayoutParams.UNSET;
            lp.topToBottom = ConstraintLayout.LayoutParams.UNSET;
        }
        mBinding.rvPreview.setLayoutManager(linearLayoutManager);
        mBinding.rvPreview.scrollToPosition(0);

        mBinding.btClose.setVisibility(View.GONE);

        if (mViewModel.isRoomOwner()) {
            mBinding.ivMenuMic.setVisibility(View.VISIBLE);
            mBinding.ivSetting.setVisibility(View.VISIBLE);
            mBinding.ivPK.setVisibility(View.VISIBLE);
            mBinding.ivLianMai.setVisibility(View.GONE);
        } else {
            mBinding.ivMenuMic.setVisibility(View.GONE);
            mBinding.ivSetting.setVisibility(View.GONE);
            mBinding.ivPK.setVisibility(View.GONE);
            mBinding.ivLianMai.setVisibility(View.VISIBLE);

            mBinding.llMoreMenu.setVisibility(View.GONE);
            closeSarpnessDialog();
            closeEffectDialog();
        }
        refreshInfoView();
    }

    /**
     * 连麦状态
     */
    private void onLiveChatingStatus() {
        //如果已经有人进行了连麦，就关闭请求等待
        closeRequestChatWaitDialog();

        ConstraintLayout.LayoutParams lp =
                (ConstraintLayout.LayoutParams) mBinding.rvPreview.getLayoutParams();
        lp.bottomToBottom = ConstraintLayout.LayoutParams.UNSET;
        lp.topToTop = ConstraintLayout.LayoutParams.UNSET;
        lp.bottomToTop = R.id.guideline;
        lp.topToBottom = R.id.layoutOwner;

        mBinding.rvPreview.setLayoutManager(gridLayoutManager);
        mBinding.rvPreview.scrollToPosition(0);

        if (mViewModel.isRoomOwner() && mViewModel.isSomeOneInChating()) {
            mBinding.btClose.setVisibility(View.VISIBLE);
        } else {
            mBinding.btClose.setVisibility(View.GONE);
        }

        if (mViewModel.isRoomOwner()) {
            mBinding.ivMenuMic.setVisibility(View.VISIBLE);
            mBinding.ivPK.setVisibility(View.GONE);
            mBinding.ivLianMai.setVisibility(View.GONE);
        } else {
            if (mViewModel.isInChating()) {
                mBinding.ivMenuMic.setVisibility(View.VISIBLE);
                mBinding.ivSetting.setVisibility(View.VISIBLE);
            } else {
                mBinding.ivMenuMic.setVisibility(View.GONE);
                mBinding.ivSetting.setVisibility(View.GONE);
            }
            mBinding.ivPK.setVisibility(View.GONE);
            mBinding.ivLianMai.setVisibility(View.GONE);
        }
        refreshInfoView();
    }

    @Override
    protected LivingRoomViewModel iniViewModel() {
        return new ViewModelProvider(this, new ViewModelProvider.Factory() {
            @NonNull
            @Override
            public <T extends ViewModel> T create(@NonNull Class<T> modelClass) {
                //noinspection unchecked
                return (T) new LivingRoomViewModel(getApplication(), LivingRoomActivity.this, room);
            }
        }).get(LivingRoomViewModel.class);
    }

    /**
     * 更新用户耳麦状态
     * 房主只需关注自身耳麦开关状态
     * 观众需先判断禁言状态，再结合自身耳麦开关状态
     */
    private void refreshMicView() {
        RoomUser mine = mViewModel.getMine();
        if (mine == null) {
            return;
        }

        if (mViewModel.isRoomOwner()) {
            mBinding.ivMenuMic.setEnabled(true);
            if (mine.isSelfMicEnable()) {
                mBinding.ivMenuMic.setImageResource(R.mipmap.ic_room_mic_on);
            } else {
                mBinding.ivMenuMic.setImageResource(R.mipmap.ic_room_mic_off);
            }
            return;
        }

        if (!mine.isMicEnable()) {
            mBinding.ivMenuMic.setEnabled(false);
            mBinding.ivMenuMic.setImageResource(R.mipmap.ic_room_all_mic_off);
            return;
        }
        if (!mine.isSelfMicEnable()) {
            mBinding.ivMenuMic.setEnabled(true);
            mBinding.ivMenuMic.setImageResource(R.mipmap.ic_room_mic_off);
        } else {
            mBinding.ivMenuMic.setEnabled(true);
            mBinding.ivMenuMic.setImageResource(R.mipmap.ic_room_mic_on);
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
        mViewModel.stopAliPlayer();
    }

    @Override
    protected void onDestroy() {
        hideLoading();
        closeInputMessageDialog();
        unregisterReceiver(bleListenerReceiver);
        mHandler.removeCallbacks(mRunnableBackground);
        mHandler = null;
        mViewModel.setSurfaceHolder(null);
        super.onDestroy();
    }
}
