package com.sclouds.datasource.thunder;

import android.annotation.SuppressLint;
import android.content.Context;

import com.google.gson.Gson;
import com.sclouds.basedroid.LogUtils;
import com.sclouds.datasource.Callback;
import com.sclouds.datasource.TokenGetter;
import com.sclouds.datasource.thunder.extension.EmptyExtension;
import com.sclouds.datasource.thunder.extension.IExtension;
import com.sclouds.datasource.thunder.mode.ThunderConfig;
import com.thunder.livesdk.IThunderAudioFilePlayerEventCallback;
import com.thunder.livesdk.LiveTranscoding;
import com.thunder.livesdk.ThunderAudioFilePlayer;
import com.thunder.livesdk.ThunderEngine;
import com.thunder.livesdk.ThunderEventHandler;
import com.thunder.livesdk.ThunderNotification;
import com.thunder.livesdk.ThunderRtcConstant;
import com.thunder.livesdk.ThunderVideoCanvas;
import com.thunder.livesdk.ThunderVideoEncoderConfiguration;
import com.thunder.livesdk.video.ThunderPlayerView;
import com.thunder.livesdk.video.ThunderPreviewView;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.Size;

/**
 * 音视频业务功能模块
 *
 * @author xipeitao
 * @since 2020-02-25 11:50
 */
public class ThunderSvc {

    private static final String TAG = ThunderSvc.class.getSimpleName();

    private long uid;
    private long appid;
    private String appSecret;

    private static ThunderSvc sInstance;
    private Gson mGson = new Gson();

    private ThunderEngine mThunderEngine = null;
    private static volatile Callback callbackJoinChannel;
    private Callback callbackLeaveChannel;
    private IOpenMusicFileCallback callback;
    private ThunderAudioFilePlayer mediaPlayer;
    private WaterMarkAdapter mAdapter;
    private ThunderConfig thunderConfig;
    private List<SimpleThunderEventHandler> observers = new CopyOnWriteArrayList<>();
    private IExtension thunderExtension = new EmptyExtension();
    private ThunderVideoEncoderConfiguration videoConfig =
            new ThunderVideoEncoderConfiguration(
                    ThunderRtcConstant.ThunderPublishPlayType.THUNDERPUBLISH_PLAY_SINGLE,
                    ThunderRtcConstant.ThunderPublishVideoMode.THUNDERPUBLISH_VIDEO_MODE_HIGHQULITY);
    private List<IThunderAudioFilePlayerEventCallback> audioObservers =
            new CopyOnWriteArrayList<>();
    private IThunderAudioFilePlayerEventCallback mIThunderAudioFilePlayerCallback =
            new IThunderAudioFilePlayerEventCallback() {
                @Override
                public void onAudioFileVolume(long volume, long currentMs, long totalMs) {
                    super.onAudioFileVolume(volume, currentMs, totalMs);
                    LogUtils.d(TAG, "onAudioFileVolume() called with: volume = [" + volume +
                            "], currentMs = [" + currentMs + "], totalMs = [" + totalMs + "]");
                    for (IThunderAudioFilePlayerEventCallback callback : audioObservers) {
                        callback.onAudioFileVolume(volume, currentMs, totalMs);
                    }
                }

                @Override
                public void onAudioFileStateChange(int event, int errorCode) {
                    super.onAudioFileStateChange(event, errorCode);
                    LogUtils.d(TAG, "onAudioFileStateChange() called with: event = [" + event +
                            "], errorCode = [" + errorCode + "]");

                    if (event ==
                            ThunderRtcConstant.ThunderAudioFilePlayerEvent.AUDIO_PLAY_EVENT_OPEN) {
                        if (errorCode == 0) {
                            //文件打开成功
                            if (callback != null) {
                                long totalPlayTimeMS = mediaPlayer.getTotalPlayTimeMS();
                                callback.onOpenSuccess(totalPlayTimeMS);
                                callback = null;
                            }
                        } else {
                            if (callback != null) {
                                callback.onOpenError(errorCode);
                                callback = null;
                            }
                        }
                    }

                    for (IThunderAudioFilePlayerEventCallback callback : audioObservers) {
                        callback.onAudioFileStateChange(event, errorCode);
                    }
                }
            };

    public ThunderEngine getEngine() {
        return mThunderEngine;
    }

    public interface IOpenMusicFileCallback {
        void onOpenSuccess(long totalPlayTimeMS);

        void onOpenError(int error);
    }

    public static void setLogFilePath(String filePath) {
        ThunderEngine.setLogFilePath(filePath);
    }

    public synchronized static ThunderSvc getInstance() {
        if (sInstance == null) {
            synchronized (ThunderSvc.class) {
                if (sInstance == null) {
                    sInstance = new ThunderSvc();
                }
            }
        }
        return sInstance;
    }

    private ThunderSvc() {
    }

