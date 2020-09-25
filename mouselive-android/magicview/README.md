# OrangeFilter SDK

[TOC]

```
OrangeFilter SDK is a video magic effects library that contains video beautification, dynamic filters, 2D and 3D. With content creation as the core, it supports cross-platform interaction through data driving, providing AR interactive entertainment solutions, and integration is fast and simple.
```

-------------------------------------------------

## 1.User Authentication
Please contact the Jocloud technical support and offer the project AppID（android:applicationId/ios:bundle Id）for authentication. After approval, you will receive the serial No.

> **Notes** 
>
> - For authentication details, see createContext  method in OrangeHelper class .
> -  Authentication type: face detection, background segmentation, and gesture detection. You can enable specified types or enable all.
> - Authentication includes SDK authentication (determines whether the SDK is available） and effect package authentication (determines whether the effect package can be loaded).
> -  For more effect packages, please contact the Jocloud technical support.

## 2.**Configure Project**

### 1) **Import OrangeFilter SDK**

Copy the Magic SDK library files to the libs directory, and add library dependencies to the build.gradle file of the app module：

```
dependencies {
    implementation fileTree(dir: 'libs', include: ['*.aar'])
}
```

**Notes:** SDK only support to depend by aar.


### 2) Declare OpenGL ES Feature & Permission

Add Declaration Code in AndroidManifest.xml file:

```
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.INTERNET"/>

<uses-feature android:glEsVersion="0x00020000" android:required="true" />
```

### 3) Add Model Data Resource File
#### Copy the file in Demo “../src/main/assets/models/venus_models” directory to the assets directory of the project.

> face - Face Model
>
> gesture - Gesture Data
>
> segment - Segmentation Data

## 3.Magic Data Loading

MouseLive Demo magic data loading is implemented by MagicDataManager singleton class

**Notes：**If the special effect package uses local resource files during customer integration, please ensure that the storage path and the special effect package file name are consistent with the current ones.

### 1) Magic Json Data Loading

please see  magicdata.json file

```
/**
 * The maigc data loading, for reference only, please overwrit it
 *
 * @param context application context
 */
public void loadEffectTabList(final Context context) 
```

After the magic json data is loaded successfully, the OnEffectLoadedEvent event is sent through EventBus to notify the loading status for UI refresh, and the maigc default effect package is downloaded

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

### 2) Magic Default Effect Package Download

```
/**
 * Load the default magic effects package, please adjust according to the project requirements,    
 * please refer to the file header class notes for the magic effect package name and index number
 *
 * @param context application context
 */
private void loadDefaultEffectData(final Context context)
```

Please adjust the following code according to actual project requirements

```
for (int i = 0; i < magicEffectList.size(); i++) {
	if (MagicConfig.MagicTypeEnum.MAGIC_TYPE_SKIN.getType().equals(groupType)
        && ((0 == i/*whiten*/) || (1 == i/*smoothen*/))) {
		// Load basic beauty magic effects package by default
		loadEffectData(context, groupType, magicEffectList.get(i));
    }
    if (MagicConfig.MagicTypeEnum.MAGIC_TYPE_FACE.getType().equals(groupType)
        && ((0 == i/*basic face*/) || (2 == i/*small face*/) || (6 == i/*big eye*/)
        || (9 == i/*thin nose*/)))                 
        // Load face magic effects package by default
        loadEffectData(context, groupType, magicEffectList.get(i));
	}
}
```

During the download of the magic effects package, the OnEffectDownloadedEvent event is sent through EventBus to notify the download status for UI refresh

```
/**
 * Download magic effects package
 * a magic effects package may contain a number of maigc effects, it is necessary to distinguish 
 * between the scenes that the maigc effects package has been downloaded or is being downloaded
 *
 * @param context application context
 * @param groupType magic effects type
 * @param magicEffect magic data object
 */
public void loadEffectData(final Context context, final String groupType, final MagicEffect magicEffect)
```

### 3) Get Magic Effects List

Get a list of magic effects for UI display, please refer to  initData method in the type corresponding Magic***Fragment class

```
/**
 * Obtain given group type magic effects list
 * please call after loadEffectTabList method
 *
 * @param groupType magice effects type
 * @return give group type magic effects list
 */
public List<MagicEffect> getMagicEffectListByGroupType(final String groupType)
```

For the definition of groupType, please refer to MagicConfig internal enumeration class MagicTypeEnum, which can be obtained by getType() method

```
/**
 * Configure the paging type enumeration class of the mgaic interface
 */
public enum MagicTypeEnum {
	MAGIC_TYPE_SKIN(0, "Skin"),       // Skin
	MAGIC_TYPE_FILTER(1, "Filter"),   // Filter
	MAGIC_TYPE_FACE(2, "Face"),       // Face
	MAGIC_TYPE_STICKER(3, "Sticker"), // Sticker
	MAGIC_TYPE_GESTURE(4, "Gesture"); // Gesture

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

## 4.Magic Effect Integration

MouseLive Demo uses ThunderBolt and OrangeFilter to achieve magic effect, implemented by MagicEffectManager singleton

**Notes：**please copy the relevant code directly to the project for customer integration, 

### 1) Initialization

```
/**
 * Initialized when the application starts call onCreate method
 *
 * @param context       application context
 * @param thunderEngine thunder object
 * @param serialNumber  authentication string (the business party needs to support internal application 
 *                      through technical support)
 */
public void init(Context context, ThunderEngine thunderEngine, String serialNumber)
```

### 2) Register

```
/**
 * The registration method needs to be called immediately below startVideoPreview method
 *
 * @param context application context
 */
public void register(Context context)
```

### 3) UnRegister

```
/**
 * The unregister method needs to be called after stopVideoPreview method
 */
public void unRegister()
```

### 4) Authentication status

```
/**
 * Get the authentication status of the OrangeFilter SDK
 *
 * @return true - success，false - failure
 */
public boolean islicenseValid()
```

### 5）Enable Default Magic Effects

Please refer to the initOrangeFilter method in MagicGPUProcesser class, please adjust the relevant code according to actual project requirements

```
// advanced face enabled by default in MouseLive Demo: small face - 40, big eyes - 40, thin nose -3
OrangeHelper.enableEffect(OrangeHelper.EffectType.ET_SeniorBeautyType, true);
OrangeHelper.setEffectParam(OrangeHelper.EffectParamType.EP_SeniorTypeSmallFaceIntensity,MagicConfig.DEFAULT_SMALL_FACE_VALUE);
OrangeHelper.setEffectParam(OrangeHelper.EffectParamType.EP_SeniorTypeBigSmallEyeIntensity,MagicConfig.DEFAULT_BIG_EYE_VALUE);
OrangeHelper.setEffectParam(OrangeHelper.EffectParamType.EP_SeniorTypeThinNoseIntensity,MagicConfig.DEFAULT_THIN_NOSE_VALUE);
OrangeHelper.enableEffect(OrangeHelper.EffectType.ET_SeniorBeautyType, false);

// basic beauty enabled by default in MouseLive Demo：whiten - 70，smoothen - 70，
OrangeHelper.enableEffect(OrangeHelper.EffectType.ET_BasicBeauty, true);
OrangeHelper.setEffectParam(OrangeHelper.EffectParamType.EP_BasicBeautyIntensity,MagicConfig.DEFAULT_WHITEN_VALUE);
OrangeHelper.setEffectParam(OrangeHelper.EffectParamType.EP_BasicBeautyOpacity,MagicConfig.DEFAULT_SMOOTHEN_VALUE);

// basic face enabled by default in MouseLive Demo：basic face - 40
OrangeHelper.enableEffect(OrangeHelper.EffectType.ET_BasicBeautyType, true);
OrangeHelper.setEffectParam(OrangeHelper.EffectParamType.EP_BasicTypeIntensity,MagicConfig.DEFAULT_BASIC_FACE_VALUE);
```

## 5.OrangeFilter SDK API

please see OrangeHelper class

### 1）Enable Basic Beauty/Filter/Face Effects

```
/**
 * Open or close given type effects
 *
 * @param et effects type
 * @param bEnable true - Open，false - Close
 */
public static boolean enableEffect(EffectType et, boolean bEnable)
```

### 2）Enable Sticker Effects

```
/**
 * Open or close given type effects
 *
 * @param path magic effects package absolute path
 * @param bEnable true - Open，false - Close
 */
public static boolean enableSticker(String path, boolean bEnable)
```

### 3）Enable Gesture Effects

```
/**
 * Open or close give type effects
 *
 * @param path magic effects package absolute path
 * @param bEnable true - Open，false - Close
 */
public static boolean enableGesture(String path, boolean bEnable)
```

### 4）Get And Set Effects Parameters

```
/**
 * Get give type effects parameters
 *
 * @param ep parameter type
 * @param effectPram parameter object
 */
public static boolean getEffectParamDetail(EffectParamType ep, EffectParam effectPram)
```

for example

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

