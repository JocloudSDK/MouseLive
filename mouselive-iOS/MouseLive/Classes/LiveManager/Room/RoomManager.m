//
//  RoomManager.m
//  MouseLive
//
//  Created by 张骥 on 2020/5/15.
//  Copyright © 2020 sy. All rights reserved.
//

#import "RoomManager.h"
#import "SYHttpService.h"
#import "SYHummerManager.h"
#import "SYThunderManagerNew.h"
#import "ParameterHelper.h"

typedef NS_OPTIONS(NSUInteger, CreateRoomStep)
{
    HummerCreateRoom = 1 << 0,
    HummerJoinRoom = 1 << 1,
    HttpSetChatId = 1 << 2,
    CreateRoomFail = 1 << 4,
};

typedef NS_OPTIONS(NSUInteger, JoinRoomStep)
{
    HttpGetChatId = 1 << 0,
    JoinHummerRoom = 1 << 1,
    JoinRoomFail = 1 << 2,
};

const NSInteger maxRetryCount = 3;
static NSInteger httpRetryCount = 0;
static NSInteger hummerRetryCount = 0;
static BOOL shouldRetry = true;

@interface RoomManager()

@property(nonatomic, strong) SYHttpService* httpService;
@property(nonatomic, strong) SYHummerManager *hummerManager;
@property(nonatomic, strong) SYThunderManagerNew *thunderManager;

@property(nonatomic, assign) CreateRoomStep createRoomStep;
@property(nonatomic, assign) JoinRoomStep joinRoomStep;

@property(nonatomic) StrCompletion successBlock;
@property(nonatomic) ErrorComplete failBlock;

@property(nonatomic, strong) NSMutableArray *taskIdArray;

@end

@implementation RoomManager

+ (instancetype)shareManager
{
    static RoomManager* manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RoomManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        _isInRoom = false;
    }
    return self;
}

- (void)getRoomListOfType:(LiveType)type
                  success:(ArrayCompletion _Nullable)success
                     fail:(ErrorComplete _Nullable)fail
{
    
    NSDictionary *paras = [ParameterHelper parametersForRequest:Http_GetRoomList additionInfo:@{kRType:@(type)}];
    YYLogFuncEntry([self class], _cmd, paras);
    
    NetServiceSuccessBlock successBlock = ^(NSString *taskId, id _Nullable respObjc) {
        NSNumber *code = [respObjc objectForKey:kCode];
        if (![code isEqualToNumber:[NSNumber numberWithInt:[ksuccessCode intValue]]]) {
            if (fail) {
                NSError *error = [[NSError alloc]initWithDomain:[NSString stringWithFormat:@"%s",__func__] code:[code integerValue] userInfo:respObjc];
                fail(error);
            }
        } else {
            NSArray *list = [[respObjc objectForKey:kData] objectForKey:kRoomList];
            NSMutableArray *roomList = [[NSMutableArray alloc] init];
            if (![list isKindOfClass:[NSNull class]]) {
                for (NSDictionary* obj in list) {
                    LiveRoomInfoModel *roomInfo = (LiveRoomInfoModel *)[LiveRoomInfoModel yy_modelWithJSON:obj];
                    [roomList addObject:roomInfo];
                }
            }
            
            if (success) {
                success(roomList);
            }
        }
    };
    
    NetServiceFailBlock failBlock = ^(NSString *taskId, NSError *error) {
        if (fail) {
            fail(error);
        }
    };
    
    [self.httpService sy_httpRequestWithType:SYHttpRequestKeyType_RoomList params:paras success:successBlock failure:failBlock];
    YYLogFuncExit([self class], _cmd);
}

