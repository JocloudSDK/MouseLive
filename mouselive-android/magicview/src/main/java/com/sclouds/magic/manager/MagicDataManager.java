package com.sclouds.magic.manager;

import android.content.Context;
import android.util.Log;
import android.widget.Toast;
import androidx.annotation.NonNull;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.greenrobot.eventbus.EventBus;

import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.functions.Function;

import com.sclouds.basedroid.LogUtils;
import com.sclouds.datasource.bean.EffectTab;
import com.sclouds.datasource.flyservice.http.FlyHttpSvc;
import com.sclouds.datasource.flyservice.http.network.BaseObserver;
import com.sclouds.datasource.flyservice.http.network.CustomThrowable;
import com.sclouds.magic.R;
import com.sclouds.magic.bean.Effect;
import com.sclouds.magic.bean.MagicEffect;
import com.sclouds.magic.bean.MagicEffectTab;
import com.sclouds.magic.config.MagicConfig;
import com.sclouds.magic.eventbus.OnEffectDownloadedEvent;
import com.sclouds.magic.eventbus.OnEffectLoadedEvent;
import com.sclouds.magic.observer.FileObserver;

/**
 * 美颜特效包数据加载管理类
 *
 * Skin - 基础美颜：索引号  0    1
 *                 名称   美白  磨皮
 * Face - 基础整形：索引号 0
 *                  名称  一键整形
 *      - 高级整形： 索引号 1    2   3     4    5   6    7   8    9   10   11    12   13  14
 *                  名称  窄脸 小脸 瘦颧骨 额高 额宽 大眼 眼距 眼角 瘦鼻 长鼻 窄鼻梁 小嘴 嘴位 下巴
 * Filter - 滤镜：假日、清晰、暖阳、清新、粉嫩
 * Sticker - YYbear、阿拉蕾、黑猫耳朵、蓓蕾眼镜、恶魔口罩、求关注、墨镜
 * Gesture - 666、OK、onehandheart、palm、thumbsup、twohandheart、yeah
 *
 * @version 1.4.2
 */
public class MagicDataManager {

    private static final String TAG = "MagicDataManager";

    private static final Object mMagicEffectTabListLockObject = new Object();
    private List<MagicEffectTab> mMagicEffectTabList = new ArrayList<>();

    private static final Object mDownloadingPathLockObject = new Object();
    private List<String> mDownloadingPath = new ArrayList<>();

    private static MagicDataManager mMagicDataManager = null;

    private MagicDataManager() {

    }

    /**
     * 获取单例实例对象，采用双检测法
     *
     * @return 单例实例对象
     */
    public static MagicDataManager getInstance() {
        if (mMagicDataManager == null) {
            synchronized (MagicDataManager.class) {
                if (mMagicDataManager == null) {
                    mMagicDataManager = new MagicDataManager();
                }
            }
        }
        return mMagicDataManager;
    }