    /**
     * SDK 初始化
     * 注： Thunder 使用时请确保用到的 Context 保持一致且在同一线程内调用相关接口
     *
     * @param context APP Context
     */
    @MainThread
    public void create(@NonNull Context context, long appid, String appSecret, boolean isChina,
                       int senceId) {
        LogUtils.d(TAG, "ini() called with: context = [" + context + "], appid = [" + appid +
                "], isChina = [" + isChina + "], senceId = [" + senceId + "]");
        this.appid = appid;
        this.appSecret = appSecret;
        if (thunderExtension == null) {
            thunderExtension = new EmptyExtension();    // TODO: 2020/4/26
        }

        if (mThunderEngine == null) {
            mThunderEngine = ThunderEngine
                    .createEngine(context, String.valueOf(appid), senceId, mThunderEventHandler);
            thunderExtension.onCreate(mThunderEngine);


        }
        mThunderEngine.setArea(isChina ? ThunderRtcConstant.AreaType.THUNDER_AREA_DEFAULT :
                ThunderRtcConstant.AreaType.THUNDER_AREA_FOREIGN);
    }

    /**
     * 销毁
     */
    @MainThread
    public void destory() {
        LogUtils.d(TAG, "destory() called");
        ThunderEngine.destroyEngine();
        mThunderEngine = null;
        thunderConfig = null;
        if (thunderExtension != null) {
            thunderExtension.onDestory();
            thunderExtension = null;
        }
    }

    /**
     * 打开播放文件
     *
     * @param file     文件地址
     * @param callback 回掉
     */
    public void openMusic(String file, IOpenMusicFileCallback callback) {
        LogUtils.d(TAG, "openMusic() file=" + file);
        this.callback = callback;
        if (mediaPlayer == null) {
            mediaPlayer = mThunderEngine.createAudioFilePlayer();
        }
        mediaPlayer.enablePublish(true);
        mediaPlayer.enableVolumeIndication(true, 500);
        mediaPlayer.setPlayerEventCallback(mIThunderAudioFilePlayerCallback);
        mediaPlayer.open(file);
    }

    /**
     * 关闭播放
     */
    public void closeMusic() {
        LogUtils.d(TAG, "closeMusic()");
        if (mediaPlayer != null) {
            mediaPlayer.close();
        }
    }

    /**
     * 开始播放
     *
     * @param isLooping 是否循环
     */
    public void startPlayMusic(boolean isLooping) {
        LogUtils.d(TAG, "startPlayMusic() isLooping=" + isLooping);
        if (mediaPlayer != null) {
            mediaPlayer.setLooping(isLooping ? -1 : 0);
            mediaPlayer.play();
        }
    }

    /**
     * 跳转到指定的播放时间
     *
     * @param timeMS 需要跳转到的时间点（单位：毫秒），不应该大于总时长
     */
    public void seekToPlayMusic(long timeMS) {
        LogUtils.d(TAG, "seekToPlayMusic() timeMS=" + timeMS);
        if (mediaPlayer != null) {
            mediaPlayer.seek(timeMS);
        }
    }

    /**
     * 继续播放
     */
    public void resumePlayMusic() {
        LogUtils.d(TAG, "resumePlayMusic()");
        if (mediaPlayer != null) {
            mediaPlayer.resume();
        }
    }

    /**
     * 暂停播放
     */
    public void pausePlayMusic() {
        LogUtils.d(TAG, "pausePlayMusic()");
        if (mediaPlayer != null) {
            mediaPlayer.pause();
        }
    }

    /**
     * 停止播放
     */
    public void stopPlayMusic() {
        LogUtils.d(TAG, "stopPlayMusic()");
        if (mediaPlayer != null) {
            mediaPlayer.stop();
        }
    }

    private int volume = 100;

    /**
     * 设置播放音量
     *
     * @param volume 音量值
     */
    public void setPlayerVolume(@Size(min = 0, max = 100) int volume) {
        LogUtils.d(TAG, "setPlayerVolume() volume=" + volume);
        if (mediaPlayer != null) {
            this.volume = volume;
            mediaPlayer.setPlayVolume(volume);
        }
    }

    /**
     * 设置水印
     */
    public void setVideoWatermark(WaterMarkAdapter adapter) {
        LogUtils.d(TAG, "setVideoWatermark() called with: adapter = [" + adapter + "]");
        mAdapter = adapter;
    }

    /**
     * 获取当前视频配置
     *
     * @return 配置对象
     */
    public ThunderVideoEncoderConfiguration getVideoConfig() {
        return videoConfig;
    }

    /**
     * 获取 SDK 版本号
     *
     * @return 版本号字符串
     */
    public String getVersion() {
        return ThunderEngine.getVersion();
    }

    /**
     * 创建 ThunderPreviewView 的上下文必须和 ini 所传入的上下文必须一致，否则会造成内存泄漏
     *
     * @param context APP Context
     * @return 目标对象
     */
    public ThunderPreviewView createPreviewView(Context context) {
        return new ThunderPreviewView(context);
    }

    /**
     * 创建 ThunderPlayerView 的上下文必须和 ini 所传入的上下文必须一致，否则会造成内存泄漏
     *
     * @param context APP Context
     * @return 目标对象
     */
    public ThunderPlayerView createPlayerView(Context context) {
        return new ThunderPlayerView(context);
    }

    /**
     * 房间配置
     *
     * @param config
     */
    public void setThunderConfig(ThunderConfig config) {
        this.thunderConfig = config;
        thunderConfig.setEngine(mThunderEngine);
        mThunderEngine.setMediaMode(thunderConfig.getMediaMode());
        mThunderEngine.setRoomMode(thunderConfig.getRoomMode());
        mThunderEngine.setAudioConfig(thunderConfig.getAudioConfig(), thunderConfig.getCommutMode(),
                thunderConfig.getScenarioMode());
    }

