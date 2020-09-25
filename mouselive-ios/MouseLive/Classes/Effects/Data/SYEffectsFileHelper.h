//
//  SYEffectsFileHelper.h
//  MouseLive
//
//  Created by GasparChu on 2020/4/13.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 美颜文件帮助类
@interface SYEffectsFileHelper : NSObject

/// 存储资源路径
/// @param typeName 资源的类型名称
+ (NSString *)effectsResourcePathWithTypeName:(NSString *)typeName;

/// 资源缓存是否存在
/// @param urlString 服务器的资源地址
/// @param typeName 资源的类型名称
+ (BOOL)cacheIsExistWithUrlString:(NSString *)urlString typeName:(NSString *)typeName;

/// 特效的路径地址
/// @param urlString urlString description
/// @param typeName typeName description
+ (NSString *)effectResourcePathWithUrlString:(NSString *)urlString typeName:(NSString *)typeName;

@end

NS_ASSUME_NONNULL_END