    /**
     * 美颜数据加载，仅供参考，请客户根据自己的加载模块复写
     *
     * @param context 应用上下文
     */
    public void loadEffectTabList(final Context context) {
        LogUtils.d(TAG, "getEffectTabList");
        synchronized (mMagicEffectTabListLockObject) {
            mMagicEffectTabList.clear();
        }
        FlyHttpSvc.getInstance().getEffectList(MagicConfig.MAGIC_VERSION_TAG).retry(MagicConfig.MAGIC_MAX_HTTP_RETRY_COUNT)
                .observeOn(AndroidSchedulers.mainThread())
                .map(new Function<List<EffectTab>, List<MagicEffectTab>>() {
                    @Override
                    public List<MagicEffectTab> apply(List<EffectTab> effectTabList) {
                        List<MagicEffectTab> list = new ArrayList<>();
                        for (EffectTab tab : effectTabList) {
                            List<MagicEffect> effectList = new ArrayList<>();
                            LogUtils.d(TAG, "getEffectTabList: groupType = " + tab.getGroupType() + ", size = " + tab.getIcons().size());
                            for(com.sclouds.datasource.bean.Effect effect : tab.getIcons()) {
                                String url = effect.getUrl();
                                String urlName = url.substring(url.lastIndexOf(File.separator) + 1);
                                String path = context.getFilesDir().getPath() + MagicConfig.MAGIC_EFFECT_STORAGE_FILE_DIR + urlName;
                                LogUtils.d(TAG, "getEffectTabList: name = " + effect.getName() + ", path = " + path);
                                Effect effect1 = new Effect(effect.getId(), effect.getName(), effect.getMd5(), effect.getThumb(), effect.getUrl(),
                                        effect.getOperationType(), effect.getResourceTypeName(), path);
                                MagicEffect magicEffect = new MagicEffect(effect1);
                                magicEffect.setDownloadStatus( new File(magicEffect.getPath()).exists() ? MagicEffect.DownloadStatus.DOWNLOADED : MagicEffect.DownloadStatus.UNDOWNLOAD);
                                effectList.add(magicEffect);
                            }
                            list.add(new MagicEffectTab(tab.getId(), tab.getGroupType(), effectList));
                        }
                        return list;
                    }
                })
                .subscribe(new BaseObserver<List<MagicEffectTab>>(context) {
                    @Override
                    public void handleSuccess(@NonNull List<MagicEffectTab> magicEffectTabList) {
                        LogUtils.d(TAG, "getEffectTabList: effect tab list load success");
                        synchronized (mMagicEffectTabListLockObject) {
                            mMagicEffectTabList.addAll(magicEffectTabList);
                        }
                        EventBus.getDefault().post(new OnEffectLoadedEvent(true));
                        loadDefaultEffectData(context);
                    }

                    public void handleError(CustomThrowable e) {
                        LogUtils.d(TAG, "getEffectTabList: effect tab list load failure");
                        super.handleError(e);
                        mMagicEffectTabList.clear();
                        Toast.makeText(context, R.string.magic_data_loading_failure, Toast.LENGTH_LONG).show();
                        EventBus.getDefault().post(new OnEffectLoadedEvent(false));
                    }
                });
    }

    /**
     * 加载默认美颜特效包，请根据项目要求进行调整，特效包名称和索引号请参见文件头类注释
     *
     * @param context 应用上下文
     */
    private void loadDefaultEffectData(final Context context) {
        synchronized (mMagicEffectTabListLockObject) {
            for (MagicEffectTab magicEffectTab : mMagicEffectTabList) {
                String groupType = magicEffectTab.getGroupType();
                LogUtils.d(TAG, "loadDefaultMagicEffectData: groupType = " + groupType);
                List<MagicEffect> magicEffectList = magicEffectTab.getMagicEffectList();
                if ((null == magicEffectList) || (0 == magicEffectList.size())) {
                    LogUtils.d(TAG, "loadDefaultMagicEffectData: list is null or size is zero");
                    return;
                }
                for (int i = 0; i < magicEffectList.size(); i++) {
                    if (MagicConfig.MagicTypeEnum.MAGIC_TYPE_SKIN.getType().equals(groupType)
                            && ((0 == i/*美白*/) || (1 == i/*磨皮*/))) {
                        // 默认加载基础美颜特效包
                        loadEffectData(context, groupType, magicEffectList.get(i));
                    }
                    if (MagicConfig.MagicTypeEnum.MAGIC_TYPE_FACE.getType().equals(groupType)
                            && ((0 == i/*基础整形*/) || (2 == i/*小脸*/) || (6 == i/*大眼*/) || (9 == i/*瘦鼻*/))) {
                        // 默认加载五官整形特效包
                        loadEffectData(context, groupType, magicEffectList.get(i));
                    }
                }
            }
        }
    }

