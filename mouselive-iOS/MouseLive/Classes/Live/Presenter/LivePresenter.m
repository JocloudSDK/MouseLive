//
//  LivePresenter.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/17.
//  Copyright © 2020 sy. All rights reserved.
//

#import "LivePresenter.h"
#import "LiveAnchorModel.h"
#import "LiveUserModel.h"
#import "LiveRoomModel.h"

@interface LivePresenter()

@property (nonatomic, assign) NSInteger Offset;

@property (nonatomic, strong) NSMutableArray *taskArray;

@property (nonatomic, assign) BOOL isStop;

@property (nonatomic, assign, readwrite) BOOL isRunningMirc; // 正在连麦

@property (nonatomic, assign, readwrite) BOOL isOwner; // 房主

@property (nonatomic, assign, readwrite) BOOL isWheat; // 连麦者

@property (nonatomic, strong) NSDictionary *respDictionary; // 网络响应数据

@property (nonatomic, strong) LiveDefaultConfig *liveConfig;

@property (nonatomic, copy) NSString *linkUid;

@end

//网络失败次数
static NSInteger createRoomRequstErrorCount = 1;
static NSInteger setChatIdRequstErrorCount  = 1;
static NSInteger getChatIdRequstErrorCount  = 1;



@implementation LivePresenter

static LivePresenter * _instance;
//单例模式
+ (LivePresenter *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LivePresenter alloc] init];
        _instance.Offset = 0;
        _instance.isStop = NO;
        _instance.isOwner = NO;
        _instance.isWheat = NO;
        _instance.isRunningMirc = NO;
    });
    return _instance;
}

#pragma mark - get / set
- (NSMutableArray *)taskArray
{
    if (!_taskArray) {
        _taskArray = [[NSMutableArray alloc] init];
    }
    return _taskArray;
}

- (void)setDelegate:(id<LivePresenterDelegate>)delegate
{
    _delegate = delegate;
}


- (void)destory
{
    YYLogDebug(@"[MouseLive-App] LivePresenter destory");
    self.isStop = YES;
    [HttpService sy_httpRequestCancelWithArray:self.taskArray];
    self.delegate = nil;

}


//用户信息
- (void)fetchUserDataWithUid:(NSString *)uid  success:(SYNetServiceSuccessBlock)success failure:(SYNetServiceFailBlock)failure
{
    RLMLiveUserModel *user = [RLMLiveUserModel objectForPrimaryKey:uid];
    //用户详情存在
    if (user.NickName) {
        if (success) {
            success(0,user);
        }
        return;
    } else {
        //用户详情不存在 请求网络
        int taskId = [HttpService sy_httpRequestWithType:SYHttpRequestKeyType_GetUserInfo params:@{kUid:@(uid.longLongValue)} success:^(int taskId, id  _Nullable respObjc) {
            [self.taskArray removeObject:@(taskId)];
            NSString *code = [NSString stringWithFormat:@"%@",respObjc[kCode]];
            if ([code isEqualToString:ksuccessCode]) {
                YYLogError(@"[MouseLive-App] LivePresenter GetUserInfo success ");
                 RLMLiveUserModel *userModel = [RLMLiveUserModel objectForPrimaryKey:uid];
                 RLMRealm *realm = [RLMRealm defaultRealm];
                if (!userModel) {
                     userModel = [RLMLiveUserModel mj_objectWithKeyValues:respObjc[kData]];
                } else {
                    RLMLiveUserModel *user = [RLMLiveUserModel mj_objectWithKeyValues:respObjc[kData]];
                    [realm beginWriteTransaction];
                    userModel.NickName = user.NickName;
                    userModel.Cover = user.Cover;
                    userModel.SelfMicEnable = user.SelfMicEnable;
                    userModel.LinkRoomId = user.LinkRoomId;
                    userModel.LinkUid = user.LinkUid;
                    [realm commitWriteTransaction];
                }
               
                [realm beginWriteTransaction];
                [realm addOrUpdateObject:userModel];
                [realm commitWriteTransaction];
                if (success && respObjc) {
                    success(0,userModel);
                }
            } else {
                if (success) {
                    success(0,nil);
                }
                YYLogError(@"[MouseLive-App] LivePresenter GetUserInfo error %@",respObjc[kMsg]);
            }
        } failure:^(int taskId, id  _Nullable respObjc, NSString * _Nullable errorCode, NSString * _Nullable errorMsg) {
            [self.taskArray removeObject:@(taskId)];
            YYLogError(@"[MouseLive-App] LivePresenter GetUserInfo error %@",errorMsg);
            if (failure) {
                failure(0,respObjc,errorCode,errorMsg);
            }
        }];
        
        [self.taskArray addObject:@(taskId)];
    }
}

