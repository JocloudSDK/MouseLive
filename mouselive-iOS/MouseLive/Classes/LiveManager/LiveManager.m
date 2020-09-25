//
//  LiveManager.m
//  MouseLive
//
//  Created by 张骥 on 2020/5/14.
//  Copyright © 2020 sy. All rights reserved.
//

#import "LiveManager.h"
#import "RoomManager.h"
#import "UserManager.h"
#import "SYToken.h"
#import "CCService.h"
#import "LiveInvite.h"
#import "LiveBeInvited.h"

@interface LiveManager() <CCServiceDelegate, LiveInviteDelegate, LiveBeInvitedDelegate, SYHummerManagerObserver>

@property(nonatomic, strong) RoomManager* roomManager;
@property(nonatomic, strong) UserManager *userManager;

@property(nonatomic, strong) CCService *ccservice;
@property(nonatomic, strong) SYHttpService *httpService;
@property(nonatomic, strong) SYHummerManager *hummerManager;
@property(nonatomic, strong) SYThunderManagerNew *thunderManager;

@property (nonatomic, strong) LiveInvite *liveInvite; // 主动连麦操作, invite 和 beinvited 外面应该还有一个manager 的
@property (nonatomic, strong) LiveBeInvited *liveBeInvited;  // 被动连麦操作

@property(nonatomic, copy) NSMutableSet<id<LiveManagerDelegate>> *delegates;
@property(nonatomic, weak) id<LiveManagerSignalDelegate> signalDelegate;
@property(nonatomic, weak) id<SYThunderDelegate> thunderDelegate;

@property(nonatomic, strong) LiveRoomInfoModel *currentRoomInfo;
@property(nonatomic, strong) LiveUserModel *currentUser;

@end

@implementation LiveManager

+ (instancetype)shareManager
{
    static LiveManager* manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (void)addDelegate:(id<LiveManagerDelegate>)delegate
{
    if (!_delegates) {
        _delegates = [[NSMutableSet alloc]init];
    }
    [_delegates addObject:delegate];
}

- (void)removeDelegate:(id<LiveManagerDelegate>)delegate
{
    [_delegates removeObject:delegate];
}

- (void)addSignalDelegate:(id<LiveManagerSignalDelegate>)delegate
{
    [self.hummerManager addHummerObserver:self];
    _signalDelegate = delegate;
}

- (void)removeSignalDelegate:(id<LiveManagerSignalDelegate>)delegate
{
    [self.hummerManager removeHummerObserver:self];
    _signalDelegate = nil;
}

- (void)addThunderDelegate:(id<SYThunderDelegate>)delagate
{
    [[SYThunderEvent sharedManager]setDelegate:delagate];
}

- (void)removeThunderDelegate:(id<SYThunderDelegate>)delagate
{
    [[SYThunderEvent sharedManager]setDelegate:nil];
}

- (void)login:(UserInfoCompletion _Nullable)success
         fail:(ErrorComplete _Nullable)fail
{
    [self.userManager login:success fail:fail];
}

- (void)getRoomListOfType:(LiveType)type
{
    [self getRoomListOfType:type success:nil fail:nil];
}

- (void)getRoomListOfType:(LiveType)type
                  success:(ArrayCompletion _Nullable)success
                     fail:(ErrorComplete _Nullable)fail
{
    NSString *paras = [NSString stringWithFormat:@"type: %ld", (long)type];
    YYLogFuncEntry([self class], _cmd, paras);
    
    WeakSelf
    ArrayCompletion successBlock = ^(NSArray * _Nullable array) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(array);
            });
        } else {
            for (id<LiveManagerDelegate> delegate in weakSelf.delegates) {
                if ([delegate respondsToSelector:@selector(liveManager:getRoomList:type:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [delegate liveManager:weakSelf getRoomList:array type:type];
                    });
                }
            }
        }
    };
    
    ErrorComplete failBlock = ^(NSError * _Nullable error) {
        if (fail) {
            dispatch_async(dispatch_get_main_queue(), ^{
                fail(error);
            });
        } else {
            for (id<LiveManagerDelegate> delegate in weakSelf.delegates) {
                if ([delegate respondsToSelector:@selector(liveManager:getRoomListFailed:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [delegate liveManager:weakSelf getRoomListFailed:error];
                    });
                }
            }
        }
    };
    [self.roomManager getRoomListOfType:type success:successBlock fail:failBlock];
    
    YYLogFuncExit([self class], _cmd);
}

- (void)createRoomForType:(LiveType)type
              publishMode:(PublishMode)mode
{
    [self createRoomForType:type publishMode:mode success:nil fail:nil];
}

- (void)createRoomForType:(LiveType)type
              publishMode:(PublishMode)mode
                  success:(RoomInfoCompletion _Nullable)success
                     fail:(ErrorComplete _Nullable)fail
{
    NSString *paras = [NSString stringWithFormat:@"type: %ld, PublishMode: %ld", (long)type, (long)mode];
    YYLogFuncEntry([self class], _cmd, paras);
    
    WeakSelf
    RoomInfoCompletion successBlock = ^(LiveRoomInfoModel * _Nullable roomInfo, NSArray<LiveUserModel *> * _Nullable userList) {
        [weakSelf connectService];
        if (success) {
            success(roomInfo, userList);
        } else {
            for (id<LiveManagerDelegate> delegate in weakSelf.delegates) {
                if ([delegate respondsToSelector:@selector(liveManager:createRoomSuccess:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [delegate liveManager:weakSelf createRoomSuccess:roomInfo];
                    });
                }
            }
        }
    };
    
    ErrorComplete failBlock = ^(NSError * _Nullable error) {
        if (fail) {
            dispatch_async(dispatch_get_main_queue(), ^{
                fail(error);
            });
        } else {
            for (id<LiveManagerDelegate> delegate in weakSelf.delegates) {
                if ([delegate respondsToSelector:@selector(liveManager:createRoomFailed:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [delegate liveManager:weakSelf createRoomFailed:error];
                    });
                }
            }
        }
    };
    
    [self.roomManager createRoomForType:type publishMode:mode success:successBlock fail:failBlock];
    
    YYLogFuncExit([self class], _cmd);
}

- (void)createChatRoom
{
    [self createChatRoomSuccess:nil fail:nil];
}

