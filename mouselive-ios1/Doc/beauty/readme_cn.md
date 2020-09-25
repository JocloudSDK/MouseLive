# OrangeFilter SDK

OrangeFilter SDK是一套以内容创作为核心，设计数据驱动的跨平台视频特效及AR互动娱乐解决方案， 包含各种视频美颜、动态滤镜，2D/3D图形特效等功能，核心代码基于C/C++语言并采用 Lua 脚本来扩展功能。

* [1.获取用户鉴权及说明](#1.获取用户鉴权及说明)
* [2.配置项目](#2.配置项目)
* [3.OrangeFilter实现美颜效果](#3.OrangeFilter实现美颜效果)
* [4.OrangeFilter SDK API](#4.OrangeFilter SDK API)
* [5.自定义特效包资源](#5.自定义特效包资源)

## 1.获取用户鉴权及说明
联系聚联云技术支持，并提供项目AppID（android:applicationId/ios:bundle Id）以申请鉴权序列号，审核通过后将显示序列号。
> **注意**
>
> - 用户鉴权详情请参考[../mouselive-android/effect]模块。
> - 授权类型包括人脸检测、背景分割、手势检测，可启用指定类型或全部启用。
> - 美颜、滤镜与人脸无关，贴纸、整形和人脸有关。
> - 鉴权分为SDK鉴权（决定OrangeFilter SDK是否可用）和特效包鉴权（决定特效能是否能被加载）。
> - 如需获取特效包，请联系聚联云技术支持。

## 2.配置项目

### 1）引入 OrangeFilter 库

将示例代码中 ../MouseLive/Classes/Effects/of_effect.framework 库直接拖入到工程目录下

> **注意：**
>
> - Added folders : Create groups

### 2）初始化人脸模型数据

- 将示例代码中 ../MouseLive/Classes/Effects/venus_models 库直接拖入到工程目录下

> **注意**
>
> Added folders : Create folder references

- 初始化加载人脸模型数据

```Objective-C
NSString *modelPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"venus_models"];
OF_Result result = OF_CreateContext(&_ofContext, [modelPath UTF8String]);  
```

### 3）鉴权逻辑

应用启动时初始化，示例实现代码：

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

## 3.OrangeFilter实现美颜效果

本文以OrangeFilter SDK 对接ThunderBolt SDK为例。SDK就会在视频生命周期中调用对应3个接口,具体实现详见泛娱乐Demo中MouseLive/Classes/Live/Controller/BaseLiveViewController类。

#### 1.renderPixelBufferRef

开始渲染

```Objective-C
/// 渲染方法
/// @param pixelBufferRef 源CVPixelBufferRef
/// @param context 上下文EAGLContext
- (CVPixelBufferRef)renderPixelBufferRef:(CVPixelBufferRef)pixelBufferRef
                                 context:(EAGLContext *)context;

/// 渲染方法
/// @param pixelBuffer 源pixelBuffer
/// @param context 上下文EAGLContext
/// @param srcTextureID 源纹理
/// @param dstTextureID 目标纹理
/// @param textureFormat 纹理格式
/// @param textureTarget 纹理target
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

在进入直播间之前将特效数据请求下来，可以考虑先把一些特效包下载下来（当前是先把美颜和滤镜的优先下载了）

> - **注意:**
> - 如果不需要开启默认美颜，可以不调用
> - 传递的参数path是特效包下载后的文件保存路径，of SDK会通过这个路径去设置
> - 要保证路径下有特效包，否则默认美颜开启不了

```Objective-C
/// 设置默认美颜路径
/// @param effectPath effectPath description
- (void)setDefaultBeautyEffectPath:(NSString *)effectPath;
```

#### 3.loadBeautyEffectWithEffectPath

加载美颜

> **注意:**
>
> 要确保美颜特效包存在，否则美颜不生效。

```Objective-C
/// 加载美颜特效
/// @param effectPath 特效地址
- (void)loadBeautyEffectWithEffectPath:(NSString *)effectPath;
```

#### 4.cancelBeautyEffect

取消美颜

```Objective-C
/// 取消美颜特效
- (void)cancelBeautyEffect;
```

#### 5.getBeautyOptionMinValue

获取当前类型下美颜的设置参数的最小值

```Objective-C
/// 获取特效最小值
/// @param filterIndex 特效在特效包中的 index
/// @param filterName 特效在特效包中的 name
- (int)getBeautyOptionMinValue:(int)filterIndex filterName:(NSString *)filterName;
```

#### 6.getBeautyOptionMaxValue

获取当前类型下美颜的设置参数的最大值

```Objective-C
/// 获取特效最大值
/// @param filterIndex 特效在特效包中的 index
/// @param filterName 特效在特效包中的 name
- (int)getBeautyOptionMaxValue:(int)filterIndex filterName:(NSString *)filterName;
```

#### 7.getBeautyOptionValue

获取当前类型下美颜的设置参数的默认值

```Objective-C
/// 获取特效当前值
/// @param filterIndex 特效在特效包中的 index
/// @param filterName 特效在特效包中的 name
- (int)getBeautyOptionValue:(int)filterIndex filterName:(NSString *)filterName;
```

#### 8.setBeautyOptionValue

调整美颜整形程度

> **注意:**
>
> 要确保已经加载美颜特效包，否则不生效。

```Objective-C
/// 设置特效强度值
/// @param filterIndex 特效在特效包中的 index
/// @param filterName 特效在特效包中的 name
/// @param value value description
- (void)setBeautyOptionValue:(int)filterIndex filterName:(NSString *)filterName value:(int)value;
```

#### 9.loadFilterEffectWithEffectPath

加载滤镜

> **注意:**
>
> 要确保滤镜特效包存在，否则美颜不生效。

```Objective-C
/// 加载滤镜特效
/// @param effectPath 特效地址
- (void)loadFilterEffectWithEffectPath:(NSString *)effectPath;
```

#### 10.cancelFilterEffect

取消滤镜

```Objective-C
/// 取消滤镜特效
- (void)cancelFilterEffect;
```

#### 11.getFilterIntensity

获取当前类型下滤镜的设置参数的默认值

```Objective-C
/// 获取当前滤镜强度
- (int)getFilterIntensity;
```

#### 12.setFilterIntensity

设置当前类型下滤镜的参数值

```Objective-C
/// 设置滤镜强度
/// @param value value description
- (void)setFilterIntensity:(int)value;
```

#### 13.loadStickerEffectWithEffectPath

加载贴纸

> **注意:**
>
> 要确保贴纸特效包存在，否则美颜不生效。

```Objective-C
/// 加载贴纸特效
/// @param effectPath 特效地址
- (void)loadStickerEffectWithEffectPath:(NSString *)effectPath;
```

#### 14.cancelStickerEffect

取消贴纸

```Objective-C
/// 取消贴纸特效
- (void)cancelStickerEffect;
```

#### 15.loadGestureEffectWithEffectPath

加载手势

> **注意:**
>
> 要确保手势特效包存在，否则美颜不生效。

```Objective-C
/// 加载手势特效
/// @param effectPath 特效地址
- (void)loadGestureEffectWithEffectPath:(NSString *)effectPath;
```

#### 16.cancelGestureEffect

取消手势

```Objective-C
/// 取消手势特效
- (void)cancelGestureEffect;
```

#### 17.destroyAllEffects

销毁所有设置生效的手势。

```Objective-C
/// 销毁所有特效（离开房间的时候调用，会释放所有资源）
- (void)destroyAllEffects;
```

## 4.OrangeFilter SDK API

#### OrangeFilter:OF_CreateContext

```Objective-C
OF_Result OF_CreateContext(OFHandle* contextID, const char* harsModelPath);
```

创建 OrangeFilter Context。

| 参数          | 类型        | 描述                                                         |
| :------------ | :---------- | :----------------------------------------------------------- |
| contextID     | OFHandle    | 输出创建的 Context ID                                        |
| harsModelPath | const char* | venus_models数据模型路径 见[初始化人脸模型数据](#2）初始化人脸模型数据) |

--------------------------

#### OrangeFilter:OF_DestroyContext

```Objective-C
OF_Result OF_DestroyContext(OFHandle contextID);
```

销毁 OrangeFilter Context。

> **注意：**
>
> 返回值：成功时返回 OF_Result_Success。

| 参数    | 类型     | 描述                |
| :------ | :------- | :------------------ |
| context | OFHandle | 要销毁的 Context id |

--------------------------


#### OrangeFilter:OF_CreateEffectFromPackage

```Objective-C
OF_Result OF_CreateEffectFromPackage(OFHandle contextID, const char* filePath, OFHandle* effectID);
```

从素材包文件创建特效

> **注意：**
>
> 返回值，成功时返回 OF_Result_Success。

| 参数      | 类型        | 描述                 |
| :-------- | :---------- | :------------------- |
| contextID | OFHandle    | Context id           |
| filePath  | const char* | 素材包文件路径       |
| effectID  | OFHandle*   | 输出创建的 Effect id |

--------------------------

#### OrangeFilter:OF_GetEffectInfo

```Objective-C
OF_Result OF_CreateEffectFromPackage(OFHandle contextID, const char* filePath, OFHandle* effectID);
```

获取 Effect 信息

> **注意：**
>
> 返回值，成功时返回 OF_Result_Success。

| 参数       | 类型           | 描述                                                       |
| :--------- | :------------- | :--------------------------------------------------------- |
| contextID  | OFHandle       | Context id                                                 |
| effectID   | OFHandle       | Effect id                                                  |
| effectInfo | OF_EffectInfo* | 传入 OrangeFilter.OF_EffectInfo 对象地址，对象属性会被填充 |

--------------------------

#### OrangeFilter:OF_GetFilterParamData

```Objective-C
OF_Result OF_GetFilterParamData(OFHandle contextID, OFHandle filterID, const char* paramName, OF_Param** param);
```

获取 Filter 参数数据

> **注意：**
>
> 返回值，成功时返回 OF_Result_Success。

| 参数      | 类型        | 描述         |
| :-------- | :---------- | :----------- |
| contextID | OFHandle    | Context id   |
| filterID  | OFHandle    | Filter id    |
| paramName | const char* | 参数名称     |
| param     | OF_Param**  | 输出参数数据 |

--------------------------

#### OrangeFilter:OF_SetFilterParamData

```Objective-C
OF_Result OF_SetFilterParamData(OFHandle contextID, OFHandle filterID, const char* paramName, OF_Param* param);
```

设置 Filter 参数数据

> **注意：**
>
> 返回值，成功时返回 OF_Result_Success。

| 参数      | 类型        | 描述         |
| :-------- | :---------- | :----------- |
| contextID | OFHandle    | Context id   |
| filterID  | OFHandle    | Filter id    |
| paramName | const char* | 参数名称     |
| param     | OF_Param**  | 输出参数数据 |

--------------------------

#### OrangeFilter:OF_DestroyEffect

```Objective-C
OF_Result OF_DestroyEffect(OFHandle contextID, OFHandle effectID);
```

销毁 Effect。

> **注意：**
>
> 返回值：成功时返回 OF_Result_Success。

| 参数      | 类型     | 描述       |
| :-------- | :------- | :--------- |
| contextID | OFHandle | Context id |
| effect    | OFHandle | Effect id  |

--------------------------

#### OrangeFilter:OF_ApplyFrameBatch

```Objective-C
OF_Result OF_ApplyFrameBatch(OFHandle contextID, const OFHandle* idList, OFUInt32 idCount,
OF_Texture* inputArray, OFUInt32 inputCount, OF_Texture* outputArray, OFUInt32 outputCount,
OF_FrameData* frameData, OF_Result *resultList, OFUInt32 resultCount);
```

渲染帧特效，批量渲染多个 Effect

> **注意：**
>
> 返回值，成功时返回 OF_Result_Success。

| 参数        | 类型            | 描述                                                         |
| :---------- | :-------------- | :----------------------------------------------------------- |
| contextID   | OFHandle        | Context id                                                   |
| idList      | const OFHandle* | Effect id 数组                                               |
| idCount     | OFUInt32        | Effect id 数组数量                                           |
| inputArray  | OF_Texture*     | 输入图像纹理数组，来源于摄像头采集视频图像或静态图片，通常为 1 个 |
| inputCount  | OFUInt32        | 输入图像纹理数组数量                                         |
| outputArray | OF_Texture*     | 输出图像纹理数组，用于渲染到屏幕或编码到视频流，通常为 1 个  |
| outputCount | OFUInt32        | 输出图像纹理数组数量                                         |
| frameData   | OF_FrameData*   | 帧输入数据                                                   |
| resultList  | OF_Result *     | 返回结果数组，用于接收每个 Effect 的返回结果                 |
| resultCount | OFUInt32        | 返回结果数组数量                                             |

## 5.自定义特效包资源

请联系聚联云技术支持获取定制特效包。

#### 下发OrangeFilter特效接口（业务自定义）

Demo协议为后台下发，分为美颜，滤镜，表情，手势相关协议。业务可以使用默认协议或定义。