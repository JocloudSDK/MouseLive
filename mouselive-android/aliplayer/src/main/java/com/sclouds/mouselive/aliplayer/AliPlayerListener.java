package com.sclouds.mouselive.aliplayer;

import android.graphics.Bitmap;
import android.util.Log;

import com.aliyun.player.IPlayer;
import com.aliyun.player.bean.ErrorCode;
import com.aliyun.player.bean.ErrorInfo;
import com.aliyun.player.bean.InfoBean;
import com.aliyun.player.bean.InfoCode;
import com.aliyun.player.nativeclass.TrackInfo;

/**
 * 播放器功能层监听回调类
 *
 * @author zhoupingyu@yy.com
 * @since  2020/4/16
 */
public class AliPlayerListener implements IPlayer.OnPreparedListener, IPlayer.OnVideoSizeChangedListener, IPlayer.OnRenderingStartListener, IPlayer.OnInfoListener,
        IPlayer.OnSeekCompleteListener, IPlayer.OnLoadingStatusListener, IPlayer.OnCompletionListener, IPlayer.OnErrorListener, IPlayer.OnStateChangedListener,
        IPlayer.OnTrackChangedListener, IPlayer.OnSubtitleDisplayListener, IPlayer.OnSnapShotListener, IPlayer.OnVideoRenderedListener {

    private static final String TAG = "AliPlayerListener";

    private IAliPlayerListener mPlayerListener = null;
    private IPlayerCallbackListener mPlayerCallbackListener = null;

    public AliPlayerListener(IAliPlayerListener playerListener) {
        mPlayerListener = playerListener;
    }

    @SuppressWarnings("unused")
    public void setStateChangedListener(IPlayerCallbackListener callbackListener) {
        mPlayerCallbackListener = callbackListener;
    }

    @SuppressWarnings("unused")
    public void onSurfaceCreated() {
        if (null != mPlayerListener) {
            mPlayerListener.onSurfaceCreated();
        }
    }

    @Override
    public void onPrepared() {
        Log.d(TAG, "onPrepared()");
        if (null != mPlayerListener) {
            mPlayerListener.onPrepared();
        }
    }

    @Override
    public void onVideoSizeChanged(int width, int height) {
        Log.d(TAG, "onVideoSizeChanged(width = " + width + "，height = " + height + ")");
    }

    @Override
    public void onRenderingStart() {
        Log.d(TAG, "onRenderingStart()");
        if (null != mPlayerListener) {
            mPlayerListener.onRenderingStart();
        }
    }

    @Override
    public void onInfo(InfoBean infoBean) {
//        Log.d(TAG, "onInfo(" + infoBean.getCode().getValue() + ")");
        if (infoBean.getCode() == InfoCode.AutoPlayStart){
            // 自动播放开始事件
            Log.d(TAG, "auto player start");
        }
        if (infoBean.getCode() == InfoCode.LoopingStart){
            //循环播放开始事件
            Log.d(TAG, "looping play start");
            if (null != mPlayerListener) {
                mPlayerListener.onAutoPlayStart();
            }
        }
        if (infoBean.getCode() == InfoCode.SwitchToSoftwareVideoDecoder) {
            //切换到软解
            Log.d(TAG, "hardware codec switch to software codec");
            if (null != mPlayerListener) {
                mPlayerListener.onCodecSwitch();
            }
        }
        if (infoBean.getCode() == InfoCode.NetworkRetry) {
            Log.d(TAG, "callback while NetworkRetryCount config value is 0");
            if (null != mPlayerListener) {
                mPlayerListener.onNetworkTimeout();
            }
        }
    }

    @Override
    public void onSeekComplete() {
        Log.d(TAG, "onSeekComplete()");
    }

    @Override
    public void onLoadingBegin() {
        Log.d(TAG, "onLoadingBegin()");
        if (null != mPlayerListener) {
            mPlayerListener.onBufferingStart();
        }
    }

    @Override
    public void onLoadingProgress(int i, float v) {
//        Log.d(TAG, "onLoadingProgress(i = " + i + "，v = " + v + ")");
    }

    @Override
    public void onLoadingEnd() {
        Log.d(TAG, "onLoadingEnd()");
        if (null != mPlayerListener) {
            mPlayerListener.onBufferingEnd();
        }
    }

    @Override
    public void onCompletion() {
        Log.d(TAG, "onCompletion()");
        if (null != mPlayerListener) {
            mPlayerListener.onCompletion();
        }
    }

    @Override
    public void onError(ErrorInfo errorInfo) {
        Log.d(TAG, "onError(" + errorInfo.getCode().getValue() + ")");
        if (errorInfo.getCode() == ErrorCode.ERROR_LOADING_TIMEOUT) {
            Log.d(TAG, "play loading timeout");
            if (null != mPlayerListener) {
                mPlayerListener.onLoadingTimeout();
                return;
            }
        }
        if (null != mPlayerListener) {
            mPlayerListener.onError(errorInfo.getCode().getValue());
        }
    }

    @Override
    public void onStateChanged(int state) {
//        Log.d(TAG, "onStateChanged(" + state + ")");
        if (null != mPlayerCallbackListener) {
            mPlayerCallbackListener.onStateChanged(state);
        }
    }

    @Override
    public void onChangedSuccess(TrackInfo trackInfo) {
        Log.d(TAG, "onChangedSuccess(" + trackInfo + ")");
    }

    @Override
    public void onChangedFail(TrackInfo trackInfo, ErrorInfo errorInfo) {
        Log.d(TAG, "onChangedFail(" + trackInfo + "，" + errorInfo + ")");
    }

    @Override
    public void onSubtitleShow(long l, String s) {
        Log.d(TAG, "onSubtitleShow(l = " + l + "，s = " + s + ")");
    }

    @Override
    public void onSubtitleHide(long l) {
        Log.d(TAG, "onSubtitleHide(l = " + l + ")");
    }

    @Override
    public void onSnapShot(Bitmap bitmap, int i, int j) {
        Log.d(TAG, "onSnapShot(i = " + i + "，j = " + j + ")");
    }

    @Override
    public void onVideoRendered(long timeMs, long pts) {
        Log.d(TAG, "onVideoRendered(timeMs = " + timeMs + "，pts = " + pts + ")");
    }

    public interface IPlayerCallbackListener {
        void onStateChanged(int state);
    }

}
