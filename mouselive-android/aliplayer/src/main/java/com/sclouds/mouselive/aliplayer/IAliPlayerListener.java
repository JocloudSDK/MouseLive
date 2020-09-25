package com.sclouds.mouselive.aliplayer;

/**
 * 播放器 APP 业务层监听回调接口
 *
 * @author zhoupingyu@yy.com
 * @since  2020/4/16
 */
public interface IAliPlayerListener {
    /**
     * Surface 创建成功时上层回调
     * 此时可以调用 prepare 接口准备播放
     */
    void onSurfaceCreated();

    /**
     * 播放准备完成时底层回调
     * 此时可以调用 getTrackInfos 获取音视频流轨道信息
     * 此时可以调用 start 接口开始播放
     * 注：自动播放时不会回调
     */
    void onPrepared();

    /**
     * 首帧画面渲染时底层回调
     */
    void onRenderingStart();

    /**
     * 自动播放成功时底层回调
     */
    void onAutoPlayStart();

    /**
     * 硬解切换为软件时底层回调
     */
    void onCodecSwitch();

    /**
     * mNetworkRetryCount 配置为 0 且发生网络超时底层回调
     */
    void onNetworkTimeout();

    /**
     * 缓冲开始时底层回调
     */
    void onBufferingStart();

    /**
     * 缓冲结束时底层回调
     */
    void onBufferingEnd();

    /**
     * 播放完成时底层回调
     */
    void onCompletion();

    /**
     * 播放起播时加载超时或播放过程中缓冲超时底层回调
     */
    void onLoadingTimeout();

    /**
     * 播放出错时底层回调
     * @param errorCode 错误码
     */
    void onError(int errorCode);
}
