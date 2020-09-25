//
//  ParameterHelper.m
//  MouseLive
//
//  Created by 张骥 on 2020/5/15.
//  Copyright © 2020 sy. All rights reserved.
//

#import "ParameterHelper.h"
#import "SYAppId.h"
#import "SYAppInfo.h"
#import "SYToken.h"

@implementation ParameterHelper

+ (NSDictionary *)parametersForRequest:(RequestType)type additionInfo:(NSDictionary * _Nullable)info
{
    NSMutableDictionary *paras = [[NSMutableDictionary alloc] initWithDictionary:[ParameterHelper defaultParamatersWithAdditionInfo:info]];
    
    switch (type) {
        case Http_GetToken: {
            [paras setObject:@([SYToken sharedInstance].validTime) forKey:kValidTime];
            break;
        }
        case Http_Login: {
            [paras setObject:@([SYToken sharedInstance].validTime) forKey:kValidTime];
            [paras setObject:[SYAppInfo sharedInstance].DevName forKey:kDevName];
            [paras setObject:[SYAppInfo sharedInstance].DevUUID forKey:kDevUUID];
            break;
        }
        case Http_GetUserInfo:
            break;
        case Http_CreateRoom:
            break;
        case Http_GetRoomList: {
            [paras setObject:@(0) forKey:kOffset];
            [paras setObject:@(20) forKey:kLimit];
            break;
        }
        case Http_SetRoomMic: {
            [paras removeObjectForKey:kUid];
            break;
        }
        default:
            break;
    }
    
    return paras;
}

+ (NSDictionary *)defaultParamatersWithAdditionInfo:(NSDictionary * _Nullable)info
{
    NSMutableDictionary *paras = [[NSMutableDictionary alloc] initWithDictionary:info];
    NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey:kUid];
    NSString *requestUid = [info valueForKey:kUid];
    
    if (!uid) {
        uid = @"0";
    }
    
    if (requestUid) {
        uid = requestUid;
    }
    
    [paras setObject:@([uid intValue]) forKey:kUid];
    [paras setObject:@([kSYAppId intValue]) forKey:kAppId];
    [paras setObject:[SYAppInfo sharedInstance].SvrVer forKey:kSvrVer];
    
    return paras;
}

@end
