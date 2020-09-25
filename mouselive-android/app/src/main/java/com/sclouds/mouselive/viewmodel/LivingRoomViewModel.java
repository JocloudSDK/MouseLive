package com.sclouds.mouselive.viewmodel;

import android.annotation.SuppressLint;
import android.app.Application;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;
import android.view.SurfaceHolder;

import com.sclouds.basedroid.LogUtils;
import com.sclouds.datasource.bean.Room;
import com.sclouds.datasource.bean.RoomUser;
import com.sclouds.datasource.business.pkg.ChatPacket;
import com.sclouds.datasource.flyservice.funws.FunWSClientHandler;
import com.sclouds.datasource.flyservice.funws.FunWSSvc;
import com.sclouds.datasource.thunder.ThunderSvc;
import com.sclouds.datasource.thunder.WaterMarkAdapter;
import com.sclouds.datasource.thunder.mode.ThunderConfig;
import com.sclouds.datasource.thunder.mode.VideoConfig;
import com.sclouds.magic.manager.MagicEffectManager;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.aliplayer.AliPlayerInstance;
import com.sclouds.mouselive.aliplayer.IAliPlayerListener;
import com.sclouds.mouselive.utils.SimpleSingleObserver;
import com.sclouds.mouselive.view.IRoomView;
import com.sclouds.mouselive.views.dialog.RoomLianMaiDialog;
import com.sclouds.mouselive.views.dialog.VoiceChangerDialog;
import com.thunder.livesdk.LiveTranscoding;
import com.thunder.livesdk.ThunderRtcConstant;
import com.thunder.livesdk.ThunderVideoEncoderConfiguration;

import org.jetbrains.annotations.NotNull;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.util.ObjectsCompat;
import androidx.lifecycle.MutableLiveData;
import io.reactivex.android.schedulers.AndroidSchedulers;

/**
 * 直播，逻辑成代码
 * <p>
 * 连麦者连麦，要重新打开麦克风，不需要记住上次状态。
 * 房主需要记住麦克风状态。
 *
 * @author chenhengfei@yy.com
 * @since 2020/03/01
 */