- (void)createChatRoomSuccess:(StrCompletion _Nullable)success
                         fail:(ErrorComplete _Nullable)fail
{
    
    YYLogFuncEntry([self class], _cmd, nil);
    
    WeakSelf
    StrCompletion successBlock = ^(NSString * _Nullable str) {
        [weakSelf connectService];
        if (success) {
            success(str);
        } else {
            for (id<LiveManagerDelegate> delegate in weakSelf.delegates) {
                if ([delegate respondsToSelector:@selector(liveManager:createChatRoomSuccess:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [delegate liveManager:weakSelf createChatRoomSuccess:str];
                    });
                }
            }
        }
    };
    
    ErrorComplete failBlock = ^(NSError * _Nullable error) {
        if (fail) {
            dispatch_async(dispatch_get_main_queue(), ^{
                fail(error);
            });
        } else {
            for (id<LiveManagerDelegate> delegate in weakSelf.delegates) {
                if ([delegate respondsToSelector:@selector(liveManager:createChatRoomFailed:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [delegate liveManager:weakSelf createChatRoomFailed:error];
                    });
                }
            }
        }
    };
    
    [self.roomManager createChatRoomSuccess:successBlock fail:failBlock];
    
    YYLogFuncExit([self class], _cmd);
}

- (void)getRoomInfo:(NSString *)roomId
               Type:(LiveType)type
{
    [self getRoomInfo:roomId Type:type success:nil fail:nil];
}

- (void)getRoomInfo:(NSString *)roomId
               Type:(LiveType)type
            success:(RoomInfoCompletion _Nullable)success
               fail:(ErrorComplete _Nullable)fail
{
    NSString *paras = [NSString stringWithFormat:@"roomId: %@, type: %ld", roomId, (long)type];
    YYLogFuncEntry([self class], _cmd, paras);
    
    WeakSelf
    RoomInfoCompletion successBlock = ^(LiveRoomInfoModel * _Nullable roomInfo, NSArray<LiveUserModel *> * _Nullable userList) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(roomInfo, userList);
            });
        } else {
            for (id<LiveManagerDelegate> delegate in weakSelf.delegates) {
                if ([delegate respondsToSelector:@selector(liveManager:getRoomInfoSuccess:userList:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [delegate liveManager:weakSelf getRoomInfoSuccess:roomInfo userList:userList];
                    });
                }
            }
        }
    };
    
    ErrorComplete failBlock = ^(NSError * _Nullable error) {
        if (fail) {
            dispatch_async(dispatch_get_main_queue(), ^{
                fail(error);
            });
        } else {
            for (id<LiveManagerDelegate> delegate in weakSelf.delegates) {
                if ([delegate respondsToSelector:@selector(liveManager:getRoomInfoFailed:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [delegate liveManager:weakSelf getRoomInfoFailed:error];
                    });
                }
            }
        }
    };
    
    [self.roomManager getRoomInfo:roomId Type:type success:successBlock fail:failBlock];
    
    YYLogFuncExit([self class], _cmd);
}

- (void)getUserInfoWith:(NSString *)uid
{
    [self getUserInfoWith:uid success:nil fail:nil];
}

- (void)getUserInfoWith:(NSString *)uid success:(UserInfoCompletion)success fail:(ErrorComplete)fail
{
    NSString *paras = [NSString stringWithFormat:@"uid: %@", uid];
    YYLogFuncEntry([self class], _cmd, paras);
    WeakSelf
    UserInfoCompletion successBlock = ^(LiveUserModel * _Nullable userInfo) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(userInfo);
            });
        } else {
            for (id<LiveManagerDelegate> delegate in weakSelf.delegates) {
                if ([delegate respondsToSelector:@selector(liveManager:getUserInfoSuccess:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [delegate liveManager:weakSelf getUserInfoSuccess:userInfo];
                    });
                }
            }
        }
    };
    
    ErrorComplete failBlock = ^(NSError * _Nullable error) {
        if (fail) {
            dispatch_async(dispatch_get_main_queue(), ^{
                fail(error);
            });
        } else {
            for (id<LiveManagerDelegate> delegate in weakSelf.delegates) {
                if ([delegate respondsToSelector:@selector(liveManager:getUserInfoFailed:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [delegate liveManager:weakSelf getUserInfoFailed:error];
                    });
                }
            }
        }
    };
    
    [self.userManager getUserInfoWith:uid success:successBlock fail:failBlock];
    
    YYLogFuncExit([self class], _cmd);
}

- (void)joinChatRoom
{
    [self joinChatRoomSuccess:nil fail:nil];
}

- (void)joinChatRoomSuccess:(StrCompletion _Nullable)success
                       fail:(ErrorComplete _Nullable)fail
{
    YYLogFuncEntry([self class], _cmd, nil);
//    [self connectService];
    WeakSelf
    StrCompletion successBlock = ^(NSString * _Nullable str) {
        [weakSelf connectService];
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success(str);
            });
        } else {
            for (id<LiveManagerDelegate> delegate in weakSelf.delegates) {
                if ([delegate respondsToSelector:@selector(liveManager:joinChatRoomSuccess:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [delegate liveManager:weakSelf joinChatRoomSuccess:str];
                    });
                }
            }
        }
    };
    
    ErrorComplete failBlock = ^(NSError * _Nullable error) {
        if (fail) {
            dispatch_async(dispatch_get_main_queue(), ^{
                fail(error);
            });
        } else {
            for (id<LiveManagerDelegate> delegate in weakSelf.delegates) {
                if ([delegate respondsToSelector:@selector(liveManager:joinChatRoomFailed:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [delegate liveManager:weakSelf joinChatRoomFailed:error];
                    });
                }
            }
        }
    };
    
    [self.roomManager joinChatRoomSuccess:successBlock fail:failBlock];
    
    YYLogFuncExit([self class], _cmd);
}

- (void)leaveRoom
{
    YYLogFuncEntry([self class], _cmd, nil);
    [self.liveInvite cancelWithComplete:nil];
    _liveInvite = nil;
    
    [self sendLeaveRoomWithComplete:nil];
    [self.roomManager leaveRoom];
    [self.thunderManager leaveRoom];
    
    [[CCService sharedInstance] removeObserver:self];
    [[CCService sharedInstance] leaveRoom];
    
    YYLogFuncExit([self class], _cmd);
}

#pragma mark - Signal methods
- (void)muteRemoteUser:(NSString *)uid mute:(BOOL)mute
{
    [self muteRemoteUser:uid mute:mute complete:nil];
}

