//
//  SYHummerManager.m
//  MouseLive
//
//  Created by 张建平 on 2020/3/17.
//  Copyright © 2020 sy. All rights reserved.
//

#import "SYHummerManager.h"
#import "SYCommonMacros.h"
#import "SYUtils.h"
#import "HMRUser+SYAdditions.h"
#import "HMRChatRoom+SYAdditions.h"
#import "SYDataEnvironment.h"
#import "HMRSignalContent.h"
#import "SYAppInfo.h"
#import <YYModel.h>
#import "SYToken.h"

static NSString * const g_AllMicOff = @"isAllMicOff";
static NSString * const g_AllMute = @"isAllMute";
static NSString * const g_TAG = @"[MouseLive-Hummer]";
static NSString * const kHMRAdminRole = @"Admin";


@interface SYHummerManager () <HMRMessageObserver, HMRChatRoomMemberObserver, HMRChatRoomObserver, HMRChannelStateObserver, HMRHummerStateObserver>

@property (nonatomic, copy, readwrite) NSString *uid;
@property (nonatomic, assign, readwrite) BOOL isLoggedIn;  // 是否已登录
@property (nonatomic, assign, readwrite) BOOL isMuted; // 用户是否被禁言
@property (nonatomic, assign, readwrite) BOOL isMicOff; // 用户是否禁麦
@property (nonatomic, assign, readwrite) BOOL isAdmin; // 是否是管理员
@property (nonatomic, assign, readwrite) BOOL isOwner; // 房主
@property (nonatomic, strong) HMRChatRoom *chatRoom;  // 保存 chatroom
@property (nonatomic, strong) NSMutableDictionary<NSString *, SYUser *> *userDic;  // 保护用户数据
@property (nonatomic, weak) id<SYHummerManagerObserver> observer;
@property (nonatomic, assign) BOOL isAllMuted;  // 用于内部发送请求
@property (nonatomic, assign) BOOL isAllMicOff;  // 用于内部发送请求
@property (nonatomic, assign) int tokenUpdateCount; // token 更新次数 -- 暂时先不用，没有 token 鉴权成功的回调

@end

@implementation SYHummerManager

+ (instancetype)sharedManager
{
    static SYHummerManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userDic = [[NSMutableDictionary alloc] init];
        [self setupHummerSDK];
        self.isAdmin = NO;
        self.isOwner = NO;
    }
    return self;
}

#pragma mark - Setup

- (void)setupHummerSDK
{
    // 1. 创建 Hummer 通道
    HMRServiceChannel *channel = [[HMRServiceChannel alloc] initWithMode:[HMRServiceChannelAutonomousMode modeWithTokenType:HMRTokenTypeThird]];
    
    // 2. 注册 Hummer 通道
    [Hummer registerChannel:channel completionHandler:^(NSError *error) {
        YYLogDebug(@"[MouseLive-Hummer] Hummer registerChannel error:%@", error);
    }];
    
    // 3. 注册观察者
    [self addDependentObserver];
    
    // 4. 初始化 Hummer SDK
    [Hummer startSDKWithAppId:[SYAppInfo sharedInstance].appId.longLongValue];

#ifndef DEBUG
    // 业务可以通过一下方法来设置 SDK 日志输出，即将日志托管给业务
    [Hummer setLogger:^(HMRLoggerLevel level, NSString * _Nonnull log) {
        switch (level) {
                case HMRLoggerLevelError:
                    YYLogDebug(@"[MouseLive-Hummer]  error %@", log);
                    break;
                case HMRLoggerLevelWarning:
                    YYLogDebug(@"[MouseLive-Hummer]  warning %@", log);
                    break;
                case HMRLoggerLevelInfo:
                    YYLogDebug(@"[MouseLive-Hummer]  info %@", log);
                    break;
                case HMRLoggerLevelDebug:
                    YYLogDebug(@"[MouseLive-Hummer]  debug %@", log);
                    break;
                case HMRLoggerLevelVerbose:
                    YYLogDebug(@"[MouseLive-Hummer]  verbose %@", log);
                    break;
        }
    }];
#endif
    
//    // zhangjianping App退出时退出聊天室
//    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
//        // 离开聊天室
//        [[HMRChatRoomService instance] leaveChatRoom:self.chatRoom completionHandler:^(NSError *error) {
//            if (error) {
//                YYLogDebug(@"[MouseLive-Hummer]  Leave chat room error: %@", error);
//            }
//        }];
//    }];
}

#pragma mark - Private

- (void)addDependentObserver
{
    // 添加需要观察的事件
    // 添加消息通道相关的监听（收发消息等通知回调）
    [[HMRChatService instance] addMessageObserver:self forTarget:self.chatRoom];
    // 添加聊天室成员回调监听（用户加入和退出聊天室，被禁言和恢复禁言，被踢出等回调）
    
    [[HMRChatRoomService instance] addMemberObserver:self];
    
    // 添加聊天室回调监听（聊天室被关闭等回调）
    [[HMRChatRoomService instance] addChatRoomObserver:self];
    
    // 增加 addChannelStateObserver，channel 状态
    [Hummer addChannelStateObserver:self];
    
    // 增加 state 状态
    [Hummer addStateObserver:self];
}

- (NSDictionary *)_yy_dictionaryWithJSON:(id)json
{
    if (!json || json == (id)kCFNull) {
        return nil;
    }
    NSDictionary *dic = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding : NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            dic = nil;
        }
    }
    return dic;
}

- (void)showErrorLog:(const char *)funcName error:(NSError *)error
{
    if (error) {
        NSString *msg = [NSString stringWithFormat:@"%@ %s, error:%@", g_TAG, funcName, error];
        [MBProgressHUD yy_showError:msg];
        YYLogError(@"[MouseLive-Hummer] %@", msg);
    }
    else {
        NSString *msg = [NSString stringWithFormat:@"%@ %s, 成功!!!!", g_TAG, funcName];
        YYLogDebug(@"[MouseLive-Hummer] %@", msg);
    }
}

#pragma mark - Public

- (void)addHummerObserver:(id<SYHummerManagerObserver>)Observer
{
    self.observer = Observer;
}

- (void)removeHummerObserver:(id<SYHummerManagerObserver>)Observer
{
    self.observer = nil;
}

- (void)loginWithUid:(NSString *)uid completionHandler:(SYCompletionHandler)completionHandler
{
    YYLogDebug(@"[MouseLive-Hummer] loginWithUid entry, uid:%@", uid);
    
    // 登录
    WeakSelf
    __block int count = 0;
    [Hummer openWithUid:uid.longLongValue environment:@"china/private/share" msgFetchStrategy:HMRContinuously tags:nil token: [SYToken sharedInstance].thToken completionHandler:^(NSError *error) {
        NSError *err = error;
        [weakSelf showErrorLog:__PRETTY_FUNCTION__ error:error];

        if (count >= 3) {
            if (completionHandler) {
                NSError *error = [NSError errorWithDomain:@"登陆失败" code:HUMMER_ERROR_OPEN_FAILED userInfo:nil];
                completionHandler(error);
                [weakSelf showErrorLog:__PRETTY_FUNCTION__ error:error];
            }
            return;
        }
        
        // 未退出继续登录的情况
        if (error.code == 1008) {
            err = nil;
        }
        else if (error.code == 1011) {
            // 需要关闭，并重新登陆
            YYLogDebug(@"[MouseLive-Hummer] loginWithUid error.Code = 1011, 需要关闭在重新 open");
            [weakSelf logoutWithCompletionHandler:^(NSError * _Nullable error) {
                count++;
                [weakSelf loginWithUid:uid completionHandler:completionHandler];
            }];
        }

        if (!err) {
            weakSelf.uid = uid;
            weakSelf.isLoggedIn = YES;
        }
        
        if (completionHandler) {
            completionHandler(err);
        }
    }];
    YYLogDebug(@"[MouseLive-Hummer] loginWithUid exit");
}

