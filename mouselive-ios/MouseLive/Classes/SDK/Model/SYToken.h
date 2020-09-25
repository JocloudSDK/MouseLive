//
//  SYToken.h
//  MouseLive
//
//  Created by 张建平 on 2020/4/23.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^TokenComplete)(NSString * _Nonnull token, NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface SYToken : NSObject

@property (nonatomic, copy) NSString* thToken;  // Thunder 和 Hummer 的 token， 直接获取不会强制更新，只有过期了，才会强制更新
@property (nonatomic, copy) NSString *localUid; // 本地用户 uid
@property (nonatomic, assign, readonly) int validTime;  // token 过期时间：单位秒：比如：3600：一小时

+ (instancetype)sharedInstance;

/// 强制更新 token
- (void)updateTokenWithComplete:(TokenComplete)complete;

@end

NS_ASSUME_NONNULL_END
