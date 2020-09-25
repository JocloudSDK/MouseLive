//
//  LiveBeInvited.h
//  MouseLive
//
//  Created by 张建平 on 2020/3/10.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiveInviteItem.h"

typedef enum : NSUInteger {
    LIVE_BE_INVITED_CANCEL,
    LIVE_BE_INVITED_APPLY,
} LiveBeInvitedActiontype;

typedef void(^SendAcceptComplete)(NSError * _Nullable error, NSString * _Nonnull  roomid);

NS_ASSUME_NONNULL_BEGIN

@protocol LiveBeInvitedDelegate <NSObject>

/// 处理后的回调
/// @param type 请求 cmd
/// @param item 返回的数据
- (void)didBeInvitedWithCmd:(LiveBeInvitedActiontype)type item:(LiveInviteItem *)item;

@end


@interface LiveBeInvited : NSObject

/// 初始化
/// @param delegate 回调 delegate
- (instancetype)initWithDelegate:(id<LiveBeInvitedDelegate>)delegate;


/// 接受连麦请求 -- 返回连麦用户的 roomid
/// @param uid 连麦用户的 uid
- (void)acceptWithUid:(NSString *)uid complete:(SendAcceptComplete)complete;

/// 拒绝连麦请求
/// @param uid 连麦用户的 uid
- (void)refuseWithUid:(NSString *)uid complete:(SendComplete)complete;

/// 完成连麦请求
/// @param uid 连麦用户的 uid
- (void)completeWithUid:(NSString *)uid;

- (void)clearBeInvitedQueue;

/// 销毁
- (void)destory;

/// 处理接到的请求
/// @param cmd 请求 cmd
/// @param body 请求内容
- (BOOL)handleMsgWithCmd:(NSNumber *)cmd body:(NSDictionary *)body;

@end

NS_ASSUME_NONNULL_END