- (void)muteRemoteUser:(NSString *)uid mute:(BOOL)mute complete:(SendComplete _Nullable)complete
{
    NSString *paras = [NSString stringWithFormat:@"uid: %@, mute: %d", uid, mute];
    YYLogFuncEntry([self class], _cmd, paras);
    
    [self.hummerManager sendMutedWithUid:uid muted:mute completionHandler:complete];
    
    YYLogFuncExit([self class], _cmd);
}

- (void)muteAllRemoteUser:(BOOL)mute complete:(SendComplete _Nullable)complete
{
    NSString *paras = [NSString stringWithFormat:@"mute: %d", mute];
    YYLogFuncEntry([self class], _cmd, paras);
    
    [self.hummerManager sendAllMutedWithMuted:mute completionHandler:complete];
    
    YYLogFuncExit([self class], _cmd);
}

- (void)offRemoteUserMic:(NSString *)uid micOff:(BOOL)micOff complete:(SendComplete _Nullable)complete
{
    NSString *paras = [NSString stringWithFormat:@"uid: %@, micOff: %d", uid, micOff];
    YYLogFuncEntry([self class], _cmd, paras);
    [self enableMicWithUid:uid enable:!micOff complete:complete];
    YYLogFuncExit([self class], _cmd);
}

- (void)offAllRemoteUserMic:(BOOL)micOff complete:(SendComplete _Nullable)complete
{
    NSString *paras = [NSString stringWithFormat:@"micOff: %d", micOff];
    YYLogFuncEntry([self class], _cmd, paras);
    
    [self.hummerManager sendAllMicOffWithOff:micOff completionHandler:complete];
    
    YYLogFuncExit([self class], _cmd);
}

- (void)setUserRole:(NSString * _Nonnull)uid isAdmin:(BOOL)isAdmin complete:(SendComplete _Nullable)complete
{
    NSString *paras = [NSString stringWithFormat:@"uid: %@, isAdmin: %d", uid, isAdmin];
    YYLogFuncEntry([self class], _cmd, paras);
    if (isAdmin) {
        [self.hummerManager addAdminWithUid:uid completionHandler:complete];
    } else {
        [self.hummerManager removeAdminWithUid:uid completionHandler:complete];
    }
    YYLogFuncExit([self class], _cmd);
}

- (void)kickUserWithUid:(NSString * _Nonnull)uid complete:(SendComplete _Nullable)complete
{
    NSString *paras = [NSString stringWithFormat:@"uid: %@", uid];
    YYLogFuncEntry([self class], _cmd, paras);
    [self.hummerManager sendKickWithUid:uid completionHandler:complete];
    YYLogFuncExit([self class], _cmd);
}

- (void)applyConnectToUser:(NSString *)uid
                    roomId:(NSString * _Nonnull)roomId
                  complete:(SendComplete _Nullable)complete
{
    NSString *paras = [NSString stringWithFormat:@"uid: %@", uid];
    YYLogFuncEntry([self class], _cmd, paras);
    
    [self.liveInvite sendInvoteWithUid:uid roomId:roomId complete:complete];
    
    YYLogFuncExit([self class], _cmd);
}

- (void)acceptConnectWithUser:(NSString *)uid
                     complete:(SendComplete _Nullable)complete
{
    NSString *paras = [NSString stringWithFormat:@"uid: %@", uid];
    YYLogFuncEntry([self class], _cmd, paras);
    
    [self.liveBeInvited acceptWithUid:uid complete:^(NSError * _Nullable error, NSString * _Nonnull roomid) {
        if (complete) {
            complete(error);
        }
    }];
    
    YYLogFuncExit([self class], _cmd);
}

- (void)clearBeInvitedQueue
{
    [self.liveBeInvited clearBeInvitedQueue];
}

- (void)refuseConnectWithUser:(NSString *)uid
                     complete:(SendComplete _Nullable)complete
{
    NSString *paras = [NSString stringWithFormat:@"uid: %@", uid];
    YYLogFuncEntry([self class], _cmd, paras);
    
    [self.liveBeInvited refuseWithUid:uid complete:complete];
    
    YYLogFuncExit([self class], _cmd);
}

- (void)hungupWithUser:(NSString *)uid
                roomId:(NSString *)roomId
              complete:(SendComplete _Nullable)complete
{
    NSString *paras = [NSString stringWithFormat:@"uid: %@, roomId: %@", uid, roomId];
    YYLogFuncEntry([self class], _cmd, paras);
    
    WSInviteRequest *q = [[WSInviteRequest alloc] init];
    q.ChatType = (int)self.roomManager.currentRoomInfo.RType;
    q.SrcUid = self.userManager.currentUser.Uid.longLongValue;
    q.SrcRoomId = self.roomManager.currentRoomInfo.RoomId.longLongValue;
    q.DestUid = uid.longLongValue;
    q.DestRoomId = roomId.longLongValue;
    [q createTraceId];
    
    [[CCService sharedInstance] sendHangup:q complete:^(NSError * _Nullable error) {
        if (complete) {
            complete(error);
        }
    }];
    
    YYLogFuncExit([self class], _cmd);
}

- (void)enableMicWithUid:(NSString * _Nonnull)uid
                  enable:(BOOL)enable
                complete:(SendComplete _Nullable)complete
{
    NSString *paras = [NSString stringWithFormat:@"uid: %@, enable: %d", uid, enable];
    YYLogFuncEntry([self class], _cmd, paras);
    
    WSMicOffRequest *q = [[WSMicOffRequest alloc] init];
    q.ChatType = (int)self.currentRoomInfo.RType;
    q.SrcUid = self.userManager.currentUser.Uid.longLongValue;
    q.SrcRoomId = self.currentRoomInfo.RoomId.longLongValue;
    q.DestUid = uid.longLongValue;
    q.DestRoomId = q.SrcRoomId;
    q.MicEnable = enable;
    [q createTraceId];
    
    [[CCService sharedInstance] sendMicEnable:q complete:^(NSError * _Nullable error) {
        if (complete) {
            complete(error);
        }
    }];
    
    YYLogFuncExit([self class], _cmd);
}

- (void)sendRoomMessage:(NSString *)message
{
    [self sendRoomMessage:message complete:nil];
}

- (void)sendRoomMessage:(NSString *)message complete:(SendComplete _Nullable)complete
{
    NSString *paras = [NSString stringWithFormat:@"message: %@", message];
    YYLogFuncEntry([self class], _cmd, paras);
    [self.hummerManager sendBroadcastMessage:message completionHandler:complete];
    YYLogFuncExit([self class], _cmd);
}

