//
//  SYEffectsDataManager.h
//  MouseLive
//
//  Created by GasparChu on 2020/4/13.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYEffectsModel, SYEffectItem;
NS_ASSUME_NONNULL_BEGIN

/// 特效数据管理器
@interface SYEffectsDataManager : NSObject

+ (instancetype)sharedManager;

/// 下载特效数据
- (void)downloadEffectsData;

/// 获取特效数据
- (NSArray *)getEffectsData;

/// 获取默认美颜特效路径
- (NSString *)getBeautyEffectPath;

/// 下载特效
/// @param effectItem effectItem description
/// @param typeName typeName description
/// @param success success description
/// @param failure failure description
- (void)downloadWithEffectItem:(SYEffectItem *)effectItem
                      typeName:(NSString *)typeName
                       success:(dispatch_block_t _Nullable)success
                       faliure:(dispatch_block_t _Nullable)failure;

@end

NS_ASSUME_NONNULL_END