    /**
     * 加入房间
     *
     * @param roomId   房间号
     * @param uid      用户号
     * @param callback 回调
     */
    public void joinRoom(byte[] token, long roomId, long uid, @NonNull Callback callback) {
        LogUtils.d(TAG,
                "joinRoom() called with: token = [" + new String(token) + "], roomId = [" + roomId +
                        "], uid = [" + uid + "], callback = [" + callback + "]");
        callbackJoinChannel = callback;
        int ret = mThunderEngine.joinRoom(token, String.valueOf(roomId), String.valueOf(uid));
        if (ret != 0) {
            callback.onFailed(ret);
        }

        this.uid = uid;
        LogUtils.d(TAG, "joinChannel result=" + ret);
    }

    /**
     * 离开房间
     *
     * @param callback 回调
     */
    public void leaveRoom(@Nullable Callback callback) {
        LogUtils.d(TAG, "leaveChannel");
        this.callbackLeaveChannel = callback;
        int ret = mThunderEngine.leaveRoom();
        if (ret != 0) {
            if (callback != null) {
                callback.onFailed(ret);
            }
        }

        if (thunderConfig != null) {
            thunderConfig.setEngine(null);
            thunderConfig = null;
        }
        LogUtils.d(TAG, "leaveChannel result=" + ret);
    }

    /**
     * 跨房间订阅。
     * 调用该方法订阅其他房间的音视频流
     *
     * @param roomId 房间号
     * @param uid    用户ID
     */
    public void addSubscribe(String roomId, String uid) {
        LogUtils.d(TAG,
                "addSubscribe() called with: roomId = [" + roomId + "], uid = [" + uid + "]");
        mThunderEngine.addSubscribe(roomId, uid);
    }

    /**
     * 取消跨房间订阅。
     * 调用该方法取消订阅其他房间的音视频流。
     *
     * @param roomId 房间号
     * @param uid    用户ID
     */
    public void removeSubscribe(String roomId, String uid) {
        LogUtils.d(TAG,
                "removeSubscribe() called with: roomId = [" + roomId + "], uid = [" + uid + "]");
        mThunderEngine.removeSubscribe(roomId, uid);
    }

    /**
     * 本地麦克风控制
     *
     * @param isEnable true-打开；false-关闭
     */
    public void toggleMicEnable(boolean isEnable) {
        LogUtils.d(TAG, "toggleMicEnable() called with: isEnable = [" + isEnable + "]");
        if (isEnable) {
            mThunderEngine.stopLocalAudioStream(false);
        } else {
            mThunderEngine.stopLocalAudioStream(true);
        }
    }

    /**
     * 本地麦克风控制，如果不想影响背景音乐ThunderAudioFilePlayer类，需要通过setAudioSourceType来实现
     *
     * @param isEnable
     */
    public void toggleMicWithMusicEnable(boolean isEnable) {
        LogUtils.d(TAG, "toggleMicWithMusicEnable() called with: isEnable = [" + isEnable + "]");
        if (isEnable) {
            mThunderEngine
                    .setAudioSourceType(ThunderRtcConstant.SourceType.THUNDER_PUBLISH_MODE_MIX);
        } else {
            mThunderEngine
                    .setAudioSourceType(ThunderRtcConstant.SourceType.THUNDER_PUBLISH_MODE_FILE);
        }
    }

    /**
     * 开启纯语言推流
     */
    public void publishAudioStream() {
        LogUtils.d(TAG, "publishAudioStream() called");
        mThunderEngine
                .setAudioSourceType(ThunderRtcConstant.SourceType.THUNDER_PUBLISH_MODE_MIX);
        mThunderEngine.setAudioVolumeIndication(500, 0, 0, 0);
        mThunderEngine.enableCaptureVolumeIndication(500, 0, 0, 0);
        mThunderEngine.stopLocalAudioStream(false);
    }

    /**
     * 停止纯语言推流
     */
    public void stopPublishAudioStream() {
        LogUtils.d(TAG, "stopPublishAudioStream() called");
        mThunderEngine.setAudioVolumeIndication(0, 0, 0, 0);
        mThunderEngine.enableCaptureVolumeIndication(0, 0, 0, 0);
        mThunderEngine.stopLocalAudioStream(true);
    }

    private boolean isStartVideoPreview = false;

    /**
     * 开启预览
     */
    public void startVideoPreview() {
        LogUtils.d(TAG,
                "startVideoPreview() called isStartVideoPreview=[" + isStartVideoPreview + "]");
        if (isStartVideoPreview) {
            return;
        }

        mThunderEngine.startVideoPreview();
        isStartVideoPreview = true;
    }

    /**
     * 结束预览
     */
    public void stopVideoPreview() {
        LogUtils.d(TAG,
                "stopVideoPreview() called isStartVideoPreview=[" + isStartVideoPreview + "]");
        if (!isStartVideoPreview) {
            return;
        }

        mThunderEngine.stopVideoPreview();
        isStartVideoPreview = false;
    }