- (void)sendMessage:(NSString *)message toUser:(NSString *)uid
{
    [self sendMessage:message toUser:uid complete:nil];
}

- (void)sendMessage:(NSString *)message toUser:(NSString *)uid complete:(SendComplete _Nullable)complete
{
    NSString *paras = [NSString stringWithFormat:@"message: %@, uid: %@", message, uid];
    YYLogFuncEntry([self class], _cmd, paras);
    [self.hummerManager sendSignalToTarget:uid message:message completionHandler:complete];
    YYLogFuncExit([self class], _cmd);
}

- (void)fetchChatRoomStatus:(SendComplete _Nullable)complete
{
    YYLogFuncEntry([self class], _cmd, nil);
    [self.hummerManager fetchRoomInfo:complete];
    YYLogFuncExit([self class], _cmd);
}

- (void)fetchMuteStatusOfUsers:(NSArray<NSString *> *)users complete:(void(^)(NSArray<NSString *> * _Nullable muteUsers, NSError * _Nullable error))complete
{
    YYLogFuncEntry([self class], _cmd, users);
    WeakSelf
    [self.hummerManager fetchMutedUsers:^(NSSet<HMRUser *> * _Nullable members, NSError * _Nullable error) {
        YYLogFuncEntry([weakSelf class], _cmd, members);
        if (error) {
            if (complete) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, error);
                });
            } else {
                if ([weakSelf.signalDelegate respondsToSelector:@selector(liveManager:fetchMuteUsersFailed:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.signalDelegate liveManager:weakSelf fetchMuteUsersFailed:error];
                    });
                }
            }
        } else {
            NSMutableArray *muteUsers = [[NSMutableArray alloc]init];
            
            for (NSString* user in users) {
                for (HMRUser* muteUser in members) {
                    if (muteUser.ID == (UInt64)[user integerValue]) {
                        [muteUsers addObject:user];
                        break;
                    }
                }
            }
            
            if (complete) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(muteUsers, nil);
                });
            } else {
                if ([weakSelf.signalDelegate respondsToSelector:@selector(liveManager:fetchMuteUsersSuccess:muteUsers:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.signalDelegate liveManager:weakSelf fetchMuteUsersSuccess:users muteUsers:muteUsers];
                    });
                }
            }
        }
        YYLogFuncExit([weakSelf class], _cmd);
    }];
    YYLogFuncExit([self class], _cmd);
}

- (void)fetchAdminOfUsers:(NSArray<NSString *> * _Nullable)users complete:(void(^)(NSArray<NSString *> * _Nullable admins, NSError * _Nullable error))complete;
{
    YYLogFuncEntry([self class], _cmd, users);
    WeakSelf
    [self.hummerManager fetchRoleMember:^(NSSet<HMRUser *> * _Nullable members, NSError * _Nullable error) {
        if (error) {
            if (complete) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, error);
                });
            } else {
                if ([weakSelf.signalDelegate respondsToSelector:@selector(liveManager:fetchAdminsFailed:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.signalDelegate liveManager:weakSelf fetchAdminsFailed:error];
                    });
                }
            }
        } else {
            NSMutableArray *admins = [[NSMutableArray alloc]init];
            for (NSString* user in users) {
                for (HMRUser* admin in members) {
                    if (admin.ID == (UInt64)[user integerValue]) {
                        [admins addObject:user];
                        break;
                    }
                }
            }
            
            if (complete) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(admins, nil);
                });
            } else {
                if ([weakSelf.signalDelegate respondsToSelector:@selector(liveManager:fetchAdminsSuccess:admins:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.signalDelegate liveManager:weakSelf fetchAdminsSuccess:users admins:admins];
                    });
                }
            }
        }
    }];
    YYLogFuncExit([self class], _cmd);
}

#pragma mark - Media methods (Thunder)

- (void)joinMediaRoom:(NSString *)roomId uid:(NSString *)uid roomType:(LiveType)roomType;
{
    NSString *paras = [NSString stringWithFormat:@"roomId: %@, uid: %@, roomType: %ld", roomId, uid, (long)roomType];
    YYLogFuncEntry([self class], _cmd, paras);
    [self.thunderManager joinMediaRoom:roomId uid:uid roomType:roomType];
    YYLogFuncExit([self class], _cmd);
}

- (void)enableLocalVideo:(BOOL)enable
{
    NSString *paras = [NSString stringWithFormat:@"enable: %d", enable];
    YYLogFuncEntry([self class], _cmd, paras);
//    [self.thunderManager.engine enableLocalVideoCapture:enable];
    [self.thunderManager.engine stopLocalVideoStream:!enable];
    YYLogFuncExit([self class], _cmd);
}

- (void)startPreview
{
    YYLogFuncEntry([self class], _cmd, nil);
    [self.thunderManager.engine startVideoPreview];
    YYLogFuncExit([self class], _cmd);
}

- (void)stopPreview
{
    YYLogFuncEntry([self class], _cmd, nil);
    [self.thunderManager.engine stopVideoPreview];
    YYLogFuncExit([self class], _cmd);
}

- (void)enableLocalAudio:(BOOL)enable
{
    NSString *paras = [NSString stringWithFormat:@"enable: %d", enable];
    YYLogFuncEntry([self class], _cmd, paras);
    [self.thunderManager.engine stopLocalAudioStream:!enable];
    YYLogFuncExit([self class], _cmd);
}

- (void)publishStreamToUrl:(NSString * _Nonnull)url
{
    YYLogFuncEntry([self class], _cmd, url);
    [self.thunderManager.engine addPublishOriginStreamUrl:url];
    YYLogFuncExit([self class], _cmd);
}

- (void)stopPublishStreamToUrl:(NSString * _Nonnull)url
{
    YYLogFuncEntry([self class], _cmd, url);
    [self.thunderManager.engine removePublishOriginStreamUrl:url];
    YYLogFuncExit([self class], _cmd);
}

- (void)enableRemoteVideoStream:(BOOL)enable
{
    NSString *paras = [NSString stringWithFormat:@"enable: %d", enable];
    YYLogFuncEntry([self class], _cmd, paras);
    [self.thunderManager.engine stopAllRemoteVideoStreams:!enable];
    YYLogFuncExit([self class], _cmd);
}