- (void)logoutWithCompletionHandler:(SYCompletionHandler)completionHandler
{
    YYLogDebug(@"[MouseLive-Hummer] logoutWithCompletionHandler entry");
    WeakSelf
    // 退出登录
    [Hummer closeWithCompletionHandler:^(NSError *error) {
        [self showErrorLog:__PRETTY_FUNCTION__ error:error];
        
        if (!error) {
            weakSelf.isLoggedIn = NO;
        }
        
        if (completionHandler) {
            completionHandler(error);
        }
    }];
    YYLogDebug(@"[MouseLive-Hummer] logoutWithCompletionHandler exit");
}


#pragma mark - Chat

- (void)createChatRoomWithCompletionHandler:(SYCharRoomCompletionHandler)completionHandler
{
    NSString *roomName = [NSString stringWithFormat:@"SY-%@", [SYUtils generateRandomNumberWithDigitCount:6]];
    
    YYLogDebug(@"[MouseLive-Hummer] createChatRoomWithCompletionHandler entry, roomName:%@", roomName);
    WeakSelf
    // 创建聊天室信息
    HMRChatRoomInfo *chatRoomInfo = [HMRChatRoomInfo chatRoomInfoWithName:roomName description:roomName bulletin:nil appExtra:nil];
    
    self.tokenUpdateCount = 0;
    
    // 创建聊天室
    [[HMRChatRoomService instance] createChatRoom:chatRoomInfo completionHandler:^(HMRChatRoom *chatRoom, NSError *error) {
        [weakSelf showErrorLog:__PRETTY_FUNCTION__ error:error];
        
        if (error) {
            if (completionHandler) {
                completionHandler([NSString stringWithFormat:@"%llu",chatRoom.ID], error);
            }
        }
        else {
            weakSelf.chatRoom = chatRoom;
            weakSelf.isAdmin = YES;
            weakSelf.isOwner = YES;
            
            NSString *roomid = [NSString stringWithFormat:@"%llu",chatRoom.ID];
            [weakSelf joinChatRoomWithRoomId:roomid completionHandler:^(NSError * _Nullable error) {
                YYLogDebug(@"[MouseLive-Hummer] joinChatRoomWithRoomId");
                [weakSelf showErrorLog:__PRETTY_FUNCTION__ error:error];

                if (completionHandler) {
                    completionHandler([NSString stringWithFormat:@"%llu",chatRoom.ID], error);
                }
            }];
        }
    }];
    YYLogDebug(@"[MouseLive-Hummer] createChatRoomWithCompletionHandler exit");
}

- (void)joinChatRoomWithRoomId:(NSString *)roomId completionHandler:(SYCompletionHandler)completionHandler
{
    YYLogDebug(@"[MouseLive-Hummer] joinChatRoomWithRoomId entry");
    WeakSelf
    HMRChatRoom *chatRoom = [HMRChatRoom chatRoomWithID:roomId.longLongValue];
    self.tokenUpdateCount = 0;
    [[HMRChatRoomService instance] joinChatRoom:chatRoom extraProps:nil completionHandler:^(NSError *error) {
        if (!error) {
            weakSelf.chatRoom = chatRoom;

            // 获取基本属性
            [[HMRChatRoomService instance] fetchBasicInfo:weakSelf.chatRoom completionHandler:^(HMRChatRoomInfo * _Nullable chatRoomInfo, NSError * _Nullable error) {
                YYLogDebug(@"[MouseLive-Hummer] joinChatRoomWithRoomId");
                if (!error) {
                    weakSelf.isMicOff = NO;
                    weakSelf.isMuted = NO;
                    weakSelf.isAllMicOff = NO;
                    weakSelf.isAllMuted = NO;
                    [weakSelf decodeExtention:chatRoomInfo.appExtra];
                    YYLogDebug(@"[MouseLive-Hummer] joinChatRoomWithRoomId fetchBasicInfo success");
                } else {
                    [weakSelf showErrorLog:__PRETTY_FUNCTION__ error:error];

                }
                YYLogDebug(@"fetchBasicInfo, appExtra:%@", chatRoomInfo.appExtra);
            }];
        }
        else {
            [weakSelf showErrorLog:__PRETTY_FUNCTION__ error:error];
        }
        if (completionHandler) {
            completionHandler(error);
        }
    }];
    YYLogDebug(@"[MouseLive-Hummer] joinChatRoomWithRoomId exit");
}

- (void)leaveChatRoomWithCompletionHandler:(SYCompletionHandler)completionHandler
{
    YYLogDebug(@"[MouseLive-Hummer] leaveChatRoomWithCompletionHandler entry");
    if (!self.chatRoom) {
        YYLogDebug(@"[MouseLive-Hummer] leaveChatRoomWithCompletionHandler 没有进入房间");
        return;
    }

    [[HMRChatRoomService instance] leaveChatRoom:self.chatRoom completionHandler:^(NSError *error) {
        if (completionHandler) {
            completionHandler(error);
        }
    }];
    
    if (self.isOwner) {
        // 销毁房间
        [[HMRChatRoomService instance] dismissChatRoom:self.chatRoom completionHandler:^(NSError *error) {
            YYLogDebug(@"[MouseLive-Hummer] leaveChatRoomWithCompletionHandler 销毁房间");
        }];
    }
    
    self.isMuted = NO;
    self.isMicOff = NO;
    self.isAdmin = NO;
    self.isOwner = NO;
    self.chatRoom = nil;
    [self.userDic removeAllObjects];
    self.observer = nil;
    self.isAllMuted = NO;
    self.isAllMicOff = NO;
    YYLogDebug(@"[MouseLive-Hummer] leaveChatRoomWithCompletionHandler exit");
}

#pragma mark - Members

// 获取观众列表
- (void)fetchAudienceMembersWithCompletionHandler:(SYFetchAudienceMembersCompletionHandler)completionHandler
{
    YYLogDebug(@"[MouseLive-Hummer] fetchAudienceMembersWithCompletionHandler entry");
    WeakSelf
    // 获取聊天室成员列表
    [[HMRChatRoomService instance] fetchMembers:self.chatRoom offset:0 num:300 completionHandler:^(NSSet<HMRUser *> * _Nullable members, NSError * _Nullable error) {
        [weakSelf showErrorLog:__PRETTY_FUNCTION__ error:error];
        if (error) {
            if (completionHandler) {
                completionHandler(nil, error);
            }
        }
        else {
            NSMutableArray *targetMembers = [[NSMutableArray alloc] initWithCapacity:members.count];
            [members enumerateObjectsUsingBlock:^(HMRUser * _Nonnull obj, BOOL * _Nonnull stop) {
                if (weakSelf.chatRoom.sy_roomOwner.ID != obj.ID) {
                    SYUser *user = [[SYUser alloc] initWithHummerUser:obj];
                    [targetMembers addObject:user];
                    [weakSelf.userDic setObject:user forKey:[NSString stringWithFormat:@"%llu", obj.ID]];
                }
            }];
            
            if (completionHandler) {
                completionHandler([targetMembers copy], error);
            }
        }
    }];
    YYLogDebug(@"[MouseLive-Hummer] fetchAudienceMembersWithCompletionHandler exit");
}

