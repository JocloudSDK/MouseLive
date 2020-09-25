//
//  WSInviteRequest.h
//  MouseLive
//
//  Created by 张建平 on 2020/3/17.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    WS_ROOM_TYPE_LIVE = 1,
    WS_ROOM_TYPE_CHAT,
    WS_ROOM_TYPE_KTV,
} WSRoomType;

@interface WSInviteRequest : WSBaseRequest

// 主动发送请求时， src 是 自己的，dst 是对方的
// 接受到请求时，如果是主播，src 是对方的，dst 是自己的； 如果是观众，判断 srcRid + dstRid 如果是自己房间，不做处理，如果是其他房间的，就要看是否订阅/取消订阅，还要看是否已经存在了

@property (nonatomic) long long SrcUid;
@property (nonatomic) long long SrcRoomId;
@property (nonatomic) long long DestUid;
@property (nonatomic) long long DestRoomId;
@property (nonatomic) int ChatType;  // 查看 RoomType
@property (nonatomic, copy) NSString *TraceId;

// 在设置过 srcUid 后调用
- (NSString *)createTraceId;

- (NSString *)string;

@end

NS_ASSUME_NONNULL_END
