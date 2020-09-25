//
//  SYEffectRender.m
//  OrangeFilterDemo
//
//  Created by GasparChu on 2020/4/13.
//  Copyright © 2020 sy. All rights reserved.
//

#if USE_BEATIFY

#import "SYEffectRender.h"
#import <OpenGLES/ES3/glext.h>
#import "SYBeautyUtil.h"
#import "SYFilterUtil.h"
#import "SYStickerUtil.h"
#import "SYGestureUtil.h"

@interface SYEffectRender ()

@property (getter=isCheckSNSuccess, nonatomic, assign) BOOL checkSNSuccess; // 校验 sn 是否成功
@property (nonatomic, assign) NSTimeInterval time;                  // 时间
@property (nonatomic, copy) NSString *defaultBeautyEffectPath;      // 默认美颜路径
@property (nonatomic, strong) SYBeautyUtil *beautyUtil;             // 美颜工具
@property (nonatomic, strong) SYFilterUtil *filterUtil;             // 滤镜工具
@property (nonatomic, strong) SYStickerUtil *stickerUtil;           // 贴纸工具
@property (nonatomic, strong) SYGestureUtil *gestureUtil;           // 手势工具

@end

@implementation SYEffectRender
{
    OFHandle _ofContext;                        // context
    CVOpenGLESTextureCacheRef _textureCache;    // 纹理缓冲区
    CVPixelBufferRef _outPixelBufferRef;        // 输出图片
    GLuint _inTexture;                          // 输入纹理
    GLuint _outTexture;                         // 输出纹理
    GLuint _fbo;                                // 帧缓冲对象
}

+ (instancetype)sharedRenderer
{
    static SYEffectRender *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)checkSDKSerailNumber:(NSString *)serialNumber
{
    NSString *ofSerialNumber = serialNumber;
    NSString *ofLicenseName = @"of_offline_license.license";
    NSArray *documentsPathArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [documentsPathArr lastObject];
    NSString *ofLicensePath = [NSString stringWithFormat:@"%@/%@", documentPath, ofLicenseName];
    OF_Result checkResult = OF_CheckSerialNumber([ofSerialNumber UTF8String], [ofLicensePath UTF8String]);
    _checkSNSuccess = YES;
    if (OF_Result_Success != checkResult) {
        YYLogError(@"SYEffectRender: check sn failed");
        _checkSNSuccess = NO;
    }
}

- (void)setDefaultBeautyEffectPath:(NSString *)effectPath
{
    _defaultBeautyEffectPath = effectPath;
}

- (CVPixelBufferRef)renderPixelBufferRef:(CVPixelBufferRef)pixelBufferRef context:(EAGLContext *)context
{
    if (!self.checkSNSuccess) {
        return pixelBufferRef;
    }
    CVPixelBufferRef outPixel = pixelBufferRef;
    if (OF_INVALID_HANDLE == _ofContext) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // context 设置到主线程
            [EAGLContext setCurrentContext:context];
            // 创建纹理缓冲区
            CVReturn result = [self createTextureCacheWithContext:context];
            if (kCVReturnSuccess != result) {
                YYLogError(@"SYEffectRender: create textureCache failed");
                return;
            }
            // 创建 SDK 上下文
            OF_Result resultOf = [self createContext];
            if (OF_Result_Success != resultOf) {
                YYLogError(@"SYEffectRender: create ofContext failed");
                return;
            }
            // 创建特效工具
            [self createBeautyUtil];
            [self createFilterUtil];
            [self createStickerUtil];
            [self createGestureUtil];
        });
    } else {
        // 特效渲染
        outPixel = [self renderToBackBuffer:pixelBufferRef];
    }
    
    return outPixel;
}

- (void)renderPixelBufferRef:(CVPixelBufferRef)pixelBuffer context:(EAGLContext *)context sourceTextureID:(unsigned int)srcTextureID destinationTextureID:(unsigned int)dstTextureID textureFormat:(int)textureFormat textureTarget:(int)textureTarget textureWidth:(int)width textureHeight:(int)height
{
    // 创建帧缓冲区
    if (0 == self->_fbo) {
        glGenFramebuffers(1, &self->_fbo);
    }
    // 校验 sn 是否成功
    if (!self.checkSNSuccess) {
        [self copySrcTexture:srcTextureID toDstTexture:dstTextureID width:width height:height];
        return;
    }
    
    if (OF_INVALID_HANDLE == _ofContext) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // context 设置到主线程
            [EAGLContext setCurrentContext:context];
            // 创建 SDK 上下文
            OF_Result resultOf = [self createContext];
            if (OF_Result_Success != resultOf) {
                [self copySrcTexture:srcTextureID toDstTexture:dstTextureID width:width height:height];
                YYLogError(@"SYEffectRender: create ofContext failed");
                return;
            }
            // 创建特效工具
            [self createBeautyUtil];
            [self createFilterUtil];
            [self createStickerUtil];
            [self createGestureUtil];
        });
    } else {
        // 特效渲染
        [self renderToBackBuffer:pixelBuffer sourceTextureID:srcTextureID destinationTextureID:dstTextureID textureFormat:textureFormat textureTarget:textureTarget textureWidth:width textureHeight:height];
    }
    
}