- (void)fetchMembersWithCompletionHandler:(SYFetchMembersCompletionHandler)completionHandler
{
    YYLogDebug(@"[MouseLive-Hummer] fetchMembersWithCompletionHandler entry");
    WeakSelf
    // 获取聊天室成员列表
    [[HMRChatRoomService instance] fetchMembers:self.chatRoom offset:0 num:300 completionHandler:^(NSSet<HMRUser *> * _Nullable members, NSError * _Nullable error) {
        [weakSelf showErrorLog:__PRETTY_FUNCTION__ error:error];
        
        if (error) {
            if (completionHandler) {
                completionHandler(nil, error);
            }
        }
        else {
            NSMutableArray *targetMembers = [[NSMutableArray alloc] initWithCapacity:members.count];
            [members enumerateObjectsUsingBlock:^(HMRUser * _Nonnull obj, BOOL * _Nonnull stop) {
                SYUser *user = [[SYUser alloc] initWithHummerUser:obj];
                [targetMembers addObject:user];
                [weakSelf.userDic setObject:user forKey:[NSString stringWithFormat:@"%llu", obj.ID]];
            }];
            [weakSelf fetchMutedUsersWithMembers:targetMembers completionHandler:completionHandler];
        }
    }];
    YYLogDebug(@"[MouseLive-Hummer] fetchMembersWithCompletionHandler exit");
}

- (void)fetchMutedUsers:(SYFetchMembersCompletionHandler)completionHandler
{
    [[HMRChatRoomService instance] fetchMutedUsers:self.chatRoom completionHandler:^(NSSet<HMRUser *> *mutedMembers, NSError * _Nullable mutedError) {
        if (mutedError) {
            if (completionHandler) {
                completionHandler(nil, mutedError);
            }
        } else {
            if (completionHandler) {
                completionHandler([mutedMembers copy], nil);
            }
        }
    }];
}

- (void)fetchRoleMember:(SYFetchMembersCompletionHandler)completionHandler
{
    [[HMRChatRoomService instance] fetchRoleMembers:self.chatRoom onlineOnly:NO completionHandler:^(NSDictionary<NSString *,NSSet<HMRUser *> *> * _Nullable roleToMembers, NSError * _Nullable error) {
        if (error) {
            if (completionHandler) {
                completionHandler(nil, error);
            }
        } else {
            NSSet<HMRUser *> * roleMembers = [roleToMembers objectForKey:HMRAdminRole];
            
            if (completionHandler) {
                completionHandler([roleMembers copy], nil);
            }
        }
    }];
}

- (void)fetchRoomInfo:(SYCompletionHandler)completionHandler
{
    WeakSelf
    [[HMRChatRoomService instance] fetchBasicInfo:self.chatRoom completionHandler:^(HMRChatRoomInfo * _Nullable chatRoomInfo, NSError * _Nullable error) {
        if (!error) {
            weakSelf.isMicOff = NO;
            weakSelf.isMuted = NO;
            weakSelf.isAllMicOff = NO;
            weakSelf.isAllMuted = NO;
            [weakSelf decodeExtention:chatRoomInfo.appExtra];
        } else {
            if (completionHandler) {
                completionHandler(error);
            }
        }
    }];
}

- (void)fetchMutedUsersWithMembers:(NSMutableArray<SYUser *> *)members completionHandler:(SYFetchMembersCompletionHandler)completionHandler
{
    YYLogDebug(@"[MouseLive-Hummer] fetchMutedUsersWithMembers entry");
    WeakSelf
    // 获取聊天室内的禁言列表
    [[HMRChatRoomService instance] fetchMutedUsers:self.chatRoom completionHandler:^(NSSet<HMRUser *> *mutedMembers, NSError * _Nullable mutedError) {
        [weakSelf showErrorLog:__PRETTY_FUNCTION__ error:mutedError];
        
        if (mutedError) {
            if (completionHandler) {
                completionHandler(nil, mutedError);
            }
        }
        else {
            // TODO: 这里有问题，全局禁言下，第三人进入时候，无法判断个人是禁言+解禁
            if (mutedMembers.count > 0) {
                for (SYUser* member in members) {
                    [mutedMembers enumerateObjectsUsingBlock:^(HMRUser *mutedUser, BOOL *mutedStop) {
                        if (member.hummerUser.ID == mutedUser.ID) {
                            member.isMuted = YES;
                            member.isAdmin = NO;
                            *mutedStop = YES;
                        }
                        if ([HMRMe getMe].ID == mutedUser.ID) {
                            [SYHummerManager sharedManager].isMuted = YES;
                        }
                    }];
                    
                    // 如果是全员禁言了，新获取的用户，看已经在线的用户，以全员属性为主
                    if ([SYHummerManager sharedManager].isAllMuted) {
                        member.isMuted = YES;
                    }
                }
            }

            [weakSelf fetchRoleUsersWithMembers:members completionHandler:completionHandler];
        }
    }];
    YYLogDebug(@"[MouseLive-Hummer] fetchMutedUsersWithMembers exit");
}

- (void)fetchRoleUsersWithMembers:(NSMutableArray<SYUser *> *)members completionHandler:(SYFetchMembersCompletionHandler)completionHandler
{
    YYLogDebug(@"[MouseLive-Hummer] fetchRoleUsersWithMembers entry");
    WeakSelf
    // 获取聊天室内的管理员列表
    [[HMRChatRoomService instance] fetchRoleMembers:self.chatRoom onlineOnly:NO completionHandler:^(NSDictionary<NSString *,NSSet<HMRUser *> *> * _Nullable roleToMembers, NSError * _Nullable error) {
        [weakSelf showErrorLog:__PRETTY_FUNCTION__ error:error];
        
        if (error) {
             if (completionHandler) {
                 completionHandler(nil, error);
             }
         }
        else {
            NSSet<HMRUser *> * roleMembers = [roleToMembers objectForKey:HMRAdminRole];
            if (roleMembers && roleMembers.count > 0) {
                YYLogDebug(@"[MouseLive-Hummer] fetchRoleUsersWithMembers have role members");
                int index = 0;
                for (SYUser* member in members) {
                    [roleMembers enumerateObjectsUsingBlock:^(HMRUser *roleUser, BOOL *mutedStop) {
                        if (member.hummerUser.ID == roleUser.ID) {
                            member.isAdmin = YES;
                            *mutedStop = YES;
                        }
                        if ([HMRMe getMe].ID == roleUser.ID) {
                            [SYHummerManager sharedManager].isAdmin = YES;
                        }
                    }];
                    
                    YYLogDebug(@"[MouseLive-Hummer] fetchRoleUsersWithMembers members[%d] uid:%lld  admin:%d  muted:%d", index++, member.hummerUser.ID, member.isAdmin, member.isMuted);
                }
            }
            else {
                YYLogDebug(@"[MouseLive-Hummer] fetchRoleUsersWithMembers no role members");
            }

            if (completionHandler) {
                completionHandler([members copy], error);
            }
         }
    }];
    YYLogDebug(@"[MouseLive-Hummer] fetchRoleUsersWithMembers exit");
}



//fetchMutedUsers
//fetchRoleMembers