- (void)createRoomForType:(LiveType)type
              publishMode:(PublishMode)mode
                  success:(RoomInfoCompletion _Nullable)success
                     fail:(ErrorComplete _Nullable)fail
{
    [self resetStatus];
    shouldRetry = true;
    
    NSDictionary *additionInfo = @{
        kRType:@(type),
        kRPublishMode:@(mode),
    };
    NSDictionary *paras = [ParameterHelper parametersForRequest:Http_CreateRoom additionInfo:additionInfo];
    YYLogFuncEntry([self class], _cmd, paras);
    
    WeakSelf
    NetServiceSuccessBlock successBlock = ^(NSString *taskId, id _Nullable respObjc) {
        [weakSelf.taskIdArray removeObject:taskId];
        NSNumber *code = [respObjc objectForKey:kCode];
        if (![code isEqualToNumber:[NSNumber numberWithInt:[ksuccessCode intValue]]]) {
            if (fail) {
                NSError *error = [[NSError alloc] initWithDomain:[NSString stringWithFormat:@"%s",__func__] code:[code integerValue] userInfo:respObjc];
                fail(error);
            }
        } else {
            NSDictionary *dic = [respObjc objectForKey:kData];
            LiveRoomInfoModel *roomInfo = (LiveRoomInfoModel *)[LiveRoomInfoModel yy_modelWithJSON:dic];
            weakSelf.currentRoomInfo = roomInfo;
            
            NSDictionary *ownerDic = [dic objectForKey:kROwner];
            LiveUserModel *owner = (LiveUserModel *)[LiveUserModel yy_modelWithJSON:ownerDic];
            weakSelf.currentRoomInfo.ROwner = owner;
            roomInfo.ROwner = owner;
            
            weakSelf.isAnchor = true;
            
            if (success) {
                success(roomInfo, nil);
            }
        }
    };
    
    NetServiceFailBlock failBlock = ^(NSString *taskId, NSError *error) {
        [weakSelf.taskIdArray removeObject:taskId];
        if (fail) {
            fail(error);
        }
    };
    
    NSString *taskId = [self.httpService sy_httpRequestWithType:SYHttpRequestKeyType_CreateRoom params:paras success:successBlock failure:failBlock];
    
    [self.taskIdArray addObject:taskId];
    YYLogFuncExit([self class], _cmd);
}

- (void)getRoomInfo:(NSString *)roomId
               Type:(LiveType)type
            success:(RoomInfoCompletion _Nullable)success
               fail:(ErrorComplete _Nullable)fail
{
    
    NSDictionary *addInfo = @{
        kRoomId:@([roomId integerValue]),
        kRType:@(type)
    };
    
    NSDictionary *paras = [ParameterHelper parametersForRequest:Http_GetRoomInfo additionInfo:addInfo];
    YYLogFuncEntry([self class], _cmd, paras);
    
    WeakSelf
    NetServiceSuccessBlock successBlock = ^(NSString *taskId, id _Nullable respObjc) {
        [weakSelf.taskIdArray removeObject:taskId];
        NSNumber *code = [respObjc objectForKey:kCode];
        if (![code isEqualToNumber:[NSNumber numberWithInt:[ksuccessCode intValue]]]) {
            if (fail) {
                NSError *error = [[NSError alloc] initWithDomain:[NSString stringWithFormat:@"%s",__func__] code:[code integerValue] userInfo:respObjc];
                fail(error);
            }
        } else {
            NSDictionary *roomData = [respObjc objectForKey:kData];
            NSDictionary *roomInfoDic = [roomData objectForKey:kRoomInfo];
            LiveRoomInfoModel *roomInfo = (LiveRoomInfoModel *)[LiveRoomInfoModel yy_modelWithJSON:roomInfoDic];
            weakSelf.currentRoomInfo = roomInfo;
            
            NSArray *userListDic = [roomData objectForKey:kUserList];
            NSMutableArray *userList = [[NSMutableArray alloc]init];
            for (NSDictionary* userDic in userListDic) {
                LiveUserModel *user = (LiveUserModel *)[LiveUserModel yy_modelWithJSON:userDic];
                [userList addObject:user];
            }
            
            weakSelf.userList = userList;
            
            if (success) {
                success(roomInfo, userList);
            }
        }
    };
    
    NetServiceFailBlock failBlock = ^(NSString *taskId, NSError *error) {
        [weakSelf.taskIdArray removeObject:taskId];
        if (fail) {
            fail(error);
        }
    };
    
    NSString *taskId = [self.httpService sy_httpRequestWithType:SYHttpRequestKeyType_RoomInfo params:paras success:successBlock failure:failBlock];
    [self.taskIdArray addObject:taskId];
    YYLogFuncExit([self class], _cmd);
}

- (void)joinChatRoomSuccess:(StrCompletion _Nullable)success
                       fail:(ErrorComplete _Nullable)fail
{
    
    YYLogFuncEntry([self class], _cmd, nil);
    [self resetStatus];
    shouldRetry = true;
    
    self.successBlock = success;
    self.failBlock = fail;
    
    self.isAnchor = false;
    
    if (self.currentRoomInfo.RChatId) {
        self.joinRoomStep = HttpGetChatId;
    } else {
        [self getChatId];
    }
    YYLogFuncExit([self class], _cmd);
}