- (void)destroyAllEffects
{
    YYLogDebug(@"render: destroy start");
    if (_ofContext != OF_INVALID_HANDLE) {
        [self.beautyUtil clearEffect];
        [self.filterUtil clearEffect];
        [self.stickerUtil clearEffect];
        [self.gestureUtil clearEffect];
        OF_DestroyContext(_ofContext);
    }
    if (0 != _inTexture) {
        glDeleteTextures(1, &_inTexture);
    }
    if (0 != _outTexture) {
        glDeleteTextures(1, &_outTexture);
    }
    if (_outPixelBufferRef) {
        CVBufferRelease(_outPixelBufferRef);
    }
    if (_textureCache) {
        CVOpenGLESTextureCacheFlush(_textureCache, 0);
        CFRelease(_textureCache);
    }
    if (0 != _fbo) {
        glDeleteFramebuffers(1, &_fbo);
    }
    
    [EAGLContext setCurrentContext:nil];
    _ofContext = 0;
    _textureCache = nil;
    _outPixelBufferRef = nil;
    _inTexture = 0;
    _outTexture = 0;
    _fbo = 0;
    self.beautyUtil = nil;
    self.filterUtil = nil;
    self.stickerUtil = nil;
    self.gestureUtil = nil;
    YYLogDebug(@"render: destroy end");
}

#pragma mark - BeautyUtil Effect Method
- (void)loadBeautyEffectWithEffectPath:(NSString *)effectPath
{
    if (!self.beautyUtil.isValid) {
        [self.beautyUtil loadEffect:_ofContext effectPath:effectPath];
    }
    self.beautyUtil.enable = YES;
    if (!self.beautyUtil) {
        YYLogDebug(@"render: error beautyUtil is nil");
    }
}

- (void)cancelBeautyEffect
{
    self.beautyUtil.enable = NO;
}

- (int)getBeautyOptionMinValue:(int)filterIndex filterName:(NSString *)filterName
{
    return [self.beautyUtil getBeautyOptionMinValue:filterIndex filterName:filterName];
}

- (int)getBeautyOptionMaxValue:(int)filterIndex filterName:(NSString *)filterName
{
    return [self.beautyUtil getBeautyOptionMaxValue:filterIndex filterName:filterName];
}

- (int)getBeautyOptionValue:(int)filterIndex filterName:(NSString *)filterName
{
    return [self.beautyUtil getBeautyOptionValue:filterIndex filterName:filterName];
}

- (void)setBeautyOptionValue:(int)filterIndex filterName:(NSString *)filterName value:(int)value
{
    [self.beautyUtil setBeautyOptionValue:filterIndex filterName:filterName value:value];
}

#pragma mark - FilterUtil Effect Method
- (void)loadFilterEffectWithEffectPath:(NSString *)effectPath
{
    [self.filterUtil loadEffect:_ofContext effectPath:effectPath];
    self.filterUtil.enable = YES;
    if (!self.filterUtil) {
        YYLogDebug(@"render: error filterUtil is nil");
    }
}

- (void)cancelFilterEffect
{
    [self.filterUtil clearEffect];
    self.filterUtil.enable = NO;
}

- (void)setFilterIntensity:(int)value
{
    [self.filterUtil setFilterIntensity:value];
}

- (int)getFilterIntensity
{
    return [self.filterUtil getFilterIntensity];
}

#pragma mark - StickerUtil Effect Method
- (void)loadStickerEffectWithEffectPath:(NSString *)effectPath
{
    [self.stickerUtil loadEffect:_ofContext effectPath:effectPath];
    self.stickerUtil.enable = YES;
    if (!self.stickerUtil) {
        YYLogDebug(@"render: error stickerUtil is nil");
    }
}

- (void)cancelStickerEffect
{
    [self.stickerUtil clearEffect];
    self.stickerUtil.enable = NO;
}

