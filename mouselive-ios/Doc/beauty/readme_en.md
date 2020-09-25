# OrangeFilter SDK

OrangeFilter SDK, with content creation as the core, provides data-driven cross-platform video effects and AR interactive entertainment solutions, including various video beauty, dynamic filters, 2D/3D graphic effects, etc. The core code is based on C/C++ language and extends functions with Lua script.

* [1.User Authentication](#1.User Authentication)
* [2.Configure Project](#2.Configure Project)
* [3.Implemention](#3.Implemention)
* [4.OrangeFilter SDK API](#4.OrangeFilter SDK API)
* [5.OrangeFilter: Custom effects resources](#OrangeFilter: Custom effects resources)

## 1.User Authentication

Please contact the Jocloud technical support and offer the project AppID（android:applicationId/ios:bundle Id）for authentication. After approval, you will receive the serial No.

> - Note
>
>   - For authenticationdetails, see module [../mouselive-android/effect].
>   -  Authentication type: face detection, background segmentation, and gesture detection. You can enable specified types or enable all.
>   - Authentication includes SDK authentication (determines whether the SDK is available） and effect package authentication (determines whether the effect package can be loaded).
>   -  For more effect packages, please contact the Jocloud technical support.

## 2.Configure Project

### 1）Import OrangeFilter SDK

Drag the  ../MouseLive/Classes/Effects/of_effect.framework in the sample code directly into the project directory

> **Note：**
>
> Added folders : Create groups

### 2）Initialize Face Model Data

- Drag the ../MouseLive/Classes/Effects/venus_models n the sample code directly into the project directory

> **Note:**
>
> Added folders : Create folder references

- Initialize face model data

```Objective-C
NSString *modelPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"venus_models"];
OF_Result result = OF_CreateContext(&_ofContext, [modelPath UTF8String]);  
```

### 3）Initialization and Check Authorization

Initialization when the application starts, sample code：

```Objective-C
// check license
NSString *ofSerialNumber = @"";
NSString *ofLicenseName = @"of_offline_license.license";
NSArray *documentsPathArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
NSString *documentPath = [documentsPathArr lastObject];
NSString *ofLicensePath = [NSString stringWithFormat:@"%@/%@", documentPath, ofLicenseName];
OF_Result checkResult = OF_CheckSerialNumber([ofSerialNumber UTF8String], [ofLicensePath UTF8String]);
if (OF_Result_Success != checkResult) {
    NSLog(@"check sn failed");
}
```

## 3.Implemention

This article uses OrangeFilter SDK to connect to ThunderBolt SDK as an example. The SDK will call three corresponding interfaces in the video lifecycle. For specific implementation, please see the MouseLive/Classes/Live/Controller/BaseLiveViewController class in the Pan Entertainment Demo.

#### 1.renderPixelBufferRef

```Objective-C
/// Rendering method
/// @param pixelBufferRef source CVPixelBufferRef
/// @param context EAGLContext
- (CVPixelBufferRef)renderPixelBufferRef:(CVPixelBufferRef)pixelBufferRef
                                 context:(EAGLContext *)context;

/// Rendering method
/// @param pixelBuffer source pixelBuffer
/// @param context EAGLContext
/// @param srcTextureID source texture id
/// @param dstTextureID target texture id
/// @param textureFormat texture format
/// @param textureTarget target texture
/// @param width width description
/// @param height height description
- (void)renderPixelBufferRef:(CVPixelBufferRef)pixelBuffer
                     context:(EAGLContext *)context
             sourceTextureID:(unsigned int)srcTextureID
        destinationTextureID:(unsigned int)dstTextureID
               textureFormat:(int)textureFormat
               textureTarget:(int)textureTarget
                textureWidth:(int)width
               textureHeight:(int)height;
```

#### 2.setDefaultBeautyEffectPath

Before requesting the special effect data before entering the live broadcast room, you may consider downloading some special effect packages first (currently, the beauty and filters are downloaded first)

> - **Note:**
> - If you do not need to open the default beauty, you can not call this method
> - The parameter path is the file saving path after the special effect package is downloaded, of SDK will set through this path
> - Make sure there are special effect packages under the path, otherwise the default beauty cannot be turned on

```Objective-C
/// Set default beauty path
/// @param effectPath effectPath description
- (void)setDefaultBeautyEffectPath:(NSString *)effectPath;
```

#### 3.loadBeautyEffectWithEffectPath

load beauty effect

> **Note:**
>
> Make sure that the beauty effects package exists, otherwise the beauty effects will not take effect.

```Objective-C
/// load beauty effect
/// @param effectPath effect path
- (void)loadBeautyEffectWithEffectPath:(NSString *)effectPath;
```

#### 4.cancelBeautyEffect

cancel beauty effect

```Objective-C
/// cancel beauty effect
- (void)cancelBeautyEffect;
```

#### 5.getBeautyOptionMinValue

Get the minimum value of the setting parameters of beauty under the current type

```Objective-C
/// Get the minimum effect value
/// @param filterIndex The index of the special effect in the special effect package
/// @param filterName The name of the special effect in the special effect package
- (int)getBeautyOptionMinValue:(int)filterIndex filterName:(NSString *)filterName;
```

#### 6.getBeautyOptionMaxValue

Get the maximum value of the setting parameters of beauty under the current type

```Objective-C
/// Get the maximum effect value
/// @param filterIndex The index of the special effect in the special effect package
/// @param filterName The name of the special effect in the special effect package
- (int)getBeautyOptionMaxValue:(int)filterIndex filterName:(NSString *)filterName;
```

#### 7.getBeautyOptionValue

Get the default value of the setting parameters of beauty under the current type

```Objective-C
/// Get the default effect value
/// @param filterIndex The index of the special effect in the special effect package
/// @param filterName The name of the special effect in the special effect package
- (int)getBeautyOptionValue:(int)filterIndex filterName:(NSString *)filterName;
```

#### 8.setBeautyOptionValue

Adjust the degree of beauty and plastic surgery

> **Note:**
>
> Make sure you have loaded the beauty effects package, otherwise it will not take effect.

```Objective-C
/// Set the effect intensity value
/// @param filterIndex The index of the special effect in the special effect package
/// @param filterName The name of the special effect in the special effect package
/// @param value value description
- (void)setBeautyOptionValue:(int)filterIndex filterName:(NSString *)filterName value:(int)value;
```

#### 9.loadFilterEffectWithEffectPath

Load filter effect

> **Note:**
>
> Make sure the filter special effect package exists, otherwise the beauty will not take effect.

```Objective-C
/// Load filter effect
/// @param effectPath effect path
- (void)loadFilterEffectWithEffectPath:(NSString *)effectPath;
```

#### 10.cancelFilterEffect

Cancel filter effect

```Objective-C
/// Cancel filter effect
- (void)cancelFilterEffect;
```

#### 11.getFilterIntensity

Get the default value of the setting parameter of the filter under the current type

```Objective-C
/// Get the default value
- (int)getFilterIntensity;
```

#### 12.setFilterIntensity

Set the parameter value of the filter under the current type

```Objective-C
/// Set filter strength
/// @param value value description
- (void)setFilterIntensity:(int)value;
```

#### 13.loadStickerEffectWithEffectPath

Loading stickers

> **Note:**
>
> Make sure the sticker special effect package exists, otherwise the beauty will not take effect.

```Objective-C
/// Loading stickers
/// @param effectPath effect path
- (void)loadStickerEffectWithEffectPath:(NSString *)effectPath;
```

#### 14.cancelStickerEffect

Cancel sticker effect

```Objective-C
/// Cancel sticker effect
- (void)cancelStickerEffect;
```

#### 15.loadGestureEffectWithEffectPath

Load gesture effect

> **Note:**
>
> Make sure that the gesture special effect package exists, otherwise the beauty will not take effect.

```Objective-C
/// Load gesture effect
/// @param effectPath effect path
- (void)loadGestureEffectWithEffectPath:(NSString *)effectPath;
```

#### 16.cancelGestureEffect

Cancel gesture effect

```Objective-C
/// Cancel gesture effect
- (void)cancelGestureEffect;
```

#### 17.destroyAllEffects

Destroy all effects

```Objective-C
/// Destroy all special effects (called when leaving the room, will release all resources)
- (void)destroyAllEffects;
```

## 4.OrangeFilter SDK API

#### OrangeFilter:OF_CreateContext

```Objective-C
OF_Result OF_CreateContext(OFHandle* contextID, const char* harsModelPath);
```

Create OrangeFilter Context.

| Parameters    | Type     | 描述                          |
| :------------ | :------- | :---------------------------- |
| contextID     | OFHandle | Context ID                    |
| harsModelPath | String   | venus_models: Data model path |

--------------------------

#### OrangeFilter:OF_DestroyContext

```Objective-C
OF_Result OF_DestroyContext(OFHandle contextID);
```

Pre-process frame data before rendering, including calculation of face pose (spatial position, orientation).

> **Note：**
>
> Return value, return 'OF_Result_Success' when success.

| Parameters | Type     | Description |
| :--------- | :------- | :---------- |
| context    | OFHandle | Context ID  |

--------------------------

#### OrangeFilter:OF_CreateEffectFromPackage

```Objective-C
OF_Result OF_CreateEffectFromPackage(OFHandle contextID, const char* filePath, OFHandle* effectID);
```

Render frame effect

> **Note：**
>
> Return value，return 'OF_Result_Success' when success.

| Parameters | Type        | Description                  |
| :--------- | :---------- | :--------------------------- |
| contextID  | OFHandle    | Context ID                   |
| filePath   | const char* | Material package file path   |
| effectID   | OFHandle*   | Output the created effect ID |

--------------------------

#### OrangeFilter:OF_GetEffectInfo

```Objective-C
OF_Result OF_CreateEffectFromPackage(OFHandle contextID, const char* filePath, OFHandle* effectID);
```

Set Filter parameter data

> **Note：**
>
> Return value，return 'OF_Result_Success' when success.

| Parameters | Type           | Description                                                  |
| :--------- | :------------- | :----------------------------------------------------------- |
| contextID  | OFHandle       | Context ID                                                   |
| effectID   | OFHandle       | Effect ID                                                    |
| effectInfo | OF_EffectInfo* | Pass in the OrangeFilter.OF_EffectInfo object address, the object properties will be filled |

--------------------------

#### OrangeFilter:OF_GetFilterParamData

```Objective-C
OF_Result OF_GetFilterParamData(OFHandle contextID, OFHandle filterID, const char* paramName, OF_Param** param);
```

Destroy Effect。

> **Note：**
>
> Return value，return 'OF_Result_Success' when success.

| Parameters | Type        | Description           |
| :--------- | :---------- | :-------------------- |
| contextID  | OFHandle    | Context ID            |
| filterID   | OFHandle    | Filter ID             |
| paramName  | const char* | parameter name        |
| param      | OF_Param**  | Output parameter data |

--------------------------

#### OrangeFilter:OF_SetFilterParamData

```Objective-C
OF_Result OF_SetFilterParamData(OFHandle contextID, OFHandle filterID, const char* paramName, OF_Param* param);
```

Destroy OrangeFilter Context。

> **Note：**
>
> Return value，return 'OF_Result_Success' when success.

| Parameters | Type        | Description           |
| :--------- | :---------- | :-------------------- |
| contextID  | OFHandle    | Context ID            |
| filterID   | OFHandle    | Filter ID             |
| paramName  | const char* | parameter name        |
| param      | OF_Param*   | Output parameter data |

#### OrangeFilter:OF_DestroyEffect

```Objective-C
OF_Result OF_DestroyEffect(OFHandle contextID, OFHandle effectID);
```

Destroy Effect。

> **Note：**
>
> Return value，return 'OF_Result_Success' when success.

| Parameters | Type     | Description |
| :--------- | :------- | :---------- |
| contextID  | OFHandle | Context ID  |
| effect     | OFHandle | Effect ID   |

--------------------------

#### OrangeFilter:OF_ApplyFrameBatch

```Objective-C
OF_Result OF_ApplyFrameBatch(OFHandle contextID, const OFHandle* idList, OFUInt32 idCount,
OF_Texture* inputArray, OFUInt32 inputCount, OF_Texture* outputArray, OFUInt32 outputCount,
OF_FrameData* frameData, OF_Result *resultList, OFUInt32 resultCount);
```

Render frame special effects, batch render multiple Effects

> **Note：**
>
> Return value，return 'OF_Result_Success' when success.

| Parameters  | Type            | Description                                                  |
| :---------- | :-------------- | :----------------------------------------------------------- |
| contextID   | OFHandle        | Context ID                                                   |
| idList      | const OFHandle* | Effect id Array                                              |
| idCount     | OFUInt32        | Effect id Array Count                                        |
| inputArray  | OF_Texture*     | Input image texture array, derived from the camera to collect video images or still pictures, usually 1 |
| inputCount  | OFUInt32        | Number of input image texture arrays                         |
| outputArray | OF_Texture*     | Output image texture array, used for rendering to screen or encoding to video stream, usually 1 |
| outputCount | OFUInt32        | Number of output image texture arrays                        |
| frameData   | OF_FrameData*   | Frame input data                                             |
| resultList  | OF_Result *     | Return result array, used to receive the return result of each Effect |
| resultCount | OFUInt32        | Returns the number of result arrays                          |

--------------------------

## 5.Custom OrangeFilter Effect

Please contact the Jocloud technical support for customizing effects.

#### Apply Custom OrangeFilter Effects

Demo protocols, delivered in the background, contain beauty, filter, expression, and gesture protocol. You can use the default ones or customize.