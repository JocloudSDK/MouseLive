# OrangeFilter SDK

[TOC]

```
OrangeFilter SDK 是一款集视频美颜、动态滤镜、2D、3D 于一体的视频特效库，以内容创作为核心，通过数据驱动支持跨平台互动，提供 AR 互动娱乐解决方案，集成快速简单。
```

-------------------------------------------------

## 1.用户鉴权及说明

联系聚联云技术支持，并提供项目 AppID（android:applicationId/ios:bundle Id）以申请鉴权序列号，审核通过后将显示序列号。
> **注意** 
> - 用户鉴权详情请参考 OrangeHelper 类 createContext 函数。
> - 授权类型包括人脸检测、背景分割、手势检测，可启用指定类型或全部启用。
> - 美颜、滤镜与人脸无关，贴纸、整形和人脸有关。
> - 鉴权分为 SDK 鉴权（决定 OrangeFilter SDK是否可用）和特效包鉴权（决定特效能是否能被加载）。
> - 如需获取特效包，请联系聚联云技术支持。

## 2.项目配置

### 1) 添加美颜 SDK 库

将美颜 SDK 库文件拷贝到 libs 目录下，在 app module 的 build.gradle 文件中加入库依赖：

```
dependencies {
    implementation fileTree(dir: 'libs', include: ['*.aar'])
}
```

**注意：**目前美颜库已 aar 方式导入。


### 2) 声明 OpenGL ES 特性及权限

在 AndroidManifest.xml 中加入响应权限:

```
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.INTERNET"/>

<uses-feature android:glEsVersion="0x00020000" android:required="true" />
```

### 3) 添加模型数据资源文件

#### 将示例代码中../src/main/assets/models/venus_models拷贝到项目工程的assets目录下
> face - 人脸模型数据 
>
> gesture - 手势数据
>
> segment - 背景分割数据

## 3.美颜数据加载

泛娱乐 Demo  美颜数据加载由 MagicDataManager 单例实现

**注意：**客户集成时如果特效包使用本地资源文件，请确保存储路径和特效包文件名与当前一致即可

### 1) 美颜配置 JSON 数据加载

请查看 magicdata.json 文件

```
/**
 * 美颜数据加载，仅供参考，请客户根据自己的加载模块复写
 *
 * @param context 应用上下文
 */
public void loadEffectTabList(final Context context) 
```
美颜 JSON 数据加载成功后，通过 EventBus 发送 OnEffectLoadedEvent 事件通知加载状态 UI 刷新，并下载美颜默认效果特效包

```
@Override
public void handleSuccess(@NonNull List<MagicEffectTab>magicEffectTabList) {
	LogUtils.d(TAG, "getEffectTabList: effect tab list load success");
	synchronized (mMagicEffectTabListLockObject) {
		mMagicEffectTabList.addAll(magicEffectTabList);
	}
	EventBus.getDefault().post(new OnEffectLoadedEvent(true));
	loadDefaultEffectData(context);
}
```

### 2) 美颜默认效果特效包下载

```
/**
 * 加载默认美颜特效包，请根据项目要求进行调整，特效包名称和索引号请参见文件头类注释
 *
 * @param context 应用上下文
 */
private void loadDefaultEffectData(final Context context)
```

请根据实际项目需求调整以下代码

```
for (int i = 0; i < magicEffectList.size(); i++) {
	if (MagicConfig.MagicTypeEnum.MAGIC_TYPE_SKIN.getType().equals(groupType)
        && ((0 == i/*美白*/) || (1 == i/*磨皮*/))) {
		// 默认加载基础美颜特效包
		loadEffectData(context, groupType, magicEffectList.get(i));
    }
    if (MagicConfig.MagicTypeEnum.MAGIC_TYPE_FACE.getType().equals(groupType)
        && ((0 == i/*基础整形*/) || (2 == i/*小脸*/) || (6 == i/*大眼*/) || (9 == i/*瘦鼻*/)))                 
        // 默认加载五官整形特效包
        loadEffectData(context, groupType, magicEffectList.get(i));
	}
}
```

特效包下载过程中通过 EventBus 发送 OnEffectDownloadedEvent 事件通知下载状态 UI 刷新

```
/**
 * 下载美颜数据特效包
 * 一个特效包可能包含若干过美颜特效，需要区分判断特效包已下载或正在下载中场景
 *
 * @param context 应用上下文
 * @param groupType 特效类型
 * @param magicEffect 特效数据对象
 */
public void loadEffectData(final Context context, final String groupType, final MagicEffect magicEffect)
```

### 3) 获取美颜效果列表

获取美颜效果列表用于 UI 展示，请参考类型对应 Magic***Fragment 类 initData 方法

```
/**
 * 获取给定类型美颜效果列表
 * 请在 loadEffectTabList 后调用
 *
 * @param groupType 美颜类型
 * @return 给定类型美颜效果列表
 */
public List<MagicEffect> getMagicEffectListByGroupType(final String groupType)
```

groupType 定义请参见 MagicConfig 内部枚举类 MagicTypeEnum，通过 getType() 方法获取