- (void)enableRemoteAudioStream:(BOOL)enable
{
    NSString *paras = [NSString stringWithFormat:@"enable: %d", enable];
    YYLogFuncEntry([self class], _cmd, paras);
    [self.thunderManager.engine stopAllRemoteAudioStreams:!enable];
    YYLogFuncExit([self class], _cmd);
}

- (void)switchFrontCamera:(BOOL)isFront
{
    NSString *paras = [NSString stringWithFormat:@"isFront: %d", isFront];
    YYLogFuncEntry([self class], _cmd, paras);
    [self.thunderManager.engine switchFrontCamera:isFront];
    YYLogFuncExit([self class], _cmd);
}

- (void)setEnableInEarMonitor:(BOOL)enable
{
    NSString *paras = [NSString stringWithFormat:@"enable: %d", enable];
    YYLogFuncEntry([self class], _cmd, paras);
    [self.thunderManager.engine setEnableInEarMonitor:enable];
    YYLogFuncExit([self class], _cmd);
}

- (void)setVoiceChanger:(ThunderRtcVoiceChangerMode)changer
{
    NSString *paras = [NSString stringWithFormat:@"changer: %ld", (long)changer];
    YYLogFuncEntry([self class], _cmd, paras);
    [self.thunderManager.engine setVoiceChanger:(int)changer];
    YYLogFuncExit([self class], _cmd);
}

- (int)addSubscribe:(NSString * _Nonnull)roomId uid:(NSString * _Nonnull)uid
{
    NSString *paras = [NSString stringWithFormat:@"roomId: %@, uid: %@", roomId, uid];
    YYLogFuncEntry([self class], _cmd, paras);
    return [self.thunderManager.engine addSubscribe:roomId uid:uid];
    YYLogFuncExit([self class], _cmd);
}

- (int)removeSubscribe:(NSString * _Nonnull)roomId uid:(NSString * _Nonnull)uid
{
    NSString *paras = [NSString stringWithFormat:@"roomId: %@, uid: %@", roomId, uid];
    YYLogFuncEntry([self class], _cmd, paras);
    return [self.thunderManager.engine removeSubscribe:roomId uid:uid];
    YYLogFuncExit([self class], _cmd);
}

- (void)openAuidoFileWithPath:(NSString * _Nonnull)path
{
    NSString *paras = [NSString stringWithFormat:@"path: %@", path];
    YYLogFuncEntry([self class], _cmd, paras);
    [self.thunderManager openAuidoFileWithPath:path];
    YYLogFuncExit([self class], _cmd);
}

- (void)closeAuidoFile
{
    YYLogFuncEntry([self class], _cmd, nil);
    [self.thunderManager closeAuidoFile];
    YYLogFuncExit([self class], _cmd);
}

- (void)setAudioFilePlayVolume:(uint32_t)volume
{
    NSString *paras = [NSString stringWithFormat:@"volume: %d", volume];
    YYLogFuncEntry([self class], _cmd, paras);
    [self.thunderManager setAudioFilePlayVolume:volume];
    YYLogFuncExit([self class], _cmd);
}

- (void)pauseAudioFile
{
    YYLogFuncEntry([self class], _cmd, nil);
    [self.thunderManager pauseAudioFile];
    YYLogFuncExit([self class], _cmd);
}

- (void)resumeAudioFile
{
    YYLogFuncEntry([self class], _cmd, nil);
    [self.thunderManager resumeAudioFile];
    YYLogFuncExit([self class], _cmd);
}

- (CGFloat)currentPlayprogress
{
    return self.thunderManager.currentPlayprogress;
}

- (void)registerVideoCaptureFrameObserver:(nullable id<ThunderVideoCaptureFrameObserver>)delegate
{
    [self.thunderManager.engine registerVideoCaptureFrameObserver:delegate];
}

- (void)setupLocalUser:(NSString *)uid videoView:(UIView * _Nonnull)view
{
    NSString *paras = [NSString stringWithFormat:@"uid: %@", uid];
    YYLogFuncEntry([self class], _cmd, paras);
    [self.thunderManager setupLocalUser:uid videoView:view];
    [self startPreview];
    YYLogFuncExit([self class], _cmd);
}

- (void)setupRemoteUser:(NSString *)uid videoView:(UIView * _Nullable)view
{
    NSString *paras = [NSString stringWithFormat:@"uid: %@", uid];
    YYLogFuncEntry([self class], _cmd, paras);
    [self.thunderManager setupRemoteUser:uid videoView:view];
    YYLogFuncExit([self class], _cmd);
}

- (void)setMirrorPreview:(BOOL)preview publish:(BOOL)publish
{
    NSString *paras = [NSString stringWithFormat:@"preview: %d, publish: %d", preview, publish];
    YYLogFuncEntry([self class], _cmd, paras);
    [self.thunderManager setMirrorPreview:preview publish:publish];
    YYLogFuncExit([self class], _cmd);
}

- (void)offLocalMic:(BOOL)micOff
{
    NSString *paras = [NSString stringWithFormat:@"micOff: %d", micOff];
    YYLogFuncEntry([self class], _cmd, paras);
    [self.thunderManager disableLocalAudioCapture:micOff];
    if (!micOff) {
        [self enableLocalAudio:true];
    }
    // 修改本地麦克风，需要发送WS消息
//    [self enableMicWithUid:self.currentUser.Uid enable:!micOff complete:nil];
    YYLogFuncExit([self class], _cmd);
}


- (void)connectService
{
    YYLogFuncEntry([self class], _cmd, nil);
    [self.ccservice setUseWS:YES];
    [self.ccservice joinRoom];
    [self.ccservice addObserver:self];
    
    LiveRoomInfoModel *info = [self roomManager].currentRoomInfo;
    NSString *roomId = info.RoomId;
    [self sendJoinRoom:roomId Complete:nil];
    YYLogFuncExit([self class], _cmd);
}

- (void)sendJoinRoom:(NSString *)roomId Complete:(SendComplete)complete
{
    NSString *paras = [NSString stringWithFormat:@"roomId: %@", roomId];
    YYLogFuncEntry([self class], _cmd, paras);
    WSRoomRequest *q = [[WSRoomRequest alloc] init];
    q.Uid = [[NSUserDefaults standardUserDefaults] stringForKey:kUid].longLongValue;
    q.LiveRoomId = roomId.longLongValue;
    q.ChatRoomId = 0;
    [[CCService sharedInstance] sendJoinRoom:q complete:complete];
    YYLogFuncExit([self class], _cmd);
}