#pragma mark - GestureUtil Effect Method
- (void)loadGestureEffectWithEffectPath:(NSString *)effectPath
{
    [self.gestureUtil loadEffect:_ofContext effectPath:effectPath];
    self.gestureUtil.enable = YES;
    if (!self.gestureUtil) {
        YYLogDebug(@"render: error gestureUtil is nil");
    }
}

- (void)cancelGestureEffect
{
    [self.gestureUtil clearEffect];
    self.gestureUtil.enable = NO;
}

- (void)cancelOneGestureEffect:(NSString *)effectPath
{
    [self.gestureUtil cancelOneGestureEffect:effectPath];
}

- (void)cancelBeautyAndFilterEffects
{
    self.beautyUtil.enable = NO;
    self.filterUtil.enable = NO;
}

- (void)restoreBeautyAndFilterEffects
{
    self.beautyUtil.enable = YES;
    self.filterUtil.enable = YES;
}

#pragma mark - RenderEffect
/// 渲染特效
/// @param inPixelBuffer inPixelBuffer description
- (CVPixelBufferRef)renderToBackBuffer:(CVPixelBufferRef)inPixelBuffer
{
    if (!inPixelBuffer) {
        return inPixelBuffer;
    }
    
    // get inputTexture
    CVPixelBufferLockBaseAddress(inPixelBuffer, 0);
    CVOpenGLESTextureRef inputTexture = nil;
    int width  = (int)CVPixelBufferGetWidth(inPixelBuffer);
    int height = (int)CVPixelBufferGetHeight(inPixelBuffer);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(inPixelBuffer);
    int pitch = (int)CVPixelBufferGetBytesPerRow(inPixelBuffer);
    OSType pixelFormat = CVPixelBufferGetPixelFormatType(inPixelBuffer);
    if (kCVPixelFormatType_32BGRA != pixelFormat) {
        CVPixelBufferUnlockBaseAddress(inPixelBuffer, 0);
        YYLogError(@"SYEffectRender: pixelFormat failed");
        return inPixelBuffer;
    }
    CVReturn err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, inPixelBuffer, NULL, GL_TEXTURE_2D, GL_RGBA, width, height, GL_BGRA, GL_UNSIGNED_BYTE, 0, &inputTexture);
    if (kCVReturnSuccess != err) {
        YYLogError(@"SYEffectRender: get inputTexture failed");
        return inPixelBuffer;
    }
    
    // get inTextureId
    GLenum target = CVOpenGLESTextureGetTarget(inputTexture);
    if (GL_TEXTURE_2D != target) {
        YYLogError(@"SYEffectRender: inputTexture target failed");
        return inPixelBuffer;
    }
    _inTexture = CVOpenGLESTextureGetName(inputTexture);
    glBindTexture(GL_TEXTURE_2D, _inTexture);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    CVPixelBufferUnlockBaseAddress(inPixelBuffer, 0);
    
    // init frameData
    OF_FrameData frameData;
    memset(&frameData, 0, sizeof(frameData));
    frameData.width     = width;
    frameData.height    = height;
    frameData.format    = OF_PixelFormat_BGR32;
    frameData.imageData = baseAddress;
    frameData.widthStep = pitch;
    frameData.timestamp = (float) ([NSDate date].timeIntervalSince1970 - _time);
    frameData.isUseCustomHarsLib = OF_FALSE;
    
    // get outTextureId
    if (0 == _outTexture) {
        glGenTextures(1, &_outTexture);
        glBindTexture(GL_TEXTURE_2D, _outTexture);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, OF_NULL);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    }
    if (0 != glGetError()) {
        YYLogError(@"SYEffectRender: get outTextureId failed");
        return inPixelBuffer;
    }
    
    // init OF inTex & outTex
    OF_Texture inTex;
    inTex.target    = GL_TEXTURE_2D;
    inTex.width     = width;
    inTex.height    = height;
    inTex.format    = GL_RGBA;
    inTex.textureID = _inTexture;
    
    OF_Texture outTex;
    outTex.target    = GL_TEXTURE_2D;
    outTex.width     = width;
    outTex.height    = height;
    outTex.format    = GL_RGBA;
    outTex.textureID = _outTexture;
    
    // render tex for OF SDK
    OF_Result result = [self applyFrame:&inTex outTex:&outTex frameData:&frameData];
    if (0 != glGetError()) {
        YYLogError(@"SYEffectRender: of apply failed");
        CFRelease(inputTexture);
        return inPixelBuffer;
    }
    CFRelease(inputTexture);
    
    // get outPixelBuffer
    CVPixelBufferRef outPixelBuffer = inPixelBuffer;
    if (OF_Result_Success == result) {
        [self renderOutTextureToCVPixelBuffer:width height:height];
        outPixelBuffer = self->_outPixelBufferRef;
    }
    
    return outPixelBuffer;
}