// ---  先不做操作
//- (void)fetchMutedUsersWithMembers:(NSSet<HMRUser *> *)members completionHandler:(SYFetchMembersCompletionHandler)completionHandler
//{
//    // 获取聊天室内的禁言列表
//    [[HMRChatRoomService instance] fetchMutedUsers:self.chatRoom completionHandler:^(NSSet<HMRUser *> *mutedMembers, NSError * _Nullable mutedError) {
//        if (mutedError) {
//            if (completionHandler) {
//                completionHandler(nil, mutedError);
//            }
//        } else {
//            // 这里需要判断一下禁言的 user 和 self.userDic
//            NSMutableArray *targetMembers = [[NSMutableArray alloc] initWithCapacity:members.count];
//
//            [members enumerateObjectsUsingBlock:^(HMRUser *user, BOOL *stop) {
//                SYUser *targetUser = [[SYUser alloc] initWithHummerUser:user];
//                [mutedMembers enumerateObjectsUsingBlock:^(HMRUser *mutedUser, BOOL *mutedStop) {
//                    if (user.ID == mutedUser.ID) {
//                        targetUser.isMuted = YES;
//                        *mutedStop = YES;
//                    }
//                }];
//
//                if (self.uid.longLongValue == user.ID) {
//                    targetUser.isRoomOwner = YES;
//                }
//
//                if (targetUser.isRoomOwner) {
//                    [targetMembers insertObject:targetUser atIndex:0];
//                } else {
//                    [targetMembers addObject:targetUser];
//                }
//            }];
//
//            if (completionHandler) {
//                completionHandler([targetMembers copy], mutedError);
//            }
//        }
//
//    }];
//}


#pragma mark - SendMessage

- (BOOL)isMutedWithCompletionHandler:(HMRCompletionHandler)completionHandler funName:(const char *)funcName
{
    return NO;
//    if (self.isMuted) {
//        // 如果是已经被禁言了
//        NSError* error = [NSError errorWithDomain:@"已经被禁言" code:HUMMER_ERROR_MUTED userInfo:nil];
//        completionHandler(error);
//        YYLogError(@"[MouseLive-Hummer] isMutedWithCompletionHandler, 已经被禁言");
//        [self showErrorLog:funcName error:error];
//        return YES;
//    }
//    return NO;
}

- (BOOL)isHavePermissionWithCompletionHandler:(HMRCompletionHandler)completionHandler funName:(const char *)funcName
{
    if (!self.isAdmin) {
        // 没有权限
        NSError *error = [NSError errorWithDomain:@"没有权限" code:HUMMER_ERROR_NO_PERMISSION userInfo:nil];
        completionHandler(error);
        [self showErrorLog:funcName error:error];
        return NO;
    }
    return YES;
}

- (BOOL)isOwnerWithCompletionHandler:(HMRCompletionHandler)completionHandler funName:(const char *)funcName
{
    if (!self.isOwner) {
        // 没有权限
        NSError *error = [NSError errorWithDomain:@"没有权限" code:HUMMER_ERROR_NO_PERMISSION userInfo:nil];
        completionHandler(error);
        [self showErrorLog:funcName error:error];
        return NO;
    }
    return YES;
}

#pragma mark -- 去掉
- (void)sendSignalMessage:(NSString *)message receiver:(NSString *)receiverUid completionHandler:(HMRCompletionHandler)completionHandler
{
    YYLogDebug(@"[MouseLive-Hummer] sendSignalMessage entry, message:%@, receiverUid:%@", message, receiverUid);
    if ([self isMutedWithCompletionHandler:completionHandler funName:"sendSignalMessage"]) {
        return;
    }
    
    SYUser *user = [self.userDic objectForKey:receiverUid];
    if (user) {
        HMRUser *receiver = [self.userDic objectForKey:receiverUid].hummerUser;
        HMRSignalContent *content = [HMRSignalContent unicstWithUser:receiver content:message];
        HMRMessage *aMessage = [HMRMessage messageWithContent:content receiver:self.chatRoom];
        [[HMRChatService instance] sendMessage:aMessage completionHandler:completionHandler];
    }
    else {
        if (completionHandler) {
            NSError *error = [NSError errorWithDomain:@"没有此用户" code:HUMMER_ERROR_NO_USER userInfo:nil];
            completionHandler(error);
            [self showErrorLog:__PRETTY_FUNCTION__ error:error];
        }
    }
    YYLogDebug(@"[MouseLive-Hummer] sendSignalMessage exit");
}

#pragma mark -- 去掉
// 发送广播消息
- (void)sendBroadcastMessage:(NSString *)message completionHandler:(SYCompletionHandler)completionHandler
{
    YYLogDebug(@"[MouseLive-Hummer] sendBroadcastMessage entry, message:%@", message);
    WeakSelf
    if ([self isMutedWithCompletionHandler:completionHandler funName:"sendBroadcastMessage"]) {
        return;
    }
    
    HMRMessage *hmrMessage = [HMRMessage messageWithContent:[HMRTextContent contentWithText:message] receiver:self.chatRoom];
    
    // 发送消息
    [[HMRChatService instance] sendMessage:hmrMessage completionHandler:^(NSError *error) {
        [weakSelf showErrorLog:__PRETTY_FUNCTION__ error:error];
        
        if (error) {
            // 在聊天室中发送文本，如果 error.code 为 HMRForbiddenErrorCode 则表示被禁言
            if (error.code == HMRForbiddenErrorCode) {
                weakSelf.isMuted = YES;
            }
        }
        else {
            weakSelf.isMuted = NO;
        }
        
        YYLogDebug(@"[MouseLive-Hummer] sendBroadcastMessage isMuted:%d", self.isMuted);
        
        if (completionHandler) {
            completionHandler(error);
        }
    }];
    YYLogDebug(@"[MouseLive-Hummer] sendBroadcastMessage exit");
}

/// 发送给某人信令
- (void)sendSignalToTarget:(NSString *)receiverUid message:(NSString *)message completionHandler:(SYCompletionHandler)completionHandler
{
    
}

/// 发送给房间内所有人信令
- (void)sendSignalToAll:(NSString *)message completionHandler:(SYCompletionHandler)completionHandler
{
    
}

/// 发送给某人消息
- (void)sendMessageToTarget:(NSString *)receiverUid message:(NSString *)message completionHandler:(SYCompletionHandler)completionHandler
{
    
}

/// 发送给房间内所有人消息
- (void)sendMessageToAll:(NSString *)message completionHandler:(SYCompletionHandler)completionHandler
{
    
}

// 踢人
- (void)sendKickWithUid:(NSString *)uid completionHandler:(SYCompletionHandler)completionHandler
{
    YYLogDebug(@"[MouseLive-Hummer] sendKickWithUid entry, uid:%@", uid);
    WeakSelf
    HMRUser *user = [HMRUser userWithID:[uid intValue]];
    [[HMRChatRoomService instance] kickMember:user fromChatRoom:self.chatRoom extraInfo:@{HMRKickReasonExtraKey:@"房主踢出"} completionHandler:^(NSError *error) {
        if (error) {
            if (completionHandler) {
                NSError *error = [NSError errorWithDomain:@"踢出房间失败" code:HUMMER_ERROR_KICK userInfo:nil];
                completionHandler(error);
                [weakSelf showErrorLog:__PRETTY_FUNCTION__ error:error];
            }
        }
        else {
            if (completionHandler) {
                completionHandler(error);
                YYLogDebug(@"[MouseLive-Hummer] kickMember success uid:%@",uid);
            }
        }
    }];
    
    YYLogDebug(@"[MouseLive-Hummer] sendKickWithUid exit");
}