- (void)sendLeaveRoomWithComplete:(SendComplete)complete
{
    YYLogFuncEntry([self class], _cmd, nil);
    if (![self roomManager].currentRoomInfo) {
        return;
    }
    // thunder 进入房间成功后，才发送 ws 消息，ws 启动后调用
    WSRoomRequest *q = [[WSRoomRequest alloc] init];
    q.Uid = [[NSUserDefaults standardUserDefaults] stringForKey:kUid].longLongValue;
    q.LiveRoomId = [self roomManager].currentRoomInfo.RoomId.longLongValue;
    q.ChatRoomId = 0;
    [[CCService sharedInstance] sendLeaveRoom:q complete:complete];
    YYLogFuncExit([self class], _cmd);
}

#pragma mark - Lazy load
- (SYHttpService *)httpService
{
    if (!_httpService) {
        _httpService = [SYHttpService shareInstance];
    }
    
    return _httpService;
}

- (SYHummerManager *)hummerManager
{
    if (!_hummerManager) {
        _hummerManager = [SYHummerManager sharedManager];
    }
    
    return _hummerManager;
}

- (SYThunderManagerNew *)thunderManager
{
    if (!_thunderManager) {
        [SYThunderEvent sharedManager];
        _thunderManager = [SYThunderManagerNew sharedManager];
    }
    
    return _thunderManager;
}

- (RoomManager *)roomManager
{
    if (!_roomManager) {
        _roomManager = [RoomManager shareManager];
    }
    return _roomManager;
}

- (UserManager *)userManager
{
    if (!_userManager) {
        _userManager = [UserManager shareManager];
    }
    
    return _userManager;
}

- (CCService *)ccservice
{
    if (!_ccservice) {
        _ccservice = [CCService sharedInstance];
    }
    return _ccservice;
}

- (LiveInvite *)liveInvite
{
    if (!_liveInvite) {
        _liveInvite = [[LiveInvite alloc] initWithDelegate:self uid:self.userManager.currentUser.Uid roomid:self.roomManager.currentRoomInfo.RoomId roomType:self.roomManager.currentRoomInfo.RType];
    }
    return _liveInvite;
}

- (LiveBeInvited *)liveBeInvited
{
    if (!_liveBeInvited) {
        _liveBeInvited = [[LiveBeInvited alloc] initWithDelegate:self];
    }
    return _liveBeInvited;
}

- (LiveRoomInfoModel *)currentRoomInfo
{
    return self.roomManager.currentRoomInfo;
}

- (LiveUserModel *)currentUser
{
    return self.userManager.currentUser;
}

#pragma mark - Handle Signal Events
- (BOOL)handleHangupWithBody:(NSDictionary *)body
{
    YYLogFuncEntry([self class], _cmd, nil);
    WSInviteRequest *q = (WSInviteRequest *)[WSInviteRequest yy_modelWithJSON:body];
    
    if ([self.signalDelegate respondsToSelector:@selector(liveManager:didReceiveHungupRequestFrom:roomId:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.signalDelegate liveManager:self didReceiveHungupRequestFrom:[NSString stringWithFormat:@"%lld", q.SrcUid] roomId:[NSString stringWithFormat:@"%lld", q.SrcRoomId]];
        });
    }
    
    return YES;
    YYLogFuncExit([self class], _cmd);
}

- (BOOL)handleChatingBroadcastWithBody:(NSDictionary *)body
{
    YYLogFuncEntry([self class], _cmd, nil);
    WSInviteRequest *q = (WSInviteRequest *)[WSInviteRequest yy_modelWithJSON:body];
    NSString *uid, *roomId;
    if (q.SrcUid == self.currentRoomInfo.ROwner.Uid.longLongValue) {
        uid = [NSString stringWithFormat:@"%lld", q.DestUid];
        roomId = [NSString stringWithFormat:@"%lld", q.DestRoomId];
    } else {
        uid = [NSString stringWithFormat:@"%lld", q.SrcUid];
        roomId = [NSString stringWithFormat:@"%lld", q.SrcRoomId];
    }
    
    if (uid && roomId) {
        if ([self.signalDelegate respondsToSelector:@selector(liveManager:anchorConnectedWith:roomId:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.signalDelegate liveManager:self anchorConnectedWith:uid roomId:roomId];
            });
        }
    }
    
    return YES;
    YYLogFuncExit([self class], _cmd);
}

- (BOOL)handleHangupBroatcastWithBody:(NSDictionary *)body
{
    YYLogFuncEntry([self class], _cmd, nil);
    WSInviteRequest *q = (WSInviteRequest *)[WSInviteRequest yy_modelWithJSON:body];
    NSString *uid, *roomId;
    if (q.SrcUid == self.currentRoomInfo.ROwner.Uid.longLongValue) {
        uid = [NSString stringWithFormat:@"%lld", q.DestUid];
        roomId = [NSString stringWithFormat:@"%lld", q.DestRoomId];
    } else {
        if (q.DestUid == self.currentRoomInfo.ROwner.Uid.longLongValue) {
            uid = [NSString stringWithFormat:@"%lld", q.SrcUid];
            roomId = [NSString stringWithFormat:@"%lld", q.SrcRoomId];
        } else {
            uid = [NSString stringWithFormat:@"%lld", q.DestUid];
            roomId = [NSString stringWithFormat:@"%lld", q.DestRoomId];
        }
    }
    
    if (uid && roomId) {
        if ([self.signalDelegate respondsToSelector:@selector(liveManager:anchorDisconnectedWith:roomId:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.signalDelegate liveManager:self anchorDisconnectedWith:uid roomId:roomId];
            });
        }
    }
    return YES;
    YYLogFuncExit([self class], _cmd);
}

- (BOOL)handleJoinBroadcastWithBody:(id)body
{
    YYLogFuncEntry([self class], _cmd, nil);
    NSArray<WSRoomRequest *> *array = (NSArray<WSRoomRequest *> *)body;
    
    for (WSRoomRequest* q in array) {
        NSString *uid = [NSString stringWithFormat:@"%lld", q.Uid];
        NSString *roomid = [NSString stringWithFormat:@"%lld", q.LiveRoomId];
        if ([self.currentRoomInfo.RoomId isEqualToString:roomid]) {
            if ([self.signalDelegate respondsToSelector:@selector(liveManager:didUserJoin:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.signalDelegate liveManager:self didUserJoin:uid];
                });
            }
        }
    }
    return YES;
    YYLogFuncExit([self class], _cmd);
}