public class LivingRoomViewModel extends BaseRoomViewModel<IRoomView>
        implements SurfaceHolder.Callback, IAliPlayerListener {

    private static final String WATER_FILE_NAME = "ic_logo.png";
    private MutableLiveData<Boolean> isMirrorMode = new MutableLiveData<>(false);
    private MutableLiveData<Boolean> isCameraFont = new MutableLiveData<>(true);

    /**
     * 当前连麦的人，不包含房主
     */
    private MutableLiveData<RoomUser> mLiveDataChatingMember = new MutableLiveData<>();

    @Nullable
    private AliPlayerInstance mAliPlayerInstance = null;

    @Nullable
    private SurfaceHolder surfaceHolder;

    public LivingRoomViewModel(@NonNull Application application, @NonNull IRoomView mView,
                               @NonNull Room room) {
        super(application, mView, room);

        VoiceChangerDialog.isEnableEar = false;
        ThunderSvc.getInstance().setEnableInEarMonitor(VoiceChangerDialog.isEnableEar);

        VoiceChangerDialog.isVoiceChanged = false;
        ThunderSvc.getInstance().setVoiceChanger(
                ThunderRtcConstant.VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_NONE);
        saveBitmap();
    }

    @Override
    public void initData() {
        if (isRoomOwner()) {
            //优先保证预览出来
            ThunderSvc.getInstance().startVideoPreview();
            MagicEffectManager.getInstance().register(getApplication());
            RoomUser mine = getMine();
            if (mine != null) {
                onVideoStart(mine);
            }
        }
        super.initData();
    }

    @Override
    protected void onJoinRoomAllCompleted() {
        //如果是断网恢复的，需要处理连麦的状态
        if (isSomeOneInChating()) {
            RoomUser chatingUser = getChatingUser();
            assert chatingUser != null;
            boolean isNeedRemove = true;
            for (RoomUser member : members) {
                if (member.getLinkUid() != 0 && member.getLinkRoomId() != 0) {
                    if (ObjectsCompat.equals(member, getOwnerUser())) {
                        continue;
                    }

                    if (ObjectsCompat.equals(member, chatingUser)) {
                        isNeedRemove = false;
                        break;
                    }
                }
            }

            if (isNeedRemove) {
                onMemberChatStop(chatingUser);
            }
        }
        super.onJoinRoomAllCompleted();
    }

    /**
     * 是否有人正在连麦
     *
     * @return
     */
    public boolean isSomeOneInChating() {
        return getChatingUser() != null;
    }

    @Override
    public boolean isInChating() {
        return ObjectsCompat.equals(getChatingUser(), getMine());
    }

    @Override
    public boolean isInChating(@NonNull RoomUser user) {
        return ObjectsCompat.equals(getChatingUser(), user);
    }

    @Nullable
    @Override
    public RoomUser getChatingMember(long userId) {
        if (getChatingUser() == null) {
            return null;
        }

        if (ObjectsCompat.equals(getChatingUser().getUid(), userId)) {
            return getChatingUser();
        }
        return null;
    }

    private void startAliPlayer() {
        LogUtils.d(TAG, "startAliPlayer() called");
        if (getRoom().getRPublishMode() == Room.RTC) {
            return;
        }

        if (mAliPlayerInstance == null) {
            mAliPlayerInstance = new AliPlayerInstance(getApplication());
            mAliPlayerInstance.init(this);
        }
        if (surfaceHolder != null && surfaceHolder.getSurface().isValid()) {
            mAliPlayerInstance.setDisplay(surfaceHolder);
            mAliPlayerInstance.prepare(getRoom().getRDownStream());
            mAliPlayerInstance.start();
        }
    }

    public void stopAliPlayer() {
        if (mAliPlayerInstance == null || getRoom().getRPublishMode() == Room.RTC) {
            return;
        }
        LogUtils.d(TAG, "stopAliPlayer() called");
        mAliPlayerInstance.setDisplay(null);
        mAliPlayerInstance.stop();
        mAliPlayerInstance.release();
        mAliPlayerInstance = null;
    }

    /**
     * 保存水印图片到SD卡
     */
    private void saveBitmap() {
        File file = new File(getApplication().getFilesDir(), WATER_FILE_NAME);
        if (file.exists()) {
            return;
        }

        Bitmap bitmap = BitmapFactory.decodeResource(getApplication().getResources(),
                R.mipmap.ic_logo);
        FileOutputStream out = null;
        try {
            out = new FileOutputStream(file);
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, out);
            out.close();
        } catch (IOException ex) {
            ex.printStackTrace();
        } finally {
            try {
                if (out != null) {
                    out.close();
                }
            } catch (IOException ex) {
                ex.printStackTrace();
            }
        }
    }

    @Override
    protected void onJoinThunderSuccess() {
        RoomUser mine = getMine();
        if (mine == null) {
            return;
        }

        if (isRoomOwner()) {
            if (reJoinRoom == false) {
                startLive();
                if (getRoom().getRPublishMode() == Room.CDN) {
                    String roomIdMy = String.valueOf(getRoom().getRoomId());
                    String userIdMy = String.valueOf(mine.getUid());

                    LiveTranscoding liveTranscoding =
                            ThunderSvc.getInstance().creatLiveTranscoding(roomIdMy, userIdMy);
                    ThunderSvc.getInstance()
                            .startPublishCDN(userIdMy, getRoom().getRUpStream(), liveTranscoding);
                }
            }
        } else if (getRoom().getRPublishMode() == Room.CDN) {
            startAliPlayer();
        }

        super.onJoinThunderSuccess();
    }

    /**
     * 开始直播,包括：开启预览，开始推流，状态同步
     */
    public void startLive() {
        RoomUser mine = getMine();
        if (mine == null) {
            return;
        }

        ThunderVideoEncoderConfiguration configuration = ThunderSvc.getInstance().getVideoConfig();
        configuration.playType =
                ThunderRtcConstant.ThunderPublishPlayType.THUNDERPUBLISH_PLAY_SINGLE;
        configuration.publishMode =
                ThunderRtcConstant.ThunderPublishVideoMode.THUNDERPUBLISH_VIDEO_MODE_HIGHQULITY;
        addWaterMark();
        ThunderSvc.getInstance().startVideoPreview();
        MagicEffectManager.getInstance().register(getApplication());
        ThunderSvc.getInstance().publishVideoStream(true, true, configuration);
        toggleCameraFont(true);
        toggleVideoMirrorMode(true);
        toggleUserMic(mine, true, true);
        onVideoStart(mine);
    }

    private void addWaterMark() {
        File file = new File(getApplication().getFilesDir(), WATER_FILE_NAME);
        WaterMarkAdapter adapter = new WaterMarkAdapter(file.getAbsolutePath(), 850, 73, 40, 40);
        ThunderSvc.getInstance().setVideoWatermark(adapter);
    }

    /**
     * 结束直播,包括：结束预览，结束推流，状态同步
     */
    public void stopLive() {
        ThunderSvc.getInstance().stopVideoPreview();
        MagicEffectManager.getInstance().unRegister();
        ThunderSvc.getInstance().stopPublishVideoStream();
        toggleCameraFont(true);

        RoomUser mine = getMine();
        if (mine != null) {
            toggleUserMic(mine, true, false);
            onVideoStop(mine);
        }
    }

    /**
     * 跨房间订阅
     */
    public void addSubscribe(long roomId, long uid) {
        ThunderSvc.getInstance().addSubscribe(String.valueOf(roomId), String.valueOf(uid));
    }

    /**
     * 取消跨房间订阅。
     */
    public void removeSubscribe(long roomId, long uid) {
        ThunderSvc.getInstance().removeSubscribe(String.valueOf(roomId), String.valueOf(uid));
    }

    /**
     * 切换前置后置
     */
    public void toggleCameraFont(boolean isCameraFont) {
        ThunderSvc.getInstance().switchFrontCamera(isCameraFont);
        LivingRoomViewModel.this.isCameraFont.postValue(isCameraFont);
    }

    /**
     * 切换分辨率
     *
     * @param publishMode
     */
    public void toggleSarpness(int publishMode) {
        ThunderVideoEncoderConfiguration videoConfig = ThunderSvc.getInstance().getVideoConfig();
        ThunderSvc.getInstance()
                .setVideoEncoderConfig(videoConfig.playType, publishMode);
    }

    /**
     * 切换镜像
     */
    public void toggleVideoMirrorMode(boolean isMirrorMode) {
        ThunderSvc.getInstance().setLocalVideoMirrorMode(isMirrorMode);
        LivingRoomViewModel.this.isMirrorMode.postValue(isMirrorMode);
    }

    public boolean isMirrorMode() {
        return isMirrorMode.getValue();
    }

    public boolean isCameraFont() {
        return isCameraFont.getValue();
    }

    @Override
    protected void close() {
        if (isRoomOwner()) {
            stopLive();
            if (getRoom().getRPublishMode() == Room.CDN) {
                RoomUser mine = getMine();
                if (mine != null) {
                    ThunderSvc.getInstance().stopPublishCDN(String.valueOf(mine.getUid()),
                            getRoom().getRUpStream());
                }
            }
        } else {
            if (isInChating()) {
                stopLive();
            }

            if (getRoom().getRPublishMode() == Room.CDN) {
                stopAliPlayer();
            }
        }
        super.close();
    }

    public void setSurfaceHolder(SurfaceHolder holder) {
        Log.d(TAG, "setSurfaceHolder() called with: holder = [" + holder + "]");
        if (getRoom().getRPublishMode() == Room.RTC) {
            return;
        }

        surfaceHolder = holder;
        if (surfaceHolder == null) {
            stopAliPlayer();
            return;
        }
        surfaceHolder.addCallback(this);
        if (mAliPlayerInstance != null &&
                surfaceHolder.getSurface().isValid()) {
            mAliPlayerInstance.setDisplay(surfaceHolder);
            mAliPlayerInstance.prepare(getRoom().getRDownStream());
            mAliPlayerInstance.start();
        }
    }

    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        LogUtils.d(TAG, "surfaceCreated() called with: holder = [" + holder + "]");
        startAliPlayer();
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
        Log.d(TAG, "surfaceChanged() called with: holder = [" + holder + "], format = [" + format +
                "], width = [" + width + "], height = [" + height + "]");
        if (mAliPlayerInstance == null) {
            return;
        }
        mAliPlayerInstance.redraw();
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        LogUtils.d(TAG, "surfaceDestroyed() called with: holder = [" + holder + "]");
        if (mAliPlayerInstance == null) {
            return;
        }
        stopAliPlayer();
    }

    /**
     * 同房间连麦，业务上来说，只有房主才能触发此接口
     *
     * @param user 被连麦者
     */
    @SuppressLint("CheckResult")
    public void acceptChat(@NonNull RoomUser user, @NonNull RoomLianMaiDialog dialog) {
        FunWSSvc.getInstance()
                .acceptChat(user.getUid(), user.getRoomId())
                .observeOn(AndroidSchedulers.mainThread())
                .compose(bindToLifecycle())
                .subscribe(aBoolean -> {
                    dialog.dismiss();
                    clearAllRequest();

                    onMemberChatStart(user);
                });
    }

    /**
     * 拒绝请求连麦，业务上来说，只有房主才能触发此接口
     *
     * @param user 被连麦者
     */
    @SuppressLint("CheckResult")
    public void refuseChat(@NonNull RoomUser user, @NonNull RoomLianMaiDialog dialog) {
        FunWSSvc.getInstance()
                .rejectChat(user.getUid(), user.getRoomId())
                .observeOn(AndroidSchedulers.mainThread())
                .compose(bindToLifecycle())
                .subscribe(aBoolean -> {
                    dialog.dismiss();
                    doNextReuqest();
                });
    }

    /**
     * 跨房间PK，业务上来说，只有房主才能触发此接口
     *
     * @param user 被连麦者
     */
    @SuppressLint("CheckResult")
    public void acceptPK(@NonNull RoomUser user, @NonNull RoomLianMaiDialog dialog) {
        FunWSSvc.getInstance()
                .acceptChat(user.getUid(), user.getRoomId())
                .observeOn(AndroidSchedulers.mainThread())
                .compose(bindToLifecycle())
                .subscribe(aBoolean -> {
                    dialog.dismiss();
                    clearAllRequest();

                    addSubscribe(user.getRoomId(), user.getUid());
                    onMemberChatStart(user);
                });
    }

    /**
     * 拒绝请求PK，业务上来说，只有房主才能触发此接口
     *
     * @param user 被连麦者
     */
    @SuppressLint("CheckResult")
    public void refusePK(@NonNull RoomUser user, @NonNull RoomLianMaiDialog dialog) {
        FunWSSvc.getInstance()
                .rejectChat(user.getUid(), user.getRoomId())
                .observeOn(AndroidSchedulers.mainThread())
                .compose(bindToLifecycle())
                .subscribe(aBoolean -> {
                    dialog.dismiss();
                    doNextReuqest();
                });
    }

    @Override
    public void onConnectStateChanged(int state) {
        super.onConnectStateChanged(state);
        if (state == FunWSClientHandler.ConnectState.CONNECT_STATE_CONNECTED &&
                getRoom().getRPublishMode() == Room.CDN) {
            startAliPlayer();
        }
    }

    @Override
    public void onChatRev(ChatPacket chatPkg) {
        LogUtils.d(TAG, "onChatRev() called with: chatPkg = [" + chatPkg + "]");
        if (isInChating()) {
            LogUtils.d(TAG, "onChatRev() isChating()");
            return;
        }

        getUserSync(chatPkg.Body.SrcRoomId, chatPkg.Body.SrcUid)
                .compose(bindToLifecycle())
                .subscribe(new SimpleSingleObserver<RoomUser>() {
                    @Override
                    public void onSuccess(RoomUser user) {
                        if (chatPkg.Body.SrcRoomId == chatPkg.Body.DestRoomId) {
                            //连麦
                            mRoomQueueAction.onChatRequestMeesage(user);
                        } else {
                            //PK
                            mRoomQueueAction.onPKRequestMeesage(user);
                        }
                    }
                });
    }

    @Override
    public void onChatCanel(ChatPacket chatPkg) {
        LogUtils.d(TAG, "onChatCanel() called with: chatPkg = [" + chatPkg + "]");
        long targetId = chatPkg.Body.SrcUid;
        long targetRoomId = chatPkg.Body.SrcUid;
        mRoomQueueAction.onCancel(targetId);
    }

    /**
     * 被主播挂断了连麦
     *
     * @param chatPkg
     */
    @Override
    public void onChatHangup(ChatPacket chatPkg) {
        RoomUser mine = getMine();
        if (mine == null) {
            return;
        }

        LogUtils.d(TAG, "onChatHangup() called with: chatPkg = [" + chatPkg + "]");
        long targetUserId = chatPkg.Body.SrcUid;
        long targetRoomId = chatPkg.Body.SrcRoomId;
        RoomUser owner = getOwnerUser();
        if (targetUserId == owner.getUid()) {
            //排除我的房主，找到对方
            targetUserId = chatPkg.Body.DestUid;
            targetRoomId = chatPkg.Body.DestRoomId;
        }
        getUserSync(targetRoomId, targetUserId)
                .observeOn(AndroidSchedulers.mainThread())
                .compose(bindToLifecycle())
                .subscribe(new SimpleSingleObserver<RoomUser>() {
                    @Override
                    public void onSuccess(RoomUser user) {
                        if (chatPkg.Body.SrcRoomId == chatPkg.Body.DestRoomId) {
                            //连麦
                            //onCloseChating这个只是针对观众而言的，直播界面，只有我被挂断
                            onMemberChatStop(mine);
                        } else {
                            //PK
                            //PK模式下，是对方
                            onMemberChatStop(user);
                        }
                    }
                });
    }

    @Override
    public void onMuiltCastChatHangup(ChatPacket chatPkg) {
        LogUtils.d(TAG, "onMuiltCastChatHangup() called with: chatPkg = [" + chatPkg + "]");
        RoomUser mine = getMine();
        if (mine == null) {
            return;
        }

        if (chatPkg.Body.SrcUid == mine.getUid() || chatPkg.Body.DestUid == mine.getUid()) {
            //只有观众处理下面的逻辑
            return;
        }

        RoomUser owner = getOwnerUser();
        long targetUserId = chatPkg.Body.DestUid;
        long targetRoomId = chatPkg.Body.DestRoomId;
        if (targetUserId == owner.getUid()) {
            //排除我的房主，找到对方
            targetUserId = chatPkg.Body.SrcUid;
            targetRoomId = chatPkg.Body.SrcRoomId;
        }

        getUserSync(targetRoomId, targetUserId)
                .observeOn(AndroidSchedulers.mainThread())
                .compose(bindToLifecycle())
                .subscribe(new SimpleSingleObserver<RoomUser>() {
                    @Override
                    public void onSuccess(RoomUser user) {
                        onMemberChatStop(user);
                    }
                });
    }

    @Override
    public void onMuiltCastChating(ChatPacket chatPkg) {
        LogUtils.d(TAG, "onMuiltCastChating() called with: chatPkg = [" + chatPkg + "]");
        RoomUser mine = getMine();
        if (mine == null) {
            return;
        }

        if (chatPkg.Body.SrcUid == mine.getUid() || chatPkg.Body.DestUid == mine.getUid()) {
            //只有观众处理下面的逻辑
            return;
        }

        long targetUserId = chatPkg.Body.DestUid;
        long targetRoomId = chatPkg.Body.DestRoomId;
        RoomUser owner = getOwnerUser();
        if (targetUserId == owner.getUid()) {
            //排除我的房主，找到对方
            targetUserId = chatPkg.Body.SrcUid;
            targetRoomId = chatPkg.Body.SrcRoomId;
        }
        getUserSync(targetRoomId, targetUserId)
                .observeOn(AndroidSchedulers.mainThread())
                .compose(bindToLifecycle())
                .subscribe(new SimpleSingleObserver<RoomUser>() {
                    @Override
                    public void onSuccess(RoomUser user) {
                        onMemberChatStart(user);
                    }
                });
    }

    @Override
    protected void onUserInChating(@NotNull RoomUser user) {
        if (!ObjectsCompat.equals(user, getOwnerUser())) {
            //直播界面，从房主角度查看连麦方，因为这个房间只能有一个人和房主连麦
            return;
        }

        long targetRoomID = user.getLinkRoomId();
        long targetUID = user.getLinkUid();
        getUserSync(targetRoomID, targetUID)
                .observeOn(AndroidSchedulers.mainThread())
                .compose(bindToLifecycle())
                .subscribe(new SimpleSingleObserver<RoomUser>() {
                    @Override
                    public void onSuccess(RoomUser user) {
                        onMemberChatStart(user);
                    }
                });
    }

    @Override
    public void onPrepared() {
        LogUtils.d(TAG, "onPrepared() called");
    }

    @Override
    public void onRenderingStart() {
        LogUtils.d(TAG, "onRenderingStart() called");
    }

    @Override
    public void onAutoPlayStart() {
        LogUtils.d(TAG, "onAutoPlayStart() called");
    }

    @Override
    public void onCodecSwitch() {
        LogUtils.d(TAG, "onCodecSwitch() called");
    }

    @Override
    public void onNetworkTimeout() {
        LogUtils.d(TAG, "onNetworkTimeout() called");
        stopAliPlayer();
    }

    @Override
    public void onBufferingStart() {
        LogUtils.d(TAG, "onBufferingStart() called");
    }

    @Override
    public void onBufferingEnd() {
        LogUtils.d(TAG, "onBufferingEnd() called");
    }

    @Override
    public void onCompletion() {
        LogUtils.d(TAG, "onCompletion() called");
    }

    @Override
    public void onLoadingTimeout() {
        LogUtils.d(TAG, "onLoadingTimeout() called");
        stopAliPlayer();
    }

    @Override
    public void onSurfaceCreated() {
        //由module接管surface，此处不做操作

    }

    @Override
    public void onError(int errorCode) {
        LogUtils.d(TAG, "onError() called errorCode=" + errorCode);
        stopAliPlayer();
        mLiveDataError.postValue(ERROR_CDN);
    }

    @Override
    public void onMemberChatStart(@NonNull RoomUser user) {
        if (getChatingUser() != null) {
            //已经有人在连麦，就退出逻辑
            return;
        }

        RoomUser mine = getMine();
        if (mine == null) {
            return;
        }

        if (isRoomOwner()) {
            if (getRoom().getRPublishMode() == Room.CDN) {
                String roomIdMy = String.valueOf(getRoom().getRoomId());
                String userIdMy = String.valueOf(mine.getUid());

                String roomIdRemote = String.valueOf(user.getRoomId());
                String userIdRemote = String.valueOf(user.getUid());
                LiveTranscoding liveTranscoding = ThunderSvc.getInstance()
                        .creatLiveTranscoding(roomIdMy, userIdMy, roomIdRemote, userIdRemote);
                ThunderSvc.getInstance()
                        .startPublishCDN(userIdMy, getRoom().getRUpStream(), liveTranscoding);
            }
        } else if (ObjectsCompat.equals(user, mine)) {
            startLive();
        }

        Room room = getRoom();
        if (user.getRoomId() != room.getRoomId()) {
            //跨房间PK
            addSubscribe(user.getRoomId(), user.getUid());
        }
        mLiveDataChatingMember.setValue(user);
        super.onMemberChatStart(user);
    }

    @Override
    public void onMemberChatStop(@NonNull RoomUser user) {
        if (getChatingUser() == null) {
            //没人在连麦，就退出逻辑
            return;
        }

        if (!ObjectsCompat.equals(user, getChatingUser())) {
            return;
        }

        RoomUser mine = getMine();
        if (mine == null) {
            return;
        }

        if (isRoomOwner()) {
            if (getRoom().getRPublishMode() == Room.CDN) {
                String roomIdMy = String.valueOf(getRoom().getRoomId());
                String userIdMy = String.valueOf(mine.getUid());

                LiveTranscoding liveTranscoding =
                        ThunderSvc.getInstance().creatLiveTranscoding(roomIdMy, userIdMy);
                ThunderSvc.getInstance()
                        .startPublishCDN(userIdMy, getRoom().getRUpStream(), liveTranscoding);
            }
        } else if (ObjectsCompat.equals(user, mine)) {
            stopLive();
        }

        Room room = getRoom();
        if (user.getRoomId() != room.getRoomId()) {
            //跨房间PK
            removeSubscribe(user.getRoomId(), user.getUid());
        }
        mLiveDataChatingMember.setValue(null);
        super.onMemberChatStop(user);
    }

    /**
     * 正在连麦的用户，这个值只对房主有用，因为只有房主能断开连麦，并且断开的时候，需要知道对方信息，所以定义了一个变量来保存.
     * 有可能为空，因为离开房间后会触发断开连麦，所以获取的时候，有可能为空。
     */
    @Nullable
    public RoomUser getChatingUser() {
        return mLiveDataChatingMember.getValue();
    }

    @Override
    protected ThunderConfig getThunderConfig() {
        return new VideoConfig();
    }
}
