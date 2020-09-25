package com.sclouds.magic.manager;

import android.content.Context;

import com.sclouds.basedroid.LogUtils;
import com.sclouds.magic.helper.OrangeHelper;
import com.sclouds.magic.processer.MagicAccelerometerProcesser;
import com.sclouds.magic.processer.MagicGPUProcesser;
import com.thunder.livesdk.ThunderEngine;

/**
 * 美颜特效接口管理类
 */
public class MagicEffectManager {

    private static final String TAG = "MagicEffectManager";

    private static MagicEffectManager sMagicEffectManager = null;

    private MagicAccelerometerProcesser mMagicAccelerometerProcesser = null;

    private ThunderEngine mThunderEngine = null;

    private String mSerialNumber = null;

    private MagicGPUProcesser mMagicGPUProcesser = null;
    private MagicGPUProcesser.VideoCaptureWrapper mVideoCaptureWrapper = null;

    private boolean isRegistered = false;

    public static MagicEffectManager getInstance() {
        if (null == sMagicEffectManager) {
            synchronized (MagicEffectManager.class) {
                if (null == sMagicEffectManager) {
                    sMagicEffectManager = new MagicEffectManager();
                }
            }
        }
        return sMagicEffectManager;
    }

    /**
     * 单例模式私有构造器
     */
    private MagicEffectManager() {

    }

    /**
     * 应用启动 Application onCreate 时初始化
     *
     * @param context       应用上下文
     * @param thunderEngine thunder 对象
     * @param serialNumber  鉴权串（需要业务方通过技术支持内部申请）
     */
    public void init(Context context, ThunderEngine thunderEngine, String serialNumber) {
        LogUtils.i(TAG, "init");
        this.mMagicAccelerometerProcesser = new MagicAccelerometerProcesser(context);
        this.mThunderEngine = thunderEngine;
        this.mSerialNumber = serialNumber;
    }

    /**
     * 注册函数需要在 startVideoPreview 紧挨着下面调用
     *
     * @param context 应用上下文
     */
    public void register(Context context) {
        if (null == mThunderEngine) {
            LogUtils.i(TAG, "register: thunder engine is null");
            return;
        }
        if (isRegistered) {
            LogUtils.i(TAG, "register: has been registered");
            return;
        }
        LogUtils.i(TAG, "register");
        mMagicAccelerometerProcesser.start();
        mMagicGPUProcesser = new MagicGPUProcesser(context, mSerialNumber);
        mThunderEngine.registerVideoCaptureTextureObserver(mMagicGPUProcesser);

        mVideoCaptureWrapper = mMagicGPUProcesser.new VideoCaptureWrapper();
        mThunderEngine.registerVideoCaptureFrameObserver(mVideoCaptureWrapper);

        isRegistered = true;
    }

    /**
     * 解注册函数需要在 stopVideoPreview 后调用
     */
    public void unRegister() {
        if (null == mThunderEngine) {
            LogUtils.i(TAG, "unRegister: thunder engine is null");
            return;
        }
        if (!isRegistered) {
            LogUtils.i(TAG, "unRegister: has not been registered");
            return;
        }
        LogUtils.i(TAG, "unRegister");
        mThunderEngine.registerVideoCaptureTextureObserver(null);
        mThunderEngine.registerVideoCaptureFrameObserver(null);
        mMagicAccelerometerProcesser.stop();
        mMagicGPUProcesser = null;
        mVideoCaptureWrapper = null;
        isRegistered = false;
    }

    /**
     * 获取美颜 SDK 鉴权状态
     *
     * @return true - 成功，false - 失败
     */
    public boolean islicenseValid() {
        return isRegistered && OrangeHelper.isContextValid();
    }

}