    /**
     * 视频直播房推流
     *
     * @param video         视频流
     * @param audio         音频流,需要和禁麦区分开来
     * @param yyVideoConfig 视频开播参数
     * @link muteLocalAudioStream
     */
    public void publishVideoStream(boolean video, boolean audio,
                                   ThunderVideoEncoderConfiguration yyVideoConfig) {
        LogUtils.d(TAG,
                "publishVideoStream() called with: video = [" + video + "], audio = [" + audio +
                        "]");
        videoConfig = yyVideoConfig;
        mThunderEngine.setVideoEncoderConfig(yyVideoConfig);
        mThunderEngine
                .setAudioSourceType(ThunderRtcConstant.SourceType.THUNDER_PUBLISH_MODE_MIX);

        //视频控制
        if (video) {
            mThunderEngine.stopLocalVideoStream(false);
        } else {
            mThunderEngine.stopLocalVideoStream(true);
        }

        //音频控制
        mThunderEngine.stopLocalAudioStream(!audio);
    }

    /**
     * 停止视频直播房推流
     */
    public void stopPublishVideoStream() {
        LogUtils.d(TAG, "stopPublishVideoStream() called");
        //视频控制
        mThunderEngine.stopLocalVideoStream(true);

        //音频控制
        mThunderEngine.stopLocalAudioStream(true);
    }

    /**
     * 开启本地预览，开播
     *
     * @param uid         当前用户的ID
     * @param previewView 预览的View
     * @param scaleMode   缩放模式
     * @see ThunderRtcConstant.ThunderVideoViewScaleMode
     */
    public void prepareLocalVideo(String uid, ThunderPreviewView previewView, int scaleMode) {
        LogUtils.d(TAG,
                "prepareLocalVideo() called with: uid = [" + uid + "], scaleMode = [" + scaleMode +
                        "]");
        ThunderVideoCanvas canvas = new ThunderVideoCanvas(previewView, scaleMode, uid);
        mThunderEngine.setLocalVideoCanvas(canvas);
    }

    /**
     * 播放远程的流，一般是在收到 onRemoteVideoStopped 通知之后调用
     *
     * @param uid        当前用户的 ID
     * @param playerView 预览的 View
     * @param scaleMode  缩放模式
     * @see ThunderRtcConstant.ThunderVideoViewScaleMode
     */
    public void prepareRemoteVideo(String uid, ThunderPlayerView playerView, int scaleMode) {
        LogUtils.d(TAG, "prepareRemoteVideo() called with: uid = [" + uid + "], playerView = [" +
                playerView + "], scaleMode = [" + scaleMode + "]"+playerView);
        ThunderVideoCanvas canvas = new ThunderVideoCanvas(playerView, scaleMode, uid);
        mThunderEngine.setRemoteVideoCanvas(canvas);
    }

    /**
     * 设置本地视频镜像模式
     * (只对前置摄像头生效，后置摄像头不生效，后置摄像头固定预览推流都不镜像,
     * 前置摄像头默认预览镜像推流不镜像)
     */
    public void setLocalVideoMirrorMode(boolean isMirrorMode) {
        LogUtils.d(TAG,
                "setLocalVideoMirrorMode() called with: isMirrorMode = [" + isMirrorMode + "]");
        if (isMirrorMode) {
            mThunderEngine.setLocalVideoMirrorMode(
                    ThunderRtcConstant.ThunderVideoMirrorMode.THUNDER_VIDEO_MIRROR_MODE_PREVIEW_PUBLISH_BOTH_MIRROR);
        } else {
            mThunderEngine.setLocalVideoMirrorMode(
                    ThunderRtcConstant.ThunderVideoMirrorMode.THUNDER_VIDEO_MIRROR_MODE_PREVIEW_PUBLISH_BOTH_NO_MIRROR);
        }
    }

    /**
     * 设置开播的编码配置，实时生效。可以根据不同的情况设置（比如人数较多等）
     *
     * @param playType    开播的类型
     * @param publishMode 开播的档位
     * @see ThunderRtcConstant.ThunderPublishPlayType
     * @see ThunderRtcConstant.ThunderPublishVideoMode
     */
    public void setVideoEncoderConfig(int playType, int publishMode) {
        LogUtils.d(TAG, "setVideoEncoderConfig() called with: playType = [" + playType +
                "], publishMode = [" + publishMode + "]");
        videoConfig.playType = playType;
        videoConfig.publishMode = publishMode;
        mThunderEngine.setVideoEncoderConfig(videoConfig);
    }

    /**
     * 切换摄像头
     *
     * @param bFront true - 前置摄像头
     *               false - 后置摄像头
     */
    public void switchFrontCamera(boolean bFront) {
        LogUtils.d(TAG, "switchFrontCamera() called with: bFront = [" + bFront + "]");
        int ret = mThunderEngine.switchFrontCamera(bFront);
        LogUtils.d(TAG, "switchFrontCamera() ret=" + ret);
    }

    /**
     * 开启扬声器
     *
     * @param enabled true - 开启
     *                false - 关闭
     */
    public void setEnableSpeakerphone(boolean enabled) {
        LogUtils.d(TAG, "setEnableSpeakerphone() called with: enabled = [" + enabled + "]");
        int ret = mThunderEngine.enableLoudspeaker(enabled);
        LogUtils.d(TAG, "enableLoudspeaker() ret=" + ret);
    }

