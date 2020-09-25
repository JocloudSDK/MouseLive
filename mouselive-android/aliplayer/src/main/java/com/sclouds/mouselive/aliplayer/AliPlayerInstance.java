package com.sclouds.mouselive.aliplayer;

import android.content.Context;
import android.util.Log;
import android.view.SurfaceHolder;

import com.aliyun.player.AliPlayer;
import com.aliyun.player.AliPlayerFactory;
import com.aliyun.player.IPlayer;
import com.aliyun.player.nativeclass.PlayerConfig;
import com.aliyun.player.nativeclass.TrackInfo;
import com.aliyun.player.source.UrlSource;

import java.util.List;

/**
 * 播放器功能类
 *
 * @author zhoupingyu@yy.com
 * @since  2020/4/16
 */
public class AliPlayerInstance implements SurfaceHolder.Callback, AliPlayerListener.IPlayerCallbackListener {

    private static final String TAG = "AliPlayerInstance";

    private AliPlayer mAliPlayer = null;
    private AliPlayerListener mAliPlayerListener = null;

    /**
     * 取值说明如下：
     * 0 - 初始化默认值
     * 1 - prepare 后 onStateChanged 回调值为 1
     * 2 - onPrepared 前 onStateChanged 回调值为 2
     * 3 - onRenderingStart 前 onStateChanged 回调值为 3
     * 4 - pause 后 onStateChanged 回调值为 4
     * 5 - stop 后 onStateChanged 回调值为 5
     * 6 - onCompletion 后 onStateChanged 回调值为 6
     * 7 - onError 前 onStateChanged 回调值为 7
     */
    private int mState = 0;

    public AliPlayerInstance(Context context) {
        mAliPlayer = AliPlayerFactory.createAliPlayer(context);
    }

    /**
     * 采用默认配置初始化播放器
     */
    @SuppressWarnings("unused")
    public void init(IAliPlayerListener listener) {
        setAliPlayerListener(listener);
        setDefaultConfig();
        setAutoPlay(false);
        setLoop(false);
        setScaleMode(AliPlayerScaleModeEnum.SCALE_ASPECT_FILL);
    }

    /**
     * 设置播放相关默认参数
     */
    public void setDefaultConfig() {
        PlayerConfig config = mAliPlayer.getConfig();
        config.mNetworkTimeout = 5000; //设置网络超时时间，单位ms
        config.mNetworkRetryCount = 2; //设置超时重试次数。每次重试间隔为networkTimeout。networkRetryCount=0 则表示不重试，重试策略app决定，默认值为2
        config.mMaxDelayTime = 5000; //最大延迟。注意：直播有效。当延时比较大时，播放器sdk内部会追帧等，保证播放器的延时在这个范围内。
        config.mMaxBufferDuration = 50000; // 最大缓冲区时长。单位ms。播放器每次最多加载这么长时间的缓冲数据。
        config.mHighBufferDuration = 3000; //高缓冲时长。单位ms。当网络不好导致加载数据时，如果加载的缓冲时长到达这个值，结束加载状态。
        config.mStartBufferDuration = 500; // 起播缓冲区时长。单位ms。这个时间设置越短，起播越快。也可能会导致播放之后很快就会进入加载状态。
        mAliPlayer.setConfig(config);
    }

    /**
     * 设置播放状态监听器
     */
    public void setAliPlayerListener(IAliPlayerListener listener) {
        mAliPlayerListener = new AliPlayerListener(listener);
        mAliPlayerListener.setStateChangedListener(this);
        mAliPlayer.setOnPreparedListener(mAliPlayerListener);
        mAliPlayer.setOnVideoSizeChangedListener(mAliPlayerListener);
        mAliPlayer.setOnRenderingStartListener(mAliPlayerListener);
        mAliPlayer.setOnInfoListener(mAliPlayerListener);
        mAliPlayer.setOnSeekCompleteListener(mAliPlayerListener);
        mAliPlayer.setOnLoadingStatusListener(mAliPlayerListener);
        mAliPlayer.setOnCompletionListener(mAliPlayerListener);
        mAliPlayer.setOnErrorListener(mAliPlayerListener);
        mAliPlayer.setOnStateChangedListener(mAliPlayerListener);
        mAliPlayer.setOnTrackChangedListener(mAliPlayerListener);
        mAliPlayer.setOnSubtitleDisplayListener(mAliPlayerListener);
        mAliPlayer.setOnSnapShotListener(mAliPlayerListener);
    }