- (void)fetchGetchatIdWithParams:(NSDictionary *)params
{
    
    int taskId = [HttpService sy_httpRequestWithType:SYHttpRequestKeyType_GetChatId params:params success:^(int taskId, id  _Nullable respObjc) {
        [self.taskArray removeObject:@(taskId)];
        NSString *code = [NSString stringWithFormat:@"%@",respObjc[kCode]];
        if ([code isEqualToString:ksuccessCode]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(successGetChatId:)]) {
                [self.delegate successGetChatId:respObjc[kData]];
            }
        } else {
            if (self.isStop) {
                return;
            }
            [NSThread sleepForTimeInterval:0.5];
            if (getChatIdRequstErrorCount < 3) {
                [self fetchGetchatIdWithParams:params];
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(createRoomError:)]) {
                    [self.delegate createRoomError:[NSString stringWithFormat:@"GetChatId-%@",code]];
                }
            }
            getChatIdRequstErrorCount += 1;
        }
    } failure:^(int taskId, id  _Nullable respObjc, NSString * _Nullable errorCode, NSString * _Nullable errorMsg) {
        [self.taskArray removeObject:@(taskId)];
        if (self.isStop) {
            return;
        }
        [NSThread sleepForTimeInterval:0.5];
        if (getChatIdRequstErrorCount < 3) {
            [self fetchGetchatIdWithParams:params];
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(createRoomError:)]) {
            [self.delegate createRoomError:[NSString stringWithFormat:@"http-GetChatId-%@",errorCode]];
            }
        }
        getChatIdRequstErrorCount += 1;
    }];
    
    [self.taskArray addObject:@(taskId)];
}

- (void)fetchChatRoomWithType:(RoomType)type params:(NSDictionary *)params
{
    
    int taskId = [HttpService sy_httpRequestWithType:SYHttpRequestKeyType_CreateRoom params:params success:^(int taskId, id  _Nullable respObjc) {
        [self.taskArray removeObject:@(taskId)];
        NSString *code = [NSString stringWithFormat:@"%@",respObjc[kCode]];
        if ([code isEqualToString:ksuccessCode]) {
#if USE_REALM
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
            RLMLiveRoomModel *roomModel = [RLMLiveRoomModel mj_objectWithKeyValues:[respObjc objectForKey:kData]];
            [realm addOrUpdateObject:roomModel];
            [realm commitWriteTransaction];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(successChatRoom:)]) {
                [self.delegate successChatRoom:roomModel];
                
            }
#else
            LiveRoomInfoModel *model = [LiveRoomInfoModel mj_objectWithKeyValues:[respObjc objectForKey:kData]];
            if (self.delegate && [self.delegate respondsToSelector:@selector(successChatRoom:withType:)]) {
                [self.delegate successChatRoom:model withType:type];
            }
#endif
        } else {
            if (self.isStop) {
                return;
            }
            if (createRoomRequstErrorCount < 3) {
                [self fetchChatRoomWithType:type params:params];
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(createRoomError:)]) {
                    [self.delegate createRoomError:[NSString stringWithFormat:@"CreateRoom-%@",code]];
                }
            }
            createRoomRequstErrorCount += 1;
        }
    } failure:^(int taskId, id  _Nullable respObjc, NSString * _Nullable errorCode, NSString * _Nullable errorMsg) {
        [self.taskArray removeObject:@(taskId)];
        if (self.isStop) {
            return;
        }
        [NSThread sleepForTimeInterval:0.5];
        if (createRoomRequstErrorCount < 3) {
            [self fetchChatRoomWithType:type params:params];
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(createRoomError:)]) {
                [self.delegate createRoomError:[NSString stringWithFormat:@"http-CreateRoom-%@",errorCode]];
            }
        }
        createRoomRequstErrorCount += 1;
    }];
    
    [self.taskArray addObject:@(taskId)];
}