    /**
     * 创建混流画面
     *
     * @return 目标对象
     */
    public LiveTranscoding creatLiveTranscoding(String roomIdMy, String userIdMy) {
        LogUtils.d(TAG,
                "creatLiveTranscoding() called with: roomId = [" + roomIdMy + "], userId = [" +
                        userIdMy + "]");

        int height = 320;
        int width = 240;
        int mixMode = ThunderRtcConstant.LiveTranscodingMode.TRANSCODING_MODE_320X240;
        if (videoConfig.publishMode ==
                ThunderRtcConstant.ThunderPublishVideoMode.THUNDERPUBLISH_VIDEO_MODE_NORMAL) {
            mixMode = ThunderRtcConstant.LiveTranscodingMode.TRANSCODING_MODE_640X360;
            height = 640;
            width = 360;
        }
        if (videoConfig.publishMode ==
                ThunderRtcConstant.ThunderPublishVideoMode.THUNDERPUBLISH_VIDEO_MODE_HIGHQULITY) {
            mixMode = ThunderRtcConstant.LiveTranscodingMode.TRANSCODING_MODE_960X544;
            height = 960;
            width = 544;
        }

        LiveTranscoding.TranscodingUser userMy = new LiveTranscoding.TranscodingUser();
        userMy.roomId = roomIdMy;
        userMy.uid = userIdMy;
        userMy.layoutW = height;
        userMy.layoutH = width;
        userMy.layoutX = 0;
        userMy.layoutY = 0;
        userMy.zOrder = 1;
        userMy.bCrop = true;

        LiveTranscoding transCoding = new LiveTranscoding();
        transCoding.addUser(userMy);
        transCoding.setTransCodingMode(mixMode);
        return transCoding;
    }

    /**
     * 创建混流画面，2人连麦人
     *
     * @return 目标对象
     */
    public LiveTranscoding creatLiveTranscoding(String roomIdMy, String userIdMy,
                                                String roomIdRemote, String userIdRemote) {
        LogUtils.d(TAG,
                "creatLiveTranscoding() called with: roomIdMy = [" + roomIdMy + "], userIdMy = [" +
                        userIdMy + "], roomIdRemote = [" + roomIdRemote + "], userIdRemote = [" +
                        userIdRemote + "]");

        int height = 320;
        int width = 240;
        int mixMode = ThunderRtcConstant.LiveTranscodingMode.TRANSCODING_MODE_320X240;
        if (videoConfig.publishMode ==
                ThunderRtcConstant.ThunderPublishVideoMode.THUNDERPUBLISH_VIDEO_MODE_NORMAL) {
            mixMode = ThunderRtcConstant.LiveTranscodingMode.TRANSCODING_MODE_640X360;
            height = 640;
            width = 360;
        }
        if (videoConfig.publishMode ==
                ThunderRtcConstant.ThunderPublishVideoMode.THUNDERPUBLISH_VIDEO_MODE_HIGHQULITY) {
            mixMode = ThunderRtcConstant.LiveTranscodingMode.TRANSCODING_MODE_960X544;
            height = 960;
            width = 544;
        }

        LiveTranscoding.TranscodingUser userMy = new LiveTranscoding.TranscodingUser();
        userMy.roomId = roomIdMy;
        userMy.uid = userIdMy;
        userMy.layoutW = height;
        userMy.layoutH = width;
        userMy.layoutX = 0;
        userMy.layoutY = 0;
        userMy.zOrder = 1;
        userMy.bCrop = true;

        LiveTranscoding.TranscodingUser userRemote = new LiveTranscoding.TranscodingUser();
        userRemote.roomId = roomIdRemote;
        userRemote.uid = userIdRemote;
        userRemote.layoutW = height;
        userRemote.layoutH = width;
        userRemote.layoutX = userMy.layoutW;
        userRemote.layoutY = 0;
        userRemote.zOrder = 1;
        userRemote.bStandard = true;
        userRemote.bCrop = true;

        LiveTranscoding transCoding = new LiveTranscoding();
        transCoding.addUser(userMy);
        transCoding.addUser(userRemote);
        transCoding.setTransCodingMode(mixMode);
        return transCoding;
    }

    /**
     * 开始推流
     *
     * @param taskId      任务id
     * @param url         推流url
     * @param transcoding 配置
     */
    public void startPublishCDN(String taskId, String url, LiveTranscoding transcoding) {
        LogUtils.d(TAG,
                "startPublishCDN() called with: taskId = [" + taskId + "], url = [" + url + "]");
        // mThunderEngine.setLiveTranscodingTask(taskId, transcoding);
        // mThunderEngine.addPublishTranscodingStreamUrl(taskId, url);
        mThunderEngine.addPublishOriginStreamUrl(url);
    }

    /**
     * 结束推流
     *
     * @param taskId 任务 id
     * @param url    推流 url
     */
    public void stopPublishCDN(String taskId, String url) {
        LogUtils.d(TAG,
                "stopPublishCDN() called with: taskId = [" + taskId + "], url = [" + url + "]");
        // mThunderEngine.removeLiveTranscodingTask(taskId);
        // mThunderEngine.removePublishTranscodingStreamUrl(taskId, url);
        mThunderEngine.removePublishOriginStreamUrl(url);
    }

    /**
     * 打开关闭耳返，默认为关闭状态
     *
     * @param enable true - 打开
     *               false - 关闭
     */
    public void setEnableInEarMonitor(boolean enable) {
        LogUtils.d(TAG, "setEnableInEarMonitor() called with: enable = [" + enable + "]");
        mThunderEngine.setEnableInEarMonitor(enable);
    }