- (BOOL)handleLeaveBroadcastWithBody:(id)body
{
    YYLogFuncEntry([self class], _cmd, nil);
    NSArray<WSRoomRequest *> *array = (NSArray<WSRoomRequest *> *)body;
    
    for (WSRoomRequest* q in array) {
        NSString *uid = [NSString stringWithFormat:@"%lld", q.Uid];
        NSString *roomid = [NSString stringWithFormat:@"%lld", q.LiveRoomId];
        if ([self.signalDelegate respondsToSelector:@selector(liveManager:didUserLeave:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.signalDelegate liveManager:self didUserLeave:uid];
            });
        }
    }
    return YES;
    YYLogFuncExit([self class], _cmd);
}

- (BOOL)handleMicOffBroadcastWithBody:(NSDictionary *)body
{
    YYLogFuncEntry([self class], _cmd, nil);
    WSMicOffRequest *q = (WSMicOffRequest *)[WSMicOffRequest yy_modelWithJSON:body];
    NSString *uid = [NSString stringWithFormat:@"%lld", q.DestUid];
    NSString *srcUid = [NSString stringWithFormat:@"%lld", q.SrcUid];
     
    if ([self.signalDelegate respondsToSelector:@selector(liveManager:didUserMicStatusChanged:byOther:status:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.signalDelegate liveManager:self didUserMicStatusChanged:uid byOther:srcUid status:q.MicEnable];
        });
    }
    return YES;
    YYLogFuncExit([self class], _cmd);
}

#pragma mark - WSDelegate
- (BOOL)didChatAccept:(nonnull id)body
{
    YYLogFuncEntry([self class], _cmd, body);
    return [self.liveInvite handleMsgWithCmd:@(CCS_CHAT_ACCEPT) body:body];
    YYLogFuncExit([self class], _cmd);
}

- (BOOL)didChatApply:(nonnull id)body
{
    YYLogFuncEntry([self class], _cmd, body);
    return [self.liveBeInvited handleMsgWithCmd:@(CCS_CHAT_APPLY) body:body];
    YYLogFuncExit([self class], _cmd);
}

- (BOOL)didChatCancel:(nonnull id)body
{
    YYLogFuncEntry([self class], _cmd, body);
    BOOL ret = [self.liveBeInvited handleMsgWithCmd:@(CCS_CHAT_CANCEL) body:body];
    if (!ret) {
        ret = [self.liveInvite handleMsgWithCmd:@(CCS_CHAT_CANCEL) body:body];
    }
    return ret;
    YYLogFuncExit([self class], _cmd);
}

- (BOOL)didChatHangup:(nonnull id)body
{
    YYLogFuncEntry([self class], _cmd, body);
    return [self handleHangupWithBody:body];
    YYLogFuncExit([self class], _cmd);
}

- (BOOL)didChatReject:(nonnull id)body
{
    YYLogFuncEntry([self class], _cmd, body);
    return [self.liveInvite handleMsgWithCmd:@(CCS_CHAT_REJECT) body:body];
    YYLogFuncExit([self class], _cmd);
}

- (BOOL)didChatingBroadcast:(nonnull id)body
{
    YYLogFuncEntry([self class], _cmd, body);
    return [self handleChatingBroadcastWithBody:body];
    YYLogFuncExit([self class], _cmd);
}

- (BOOL)didChattingLimit:(nonnull id)body
{
    YYLogFuncEntry([self class], _cmd, body);
    return [self.liveInvite handleMsgWithCmd:@(CCS_CHAT_CHATTING) body:body];
    YYLogFuncExit([self class], _cmd);
}

- (BOOL)didHangupBroadcast:(nonnull id)body
{
    YYLogFuncEntry([self class], _cmd, body);
    return [self handleHangupBroatcastWithBody:body];
    YYLogFuncExit([self class], _cmd);
}

- (BOOL)didJoinRoomBroadcast:(nonnull id)body
{
    YYLogFuncEntry([self class], _cmd, body);
    return [self handleJoinBroadcastWithBody:body];
    YYLogFuncExit([self class], _cmd);
}

- (BOOL)didLeaveRoomBroadcast:(nonnull id)body
{
    YYLogFuncEntry([self class], _cmd, body);
    return [self handleLeaveBroadcastWithBody:body];
    YYLogFuncExit([self class], _cmd);
}

- (BOOL)didMicEnableBroadcast:(nonnull id)body
{
    YYLogFuncEntry([self class], _cmd, body);
    return [self handleMicOffBroadcastWithBody:body];
    YYLogFuncExit([self class], _cmd);
}

- (void)didNetClose
{
    YYLogFuncEntry([self class], _cmd, nil);
    for (id<LiveManagerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(liveManagerDidNetClosed:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate liveManagerDidNetClosed:self];
            });
        }
    }
    YYLogFuncExit([self class], _cmd);
}

- (void)didNetConnected
{
    YYLogFuncEntry([self class], _cmd, nil);
    for (id<LiveManagerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(liveManagerDidNetConnected:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate liveManagerDidNetConnected:self];
            });
        }
    }
    YYLogFuncExit([self class], _cmd);
}

- (void)didNetError:(nonnull NSError *)error
{
    YYLogFuncEntry([self class], _cmd, nil);
    for (id<LiveManagerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(liveManager:didNetError:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate liveManager:self didNetError:error];
            });
        }
    }
    YYLogFuncExit([self class], _cmd);
}

//- (BOOL)didRoomDestory:(nonnull id)body {
//
//}

- (void)didnetConnecting
{
    YYLogFuncEntry([self class], _cmd, nil);
    for (id<LiveManagerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(liveManagerNetConnecting:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate liveManagerNetConnecting:self];
            });
        }
    }
    YYLogFuncExit([self class], _cmd);
}