- (void)fetchSetchatIdWithParams:(NSDictionary *)params
{
    
    int taskId = [HttpService sy_httpRequestWithType:SYHttpRequestKeyType_SetChatId params:params success:^(int taskId, id  _Nullable respObjc) {
        [self.taskArray removeObject:@(taskId)];
        NSString *code = [NSString stringWithFormat:@"%@",respObjc[kCode]];
        if ([code isEqualToString:ksuccessCode]) {
            DDLogDebug(@"fetchSetchatIdWithParams, 创建成功");
            if (self.delegate && [self.delegate respondsToSelector:@selector(createRoomSucess:)]) {
                [self.delegate createRoomSucess:respObjc[kData]];
            }
        } else {
            if (self.isStop) {
                return;
            }
            DDLogDebug(@"fetchSetchatIdWithParams, 创建失败");
            [NSThread sleepForTimeInterval:0.5];
            if (setChatIdRequstErrorCount < 3) {
                [self fetchSetchatIdWithParams:params];
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(createRoomError:)]) {
                    [self.delegate createRoomError:[NSString stringWithFormat:@"SetChatId-%@",code]];

                }
            }
            setChatIdRequstErrorCount += 1;
        }
    } failure:^(int taskId, id  _Nullable respObjc, NSString * _Nullable errorCode, NSString * _Nullable errorMsg) {
        [self.taskArray removeObject:@(taskId)];
        if (self.isStop) {
            return;
        }
        [NSThread sleepForTimeInterval:0.5];
        if (setChatIdRequstErrorCount < 3) {
            [self fetchSetchatIdWithParams:params];
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(createRoomError:)]) {
                [self.delegate createRoomError:[NSString stringWithFormat:@"http-SetChatId-%@",errorCode]];
            }
        }
        setChatIdRequstErrorCount += 1;
    }];
    
    [self.taskArray addObject:@(taskId)];
}

//重新请求roominfo
- (void)fetchRoomInfoWithType:(RoomType)type config:(LiveDefaultConfig *)config
{
   NSDictionary *params = @{
        kUid:[NSNumber numberWithInteger:[config.localUid integerValue]],
        kRoomId:[NSNumber numberWithInteger:[config.ownerRoomId integerValue]],
        kRType:@(type),
    };
    int taskId = [HttpService sy_httpRequestWithType:SYHttpRequestKeyType_RoomInfo params:params success:^(int taskId, id  _Nullable respObjc) {
        [self.taskArray removeObject:@(taskId)];
        NSString *code = [NSString stringWithFormat:@"%@",respObjc[kCode]];
        if ([code isEqualToString:ksuccessCode]) {
            YYLogDebug(@"[MouseLive LivePresenter] fetchRoomInfoWithType:config success");
        }
    } failure:^(int taskId, id  _Nullable respObjc, NSString * _Nullable errorCode, NSString * _Nullable errorMsg) {
        [self.taskArray removeObject:@(taskId)];
    }];
    
    [self.taskArray addObject:@(taskId)];
}
//房间信息
- (void)fetchRoomInfoWithType:(RoomType)type config:(LiveDefaultConfig *)config success:(SYNetServiceSuccessBlock)success failure:(SYNetServiceFailBlock)failure
{
    
    NSDictionary *params = @{
        kUid:[NSNumber numberWithInteger:[config.localUid integerValue]],
        kRoomId:[NSNumber numberWithInteger:[config.ownerRoomId integerValue]],
        kRType:@(type),
    };
    int taskId = [HttpService sy_httpRequestWithType:SYHttpRequestKeyType_RoomInfo params:params success:^(int taskId, id  _Nullable respObjc) {
        [self.taskArray removeObject:@(taskId)];
        self.liveConfig = [[LiveDefaultConfig alloc]init];
        NSString *code = [NSString stringWithFormat:@"%@",respObjc[kCode]];
        if ([code isEqualToString:ksuccessCode]) {
        YYLogDebug(@"[MouseLive LivePresenter] getRoomInfo success");
#if USE_REALM
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
            RLMLiveRoomModel *roomModel = [RLMLiveRoomModel mj_objectWithKeyValues:[respObjc objectForKey:kData]];
            [realm addOrUpdateObject:roomModel];
            [realm commitWriteTransaction];
            if (self.delegate && [self.delegate respondsToSelector:@selector(successChatRoom:)]) {
                [self.delegate successChatRoom:roomModel];
            }
#else
        LiveRoomModel *model = [LiveRoomModel mj_objectWithKeyValues:[respObjc objectForKey:kData]];
            if (success && respObjc) {
                success(0,model);
            }
            if ([model.RoomInfo.ROwner.Uid isEqualToString:LoginUserUidString]) {
                           self.isOwner = YES;
                       }
            NSArray *mircUserListArray = model.UserList;

            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Uid == %@", model.RoomInfo.ROwner.Uid];
            NSArray *filteredArray = nil;
            if (![mircUserListArray isKindOfClass:[NSNull class]]) {
            filteredArray = [mircUserListArray filteredArrayUsingPredicate:predicate];
            }
            if (filteredArray.count > 0) {
                LiveUserModel *mircUserModel = filteredArray.lastObject;
                self.linkUid = mircUserModel.LinkUid;
                if ([mircUserModel.LinkUid isEqualToString:LoginUserUidString]) {
                    self.isWheat = YES;
                } else {
                    self.isWheat = NO;
                }
                if ([self.linkUid isEqualToString:@"0"]) {
                    self.isRunningMirc = NO;
                } else {
                    self.isRunningMirc = YES;
                }
                self.liveConfig.localUid = LoginUserUidString;
                self.liveConfig.ownerRoomId = model.RoomInfo.RoomId;
                self.liveConfig.anchroMainUid = mircUserModel.Uid;
                self.liveConfig.anchroMainRoomId = mircUserModel.roomId;
                self.liveConfig.anchroSecondUid = mircUserModel.LinkUid;
                self.liveConfig.anchroSecondRoomId = mircUserModel.LinkRoomId;
                if ([self.liveConfig.anchroSecondUid isEqualToString:@"0"]) {
                    self.liveConfig.anchroSecondUid = @"";
                }
                if ([self.liveConfig.anchroSecondRoomId isEqualToString:@"0"]) {
                    self.liveConfig.anchroSecondRoomId = @"";
                }
            } else {
                self.isRunningMirc = NO;
                NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kUserInfo];
                self.liveConfig.localUid = [NSString stringWithFormat:@"%@",[userDict objectForKey:kUid]];
                self.liveConfig.anchroMainUid = [NSString stringWithFormat:@"%@",[userDict objectForKey:kUid]];
                self.liveConfig.ownerRoomId = model.RoomInfo.RoomId;
            }
//            if (self.delegate && type == LiveTypeVideo && [self.delegate respondsToSelector:@selector(resetLiveConfig:)]) {
//                [self.delegate resetLiveConfig:self.liveConfig];
//            }
//            if (self.delegate && [self.delegate respondsToSelector:@selector(refreshLiveStatusWithLinkUid:)]) {
//                    [self.delegate refreshLiveStatusWithLinkUid:self.liveConfig.anchroSecondUid];
//            }
//            if (self.delegate && [self.delegate respondsToSelector:@selector(liveViewRoomInfo:UserListDataSource:)]) {
//                [self.delegate liveViewRoomInfo:model.RoomInfo UserListDataSource:model.UserList];
//            }
#endif
            if (success && respObjc) {
                success(0,respObjc);
            }

        } else {
            if (success && respObjc) {
                success(0,nil);
            }
            YYLogDebug(@"[MouseLive LivePresenter] getRoomInfo error %@",respObjc[@"Msg"]);
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestError:)]) {
                [self.delegate requestError:respObjc[@"Msg"]];
            }
        }
    } failure:^(int taskId, id  _Nullable respObjc, NSString * _Nullable errorCode, NSString * _Nullable errorMsg) {
        if (failure && respObjc) {
            failure(0,respObjc,errorCode,errorMsg);
        }
        YYLogDebug(@"[MouseLive LivePresenter] getRoomInfo error %@",errorMsg);
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestError:)]) {
            [self.delegate requestError:respObjc[@"Msg"]];
        }
        [self.taskArray removeObject:@(taskId)];
    }];
    
    [self.taskArray addObject:@(taskId)];
}