// 禁言/解禁
- (void)sendMutedWithUid:(NSString *)uid muted:(BOOL)muted completionHandler:(SYCompletionHandler)completionHandler
{
    YYLogDebug(@"[MouseLive-Hummer] sendMutedWithUid entry, uid:%@, muted:%d", uid, muted);
    WeakSelf
    
    HMRUser *user = [HMRUser userWithID:uid.intValue];
    if (muted) {
        [[HMRChatRoomService instance] muteMember:user inChatRoom:self.chatRoom reason:@"禁言" completionHandler:^(NSError *error) {
            if (error) {
                if (completionHandler) {
                    NSError *error = [NSError errorWithDomain:@"禁言失败" code:HUMMER_ERROR_MUTE userInfo:nil];
                    completionHandler(error);
                    [weakSelf showErrorLog:__PRETTY_FUNCTION__ error:error];
                }
            }
            else {
                if (completionHandler) {
                    completionHandler(error);
                    YYLogDebug(@"[MouseLive-Hummer] muteMember success uid:%@",uid);

                }
            }
        }];
    }
    else {
        [[HMRChatRoomService instance] unmuteMember:user inChatRoom:self.chatRoom reason:@"解禁" completionHandler:^(NSError *error) {
            if (error) {
                if (completionHandler) {
                    NSError *error = [NSError errorWithDomain:@"解禁失败" code:HUMMER_ERROR_MUTE userInfo:nil];
                    completionHandler(error);
                    [weakSelf showErrorLog:__PRETTY_FUNCTION__ error:error];
                }
            }
            else {
                if (completionHandler) {
                    completionHandler(error);
                    YYLogDebug(@"[MouseLive-Hummer] unmuteMember success uid:%@",uid);
                }
            }
        }];
    }
    YYLogDebug(@"[MouseLive-Hummer] sendMutedWithUid exit");
}

// 全体禁言/解禁
- (void)sendAllMutedWithMuted:(BOOL)muted completionHandler:(SYCompletionHandler)completionHandler
{
    YYLogDebug(@"[MouseLive-Hummer] sendAllMutedWithMuted entry, muted:%d", muted);
 
    [[HMRChatRoomService instance] changeBasicInfo:@{@(HMRChatRoomBasicInfoTypeExtention):[self encodeExtentionWithAllMute:muted allMicOff:self.isAllMicOff]} forChatRoom:self.chatRoom completionHandler:^(NSError *error) {
        [self showErrorLog:__PRETTY_FUNCTION__ error:error];
        
        if (error) {
            if (completionHandler) {
                NSString *str = @"禁言失败";
                if (!muted) {
                    str = @"解禁失败";
                }
                NSError *error = [NSError errorWithDomain:str code:HUMMER_ERROR_MUTE userInfo:nil];
                completionHandler(error);
                [self showErrorLog:__PRETTY_FUNCTION__ error:error];
            }
        }
        else {
            if (completionHandler) {
                completionHandler(error);
            }
        }
    }];
    YYLogDebug(@"[MouseLive-Hummer] sendAllMutedWithMuted exit");
}

// 全体禁麦/开麦
- (void)sendAllMicOffWithOff:(BOOL)off completionHandler:(SYCompletionHandler)completionHandler;
{
    YYLogDebug(@"[MouseLive-Hummer] sendAllMicOffWithOff entry, off:%d", off);
    WeakSelf
    [[HMRChatRoomService instance] changeBasicInfo:@{@(HMRChatRoomBasicInfoTypeExtention):[self encodeExtentionWithAllMute:self.isAllMuted allMicOff:off]} forChatRoom:self.chatRoom completionHandler:^(NSError *error) {
        [weakSelf showErrorLog:__PRETTY_FUNCTION__ error:error];
        
        if (error) {
            if (completionHandler) {
                NSString *str = @"闭麦失败";
                if (!off) {
                    str = @"开麦失败";
                }
                NSError *error = [NSError errorWithDomain:str code:HUMMER_ERROR_MIC_OFF userInfo:nil];
                completionHandler(error);
                [weakSelf showErrorLog:__PRETTY_FUNCTION__ error:error];
            }
        }
        else {
//            self.isAllMicOff = off;
            if (completionHandler) {
                completionHandler(error);
            }
        }
    }];
    YYLogDebug(@"[MouseLive-Hummer] sendAllMicOffWithOff exit");
}

// 提升管理员
- (void)addAdminWithUid:(NSString *)uid completionHandler:(SYCompletionHandler)completionHandler
{
    YYLogDebug(@"[MouseLive-Hummer] addAdminWithUid entry, uid:%@", uid);
    WeakSelf
    HMRUser *user = [HMRUser userWithID:uid.intValue];
    [[HMRChatRoomService instance] addRole:HMRAdminRole forMember:user chatRoom:self.chatRoom completionHandler:^(NSError *error) {
        if (error) {
            if (completionHandler) {
                NSError *error = [NSError errorWithDomain:@"添加管理员失败" code:HUMMER_ERROR_ROLE userInfo:nil];
                completionHandler(error);
                [weakSelf showErrorLog:__PRETTY_FUNCTION__ error:error];
            }
        } else {
            if (completionHandler) {
                completionHandler(error);
            }
            YYLogDebug(@"[MouseLive-Hummer] addAdminWithUid success uid:%@",uid);
        }
    }];
    
    YYLogDebug(@"[MouseLive-Hummer] addAdminWithUid exit");
}

// 撤销管理员
- (void)removeAdminWithUid:(NSString *)uid completionHandler:(SYCompletionHandler)completionHandler
{
    YYLogDebug(@"[MouseLive-Hummer] removeAdminWithUid entry, uid:%@", uid);
    WeakSelf

    HMRUser *user = [HMRUser userWithID:uid.intValue];
    
    [[HMRChatRoomService instance] removeRole:HMRAdminRole forMember:user chatRoom:self.chatRoom completionHandler:^(NSError *error) {
        
        if (error) {
            if (completionHandler) {
                NSError *error = [NSError errorWithDomain:@"撤销管理员失败" code:HUMMER_ERROR_ROLE userInfo:nil];
                completionHandler(error);
                [weakSelf showErrorLog:__PRETTY_FUNCTION__ error:error];
            }
        }
        else {
            if (completionHandler) {
                completionHandler(error);
            }
            YYLogDebug(@"[MouseLive-Hummer] removeRole success uid:%@",uid);
        }
    }];
    
    YYLogDebug(@"[MouseLive-Hummer] removeAdminWithUid exit");
}

#pragma mark - Get or Set

#pragma mark - HMRMessageObserver
/**
 即将发送聊天消息前会收到该事件的回调通知
 
 @param message 即将要发送的聊天消息
 */
- (void)willSendMessage:(HMRMessage *)message
{
    if (![message.receiver isEqual:self.chatRoom]) {
        return;
    }
}
/**
 发送完成聊天消息后会收到该事件的回调通知
 
 @param message 发送完成的聊天消息
 */
- (void)didSendMessage:(HMRMessage *)message
{
    if (![message.receiver isEqual:self.chatRoom]) {
        return;
    }
}
/**
 即将收到前会收到该事件的回调通知
 
 @param message 即将收到的聊天消息
 */
- (void)willReceiveMessage:(HMRMessage *)message
{
    if (![message.receiver isEqual:self.chatRoom]) {
        return;
    }
}
/**
 收到该消息会收到该事件的回调通知
 
 @param message 收到的聊天消息
 */