    /**
     * 设置变声模式
     *
     * @param mode =ThunderRtcConstant.VoiceChangerMode.
     *             THUNDER_VOICE_CHANGER_NONE                = 关闭模式
     *             THUNDER_VOICE_CHANGER_ETHEREAL            = 空灵
     *             THUNDER_VOICE_CHANGER_THRILLER            = 惊悚
     *             THUNDER_VOICE_CHANGER_LUBAN               = 鲁班
     *             THUNDER_VOICE_CHANGER_LORIE               = 萝莉
     *             THUNDER_VOICE_CHANGER_UNCLE               = 大叔
     *             THUNDER_VOICE_CHANGER_DIEFAT              = 死肥仔
     *             THUNDER_VOICE_CHANGER_BADBOY              = 熊孩子
     *             THUNDER_VOICE_CHANGER_WRACRAFT            = 魔兽农民
     *             THUNDER_VOICE_CHANGER_HEAVYMETAL          = 重金属
     *             THUNDER_VOICE_CHANGER_COLD                = 感冒
     *             THUNDER_VOICE_CHANGER_HEAVYMECHINERY      = 重机械
     *             THUNDER_VOICE_CHANGER_TRAPPEDBEAST        = 困兽
     *             THUNDER_VOICE_CHANGER_POWERCURRENT        = 强电流
     */
    public void setVoiceChanger(int mode) {
        mThunderEngine.setVoiceChanger(mode);
    }

