//
//  VideoViewController+SYAddEffect.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/5/12.
//  Copyright © 2020 sy. All rights reserved.
//

#import "VideoViewController+SYAddEffect.h"
#import "SYEffectsDataManager.h"
#import "SYEffectsModel.h"
#import "SYEffectProtocol.h"
#import "SYEffectRender.h"

@implementation VideoViewController (SYAddEffect)

#if USE_BEATIFY
- (void)sy_downloadEffectData
{
    [[SYEffectsDataManager sharedManager] downloadEffectsData];
}

- (NSArray *)sy_getEffectsData
{
    return [SYEffectsDataManager sharedManager].getEffectsData;
}

- (void)sy_setDefaultBeautyEffect
{
    NSString *beautyEffectPath = [[SYEffectsDataManager sharedManager] getBeautyEffectPath];
    [[SYEffectRender sharedRenderer] setDefaultBeautyEffectPath:beautyEffectPath];
}

- (void)sy_destroyAllEffects
{
    [[SYEffectRender sharedRenderer] destroyAllEffects];
}

- (CVPixelBufferRef)sy_renderPixelBufferRef:(CVPixelBufferRef)pixelBuffer context:(EAGLContext *)context
{
    CVPixelBufferRef outPixelBuf = [[SYEffectRender sharedRenderer] renderPixelBufferRef:pixelBuffer context:context];
    return outPixelBuf;
}

- (void)sy_renderPixelBufferRef:(CVPixelBufferRef)pixelBuffer context:(EAGLContext *)context sourceTextureID:(unsigned int)srcTextureID destinationTextureID:(unsigned int)dstTextureID textureFormat:(int)textureFormat textureTarget:(int)textureTarget textureWidth:(int)width textureHeight:(int)height
{
    [[SYEffectRender sharedRenderer] renderPixelBufferRef:pixelBuffer context:context sourceTextureID:srcTextureID destinationTextureID:dstTextureID textureFormat:textureFormat textureTarget:textureTarget textureWidth:width textureHeight:height];
}

#pragma mark - SYEffectViewDelegate
- (void)selectedItem:(SYEffectItem *)item model:(SYEffectsModel *)model
{
    YYLogDebug(@"SYEffectViewDelegate: selectedItem %@ start %d", model.GroupType, item.value);
    if (!item.effectPath.length) {
        return ;
    }
    if (model.isBeautyGroup) {
        [[SYEffectRender sharedRenderer] loadBeautyEffectWithEffectPath:item.effectPath];
        int filterIndex = item.OperationType.intValue;
        NSString *filterName = item.ResourceTypeName;
        item.value = [[SYEffectRender sharedRenderer] getBeautyOptionValue:filterIndex filterName:filterName];
        if (!item.isHasSelected) {
            item.minValue = [[SYEffectRender sharedRenderer] getBeautyOptionMinValue:filterIndex filterName:filterName];
            item.maxValue = [[SYEffectRender sharedRenderer] getBeautyOptionMaxValue:filterIndex filterName:filterName];
            item.defaultValue = item.value;
        }
    } else if (model.isFilterGroup) {
        [[SYEffectRender sharedRenderer] loadFilterEffectWithEffectPath:item.effectPath];
        if (!item.isHasSelected) {
            item.minValue = 0;
            item.maxValue = 100;
            item.value = [[SYEffectRender sharedRenderer] getFilterIntensity];
            item.defaultValue = item.value;
        } else { // 已经选中过的滤镜强度可能改变过，但是重新加载的特效包中的强度还是100，所以重新设置到已经改变的强度值
            [self changeEffectIntensity:item.value item:item model:model];
        }
    } else if (model.isStickerGroup) {
        [[SYEffectRender sharedRenderer] loadStickerEffectWithEffectPath:item.effectPath];
    } else if (model.isGestureGroup) {
        [[SYEffectRender sharedRenderer] loadGestureEffectWithEffectPath:item.effectPath];
    }
    item.hasSelected = YES;
    YYLogDebug(@"SYEffectViewDelegate: selectedItem %@ end %d", model.GroupType, item.value);
}

- (void)cancelEffect:(SYEffectsModel *)model
{
    if (model.isBeautyGroup) {
        [[SYEffectRender sharedRenderer] cancelBeautyEffect];
    } else if (model.isFilterGroup) {
        [[SYEffectRender sharedRenderer] cancelFilterEffect];
    } else if (model.isStickerGroup) {
        [[SYEffectRender sharedRenderer] cancelStickerEffect];
    } else if (model.isGestureGroup) {
        [[SYEffectRender sharedRenderer] cancelGestureEffect];
    }
}

- (void)cancelEffect:(SYEffectsModel *)model effectItem:(SYEffectItem *)item
{
    if (model.isGestureGroup) {
        [[SYEffectRender sharedRenderer] cancelOneGestureEffect:item.effectPath];
    }
}

- (void)changeEffectIntensity:(int)value item:(SYEffectItem *)item model:(SYEffectsModel *)model
{
    if (model.isBeautyGroup) {
        int filterIndex = item.OperationType.intValue;
        NSString *filterName = item.ResourceTypeName;
        [[SYEffectRender sharedRenderer] setBeautyOptionValue:filterIndex filterName:filterName value:value];
    } else if (model.isFilterGroup) {
        [[SYEffectRender sharedRenderer] setFilterIntensity:value];
    }
}

- (void)longGestureBegan
{
    [[SYEffectRender sharedRenderer] cancelBeautyAndFilterEffects];
}

- (void)longGestureEnded
{
    [[SYEffectRender sharedRenderer] restoreBeautyAndFilterEffects];
}

#endif
@end
