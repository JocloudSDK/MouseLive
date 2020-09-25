//
//  VideoViewController+SYAddEffect.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/5/12.
//  Copyright © 2020 sy. All rights reserved.
//

#import "VideoViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoViewController (SYAddEffect)

- (void)sy_downloadEffectData;

/// 获取特效数据
- (NSArray *)sy_getEffectsData;

/// 设置默认美颜
- (void)sy_setDefaultBeautyEffect;

/// 销毁所有特效（离开房间的时候调用，会释放所有资源）
- (void)sy_destroyAllEffects;

/// 渲染特效
/// @param pixelBuffer pixelBuffer description
/// @param context context description
- (CVPixelBufferRef)sy_renderPixelBufferRef:(CVPixelBufferRef)pixelBuffer
                                 context:(EAGLContext *)context;

/// 渲染
/// @param pixelBuffer 源pixelBuffer
/// @param context 上下文EAGLContext
/// @param srcTextureID 源纹理
/// @param dstTextureID 目标纹理
/// @param textureFormat 纹理格式
/// @param textureTarget 纹理target
/// @param width width description
/// @param height height description
- (void)sy_renderPixelBufferRef:(CVPixelBufferRef)pixelBuffer
                     context:(EAGLContext *)context
             sourceTextureID:(unsigned int)srcTextureID
        destinationTextureID:(unsigned int)dstTextureID
               textureFormat:(int)textureFormat
               textureTarget:(int)textureTarget
                textureWidth:(int)width
               textureHeight:(int)height;
@end

NS_ASSUME_NONNULL_END