- (void)didReceiveMessage:(HMRMessage *)message
{
    // 用户自己是被 SDK 屏蔽的
    YYLogDebug(@"[MouseLive-Hummer] didReceiveMessage entry");
    
    // 不是该聊天室的消息不接收
    if (![message.receiver isEqual:self.chatRoom]) {
        return;
    }

    if ([message.content isKindOfClass:HMRSignalContent.class]) {
        // 单播消息
        HMRSignalContent *signalContent = (HMRSignalContent *)message.content;
        NSString *messageContent = signalContent.content;
        id<HMRIdentifiable> sender = message.sender;
        id<HMRIdentifiable> receiver = message.receiver;
        
        // TODO: zhangjianping 有问题，怎么给自己的？？？
        if ([self.observer respondsToSelector:@selector(didReceivedSelfSignalMessageFrom:message:)]) {
            NSString *strSender = [NSString stringWithFormat:@"%llu", sender.ID];
            NSString *strReceiver = [NSString stringWithFormat:@"%llu", receiver.ID];
            YYLogDebug(@"[MouseLive-Hummer] didReceiveMessage didReceivedSignalMessageFrom, sender:%@, receiver:%@, message:%@", strSender, strReceiver, messageContent);
            [self.observer didReceivedSelfSignalMessageFrom:strSender message:messageContent];
        }
    }
    else if ([message.content isKindOfClass:HMRTextContent.class]) {
        // 广播消息
        HMRTextContent *content = (HMRTextContent *)message.content;
        if ([self.observer respondsToSelector:@selector(didReceivedBroadcastFrom:message:)]) {
            NSString *strSender = [NSString stringWithFormat:@"%llu", message.sender.ID];
            YYLogDebug(@"[MouseLive-Hummer] didReceiveMessage didReceivedBroadcastFrom, sender:%@, message:%@", strSender, content.text);
            [self.observer didReceivedBroadcastFrom:strSender message:content.text];
        }
    }
    YYLogDebug(@"[MouseLive-Hummer] removeAdminWithUid exit");
}

/**
 聊天消息发生变化时会收到该事件的通知回调
 在发送过程中会进行变更消息的状态信息，在状态变更时会触发该事件
 
 @param message 变化后的聊天消息
 */
- (void)didUpdateMessage:(HMRMessage *)message
{
    if (![message.receiver isEqual:self.chatRoom]) {
        return;
    }
}

#pragma mark -- HMRChatRoomMemberObserver

/**
 当有成员进入聊天室时的回调

 @param chatRoom 聊天室标识
 @param members 进入聊天室的成员
 */
- (void)chatRoom:(HMRChatRoom *)chatRoom
  didJoinMembers:(NSSet<HMRUser *> *)members
{
    YYLogDebug(@"[MouseLive-Hummer] didJoinMembers entry");
    WeakSelf
    if (![chatRoom isEqual:self.chatRoom]) {
        YYLogError(@"[MouseLive-Hummer] didJoinMembers 不是当前房间");
        return;
    }
    
    __block int index = 0;
    NSMutableArray *targetMembers = [[NSMutableArray alloc] initWithCapacity:members.count];
    [members enumerateObjectsUsingBlock:^(HMRUser * _Nonnull obj, BOOL * _Nonnull stop) {
        YYLogDebug(@"[MouseLive-Hummer] didJoinMembers [%d]:%lld", index++, obj.ID);
        if (weakSelf.uid.longLongValue != obj.ID) {
            SYUser *user = [[SYUser alloc] initWithHummerUser:obj];
            [targetMembers addObject:user];
            [weakSelf.userDic setObject:user forKey:[NSString stringWithFormat:@"%llu", obj.ID]];
        }
    }];
    
    if ([self.observer respondsToSelector:@selector(didJoinWithArray:)]) {
        YYLogDebug(@"[MouseLive-Hummer] didJoinMembers  didJoinWithArray");
        [self.observer didJoinWithArray:[targetMembers copy]];
    }
    YYLogDebug(@"[MouseLive-Hummer] didJoinMembers exit");
}

/**
 当有成员离开聊天室时的回调

 @param chatRoom 聊天室标识
 @param members 离开聊天室的成员
 */
- (void)chatRoom:(HMRChatRoom *)chatRoom
didLeaveMembers:(NSSet<HMRUser *> *)members
         reason:(NSString *)reason
    leavingType:(NSInteger)type
{
    YYLogDebug(@"[MouseLive-Hummer] didLeaveMembers entry");
    WeakSelf
    if (![chatRoom isEqual:self.chatRoom]) {
        YYLogError(@"[MouseLive-Hummer] didLeaveMembers 不是当前房间");
        return;
    }
    
    __block int index = 0;
    NSMutableArray *targetMembers = [[NSMutableArray alloc] initWithCapacity:members.count];
    [members enumerateObjectsUsingBlock:^(HMRUser * _Nonnull obj, BOOL * _Nonnull stop) {
        YYLogDebug(@"[MouseLive-Hummer] didLeaveMembers [%d]:%lld", index++, obj.ID);
        if (weakSelf.uid.longLongValue != obj.ID) {
            SYUser *user = [[SYUser alloc] initWithHummerUser:obj];
            [targetMembers addObject:user];
            [weakSelf.userDic removeObjectForKey:[NSString stringWithFormat:@"%llu", obj.ID]];
        }
    }];
    
    if ([self.observer respondsToSelector:@selector(didLeaveWithArray:)]) {
        YYLogDebug(@"[MouseLive-Hummer] didLeaveMembers didLeaveWithArray");
        [self.observer didLeaveWithArray:[targetMembers copy]];
    }
    YYLogDebug(@"[MouseLive-Hummer] didLeaveMembers exit");
}

/**
 当聊天室成员发生变化时的回调

 @param chatRoom 聊天室标识
 @param count 变化后的数量
 */
- (void)chatRoom:(HMRChatRoom *)chatRoom didChangeMemberCount:(NSUInteger)count
{
    YYLogDebug(@"[MouseLive-Hummer] didChangeMemberCount entry, count:%lu", (unsigned long)count);
    if (![chatRoom isEqual:self.chatRoom]) {
        YYLogError(@"[MouseLive-Hummer] didChangeMemberCount 不是当前房间");
        return;
    }
    
    if ([self.observer respondsToSelector:@selector(didChangeMemberCount:)]) {
        YYLogDebug(@"[MouseLive-Hummer] didChangeMemberCount didChangeMemberCount");
        [self.observer didChangeMemberCount:count];
    }
    YYLogDebug(@"[MouseLive-Hummer] didChangeMemberCount exit");
}

/**
 当聊天室成员被踢出聊天室时的回调

 @param chatRoom 聊天室标识
 @param members 被踢出频道的成员
 @param operatorUser 执行踢出操作的管理员
 @param reason 被踢出频道的原因
 */
- (void)chatRoom:(HMRChatRoom *)chatRoom
  didKickMembers:(NSSet<HMRUser *> *)members
      byOperator:(HMRUser *)operatorUser
          reason:(NSString *)reason
{
    YYLogDebug(@"[MouseLive-Hummer] didKickMembers entry");
    WeakSelf
    if (![chatRoom isEqual:self.chatRoom]) {
        YYLogError(@"[MouseLive-Hummer] didKickMembers 不是当前房间");
        return;
    }
    
    __block BOOL isSelf = NO;
    __block int index = 0;
    NSMutableArray *targetMembers = [[NSMutableArray alloc] initWithCapacity:members.count];
    [members enumerateObjectsUsingBlock:^(HMRUser * _Nonnull obj, BOOL * _Nonnull stop) {
        YYLogDebug(@"[MouseLive-Hummer] didKickMembers [%d]:%lld", index++, obj.ID);
        if (weakSelf.uid.longLongValue != obj.ID) {
            SYUser *user = [[SYUser alloc] initWithHummerUser:obj];
            [targetMembers addObject:user];
            [weakSelf.userDic removeObjectForKey:[NSString stringWithFormat:@"%llu", obj.ID]];
        }
        else {
            isSelf = YES;
        }
    }];
    
    if (isSelf) {
        if ([self.observer respondsToSelector:@selector(didKickedSelf)]) {
            YYLogDebug(@"[MouseLive-Hummer] didKickedSelf");
            [self.observer didKickedSelf];
        }
    }
    else {
        if ([self.observer respondsToSelector:@selector(didKickedWithArray:)]) {
            YYLogDebug(@"[MouseLive-Hummer] didKickedWithArray");
            [self.observer didKickedWithArray:[targetMembers copy]];
        }
    }
    YYLogDebug(@"[MouseLive-Hummer] didKickMembers exit");
}

