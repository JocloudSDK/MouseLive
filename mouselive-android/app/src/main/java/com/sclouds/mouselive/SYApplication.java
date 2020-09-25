package com.sclouds.mouselive;

import android.annotation.SuppressLint;
import android.app.Application;
import android.os.StrictMode;
import android.os.StrictMode.VmPolicy;

import com.sclouds.basedroid.Tools;
import com.sclouds.basedroid.net.NetworkMgr;
import com.sclouds.datasource.Constants;
import com.sclouds.datasource.database.DatabaseSvc;
import com.sclouds.datasource.flyservice.http.FlyHttpSvc;
import com.sclouds.datasource.thunder.ThunderSvc;
import com.sclouds.magic.manager.MagicEffectManager;
import com.sclouds.mouselive.utils.FileUtil;
import com.sclouds.mouselive.views.SettingFragment;
import com.yy.spidercrab.SCLog;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;

import androidx.multidex.MultiDex;
import tv.athena.core.axis.Axis;
import tv.athena.crash.api.ICrashService;
import tv.athena.klog.api.ILogService;
import tv.athena.klog.api.LogLevel;
import tv.athena.util.FP;
import tv.athena.util.ProcessorUtils;
import tv.athena.util.RuntimeInfo;

/**
 * @author xipeitao
 * @since : 2020-03-04 14:13
 */
public class SYApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        closeAndroidPDialog();
        // initStrictMode();
        MultiDex.install(this);
        initConfig();
        initPrivate();

        initSDK();
        initMagicEffect();
    }

    private void initSDK() {
        SCLog.init(this);
        SCLog.enableConsoleLogger(true);
        // 初始化 SDK 日志存储目录
        ThunderSvc.setLogFilePath(FileUtil.getLog(this));
        SCLog.setDefaultFilePath(FileUtil.getLog(this));
        //初始化Thunder
        ThunderSvc.getInstance().create(this, Consts.APPID, Consts.APP_SECRET,
                SettingFragment.isChina(this), 0);
    }

    /**
     * 初始化 OrangeFilter sdk, serialNumber:of sdk鉴权序列号
     */
    private void initMagicEffect() {
        MagicEffectManager.getInstance().init(this, ThunderSvc.getInstance().getEngine(),
                Consts.OF_SERIAL_NAMBER);
    }

    /**
     * 关闭 Android P 后反射直接调用源码弹出提示窗
     */
    private void closeAndroidPDialog() {
        try {
            @SuppressLint("PrivateApi") Class aClass =
                    Class.forName("android.content.pm.PackageParser$Package");
            Constructor declaredConstructor = aClass.getDeclaredConstructor(String.class);
            declaredConstructor.setAccessible(true);
        } catch (Exception e) {
            e.printStackTrace();
        }
        try {
            @SuppressLint("PrivateApi") Class cls = Class.forName("android.app.ActivityThread");
            @SuppressLint("DiscouragedPrivateApi") Method declaredMethod =
                    cls.getDeclaredMethod("currentActivityThread");
            declaredMethod.setAccessible(true);
            Object activityThread = declaredMethod.invoke(null);
            Field mHiddenApiWarningShown = cls.getDeclaredField("mHiddenApiWarningShown");
            mHiddenApiWarningShown.setAccessible(true);
            mHiddenApiWarningShown.setBoolean(activityThread, true);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * DEBUG 环境下启用 Android 严格模式
     */
    private void initStrictMode() {
        if (BuildConfig.DEBUG) {
            StrictMode.setThreadPolicy(new StrictMode.ThreadPolicy.Builder()
                    .detectAll()
                    .penaltyLog()
                    .permitNetwork()
                    .build());
            VmPolicy.Builder policy = new VmPolicy.Builder()
                    .detectAll()
                    .penaltyLog();
            // try {
            //     permitUntaggedSockets(policy);
            // } catch (InvocationTargetException e) {
            //     e.printStackTrace();
            // } finally {
            //     StrictMode.setVmPolicy(policy.build());
            // }
        }
    }

    // private void permitUntaggedSockets(VmPolicy.Builder obj)
    //         throws IllegalArgumentException, InvocationTargetException {
    //     try {
    //         Class<?> clz = Class.forName("android.os.StrictMode.VmPolicy.Builder");
    //         Method m = clz.getDeclaredMethod("permitUntaggedSockets", null);
    //         m.invoke(obj);
    //     } catch (Throwable t) {
    //         throw new InvocationTargetException(t);
    //     }
    // }

    /**
     * 初始化后台服务、数据及网络配置，非业务开发无需关注
     */
    private void initConfig() {
        FlyHttpSvc.getInstance().setAppId(Consts.APPID);
        DatabaseSvc.init(this);
        Tools.initCtx(this);
        NetworkMgr.getInstance().init(this);
    }

    /**
     * 公司内部代码，第三方无需关注
     */
    private void initPrivate() {
        // 初始化 Runtime 信息
        String processName = ProcessorUtils.INSTANCE.getMyProcessName();
        RuntimeInfo.INSTANCE.appContext(this)
                .packageName(this.getPackageName())
                .processName((null != processName) ? processName : "")
                .isDebuggable(true)
                .isMainProcess(FP.eq(RuntimeInfo.sPackageName, RuntimeInfo.sProcessName));

        // 初始化 KLog 服务
        ILogService logService = Axis.Companion.getService(ILogService.class);
        if (null != logService) {
            logService.config()
                    .logCacheMaxSiz(100 * 1024 * 1024)
                    .singleLogMaxSize(4 * 1024 * 1024)
                    .logLevel(LogLevel.INSTANCE.getLEVEL_VERBOSE())
                    .processTag(Constants.FEEDBACK_CRASHLOGID)
                    .logPath(FileUtil.getLog(this))
                    .apply();
        }

        // 初始化 Crash 服务
        ICrashService crashService = Axis.Companion.getService(ICrashService.class);
        if (null != crashService) {
            crashService.start(Constants.FEEDBACK_CRASHLOGID, "");
        }
    }

}