/// 渲染特效
- (void)renderToBackBuffer:(CVPixelBufferRef)inPixelBuffer sourceTextureID:(unsigned int)srcTextureID destinationTextureID:(unsigned int)dstTextureID textureFormat:(int)textureFormat textureTarget:(int)textureTarget textureWidth:(int)width textureHeight:(int)height
{
    // get inputTexture
    CVPixelBufferLockBaseAddress(inPixelBuffer, 0);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(inPixelBuffer);
    int pitch = (int)CVPixelBufferGetBytesPerRow(inPixelBuffer);
    OSType pixelFormat = CVPixelBufferGetPixelFormatType(inPixelBuffer);
    if (kCVPixelFormatType_32BGRA != pixelFormat) {
        CVPixelBufferUnlockBaseAddress(inPixelBuffer, 0);
        [self copySrcTexture:srcTextureID toDstTexture:dstTextureID width:width height:height];
        YYLogError(@"SYEffectRender: pixelFormat failed");
        return;
    }
    CVPixelBufferUnlockBaseAddress(inPixelBuffer, 0);
    
    // init frameData
    OF_FrameData frameData;
    memset(&frameData, 0, sizeof(frameData));
    frameData.width     = width;
    frameData.height    = height;
    frameData.format    = textureFormat;
    frameData.imageData = baseAddress;
    frameData.widthStep = pitch;
    frameData.timestamp = (float) ([NSDate date].timeIntervalSince1970 - _time);
    frameData.isUseCustomHarsLib = OF_FALSE;

    // init OF inTex & outTex
    OF_Texture inTex;
    inTex.target    = GL_TEXTURE_2D;
    inTex.width     = width;
    inTex.height    = height;
    inTex.format    = GL_RGBA;
    inTex.textureID = srcTextureID;
    
    OF_Texture outTex;
    outTex.target    = GL_TEXTURE_2D;
    outTex.width     = width;
    outTex.height    = height;
    outTex.format    = GL_RGBA;
    outTex.textureID = dstTextureID;
    
    // render tex for OF SDK
    OF_Result result = [self applyFrame:&inTex outTex:&outTex frameData:&frameData];
    if (0 != glGetError()) {
        [self copySrcTexture:srcTextureID toDstTexture:dstTextureID width:width height:height];
        YYLogError(@"SYEffectRender: of apply failed");
        return;
    }
    if (OF_Result_Success != result) {
        [self copySrcTexture:srcTextureID toDstTexture:dstTextureID width:width height:height];
    }
}

/// 输出纹理转输出 pixel
/// @param width width description
/// @param height height description
- (void)renderOutTextureToCVPixelBuffer:(int)width height:(int)height
{
    glFinish();
    if (!self->_outPixelBufferRef) {
        self->_outPixelBufferRef = [self createPixelBufferRef:width height:height];
    }
    static CIContext *_ciContext;
    CIImage *outputImage = [CIImage imageWithTexture:_outTexture size:CGSizeMake(width, height) flipped:YES colorSpace:NULL];
    if (outputImage != nil) {
        if (_ciContext == nil) {
            _ciContext = [CIContext contextWithEAGLContext:[EAGLContext currentContext]  options:@{kCIContextWorkingColorSpace:[NSNull null]}];
        }
        [_ciContext render:outputImage toCVPixelBuffer:self->_outPixelBufferRef bounds:[outputImage extent] colorSpace:NULL];
    }
}

/// copy 源纹理到目标纹理
/// @param srcTex srcTex description
/// @param dstTex dstTex description
/// @param width width description
/// @param height height description
- (void)copySrcTexture:(int)srcTex toDstTexture:(int)dstTex width:(int)width height:(int)height
{
    glBindFramebuffer(GL_READ_FRAMEBUFFER, _fbo);
    glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, srcTex, 0);
    glBindTexture(GL_TEXTURE_2D, dstTex);
    glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 0, 0, width,height);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindTexture(GL_TEXTURE_2D,0);
}

