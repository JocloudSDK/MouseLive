//
//  LiveInvite.h
//  MouseLive
//
//  Created by 张建平 on 2020/3/10.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiveInviteItem.h"
#import "WSInviteRequest.h"

typedef enum : NSUInteger {
    LIVE_INVITE_TYPE_ACCEPT,
    LIVE_INVITE_TYPE_REFUSE,
    LIVE_INVITE_TYPE_RUNNING,
    LIVE_INVITE_TYPE_TIME_OUT,
    LIVE_INVITE_TYPE_CHATING,
} LiveInviteActionType;

NS_ASSUME_NONNULL_BEGIN

@protocol LiveInviteDelegate <NSObject>

/// 处理后的回调
/// @param type 请求 cmd
/// @param item 返回的数据
- (void)didInviteWithCmd:(LiveInviteActionType)type item:(LiveInviteItem *)item;

@end

@interface LiveInvite : NSObject

/// 初始化
/// @param delegate 回调 delegate
/// @param uid 本地用户 uid
/// @param roomid 本地用户进入的房间 roomid
/// @param roomType 房间类型
- (instancetype)initWithDelegate:(id<LiveInviteDelegate>)delegate uid:(NSString *)uid roomid:(NSString *)roomid roomType:(LiveType)roomType;

/// 发送申请连麦请求
/// @param uid 要连麦用户 uid
/// @param roomid 要连麦用户 roomid
- (void)sendInvoteWithUid:(NSString *)uid roomId:(NSString *)roomid complete:(SendComplete)complete;

/// 取消连麦
- (void)cancelWithComplete:(SendComplete)complete;

/// 处理接到的请求
/// @param cmd 请求 cmd
/// @param body 请求内容
- (BOOL)handleMsgWithCmd:(NSNumber *)cmd body:(NSDictionary *)body;

@end

NS_ASSUME_NONNULL_END