    /**
     * 下载美颜数据特效包
     * 一个特效包可能包含若干过美颜特效，需要区分判断特效包已下载或正在下载中场景
     *
     * @param context 应用上下文
     * @param groupType 特效类型
     * @param magicEffect 特效数据对象
     */
    public void loadEffectData(final Context context, final String groupType, final MagicEffect magicEffect) {
        LogUtils.d(TAG, "downloadEffectData: name = " + magicEffect.getName() + ", path = " + magicEffect.getPath());
        if (new File(magicEffect.getPath()).exists()) {
            // 特效包已下载完成
            Log.d(TAG, "downloadEffectData: file has been downloaded");
            magicEffect.setDownloadStatus(MagicEffect.DownloadStatus.DOWNLOADED);
            EventBus.getDefault().post(new OnEffectDownloadedEvent(magicEffect, groupType));
            return;
        }

        synchronized (mDownloadingPathLockObject) {
            if (mDownloadingPath.contains(magicEffect.getPath())) {
                // 特效包已在下载队列中
                LogUtils.d(TAG, "downloadEffectData: file is downloading");
                return;
            } else {
                mDownloadingPath.add(magicEffect.getPath());
            }
        }

        magicEffect.setDownloadStatus(MagicEffect.DownloadStatus.DOWNLOADING);
        EventBus.getDefault().post(new OnEffectDownloadedEvent(magicEffect, groupType));
        FlyHttpSvc.getInstance().download(magicEffect.getUrl()).retry(MagicConfig.MAGIC_MAX_HTTP_RETRY_COUNT)
                .subscribe(new FileObserver(context, new File(magicEffect.getPath())) {
                    @Override
                    public void onError(Throwable e) {
                        LogUtils.e(TAG, "downloadEffectData: " + magicEffect.getName() + " download failure");
                        synchronized (mDownloadingPathLockObject) {
                            mDownloadingPath.remove(magicEffect.getPath());
                        }
                        magicEffect.setDownloadStatus(MagicEffect.DownloadStatus.UNDOWNLOAD);
                        EventBus.getDefault().post(new OnEffectDownloadedEvent(magicEffect, groupType));
                    }

                    @Override
                    public void onComplete() {
                        LogUtils.d(TAG, "downloadEffectData: " + magicEffect.getName() + " download success for " + groupType);
                        synchronized (mDownloadingPathLockObject) {
                            mDownloadingPath.remove(magicEffect.getPath());
                        }
                        magicEffect.setDownloadStatus(MagicEffect.DownloadStatus.DOWNLOADED);
                        EventBus.getDefault().post(new OnEffectDownloadedEvent(magicEffect, groupType));
                    }
                });
    }

    /**
     * 清除美颜数据
     */
    public void clearEffectTabList() {
        synchronized (mMagicEffectTabListLockObject) {
            LogUtils.d(TAG, "clearEffectTabList");
            mMagicEffectTabList.clear();
        }
    }

    /**
     * 视频 OpenGL 渲染线程初始化回调设置默认美颜效果时设置默认选中状态
     */
    public void setDefaultSelectedStatus() {
        synchronized (mMagicEffectTabListLockObject) {
            for (MagicEffectTab magicEffectTab : mMagicEffectTabList) {
                String groupType = magicEffectTab.getGroupType();
                LogUtils.d(TAG, "setDefaultSelectedStatus: groupType = " + groupType);
                for (int i = 0; i < magicEffectTab.getMagicEffectList().size(); i++) {
                    MagicEffect magicEffect = magicEffectTab.getMagicEffectList().get(i);
                    if (MagicConfig.MagicTypeEnum.MAGIC_TYPE_SKIN.getType().equals(groupType)) {
                        // 泛娱乐默认选中基础美颜
                        magicEffect.setSelected(true);
                    }
                    if (MagicConfig.MagicTypeEnum.MAGIC_TYPE_FACE.getType().equals(groupType) && (0 == i)) {
                        // 泛娱乐默认选中基础整形
                        magicEffect.setSelected(true);
                    }
                }
            }
        }
    }