- (void)createChatRoomSuccess:(StrCompletion _Nullable)success
                         fail:(ErrorComplete _Nullable)fail
{
    YYLogFuncEntry([self class], _cmd, nil);
    self.successBlock = success;
    self.failBlock = fail;
    WeakSelf
    [self.hummerManager createChatRoomSuccess:^(NSString * _Nullable str) {
        hummerRetryCount = 0;
        weakSelf.currentRoomInfo.RChatId = str;
        weakSelf.createRoomStep = HummerCreateRoom;
    } fail:^(NSError * _Nullable error) {
        if (hummerRetryCount < maxRetryCount) {
            hummerRetryCount += 1;
            [weakSelf createChatRoomSuccess:success fail:fail];
        } else {
            [weakSelf retuenFailed:error];
        }
    }];
    YYLogFuncExit([self class], _cmd);
}

- (void)leaveRoom
{
    YYLogFuncEntry([self class], _cmd, nil);
    [self leaveChatRoom];
    [self resetStatus];
    [self.httpService cancelRequestWithRequestIDList:self.taskIdArray];
    shouldRetry = false;
    YYLogFuncExit([self class], _cmd);
}

- (void)joinChatRoom
{
    YYLogFuncEntry([self class], _cmd, nil);
    NSString *roomId = self.currentRoomInfo.RChatId;
    
    WeakSelf
    [self.hummerManager joinChatRoomWithRoomId:roomId completionHandler:^(NSError * _Nullable error) {
        if (!error) {
            hummerRetryCount = 0;
            if (weakSelf.isAnchor) {
                weakSelf.createRoomStep = weakSelf.createRoomStep | HummerJoinRoom;
            } else {
                weakSelf.joinRoomStep = weakSelf.joinRoomStep | JoinHummerRoom;
            }
        } else {
            if (!shouldRetry) { return; }
            if (hummerRetryCount < maxRetryCount) {
                hummerRetryCount += 1;
                [weakSelf joinChatRoom];
            } else {
                [weakSelf retuenFailed:error];
            }
        }
    }];
    
    YYLogFuncExit([self class], _cmd);
}

- (void)leaveChatRoom
{
    YYLogFuncEntry([self class], _cmd, nil);
    [self.hummerManager leaveChatRoomWithCompletionHandler:^(NSError * _Nullable error) {
        
    }];
}

- (void)setChatId
{
    NSString *roomId = self.currentRoomInfo.RoomId;
    NSString *chatId = self.currentRoomInfo.RChatId;
    LiveType roomType = self.currentRoomInfo.RType;
    
    NSDictionary *addInfo = @{
        kRChatId: @([chatId integerValue]),
        kRoomId: @([roomId integerValue]),
        kRType: @(roomType),
    };
    
    NSDictionary *paras = [ParameterHelper parametersForRequest:Http_SetChatId additionInfo:addInfo];
    
    YYLogFuncEntry([self class], _cmd, paras);
    
    WeakSelf
    NetServiceSuccessBlock successBlock = ^(NSString *taskId, id _Nullable respObjc) {
        [weakSelf.taskIdArray removeObject:taskId];
        NSNumber *code = [respObjc objectForKey:kCode];
        if (![code isEqualToNumber:[NSNumber numberWithInt:[ksuccessCode intValue]]]) {
            if (httpRetryCount < maxRetryCount) {
                httpRetryCount += 1;
                [weakSelf setChatId];
            } else {
                NSError *error = [[NSError alloc] initWithDomain:[NSString stringWithFormat:@"%s",__func__] code:[code integerValue] userInfo:respObjc];
                [weakSelf retuenFailed:error];
            }
        } else {
            httpRetryCount = 0;
            weakSelf.createRoomStep = weakSelf.createRoomStep | HttpSetChatId;
        }
    };
    
    NetServiceFailBlock failBlock = ^(NSString *taskId, NSError *error) {
        [weakSelf.taskIdArray removeObject:taskId];
        if (httpRetryCount < maxRetryCount) {
            httpRetryCount += 1;
            [weakSelf setChatId];
        } else {
            [weakSelf retuenFailed:error];
        }
    };
    
    NSString *taskId = [self.httpService sy_httpRequestWithType:SYHttpRequestKeyType_SetChatId params:paras success:successBlock failure:failBlock];
    [self.taskIdArray addObject:taskId];
    
    YYLogFuncExit([self class], _cmd);
}

