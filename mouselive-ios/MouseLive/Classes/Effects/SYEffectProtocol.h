//
//  SYEffectProtocol.h
//  MouseLive
//
//  Created by GasparChu on 2020/4/16.
//  Copyright © 2020 sy. All rights reserved.
//
#import "of_effect/orangefilter.h"

@protocol SYEffectProtocol <NSObject>
@optional
/// 加载特效
/// @param ofContext 上下文
/// @param effectPath 特效包地址
- (void)loadEffect:(OFHandle)ofContext effectPath:(NSString *)effectPath;

/// 获取特效
- (OFHandle)getEffect;

/// 清除特效
- (void)clearEffect;

// 美颜是否生效
@property (nonatomic, assign, readwrite, getter=isEnable) BOOL enable;
// 美颜特效包是否是有效的
@property (nonatomic, assign, readonly, getter=isValid) BOOL valid;

@end

@protocol SYBeautyProtocol <NSObject>
/*
 服务端返回的数据需要和特效包中的单个特效一一对应，比如服务端返回的 OperationType 需要对应特效包中的 filterIndex，ResourceTypeName 需要对应特效包中的 name，假如不对应会有问题。对应关系如下：
 ————————————————————————————————————————————————————————
 ｜ 特效 ｜ filterIndex ｜   name                        ｜
 ｜ 美肤 ｜     1       ｜   Opacity                     ｜
 ｜ 美白 ｜     0       ｜   Intensity                   ｜
 ｜ 窄脸 ｜     3       ｜   ThinfaceIntensity           ｜
 ｜ 小脸 ｜     3       ｜   SmallfaceIntensity          ｜
 ｜瘦颧骨｜     3       ｜   SquashedFaceIntensity       ｜
 ｜ 额高 ｜     3       ｜   ForeheadLiftingIntensity    ｜
 ｜ 额宽 ｜     3       ｜   WideForeheadIntensity       ｜
 ｜ 大眼 ｜     3       ｜   BigSmallEyeIntensity        ｜
 ｜ 眼距 ｜     3       ｜   EyesOffset                  ｜
 ｜ 眼角 ｜     3       ｜   EyesRotationIntensity       ｜
 ｜ 瘦鼻 ｜     3       ｜   ThinNoseIntensity           ｜
 ｜ 长鼻 ｜     3       ｜   LongNoseIntensity           ｜
 ｜窄鼻梁｜     3       ｜   ThinNoseBridgeIntensity     ｜
 ｜ 小嘴 ｜     3       ｜   ThinmouthIntensity          ｜
 ｜ 嘴位 ｜     3       ｜   MovemouthIntensity          ｜
 ｜ 下巴 ｜     3       ｜   ChinLiftingIntensity        ｜
 ————————————————————————————————————————————————————————
 */
@optional
/// 获取特效最小值
/// @param filterIndex 特效在特效包中的 index
/// @param filterName 特效在特效包中的 name
- (int)getBeautyOptionMinValue:(int)filterIndex filterName:(NSString *)filterName;

/// 获取特效最大值
/// @param filterIndex 特效在特效包中的 index
/// @param filterName 特效在特效包中的 name
- (int)getBeautyOptionMaxValue:(int)filterIndex filterName:(NSString *)filterName;

/// 获取特效当前值
/// @param filterIndex 特效在特效包中的 index
/// @param filterName 特效在特效包中的 name
- (int)getBeautyOptionValue:(int)filterIndex filterName:(NSString *)filterName;

/// 设置特效强度值
/// @param filterIndex 特效在特效包中的 index
/// @param filterName 特效在特效包中的 name
/// @param value value description
- (void)setBeautyOptionValue:(int)filterIndex filterName:(NSString *)filterName value:(int)value;

@end

@protocol SYFilterProtocol <NSObject>
@optional
/// 设置滤镜强度
/// @param value value description
- (void)setFilterIntensity:(int)value;

/// 获取当前滤镜强度
- (int)getFilterIntensity;

@end

@protocol SYGestureProtocol <NSObject>
@optional

/// 取消某一个手势特效
/// @param effectPath 手势特效地址
- (void)cancelOneGestureEffect:(NSString *)effectPath;

@end

@class SYEffectsModel, SYEffectItem;
@protocol SYEffectViewDelegate <NSObject>
@optional
/// 选择特效
/// @param item item description
/// @param model model description
- (void)selectedItem:(SYEffectItem *)item model:(SYEffectsModel *)model;

/// 取消某一类型特效
/// @param model model description
- (void)cancelEffect:(SYEffectsModel *)model;

/// 取消某一类型的某个特效
/// @param model model description
/// @param item item description
- (void)cancelEffect:(SYEffectsModel *)model effectItem:(SYEffectItem *)item;

/// 改变特效强度
/// @param value value description
/// @param item item description
/// @param model model description
- (void)changeEffectIntensity:(int)value item:(SYEffectItem *)item model:(SYEffectsModel *)model;

/// 长按开始，长按中的时候暂时取消美颜和滤镜特效
- (void)longGestureBegan;

/// 长按结束，长按结束的时候恢复已选中的美颜和滤镜特效
- (void)longGestureEnded;

@end