    /**
     * 视频 OpenGL 渲染线程销毁回调释放美颜资源时清除选中状态
     */
    public void clearSelectedStatus() {
        synchronized (mMagicEffectTabListLockObject) {
            LogUtils.d(TAG, "clearSelectedStatus");
            for (MagicEffectTab magicEffectTab : mMagicEffectTabList) {
                for (MagicEffect magicEffect : magicEffectTab.getMagicEffectList()) {
                    magicEffect.setSelected(false);
                }
            }
        }
    }

    /**
     * 获取美颜数据加载状态
     *
     * @return true - 已加载，false - 未加载
     */
    public boolean isLoaded() {
        synchronized (mMagicEffectTabListLockObject) {
            boolean result = (mMagicEffectTabList.size() > 0);
            LogUtils.d(TAG, "isLoaded: result = " + result);
            return result;
        }
    }

    /**
     * 获取给定类型美颜效果列表
     * 请在 loadEffectTabList 后调用
     *
     * @param groupType 美颜类型
     * @return 给定类型美颜效果列表
     */
    public List<MagicEffect> getMagicEffectListByGroupType(final String groupType) {
        synchronized (mMagicEffectTabListLockObject) {
            LogUtils.d(TAG, "getMagicEffectListByGroupType: groupType = " + groupType);
            List<MagicEffect> list = new ArrayList<>();
            for (MagicEffectTab magicEffectTab : mMagicEffectTabList) {
                if (groupType.equals(magicEffectTab.getGroupType())) {
                    list.addAll(magicEffectTab.getMagicEffectList());
                    break;
                }
            }
            return list;
        }
    }

    /**
     * 下载所有美颜效果特效包
     *
     * @param context 应用上下文
     */
    public void loadAllEffectData(final Context context) {
        synchronized (mMagicEffectTabListLockObject) {
            for (MagicEffectTab magicEffectTab : mMagicEffectTabList) {
                String groupType = magicEffectTab.getGroupType();
                LogUtils.d(TAG, "downloadAllEffectData: groupType = " + groupType);
                for (MagicEffect magicEffect : magicEffectTab.getMagicEffectList()) {
                    loadEffectData(context, groupType, magicEffect);
                }
            }
        }
    }

    /**
     * 下载指定类型美颜效果特效包
     *
     * @param context 应用上下文
     * @param groupType 美颜类型
     */
    public void loadEffectDataByGroupType(final Context context, String groupType) {
        synchronized (mMagicEffectTabListLockObject) {
            LogUtils.d(TAG, "downloadEffectDataByGroupType: groupType = " + groupType);
            for (MagicEffectTab magicEffectTab : mMagicEffectTabList) {
                if (!groupType.equals(magicEffectTab.getGroupType())) {
                    continue;
                }
                for (MagicEffect magicEffect : magicEffectTab.getMagicEffectList()) {
                    LogUtils.d(TAG, "downloadEffectDataByGroupType: name = " + magicEffect.getName());
                    loadEffectData(context, magicEffectTab.getGroupType(), magicEffect);
                }
                return;
            }
        }
    }

    /**
     * 下载指定类型且指定名称美颜效果特效包
     *
     * @param context 应用上下文
     * @param groupType 美颜类型
     * @param name 美颜名称
     */
    public void loadEffectDataByGroupTypeAndName(final Context context, String groupType, String name) {
        synchronized (mMagicEffectTabListLockObject) {
            LogUtils.d(TAG, "loadEffectDataByGroupTypeAndName: groupType = " + groupType);
            for (MagicEffectTab magicEffectTab : mMagicEffectTabList) {
                if (!groupType.equals(magicEffectTab.getGroupType())) {
                    continue;
                }
                for (MagicEffect magicEffect : magicEffectTab.getMagicEffectList()) {
                    if (!magicEffect.getName().equals(name)) {
                        continue;
                    }
                    LogUtils.d(TAG, "loadEffectDataByGroupTypeAndName: name = " + magicEffect.getName());
                    loadEffectData(context, magicEffectTab.getGroupType(), magicEffect);
                    return;
                }
            }
        }
    }

}