/**
 当聊天室成员被赋予角色时的回调

 @param chatRoom 聊天室标识
 @param role 被赋予的角色
 @param member 被赋予角色的成员
 @param operatorUser 赋予角色的管理员
 */
- (void)chatRoom:(HMRChatRoom *)chatRoom
      didAddRole:(NSString *)role
       forMember:(HMRUser *)member
      byOperator:(HMRUser *)operatorUser
{
    YYLogDebug(@"[MouseLive-Hummer] didAddRole entry, role:%@, uid:%lld", role, member.ID);
    if (![chatRoom isEqual:self.chatRoom]) {
        YYLogError(@"[MouseLive-Hummer] didAddRole 不是当前房间");
        return;
    }

    // android 是 Admin，iOS 是 HMRAdminRole， admin
    if (member.ID == self.uid.longLongValue) {
        self.isAdmin = YES;
    }
    
    if ([self.observer respondsToSelector:@selector(didAddRoleWithUid:)]) {
        YYLogDebug(@"[MouseLive-Hummer] didAddRole   didAddRoleWithUid");
        [self.observer didAddRoleWithUid: [NSString stringWithFormat:@"%llu", member.ID]];
    }
    YYLogDebug(@"[MouseLive-Hummer] didAddRole exit");
}

/**
 当聊天室成员被移除角色时的回调

 @param chatRoom 聊天室标识
 @param role 被移除的角色
 @param member 被移除角色的成员
 @param operatorUser 移除角色的管理员
 */
- (void)chatRoom:(HMRChatRoom *)chatRoom
   didRemoveRole:(NSString *)role
       forMember:(HMRUser *)member
      byOperator:(HMRUser *)operatorUser
{
    YYLogDebug(@"[MouseLive-Hummer] didRemoveRole entry, role:%@, uid:%lld", role, member.ID);
    if (![chatRoom isEqual:self.chatRoom]) {
        YYLogError(@"[MouseLive-Hummer] didRemoveRole 不是当前房间");
        return;
    }

    if (member.ID == self.uid.longLongValue) {
        self.isAdmin = NO;
    }
    
    if ([self.observer respondsToSelector:@selector(didRemoveRoleWithUid:)]) {
        YYLogDebug(@"[MouseLive-Hummer] didRemoveRole   didRemoveRoleWithUid");
        [self.observer didRemoveRoleWithUid: [NSString stringWithFormat:@"%llu", member.ID]];
    }
    YYLogDebug(@"[MouseLive-Hummer] didRemoveRole exit");
}

/**
 当聊天室成员被禁言时的回调

 @param chatRoom 聊天室标识
 @param members 被禁言的成员
 @param operatorUser 禁言的管理员
 @param reason 原因
 */
- (void)chatRoom:(HMRChatRoom *)chatRoom
  didMuteMembers:(NSSet<HMRUser *> *)members
      byOperator:(HMRUser *)operatorUser
          reason:(NSString *)reason
{
    YYLogDebug(@"[MouseLive-Hummer] didMuteMembers entry");
    WeakSelf
    if (![chatRoom isEqual:self.chatRoom]) {
        YYLogError(@"[MouseLive-Hummer] didMuteMembers 不是当前房间");
        return;
    }

    __block int index = 0;
    NSMutableArray *targetMembers = [[NSMutableArray alloc] initWithCapacity:members.count];
    [members enumerateObjectsUsingBlock:^(HMRUser * _Nonnull obj, BOOL * _Nonnull stop) {
        YYLogDebug(@"[MouseLive-Hummer] didMuteMembers [%d]:%lld", index++, obj.ID);
        SYUser *user = [[SYUser alloc] initWithHummerUser:obj];
        [targetMembers addObject:user];
//        if (weakSelf.uid.longLongValue != obj.ID) {
//            SYUser *user = [[SYUser alloc] initWithHummerUser:obj];
//            [targetMembers addObject:user];
//        }
//        else {
//            if (!weakSelf.isOwner) {
//                weakSelf.isMuted = YES;
//            }
//        }
    }];
    
    if ([self.observer respondsToSelector:@selector(didMutedWithArray:muted:)]) {
        YYLogDebug(@"[MouseLive-Hummer] didMuteMembers didMutedWithArray muted: YES");
        [self.observer didMutedWithArray: [targetMembers copy] muted:YES];
    }
    YYLogDebug(@"[MouseLive-Hummer] didMuteMembers exit");
}

/**
 当聊天室成员被解除禁言时的回调
 
 @param chatRoom 聊天室标识
 @param members 被解除禁言的成员
 @param operatorUser 解除禁言的管理员
 @param reason 原因
 */
- (void)chatRoom:(HMRChatRoom *)chatRoom
didUnmuteMembers:(NSSet<HMRUser *> *)members
      byOperator:(HMRUser *)operatorUser
          reason:(NSString *)reason
{
    YYLogDebug(@"[MouseLive-Hummer] didUnmuteMembers entry");
    WeakSelf
    if (![chatRoom isEqual:self.chatRoom]) {
        YYLogError(@"[MouseLive-Hummer] didUnmuteMembers 不是当前房间");
        return;
    }

    __block int index = 0;
    NSMutableArray *targetMembers = [[NSMutableArray alloc] initWithCapacity:members.count];
    [members enumerateObjectsUsingBlock:^(HMRUser * _Nonnull obj, BOOL * _Nonnull stop) {
        YYLogDebug(@"[MouseLive-Hummer] didUnmuteMembers [%d]:%lld", index++, obj.ID);
        if (weakSelf.uid.longLongValue == obj.ID) {
            weakSelf.isMuted = NO;
        }
        
        SYUser *user = [[SYUser alloc] initWithHummerUser:obj];
        [targetMembers addObject:user];
    }];
    
    if ([self.observer respondsToSelector:@selector(didMutedWithArray:muted:)]) {
        YYLogDebug(@"[MouseLive-Hummer] didUnmuteMembers didMutedWithArray muted: NO");
        [self.observer didMutedWithArray: [targetMembers copy] muted:NO];
    }
    YYLogDebug(@"[MouseLive-Hummer] didUnmuteMembers exit");
}

#pragma mark - HMRChatRoomObserver

/**
 当聊天室被解散时发生的回调通知

 @param chatRoom 被解散的聊天室的标识
 @param operatorUser 解散聊天室的管理员
 */
- (void)chatRoom:(HMRChatRoom *)chatRoom didDismissByOperator:(HMRUser *)operatorUser
{
    YYLogDebug(@"[MouseLive-Hummer] didDismissByOperator entry");
    if (![chatRoom isEqual:self.chatRoom]) {
        return;
    }
    
    YYLogDebug(@"[MouseLive-Hummer] didDismissByOperator will send");
    if ([self.observer respondsToSelector:@selector(didDismissByOperator)]) {
        YYLogDebug(@"[MouseLive-Hummer] didDismissByOperator send");
        [self.observer didDismissByOperator];
    }
    
    YYLogDebug(@"[MouseLive-Hummer] didDismissByOperator exit");
}