#pragma mark - Invire Delegate
- (void)didInviteWithCmd:(LiveInviteActionType)type item:(LiveInviteItem *)item
{
    NSString *paras = [NSString stringWithFormat:@"item: %@, type: %ld", item, (unsigned long)type];
    YYLogFuncEntry([self class], _cmd, paras);
    // ui 线程运行
    switch ((int)type) {
        case LIVE_INVITE_TYPE_ACCEPT:
            if ([self.signalDelegate respondsToSelector:@selector(liveManager:didInviteAcceptBy:roomId:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.signalDelegate liveManager:self didInviteAcceptBy:item.uid roomId:item.roomid];
                });
            }
            break;
        case LIVE_INVITE_TYPE_REFUSE:
            if ([self.signalDelegate respondsToSelector:@selector(liveManager:didInviteRefuseBy:roomId:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.signalDelegate liveManager:self didInviteRefuseBy:item.uid roomId:item.roomid];
                });
            }
            break;
        case LIVE_INVITE_TYPE_RUNNING:
            if ([self.signalDelegate respondsToSelector:@selector(liveManager:didInviteRunningBy:roomId:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.signalDelegate liveManager:self didInviteRunningBy:item.uid roomId:item.roomid];
                });
            }
            break;
        case LIVE_INVITE_TYPE_TIME_OUT:
            if ([self.signalDelegate respondsToSelector:@selector(liveManager:didInviteTimeoutBy:roomId:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.signalDelegate liveManager:self didInviteTimeoutBy:item.uid roomId:item.roomid];
                });
            }
            break;
    }
    YYLogFuncExit([self class], _cmd);
}

- (void)didBeInvitedWithCmd:(LiveBeInvitedActiontype)type item:(LiveInviteItem *)item
{
    NSString *paras = [NSString stringWithFormat:@"item: %@, type: %ld", item, (unsigned long)type];
    YYLogFuncEntry([self class], _cmd, paras);
    switch (type) {
        case LIVE_BE_INVITED_APPLY:
            if ([self.signalDelegate respondsToSelector:@selector(liveManager:didBeInvitedBy:roomId:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.signalDelegate liveManager:self didBeInvitedBy:item.uid roomId:item.roomid];
                });
            }
            break;
        case LIVE_BE_INVITED_CANCEL:
            if ([self.signalDelegate respondsToSelector:@selector(liveManager:didInviteCancelBy:roomId:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.signalDelegate liveManager:self didInviteCancelBy:item.uid roomId:item.roomid];
                });
            }
            break;
    }
    YYLogFuncExit([self class], _cmd);
}

#pragma mark - Hummer Manager Delegate
- (void)didReceivedSelfSignalMessageFrom:(NSString *)uid message:(NSString *)message
{
    NSString *paras = [NSString stringWithFormat:@"uid: %@, message: %@", uid, message];
    YYLogFuncEntry([self class], _cmd, paras);
    if ([self.signalDelegate respondsToSelector:@selector(liveManager:didReceivedMessageFrom:message:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.signalDelegate liveManager:self didReceivedMessageFrom:uid message:message];
        });
    }
    YYLogFuncExit([self class], _cmd);
}

- (void)didReceivedBroadcastFrom:(NSString *)uid message:(NSString *)message
{
    NSString *paras = [NSString stringWithFormat:@"uid: %@, message: %@", uid, message];
    YYLogFuncEntry([self class], _cmd, paras);
    if ([self.signalDelegate respondsToSelector:@selector(liveManager:didReceivedRoomMessageFrom:message:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.signalDelegate liveManager:self didReceivedRoomMessageFrom:uid message:message];
        });
    }
    YYLogFuncExit([self class], _cmd);
}

- (void)didKickedWithArray:(NSArray<SYUser *> *)user
{
    YYLogFuncEntry([self class], _cmd, nil);
    for (SYUser* u in user) {
        if ([self.signalDelegate respondsToSelector:@selector(liveManager:didUserBeKicked:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.signalDelegate liveManager:self didUserBeKicked:[NSString stringWithFormat:@"%llu", u.hummerUser.ID]];
            });
        }
    }
    YYLogFuncExit([self class], _cmd);
}

- (void)didKickedSelf
{
    YYLogFuncEntry([self class], _cmd, nil);
    if ([self.signalDelegate respondsToSelector:@selector(liveManagerDidSelfBeKicked:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.signalDelegate liveManagerDidSelfBeKicked:self];
        });
    }
    YYLogFuncExit([self class], _cmd);
}

- (void)didMutedWithArray:(NSArray<SYUser *> *)user muted:(BOOL)muted
{
    YYLogFuncEntry([self class], _cmd, nil);
    for (SYUser* u in user) {
        if ([self.signalDelegate respondsToSelector:@selector(liveManager:didUser:muteStatusChanged:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.signalDelegate liveManager:self didUser:[NSString stringWithFormat:@"%llu", u.hummerUser.ID] muteStatusChanged:muted];
            });
        }
    }
    YYLogFuncExit([self class], _cmd);
}

- (void)didAllMuted:(BOOL)muted
{
    NSString *paras = [NSString stringWithFormat:@"mute: %d", muted];
    YYLogFuncEntry([self class], _cmd, paras);
    if ([self.signalDelegate respondsToSelector:@selector(liveManager:didRoomMuteStatusChanged:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.signalDelegate liveManager:self didRoomMuteStatusChanged:muted];
        });
    }
    YYLogFuncExit([self class], _cmd);
}

- (void)didAllMicOff:(BOOL)micOff
{
    NSString *paras = [NSString stringWithFormat:@"micOff: %d", micOff];
    YYLogFuncEntry([self class], _cmd, paras);
    if ([self.signalDelegate respondsToSelector:@selector(liveManager:didRoomMicStatusChanged:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.signalDelegate liveManager:self didRoomMicStatusChanged:!micOff];
        });
    }
    YYLogFuncExit([self class], _cmd);
}

- (void)didAddRoleWithUid:(NSString *)uid
{
    NSString *paras = [NSString stringWithFormat:@"uif: %@", uid];
    YYLogFuncEntry([self class], _cmd, paras);
    if ([self.signalDelegate respondsToSelector:@selector(liveManager:didUser:roleChanged:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.signalDelegate liveManager:self didUser:uid roleChanged:YES];
        });
    }
    YYLogFuncExit([self class], _cmd);
}

- (void)didRemoveRoleWithUid:(NSString *)uid
{
    NSString *paras = [NSString stringWithFormat:@"uif: %@", uid];
    YYLogFuncEntry([self class], _cmd, paras);
    if ([self.signalDelegate respondsToSelector:@selector(liveManager:didUser:roleChanged:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.signalDelegate liveManager:self didUser:uid roleChanged:NO];
        });
    }
    YYLogFuncExit([self class], _cmd);
}

@end
