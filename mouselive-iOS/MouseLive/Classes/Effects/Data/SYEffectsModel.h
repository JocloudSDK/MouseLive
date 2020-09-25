//
//  SYEffectsModel.h
//  MouseLive
//
//  Created by GasparChu on 2020/4/13.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYEffectItem;
NS_ASSUME_NONNULL_BEGIN

@interface SYEffectsModel : NSObject

@property (nonatomic, copy) NSString *GroupType;    // 特效类型
@property (nonatomic, strong) NSMutableArray<SYEffectItem *> *Icons; // 特效列表

// 业务字段
@property (getter=isSelected, nonatomic, assign) BOOL selected; // 是否选中当前标签
@property (getter=isBeautyGroup, nonatomic, assign) BOOL beautyGroup;   // 是否是美颜
@property (getter=isFilterGroup, nonatomic, assign) BOOL filterGroup;   // 是否是滤镜
@property (getter=isStickerGroup, nonatomic, assign) BOOL stickerGroup; // 是否是贴纸
@property (getter=isGestureGroup, nonatomic, assign) BOOL gestureGroup; // 是否是手势
@property (nonatomic, strong) NSMutableArray *selectedMArr; // 选中的特效数组(除了手势多选其他都是单选)

// 本地业务字段值重置
- (void)resetStatus;

@end

@interface SYEffectItem : NSObject

@property (nonatomic, copy) NSString *Name;     // 名称
@property (nonatomic, copy) NSString *Thumb;    // 缩略图
@property (nonatomic, copy) NSString *DynamicThumb; // 动态图
@property (nonatomic, copy) NSString *Url;      // 资源地址
@property (nonatomic, copy) NSString *OperationType;    //操作类型（美颜、手势用到）
@property (nonatomic, copy) NSString *ResourceTypeName; // 操作类型名称（美颜用到）
@property (nonatomic, copy) NSString *Md5;

// 业务字段
@property (getter=isDownloaded, nonatomic, assign) BOOL downloaded; // 是否下载完成
@property (getter=isDownloading, nonatomic, assign) BOOL downloading; // 是否正在下载
@property (nonatomic, copy) NSString *effectPath;   // 特效在本地的路径
@property (nonatomic, assign) int minValue;   // 特效强度最小值
@property (nonatomic, assign) int maxValue;   // 特效强度最大值
@property (nonatomic, assign) int value;      // 特效强度当前值
@property (nonatomic, assign) int defaultValue;      // 特效强度默认值
@property (getter=isHasSelected, nonatomic, assign) BOOL hasSelected; // 是否选中过（获取特效强度的时候使用）
@property (getter=isSelected, nonatomic, assign) BOOL selected; // 是否选中当前特效

// 本地业务字段值重置
- (void)resetStatus;

@end

NS_ASSUME_NONNULL_END