/// 创建 pixel
/// @param width width description
/// @param height height description
- (CVPixelBufferRef)createPixelBufferRef:(int)width height:(int)height
{
    const void *keys[] = {
        kCVPixelBufferOpenGLESCompatibilityKey,
        kCVPixelBufferIOSurfacePropertiesKey,
    };
    const void *values[] = {
        (__bridge const void *)([NSNumber numberWithBool:YES]),
        (__bridge const void *)([NSDictionary dictionary])
    };
    OSType bufferPixelFormat = kCVPixelFormatType_32BGRA;
    CFDictionaryRef optionsDictionary = CFDictionaryCreate(NULL, keys, values, 2, NULL, NULL);
    CVPixelBufferRef pixelBuffer = NULL;
    CVPixelBufferCreate(kCFAllocatorDefault,
                        width,
                        height,
                        bufferPixelFormat,
                        optionsDictionary,
                        &pixelBuffer);
    CFRelease(optionsDictionary);
    return pixelBuffer;
}

/// 批量渲染帧特效
/// @param inTex 输入纹理
/// @param outTex 输出纹理
/// @param frameData 帧输入数据
- (OF_Result)applyFrame:(OF_Texture *)inTex outTex:(OF_Texture *)outTex frameData:(OF_FrameData *)frameData
{
    OF_Result result = OF_Result_Failed;
    if (OF_INVALID_HANDLE != _ofContext) {
        std::vector<OFHandle> effects;
        std::vector<OF_Result> results;
        
        if ([self gestureEffectIsValid]) {
            std::vector<OFHandle> gestureEffects = [self.gestureUtil getGestureEffects];
            for (int i = 0; i < gestureEffects.size(); i++) {
                OFHandle gestureEffect = gestureEffects[i];
                if (OF_INVALID_HANDLE != gestureEffect) {
                    effects.push_back(gestureEffect);
                }
            }
        }
        if ([self beautyEffectIsValid]) {
            OFHandle beautyEffect = [self.beautyUtil getEffect];
            effects.push_back(beautyEffect);
        }
        if ([self filterEffectIsValid]) {
            OFHandle filterEffect = [self.filterUtil getEffect];
            effects.push_back(filterEffect);
        }
        if ([self stickerEffectIsValid]) {
            OFHandle stickerEffect = [self.stickerUtil getEffect];
            effects.push_back(stickerEffect);
        }
        
        if (effects.size() > 0) {
            results.resize(effects.size());
            result = OF_ApplyFrameBatch(_ofContext, &effects[0], (OFUInt32) effects.size(), inTex, 1, outTex, 1, frameData, &results[0], (OFUInt32) results.size());
        }
    }
    return result;
}

- (BOOL)beautyEffectIsValid
{
    return self.beautyUtil && self.beautyUtil.isValid && self.beautyUtil.isEnable;
}

- (BOOL)filterEffectIsValid
{
    return self.filterUtil && self.filterUtil.isValid && self.filterUtil.isEnable;
}

- (BOOL)stickerEffectIsValid
{
    return self.stickerUtil && self.stickerUtil.isValid && self.stickerUtil.isEnable;
}

- (BOOL)gestureEffectIsValid
{
    return self.gestureUtil && self.gestureUtil.isValid && self.gestureUtil.isEnable;
}

#pragma mark - init SDK & TextureCache
/// 创建纹理缓冲区
- (CVReturn)createTextureCacheWithContext:(EAGLContext *)context
{
    if (_textureCache) {
        return kCVReturnSuccess;
    }
    CVReturn result = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, context, NULL, &_textureCache);
    return result;
}

/// 创建上下文
- (OF_Result)createContext
{
    if (OF_INVALID_HANDLE != _ofContext) {
        return OF_Result_Success;
    }
    NSString *modelPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"venus_models"];
    OF_Result result = OF_CreateContext(&_ofContext, [modelPath UTF8String]);
    _time = [NSDate date].timeIntervalSince1970;
    return result;
}

#pragma mark - Init EffectUtil
- (void)createBeautyUtil
{
    if (!self.beautyUtil) {
        _beautyUtil = [SYBeautyUtil new];
        if (self.defaultBeautyEffectPath) {
            [self.beautyUtil loadEffect:_ofContext effectPath:self.defaultBeautyEffectPath];
        }
    }
}

- (void)createFilterUtil
{
    if (!self.filterUtil) {
        _filterUtil = [SYFilterUtil new];
    }
}

- (void)createStickerUtil
{
    if (!self.stickerUtil) {
        _stickerUtil = [SYStickerUtil new];
    }
}

- (void)createGestureUtil
{
    if (!self.gestureUtil) {
        _gestureUtil = [SYGestureUtil new];
    }
}

@end

#endif