    /**
     * thunder 回调事件
     */
    private ThunderEventHandler mThunderEventHandler = new ThunderEventHandler() {

        @Override
        public void onError(int error) {
            LogUtils.d(TAG, "ThunderEventHandler onError: " + error);
            // TODO: 2020-03-18 当前没有办法判断是哪一步操作导致的error
            for (ThunderEventHandler o : observers) {
                o.onError(error);
            }
        }

        @Override
        public void onJoinRoomSuccess(String room, String uid, int elapsed) {
            LogUtils.d(TAG,
                    "ThunderEventHandler onJoinRoomSuccess:room:" + room + ",Uid:" + uid +
                            ", elapsed:" +
                            elapsed);
            callbackJoinChannel.onSuccess();
            callbackJoinChannel = null;

            for (ThunderEventHandler o : observers) {
                o.onJoinRoomSuccess(room, uid, elapsed);
            }
        }

        @Override
        public void onLeaveRoom(RoomStats status) {
            LogUtils.d(TAG, "ThunderEventHandler onLeaveRoom: status:" + status.temp);
            if (callbackLeaveChannel != null) {
                callbackLeaveChannel.onSuccess();
                callbackLeaveChannel = null;
            }

            for (ThunderEventHandler o : observers) {
                o.onLeaveRoom(status);
            }
        }

        @Override
        public void onBizAuthResult(boolean bPublish, int result) {
            LogUtils.d(TAG,
                    "ThunderEventHandler onBizAuthResult: bPublish:" + bPublish + ", result:" +
                            result);

            for (ThunderEventHandler o : observers) {
                o.onBizAuthResult(bPublish, result);
            }
        }

        @SuppressLint("CheckResult")
        @Override
        public void onSdkAuthResult(int result) {
            LogUtils.d(TAG, "ThunderEventHandler onSdkAuthResult: result:" + result);
            LogUtils.d("peter",
                    "onSdkAuthResult() called with: +result = [" + +result + "] +uid = " +
                            "[" + +uid + "]");
            if (result != 0) {
                TokenGetter.updateToken(uid, appid, appSecret).subscribe(
                        aBoolean -> mThunderEngine.updateToken(TokenGetter.getToken().getBytes()));
            }
            for (ThunderEventHandler o : observers) {
                o.onSdkAuthResult(result);
            }
        }

        @Override
        public void onUserBanned(boolean status) {
            LogUtils.d(TAG, "ThunderEventHandler onUserBanned: status:" + status);

            for (ThunderEventHandler o : observers) {
                o.onUserBanned(status);
            }
        }

        @Override
        public void onUserJoined(String uid, int elapsed) {
            LogUtils.d(TAG,
                    "ThunderEventHandler onUserJoined: Uid:" + uid + ", elapsed:" + elapsed);

            for (ThunderEventHandler o : observers) {
                o.onUserJoined(uid, elapsed);
            }
        }

        @Override
        public void onUserOffline(String uid, int reason) {
            LogUtils.d(TAG, "ThunderEventHandler onUserOffline() called with: Uid = [" + uid +
                    "], reason = [" +
                    reason + "]");

            for (ThunderEventHandler o : observers) {
                o.onUserOffline(uid, reason);
            }
        }

        @SuppressLint("CheckResult")
        @Override
        public void onTokenWillExpire(byte[] token) {
            LogUtils.d(TAG, "ThunderEventHandler onTokenWillExpire");
            TokenGetter.updateToken(uid, appid, appSecret).subscribe(
                    aBoolean -> mThunderEngine.updateToken(TokenGetter.getToken().getBytes()));
            for (ThunderEventHandler o : observers) {
                o.onTokenWillExpire(token);
            }
        }

        @SuppressLint("CheckResult")
        @Override
        public void onTokenRequested() {
            LogUtils.d(TAG, "ThunderEventHandler onTokenRequested: ");
            LogUtils.d("peter", "onTokenRequested() called" + uid);
            TokenGetter.updateToken(uid, appid, appSecret).subscribe(
                    aBoolean -> mThunderEngine.updateToken(TokenGetter.getToken().getBytes()));
            for (ThunderEventHandler o : observers) {
                o.onTokenRequested();
            }
        }

        @Override
        public void onNetworkQuality(String uid, int txQuality, int rxQuality) {
            LogUtils.d(TAG, "ThunderEventHandler onNetworkQuality() called with: Uid = [" + uid +
                    "], txQuality = [" + txQuality + "], rxQuality = [" + rxQuality + "]");

            for (ThunderEventHandler o : observers) {
                o.onNetworkQuality(uid, txQuality, rxQuality);
            }
        }

        @Override
        public void onRoomStats(ThunderNotification.RoomStats stats) {
            LogUtils.d(TAG, "ThunderEventHandler onRoomStats() called with: stats = [" +
                    mGson.toJson(stats) + "]");

            for (ThunderEventHandler o : observers) {
                o.onRoomStats(stats);
            }
        }

        @Override
        public void onPlayVolumeIndication(AudioVolumeInfo[] speakers, int totalVolume) {
            LogUtils.d(TAG, "ThunderEventHandler onPlayVolumeIndication");

            for (ThunderEventHandler o : observers) {
                o.onPlayVolumeIndication(speakers, totalVolume);
            }
        }

        @Override
        public void onCaptureVolumeIndication(int totalVolume, int cpt, int micVolume) {
            LogUtils.d(TAG,
                    "ThunderEventHandler onCaptureVolumeIndication, totalVolume:" + totalVolume);

            for (ThunderEventHandler o : observers) {
                o.onCaptureVolumeIndication(totalVolume, cpt, micVolume);
            }
        }

        @Override
        public void onAudioQuality(String uid, int quality, short delay, short lost) {
            LogUtils.d(TAG,
                    "ThunderEventHandler onAudioQuality() called with: Uid = [" + uid +
                            "], quality = [" +
                            quality +
                            "], delay = [" + delay + "], lost = [" + lost + "]");

            for (ThunderEventHandler o : observers) {
                o.onAudioQuality(uid, quality, delay, lost);
            }
        }

        @Override
        public void onConnectionLost() {
            LogUtils.d(TAG, "ThunderEventHandler onConnectionLost() called");

            for (ThunderEventHandler o : observers) {
                o.onConnectionLost();
            }
        }

        @Override
        public void onConnectionInterrupted() {
            LogUtils.d(TAG, "ThunderEventHandler onConnectionInterrupted() called");

            for (ThunderEventHandler o : observers) {
                o.onConnectionInterrupted();
            }
        }

        @Override
        public void onAudioRouteChanged(int routing) {
            LogUtils.d(TAG,
                    "ThunderEventHandler onAudioRouteChanged() called with: routing = [" + routing +
                            "]");

            for (ThunderEventHandler o : observers) {
                o.onAudioRouteChanged(routing);
            }
        }

        @Override
        public void onAudioPlayData(byte[] data, long cpt, long pts, String uid, long duration) {
            LogUtils.d(TAG, "ThunderEventHandler onAudioPlayData:Uid:" + uid);

            for (ThunderEventHandler o : observers) {
                o.onAudioPlayData(data, cpt, pts, uid, duration);
            }
        }

        @Override
        public void onAudioPlaySpectrumData(byte[] data) {
            LogUtils.d(TAG, "ThunderEventHandler onAudioPlaySpectrumData:");

            for (ThunderEventHandler o : observers) {
                o.onAudioPlaySpectrumData(data);
            }
        }

        @Override
        public void onAudioCapturePcmData(byte[] data, int dataSize, int sampleRate, int channel) {
            LogUtils.d(TAG, "ThunderEventHandler onAudioCapturePcmData:channel:" + channel);

            for (ThunderEventHandler o : observers) {
                o.onAudioCapturePcmData(data, dataSize, sampleRate, channel);
            }
        }

        @Override
        public void onAudioRenderPcmData(byte[] data, int dataSize, long duration, int sampleRate,
                                         int channel) {
            LogUtils.d(TAG, "ThunderEventHandler onAudioRenderPcmData:channel:" + channel);

            for (ThunderEventHandler o : observers) {
                o.onAudioRenderPcmData(data, dataSize, duration, sampleRate, channel);
            }
        }

        @Override
        public void onRecvUserAppMsgData(byte[] data, String uid) {
            LogUtils.d(TAG, "ThunderEventHandler onRecvUserAppMsgData:Uid:" + uid);

            for (ThunderEventHandler o : observers) {
                o.onRecvUserAppMsgData(data, uid);
            }
        }

        @Override
        public void onSendAppMsgDataFailedStatus(int status) {
            LogUtils.d(TAG, "ThunderEventHandler onSendAppMsgDataFailedStatus:status:" + status);

            for (ThunderEventHandler o : observers) {
                o.onSendAppMsgDataFailedStatus(status);
            }
        }

        @Override
        public void onRemoteAudioStopped(String uid, boolean stop) {
            LogUtils.d(TAG,
                    "ThunderEventHandler onRemoteAudioStopped:Uid:" + uid + ",stop:" + stop);

            for (ThunderEventHandler o : observers) {
                o.onRemoteAudioStopped(uid, stop);
            }
        }

        @Override
        public void onRemoteVideoStopped(String uid, boolean stop) {
            LogUtils.d(TAG,
                    "ThunderEventHandler onRemoteVideoStopped:Uid:" + uid + ", stop:" + stop);

            for (ThunderEventHandler o : observers) {
                o.onRemoteVideoStopped(uid, stop);
            }
        }

        @Override
        public void onRemoteVideoPlay(String uid, int width, int height, int elapsed) {
            LogUtils.d(TAG,
                    "ThunderEventHandler onRemoteVideoPlay() called with: Uid = [" + uid +
                            "], width = [" +
                            width +
                            "], height = [" + height + "], elapsed = [" + elapsed + "]");

            for (ThunderEventHandler o : observers) {
                o.onRemoteVideoPlay(uid, width, height, elapsed);
            }
        }

        @Override
        public void onVideoSizeChanged(String uid, int width, int height, int rotation) {
            LogUtils.d(TAG,
                    "ThunderEventHandler onVideoSizeChanged:Uid:" + uid + ", width:" + width +
                            ", height:" +
                            height + ", rotation:" + rotation);
            if (mAdapter != null && uid.equals(String.valueOf(ThunderSvc.this.uid))) {
                mThunderEngine.setVideoWatermark(mAdapter.createThunderBoltImage(width, height,
                        rotation));
            }
            for (ThunderEventHandler o : observers) {
                o.onVideoSizeChanged(uid, width, height, rotation);
            }
        }

        @Override
        public void onFirstLocalAudioFrameSent(int elapsed) {
            LogUtils.d(TAG, "ThunderEventHandler onFirstLocalAudioFrameSent: elapsed:" + elapsed);

            for (ThunderEventHandler o : observers) {
                o.onFirstLocalAudioFrameSent(elapsed);
            }
        }

        @Override
        public void onFirstLocalVideoFrameSent(int elapsed) {
            LogUtils.d(TAG, "ThunderEventHandler onFirstLocalVideoFrameSent: elapsed:" + elapsed);

            for (ThunderEventHandler o : observers) {
                o.onFirstLocalVideoFrameSent(elapsed);
            }
        }

        @Override
        public void onPublishStreamToCDNStatus(String url, int errorCode) {
            LogUtils.d(TAG,
                    "onPublishStreamToCDNStatus() called with: url = [" + url + "], errorCode = [" +
                            errorCode + "]");

            for (ThunderEventHandler o : observers) {
                o.onPublishStreamToCDNStatus(url, errorCode);
            }
        }

        @Override
        public void onNetworkTypeChanged(int type) {
            String[] strTypeArray =
                    {"网络连接类型未知", "网络连接已断开", "有线网络", "无线Wi-Fi（包含热点）", "移动网络，不分2G,3G,4G网络", "2G",
                            "3G", "4G"};
            String strType = "不知道";
            if ((type >= ThunderRtcConstant.ThunderNetworkType.THUNDER_NETWORK_TYPE_UNKNOWN)
                    && (type <=
                    ThunderRtcConstant.ThunderNetworkType.THUNDER_NETWORK_TYPE_MOBILE_4G)) {
                strType = strTypeArray[type];
            }

            String outStr =
                    "ThunderEventHandler onNetworkTypeChanged:" + strType + ", type:" + type;
            LogUtils.d(TAG, outStr);

            for (ThunderEventHandler o : observers) {
                o.onNetworkTypeChanged(type);
            }
        }

        @Override
        public void onConnectionStatus(int status) {
            String[] strStatusArray = {"连接中", "连接成功", "连接断开"};
            String strState = "不知道";
            if ((status >=
                    ThunderRtcConstant.ThunderConnectionStatus.THUNDER_CONNECTION_STATUS_CONNECTING)
                    && (status <=
                    ThunderRtcConstant.ThunderConnectionStatus.THUNDER_CONNECTION_STATUS_DISCONNECTED)) {
                strState = strStatusArray[status];
            }
            String outStr =
                    "ThunderEventHandler onConnectionStatus:" + strState + ", status:" + status;
            LogUtils.d(TAG, outStr);

            for (ThunderEventHandler o : observers) {
                o.onConnectionStatus(status);
            }
        }

        @Override
        public void onAudioCaptureStatus(int status) {
            LogUtils.d(TAG, "ThunderEventHandler onAudioCaptureStatus:" + status);

            for (ThunderEventHandler o : observers) {
                o.onAudioCaptureStatus(status);
            }
        }

        @Override
        public void onVideoCaptureStatus(int status) {
            LogUtils.d(TAG, "ThunderEventHandler onVideoCaptureStatus:" + status);

            for (ThunderEventHandler o : observers) {
                o.onVideoCaptureStatus(status);
            }
        }
    };

    public void addAudioListener(
            @NonNull IThunderAudioFilePlayerEventCallback observer) {
        LogUtils.d(TAG, "addAudioListener");
        audioObservers.add(observer);
    }

    public void removeAudioListener(
            @NonNull IThunderAudioFilePlayerEventCallback observer) {
        LogUtils.d(TAG, "removeAudioListener");
        audioObservers.remove(observer);
    }

    public void addListener(@NonNull SimpleThunderEventHandler observer) {
        LogUtils.d(TAG, "addMemListener");
        observers.add(observer);
    }

    public void removeListener(@NonNull SimpleThunderEventHandler observer) {
        LogUtils.d(TAG, "removeMemListener");
        observers.remove(observer);
    }
}
