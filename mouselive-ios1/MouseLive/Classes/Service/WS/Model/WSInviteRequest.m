//
//  WSInviteRequest.m
//  MouseLive
//
//  Created by 张建平 on 2020/3/17.
//  Copyright © 2020 sy. All rights reserved.
//

#import "WSInviteRequest.h"

@implementation WSInviteRequest

- (NSString *)getNowTimeStamp
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYYMMdd-HHmmss-SSS"]; // 设置想要的格式，hh与HH的区别:分别表示12小时制,24小时制
    //设置时区,这一点对时间的处理很重要
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *dateNow = [NSDate date];
//    NSString *timeStamp = [NSString stringWithFormat:@"%ld", (long)[dateNow timeIntervalSince1970]];
    NSString *now = [formatter stringFromDate:dateNow];
    return now;
}

- (NSString *)createTraceId
{
    self.TraceId = [NSString stringWithFormat:@"%lld-%@", self.SrcUid, [self getNowTimeStamp]];
    return self.TraceId;
}

- (NSString *)string
{
    return [NSString stringWithFormat:@"[SrcUid:%lld, SrcRoomId:%lld, DestUid:%lld, DestRoomId:%lld, ChatType:%d, TraceId:%@]",
            self.SrcUid, self.SrcRoomId, self.DestUid, self.DestRoomId, self.ChatType, self.TraceId];
}

@end