- (void)fetchAnchorListWithType:(RoomType)type config:(LiveDefaultConfig *)config success:(SYNetServiceSuccessBlock)success failure:(SYNetServiceFailBlock)failure
{
    NSDictionary *params = @{
        kUid:[NSNumber numberWithInteger:[config.localUid integerValue]],
        kRType:@(type),
    };
    int taskId = [HttpService sy_httpRequestWithType:SYHttpRequestKeyType_AnchorList params:params success:^(int taskId, id  _Nullable respObjc) {
        [self.taskArray removeObject:@(taskId)];
        NSString *code = [NSString stringWithFormat:@"%@",respObjc[kCode]];
        
        if ([code isEqualToString:ksuccessCode]) {
            YYLogDebug(@"[MouseLive LivePresenter] getAnchorList success");
            
            NSArray *dataArray = [LiveAnchorModel mj_objectArrayWithKeyValuesArray:[respObjc objectForKey:kData]];
            if (self.delegate && [self.delegate respondsToSelector:@selector(liveViewAnchorListDataSource:)]) {
                [self.delegate liveViewAnchorListDataSource:dataArray];
            }
            if (success && respObjc) {
                success(0,dataArray);
            }
        } else {
            YYLogDebug(@"[MouseLive LivePresenter] getAnchorList error %@",respObjc[kMsg]);
            if (success && respObjc) {
                success(0,nil);
            }
        }
    } failure:^(int taskId, id  _Nullable respObjc, NSString * _Nullable errorCode, NSString * _Nullable errorMsg) {
        if (failure && respObjc) {
            failure(0,respObjc,errorCode,errorMsg);
        }
        YYLogDebug(@"[MouseLive LivePresenter] getAnchorList error %@",errorMsg);
        
        [self.taskArray removeObject:@(taskId)];
    }];
    
    [self.taskArray addObject:@(taskId)];
}




@end