    /**
     * 自动开始播放设置
     * @param auto true - 自动开始播放，不回调 onPrepared
     *             false - 需要主动调用 start 接口播放
     */
    public void setAutoPlay(boolean auto) {
        mAliPlayer.setAutoPlay(auto);
    }

    /**
     * 循环播放设置
     * @param loop true - 循环播放
     *             false - 单次播放
     */
    public void setLoop(boolean loop) {
        mAliPlayer.setLoop(loop);
    }

    /**
     * 设置画面缩放模式
     * @param scaleMode 缩放模式枚举类
     */
    public void setScaleMode(AliPlayerScaleModeEnum scaleMode) {
        IPlayer.ScaleMode playerScaleMode = IPlayer.ScaleMode.SCALE_ASPECT_FIT;
        switch (scaleMode) {
            case SCALE_ASPECT_FIT:
                break;
            case SCALE_ASPECT_FILL:
                playerScaleMode = IPlayer.ScaleMode.SCALE_ASPECT_FILL;
                break;
            case SCALE_TO_FILL:
                playerScaleMode = IPlayer.ScaleMode.SCALE_TO_FILL;
                break;
            default:
                break;
        }
        mAliPlayer.setScaleMode(playerScaleMode);
    }

    /**
     * 硬解开关，默认是硬解
     * @param hardware true - 硬解
     *                 false - 软解
     */
    @SuppressWarnings("unused")
    public void enableHardwareDecoder(boolean hardware) {
        mAliPlayer.enableHardwareDecoder(hardware);
    }

    /**
     * 设置播放地址准备播放
     * @param uri 播放地址
     */
    @SuppressWarnings("unused")
    public void prepare(String uri) {
        Log.d(TAG, "prepare()");
        UrlSource urlSource = new UrlSource();
        urlSource.setUri(uri);
        mAliPlayer.setDataSource(urlSource);
        mAliPlayer.prepare();
    }

    /**
     * 设置重新加载网络
     * mNetworkRetryCount 配置为 0 且发生网络超时， APP 可根据业务需求监听回调调用该接口
     */
    @SuppressWarnings("unused")
    public void reload() {
        Log.d(TAG, "reload()");
        mAliPlayer.reload();
    }

    /**
     * 开始/恢复播放
     */
    @SuppressWarnings("unused")
    public void start() {
        Log.d(TAG, "start()");
        mAliPlayer.start();
    }

    /**
     * 跳转到指定位置开始播放
     * 注：非精准跳转
     * @param position 跳转位置 单位：ms
     */
    @SuppressWarnings("unused")
    public void seekTo(long position) {
        Log.d(TAG, "seekTo(" + position + ")");
        mAliPlayer.seekTo(position);
    }

    /**
     * 暂停播放
     */
    @SuppressWarnings("unused")
    public void pause() {
        Log.d(TAG, "pause()");
        mAliPlayer.pause();
    }

    /**
     * 重置播放状态
     * 注：reset 后 start 可恢复正常播放
     */
    @SuppressWarnings("unused")
    public void reset() {
        Log.d(TAG, "reset()");
        mAliPlayer.reset();
    }

    /**
     * 停止播放
     * 注：stop 后 start 无效
     */
    @SuppressWarnings("unused")
    public void stop() {
        Log.d(TAG, "stop()");
        mAliPlayer.stop();
    }

    /**
     * 释放播放资源
     * 注：release 后 start 无效
     */
    @SuppressWarnings("unused")
    public void release() {
        Log.d(TAG, "release()");
        mAliPlayer.release();
    }

    /**
     * 设置静音状态
     * @param mute true - 静音
     *             false - 非静音
     */
    @SuppressWarnings("unused")
    public void setMute(boolean mute) {
        mAliPlayer.setMute(mute);
    }

    /**
     * 获取当前播放音量
     * @return 音量值
     */
    @SuppressWarnings("unused")
    public float getVolume() {
        return mAliPlayer.getVolume();
    }

