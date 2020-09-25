//
//  SYEffectRender.h
//  OrangeFilterDemo
//
//  Created by GasparChu on 2020/4/13.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYEffectProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/// 特效渲染工具类
@class SYBeautyUtil, SYFilterUtil, SYStickerUtil;
@interface SYEffectRender : NSObject<SYBeautyProtocol, SYFilterProtocol, SYGestureProtocol>

+ (instancetype)sharedRenderer;

/// 应用启动时请校验 SDK 序列号，否则不生效
/// @param serialNumber 序列号 SN
- (void)checkSDKSerailNumber:(NSString *)serialNumber;

/// 设置默认美颜路径
/// @param effectPath effectPath description
- (void)setDefaultBeautyEffectPath:(NSString *)effectPath;

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

/// 销毁所有特效（离开房间的时候调用，会释放所有资源）
- (void)destroyAllEffects;

/// 加载美颜特效
/// @param effectPath 特效地址
- (void)loadBeautyEffectWithEffectPath:(NSString *)effectPath;

/// 加载滤镜特效
/// @param effectPath 特效地址
- (void)loadFilterEffectWithEffectPath:(NSString *)effectPath;

/// 加载贴纸特效
/// @param effectPath 特效地址
- (void)loadStickerEffectWithEffectPath:(NSString *)effectPath;

/// 加载手势特效
/// @param effectPath 特效地址
- (void)loadGestureEffectWithEffectPath:(NSString *)effectPath;

/// 取消美颜特效
- (void)cancelBeautyEffect;

/// 取消滤镜特效
- (void)cancelFilterEffect;

/// 取消贴纸特效
- (void)cancelStickerEffect;

/// 取消手势特效
- (void)cancelGestureEffect;

/// 长按取消美颜和滤镜特效
- (void)cancelBeautyAndFilterEffects;

/// 长按结束恢复美颜和滤镜特效
- (void)restoreBeautyAndFilterEffects;

@end

NS_ASSUME_NONNULL_END