```
/**
 * 配置美颜界面分页类型枚举类
 */
public enum MagicTypeEnum {
	MAGIC_TYPE_SKIN(0, "Skin"),       // 美肤
	MAGIC_TYPE_FILTER(1, "Filter"),   // 滤镜
	MAGIC_TYPE_FACE(2, "Face"),       // 整形
	MAGIC_TYPE_STICKER(3, "Sticker"), // 贴纸
	MAGIC_TYPE_GESTURE(4, "Gesture"); // 手势

	private int mValue;
	private String mType;

	MagicTypeEnum(int value, String type) {
	this.mValue = value;
	this.mType = type;
	}

	public int getValue() {
		return mValue;
	}

	public String getType() {
		return mType;
	}
}
```

## 4.美颜效果集成

泛娱乐 Demo 使用 ThunderBolt + OrangeFilter 实现美颜效果，由 MagicEffectManager 单例实现

**注意：**客户集成时请直接将相关代码拷贝到工程即可

### 1) 初始化

```
/**
 * 应用启动 Application onCreate 时初始化
 *
 * @param context       应用上下文
 * @param thunderEngine thunder 对象
 * @param serialNumber  鉴权串（需要业务方通过技术支持内部申请）
 */
public void init(Context context, ThunderEngine thunderEngine, String serialNumber)
```

### 2) 注册

```
/**
 * 注册函数需要在 startVideoPreview 紧挨着下面调用
 *
 * @param context 应用上下文
 */
public void register(Context context)
```

### 3) 解注册

```
/**
 * 解注册函数需要在 stopVideoPreview 后调用
 */
public void unRegister()
```

### 4) 鉴权状态

```
/**
 * 获取美颜 SDK 鉴权状态
 *
 * @return true - 成功，false - 失败
 */
public boolean islicenseValid()
```

### 5）开启美颜默认效果

请参见 MagicGPUProcesser 类 initOrangeFilter 方法，请根据实际项目需求调整相关代码

```
// 基础整形和高级整形互斥，高级美颜默认值：小脸 - 40，大眼 - 40，瘦鼻 - -3
OrangeHelper.enableEffect(OrangeHelper.EffectType.ET_SeniorBeautyType, true);
OrangeHelper.setEffectParam(OrangeHelper.EffectParamType.EP_SeniorTypeSmallFaceIntensity,MagicConfig.DEFAULT_SMALL_FACE_VALUE);
OrangeHelper.setEffectParam(OrangeHelper.EffectParamType.EP_SeniorTypeBigSmallEyeIntensity,MagicConfig.DEFAULT_BIG_EYE_VALUE);
OrangeHelper.setEffectParam(OrangeHelper.EffectParamType.EP_SeniorTypeThinNoseIntensity,MagicConfig.DEFAULT_THIN_NOSE_VALUE);
OrangeHelper.enableEffect(OrangeHelper.EffectType.ET_SeniorBeautyType, false);

// 泛娱乐 Demo 默认开启基础美颜，默认值：美白 - 70，磨皮 - 70，
OrangeHelper.enableEffect(OrangeHelper.EffectType.ET_BasicBeauty, true);
OrangeHelper.setEffectParam(OrangeHelper.EffectParamType.EP_BasicBeautyIntensity,MagicConfig.DEFAULT_WHITEN_VALUE);
OrangeHelper.setEffectParam(OrangeHelper.EffectParamType.EP_BasicBeautyOpacity,MagicConfig.DEFAULT_SMOOTHEN_VALUE);

// 泛娱乐 Demo 默认开启基础整形，默认值：基础整形 - 40
OrangeHelper.enableEffect(OrangeHelper.EffectType.ET_BasicBeautyType, true);
OrangeHelper.setEffectParam(OrangeHelper.EffectParamType.EP_BasicTypeIntensity,MagicConfig.DEFAULT_BASIC_FACE_VALUE);
```

## 5.OrangeFilter SDK API

请参见 OrangeHelper 类

### 1）开启或关闭基础美颜、整形、滤镜特效

```
/**
 * 开启或关闭指定类型特效
 *
 * @param et 美颜类型
 * @param bEnable true - 开启，false - 关闭
 */
public static boolean enableEffect(EffectType et, boolean bEnable)
```

### 2）开启或关闭贴纸特效

```
/**
 * 开启或关闭指定类型特效
 *
 * @param path 美颜特效包存储绝对路径
 * @param bEnable true - 开启，false - 关闭
 */
public static boolean enableSticker(String path, boolean bEnable)
```

### 3）开启或关闭手势特效

```
/**
 * 开启或关闭指定类型特效
 *
 * @param path 美颜特效包存储绝对路径
 * @param bEnable true - 开启，false - 关闭
 */
public static boolean enableGesture(String path, boolean bEnable)
```

### 4）获取及设置特效参数

```
/**
 * 获取指定特效参数对象
 *
 * @param ep 参数类型
 * @param effectPram 参数对象
 */
public static boolean getEffectParamDetail(EffectParamType ep, EffectParam effectPram)
```

使用范例如下

```
OrangeHelper.EffectParam effectPram = new OrangeHelper.EffectParam();
if (OrangeHelper.getEffectParamDetail(OrangeHelper.EffectParamType.EP_BasicTypeIntensity, effectPram)) {
	boolean result = OrangeHelper.setEffectParam(OrangeHelper.EffectParamType.EP_BasicTypeIntensity, 
		MagicConfig.DEFAULT_BASIC_FACE_VALUE);
	int progress = 100 * (MagicConfig.DEFAULT_BASIC_FACE_VALUE - effectPram.minVal) / (effectPram.maxVal - 	
		effectPram.minVal);
    mDataBinding.faceSeekBar.setProgress(progress);
}
```