/**
 当聊天室基础信息发生变化时的回调

 @param chatRoom 发生变化的聊天室的标识
 @param propInfo 变化的键值对， 为 { @(HMRChatRoomBasicInfoType): newValue }
 @param operatorUser 修改聊天室信息的管理员
 */
- (void)chatRoom:(HMRChatRoom *)chatRoom didChangeBasicInfo:(NSDictionary<NSNumber *, NSString *> *)propInfo byOperator:(HMRUser *)operatorUser
{
    YYLogDebug(@"[MouseLive-Hummer] didChangeBasicInfo entry");
    if (![chatRoom isEqual:self.chatRoom]) {
        YYLogError(@"[MouseLive-Hummer] didChangeBasicInfo 不是当前房间");
        return;
    }
    
    NSString *js = [propInfo objectForKey:@(HMRChatRoomBasicInfoTypeExtention)];
    NSDictionary *response = [self _yy_dictionaryWithJSON:js];
    id isAllMute = [response objectForKey:g_AllMute];
    if (isAllMute) {
        BOOL isAllMuted = [isAllMute boolValue];
        YYLogDebug(@"[MouseLive-Hummer] didChangeBasicInfo self.isAllMuted:%d, get isAllMuted:%d", self.isAllMuted, isAllMuted);
        if (self.isAllMuted != isAllMuted) {
            self.isAllMuted = isAllMuted;
            if (!self.isOwner) {
                self.isMuted = self.isAllMuted;
            }
            
            // 有变化就发送
            if ([self.observer respondsToSelector:@selector(didAllMuted:)]) {
                YYLogDebug(@"[MouseLive-Hummer] didChangeBasicInfo didAllMuted, self.isAllMuted:%d", self.isAllMuted);
                [self.observer didAllMuted:self.isAllMuted];
            }
        }
    }
    
    id isAllMicOff = [response objectForKey:g_AllMicOff];
    if (isAllMicOff) {
        BOOL isAllMicOf = [isAllMicOff boolValue];
        YYLogDebug(@"[MouseLive-Hummer] didChangeBasicInfo self.isAllMicOff:%d, get isAllMicOff:%d", self.isAllMicOff, isAllMicOf);
        if (self.isAllMicOff !=  isAllMicOf) {
            self.isAllMicOff = isAllMicOf;
            if (!self.isOwner) {
                self.isMicOff = self.isAllMicOff;
            }
            
            // 有变化就发送
            if ([self.observer respondsToSelector:@selector(didAllMicOff:)]) {
                YYLogDebug(@"[MouseLive-Hummer] didChangeBasicInfo didAllMicOff, self.isAllMicOff:%d", self.isAllMicOff);
                [self.observer didAllMicOff:self.isAllMicOff];
            }
        }
    }
    YYLogDebug(@"[MouseLive-Hummer] didChangeBasicInfo exit");
}

- (NSString *)encodeExtentionWithAllMute:(BOOL)allMute allMicOff:(BOOL)allMicOff
{
    NSDictionary *dic = @{g_AllMute:@(allMute), g_AllMicOff:@(allMicOff)};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)decodeExtention:(NSString *)js
{
    NSDictionary *response = [self _yy_dictionaryWithJSON:js];
    id isAllMute = [response objectForKey:g_AllMute];
    if (isAllMute) {
        self.isAllMuted = [isAllMute boolValue];
        if (!self.isOwner) {
            self.isMuted = self.isAllMuted;
        }
        
        if ([self.observer respondsToSelector:@selector(didAllMuted:)]) {
            YYLogDebug(@"[MouseLive-Hummer] didChangeBasicInfo didAllMuted, self.isAllMuted:%d", self.isAllMuted);
            [self.observer didAllMuted:self.isAllMuted];
        }
    }
    id isAllMicOff = [response objectForKey:g_AllMicOff];
    if (isAllMicOff) {
        self.isAllMicOff = [isAllMicOff boolValue];
        if (!self.isOwner) {
            self.isMicOff = self.isAllMicOff;
        }
        
        if ([self.observer respondsToSelector:@selector(didAllMicOff:)]) {
            YYLogDebug(@"[MouseLive-Hummer] didChangeBasicInfo didAllMicOff, self.isAllMicOff:%d", self.isAllMicOff);
            [self.observer didAllMicOff:self.isAllMicOff];
        }
    }
}

/**
 * 当聊天室成员信息被设置时的回调
 * @param chatRoom 聊天室标识
 * @param user 信息变更的成员
 * @param infos 设置后的用户信息
 */
- (void)chatRoom:(HMRChatRoom *)chatRoom
  didUserInfoSet:(HMRUser *)user
           infos:(NSDictionary<NSString *, NSString *> *)infos
{
    
}

#pragma mark -- HMRChannelStateObserver
/**
 当长连接状态变化时，会通过该通知进行回调
 
 @param fromState 旧的状态
 @param toState 新的状态
 */
- (void)didChangeChannelStateFrom:(HMRChannelState)fromState
                          toState:(HMRChannelState)toState
{
    YYLogDebug(@"[MouseLive-Hummer] --- didChangeChannelStateFrom entry, fromState:%ld, toState:%ld", (long)fromState, (long)toState);
}

#pragma mark -- HMRHummerStateObserver
- (void)didUpdateStateFrom:(HMRHummerState)oldState toState:(HMRHummerState)newState
{
    YYLogDebug(@"[MouseLive-Hummer] --- didUpdateStateFrom entry, oldState:%ld, newState:%ld", (long)oldState, (long)newState);
    if (newState == HMRHummerStateClosed) {
        YYLogDebug(@"[MouseLive-Hummer] --- didUpdateStateFrom will send didNetDisconnect");
        if ([self.observer respondsToSelector:@selector(didNetDisconnect)]) {
            YYLogDebug(@"[MouseLive-Hummer] --- didUpdateStateFrom send didNetDisconnect");
            [self.observer didNetDisconnect];
        }
    }
}

// 鉴权 token 回调
- (void)didHummerTokenInvalid:(HMRTokenInvalidCode)code withDescription:(NSString *)desc
{
    YYLogDebug(@"[MouseLive-Hummer] didHummerTokenInvalid entry, code:%ld, desc:%@", (long)code, desc);
    if (code == HMRTokenInvalidCode_Expired) {
        [[SYToken sharedInstance] updateTokenWithComplete:^(NSString * _Nonnull token, NSError * _Nullable error) {
            if (!error) {
                YYLogDebug(@"[MouseLive-iOS] didHummerTokenInvalid, update token:%@", token);
                [Hummer refreshToken:token];
            }
            else {
                YYLogDebug(@"[MouseLive-iOS] didHummerTokenInvalid, error:%@", error);
            }
        }];
    }
}

- (void)createChatRoomSuccess:(StrCompletion)success fail:(ErrorComplete)fail
{
    NSString *roomName = [NSString stringWithFormat:@"SY-%@", [SYUtils generateRandomNumberWithDigitCount:6]];
    HMRChatRoomInfo *chatRoomInfo = [HMRChatRoomInfo chatRoomInfoWithName:roomName description:nil bulletin:nil appExtra:nil];
    // 创建聊天室
    [[HMRChatRoomService instance] createChatRoom:chatRoomInfo completionHandler:^(HMRChatRoom *chatRoom, NSError *error) {
        if (error) {
            if (fail) {
                fail(error);
            }
        }
        else {
            if (success) {
                NSString *roomid = [NSString stringWithFormat:@"%llu",chatRoom.ID];
                if (success) {
                    success(roomid);
                }
            }
        }
    }];
}

@end

 