    /**
     * 设置音量大小
     * @param volume 音量值，取值范围为 [0f,1.0f]
     */
    @SuppressWarnings("unused")
    public void setVolume(float volume) {
        mAliPlayer.setVolume(volume);
    }

    /**
     * 设置倍速播放
     * @param speed 倍数，取值范围为 [0.5f,2.0f]
     */
    @SuppressWarnings("unused")
    public void setSpeed(float speed) {
        mAliPlayer.setSpeed(speed);
    }

    /**
     * 设置播放旋转角度
     * @param rotation 旋转角度枚举类
     */
    public void setRotation(AliPlayerRotationEnum rotation) {
        IPlayer.RotateMode rotateMode = IPlayer.RotateMode.ROTATE_0;
        switch (rotation) {
            case ROTATE_90:
                rotateMode = IPlayer.RotateMode.ROTATE_90;
            case ROTATE_180:
                rotateMode = IPlayer.RotateMode.ROTATE_180;
            case ROTATE_270:
                rotateMode = IPlayer.RotateMode.ROTATE_270;
            default:
                break;
        }
        mAliPlayer.setRotateMode(rotateMode);
    }

    /**
     * 获取播放总时长
     * 注：直播时长为 0
     * @return 播放总时长，单位： ms
     */
    @SuppressWarnings("unused")
    public long getDuration() {
        return mAliPlayer.getDuration();
    }

    /**
     * 获取视频流轨道信息
     * @return 视频流轨道信息列表
     */
    @SuppressWarnings("unused")
    public List<TrackInfo> getTrackInfos() {
        return mAliPlayer.getMediaInfo().getTrackInfos();
    }

    /**
     * 音视频流轨道切换实现清晰度切换功能
     * @param index 轨道序列号，通过 TrackInfo.getIndex() 获得
     */
    @SuppressWarnings("unused")
    public void selectTrack(int index) {
        mAliPlayer.selectTrack(index);
    }

    /**
     * 截取当前播放画面，通过 OnSnapShotListener 回调返回结果
     */
    @SuppressWarnings("unused")
    public void snapshot() {
        mAliPlayer.snapshot();
    }

    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        Log.d(TAG, "surfaceCreated(" + holder + ")");
        setDisplay(holder);
        if (null != mAliPlayerListener) {
            mAliPlayerListener.onSurfaceCreated();
        }
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
        Log.d(TAG, "surfaceChanged(holder = " + holder + "，format = " + format + "，width = " + width + ", height = " + height + ")");
        redraw();
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        Log.d(TAG, "surfaceDestroyed(" + holder + ")");
        setDisplay(null);
    }

    /**
     * surfacecreated 时设置 SurfaceHolder 显示播放画面
     * surfaceDestroyed 时设置为 null
     * @param holder 显示 SurfaceHolder
     */
    public void setDisplay(SurfaceHolder holder) {
        mAliPlayer.setDisplay(holder);
    }

    /**
     * surfaceChanged 时调用刷新显示播放画面
     */
    public void redraw() {
        mAliPlayer.redraw();
    }

    @Override
    public void onStateChanged(int state) {
        Log.d(TAG, "onStateChanged(" + state + ")");
        mState = state;
    }

    /**
     * 判断播放器是否首次开始播放
     * @return true - 首次播放
     *         false - 非首次开始播放
     */
    @SuppressWarnings("unused")
    public boolean isFirst() {
        return (mState == 0);
    }

    /**
     * 判断播放器是否处于播放中状态
     * @return true - 播放中
     *         false - 非播放中
     */
    @SuppressWarnings("unused")
    public boolean isPlaying() {
        return (mState == 3);
    }

    /**
     * 判断播放器是否处于暂停状态
     * @return true - 暂停
     *         false - 非暂停
     */
    @SuppressWarnings("unused")
    public boolean isPaused() {
        return (mState == 4);
    }

    /**
     * 判断播放器是否处于播放完成状态
     * @return true - 播放完成
     *         false - 非播放完成
     */
    @SuppressWarnings("unused")
    public boolean isCompletion() {
        return (mState == 6);
    }

    /**
     * 判断播放器是否处于出错状态
     * @return true - 出错
     *         false - 非出错
     */
    @SuppressWarnings("unused")
    public boolean isError() {
        return (mState == 7);
    }

}