- (void)getChatId
{
    NSString *roomId = self.currentRoomInfo.RoomId;
    LiveType roomType = self.currentRoomInfo.RType;
    
    NSDictionary *addInfo = @{
        kRoomId: @([roomId integerValue]),
        kRType: @(roomType),
    };
    
    NSDictionary *paras = [ParameterHelper parametersForRequest:Http_GetChatId additionInfo:addInfo];
    YYLogFuncEntry([self class], _cmd, paras);
    
    WeakSelf
    NetServiceSuccessBlock successBlock = ^(NSString *taskId, id _Nullable respObjc) {
        [weakSelf.taskIdArray removeObject:taskId];
        NSNumber *code = [respObjc objectForKey:kCode];
        if (![code isEqualToNumber:[NSNumber numberWithInt:[ksuccessCode intValue]]]) {
            if (httpRetryCount < maxRetryCount) {
                httpRetryCount += 1;
                [weakSelf getChatId];
            } else {
                NSError *error = [[NSError alloc] initWithDomain:[NSString stringWithFormat:@"%s",__func__] code:[code integerValue] userInfo:respObjc];
                [weakSelf retuenFailed:error];
            }
        } else {
            httpRetryCount = 0;
            NSString *chatId = [[respObjc objectForKey:kData] objectForKey:kRChatId];
            weakSelf.currentRoomInfo.RChatId = chatId;
            weakSelf.joinRoomStep = weakSelf.joinRoomStep | HttpGetChatId;
        }
    };
    
    NetServiceFailBlock failBlock = ^(NSString *taskId, NSError *error) {
        [weakSelf.taskIdArray removeObject:taskId];
        if (httpRetryCount < maxRetryCount) {
            httpRetryCount += 1;
            [weakSelf getChatId];
        } else {
            [weakSelf retuenFailed:error];
        }
    };
    
    NSString *taskId =  [self.httpService sy_httpRequestWithType:SYHttpRequestKeyType_GetChatId params:paras success:successBlock failure:failBlock];
    [self.taskIdArray addObject:taskId];
    
    YYLogFuncExit([self class], _cmd);
}

- (void)retuenFailed:(NSError * _Nullable)error
{
    [self resetStatus];
    
    if (_failBlock) {
        _failBlock(error);
    }
    
    _failBlock = nil;
}

- (void)setCreateRoomStep:(CreateRoomStep)createRoomStep
{
    NSString *paras = [NSString stringWithFormat:@"createRoomStep: %lu", (unsigned long)createRoomStep];
    YYLogFuncEntry([self class], _cmd, paras);
    _createRoomStep = createRoomStep;
    if (!shouldRetry) { return; }
    if (_createRoomStep & HttpSetChatId && _createRoomStep & HummerJoinRoom) {
        if (_successBlock) {
            _successBlock(_currentRoomInfo.RChatId);
        }
        _successBlock = nil;
        return;
    }
    
    if (_createRoomStep & HummerCreateRoom) {
        if (_createRoomStep & HummerJoinRoom || _createRoomStep & HttpSetChatId) {
            return;
        }
        [self setChatId];
        [self joinChatRoom];
        return;
    }
}

- (void)setJoinRoomStep:(JoinRoomStep)joinRoomStep
{
    NSString *paras = [NSString stringWithFormat:@"joinRoomStep: %lu", (unsigned long)joinRoomStep];
    YYLogFuncEntry([self class], _cmd, paras);
    _joinRoomStep = joinRoomStep;
    if (!shouldRetry) { return; }
    if (_joinRoomStep & JoinHummerRoom) {
        if (_successBlock) {
            _successBlock(_currentRoomInfo.RChatId);
        }
        _successBlock = nil;
        return;
    }
    
    if (_joinRoomStep & HttpGetChatId) {
        [self joinChatRoom];
        return;
    }
}

- (void)resetStatus
{
    _createRoomStep = 0;
    _joinRoomStep = 0;
    hummerRetryCount = 0;
    hummerRetryCount = 0;
//    self.currentRoomInfo = nil;
//    self.userList = nil;
    self.isAnchor = false;
}

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
        _thunderManager = [SYThunderManagerNew sharedManager];
    }
    
    return _thunderManager;
}
@end
