//
//  UserManager.m
//  MouseLive
//
//  Created by 张骥 on 2020/5/15.
//  Copyright © 2020 sy. All rights reserved.
//

#import "UserManager.h"
#import "SYHttpService.h"
#import "SYHummerManager.h"
#import "ParameterHelper.h"
#import "SYToken.h"

@interface UserManager()

@property(nonatomic, copy)NSArray<LiveUserModel *> *videoAnchorLst;
@property(nonatomic, copy)NSArray<LiveUserModel *> *audioAnchorLst;
@property(nonatomic, copy)NSArray<LiveUserModel *> *ktvAnchorLst;

@property(nonatomic, strong) SYHttpService *httpService;
@property(nonatomic, strong) SYHummerManager *hummerManager;

@end

@implementation UserManager



+ (instancetype)shareManager
{
    static UserManager* manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[UserManager alloc]init];
    });
    
    return manager;
}

- (void)login:(UserInfoCompletion _Nullable)success
         fail:(ErrorComplete _Nullable)fail
{
    
    NSDictionary *params = [ParameterHelper parametersForRequest:Http_Login additionInfo:nil];
    
    WeakSelf
    NetServiceSuccessBlock successBlock = ^(NSString *taskId, id _Nullable respObjc) {
        NSNumber *code = [respObjc objectForKey:kCode];
        if (![code isEqualToNumber:[NSNumber numberWithInt:[ksuccessCode intValue]]]) {
            if (fail) {
                NSError *error = [[NSError alloc] initWithDomain:[NSString stringWithFormat:@"%s",__func__] code:[code integerValue] userInfo:respObjc];
                fail(error);
            }
        } else {
            NSDictionary *userInfo = [respObjc objectForKey:kData];
            NSString *uid = (NSString *)[userInfo objectForKey:kUid];
            NSString *token = (NSString *)[userInfo objectForKey:kToken];
            NSString *nickname = (NSString *)[userInfo objectForKey:kNickName];
            
            [[NSUserDefaults standardUserDefaults] setObject:uid forKey:kUid];
            [[NSUserDefaults standardUserDefaults] setObject:token forKey:kToken];
            [[NSUserDefaults standardUserDefaults] setObject:nickname forKey:kNickName];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [SYToken sharedInstance].thToken = token;
            [SYToken sharedInstance].localUid = uid;
            
            LiveUserModel *user = (LiveUserModel *)[LiveUserModel yy_modelWithJSON:userInfo];
            weakSelf.currentUser = user;
            [self.hummerManager loginWithUid:uid completionHandler:^(NSError * _Nullable error) {
                YYLogError(@"Hummer failure%@",error);
                if (error) {
                    if (fail) {
                        fail(error);
                    }
                } else {
                    if (success) {
                        success(user);
                    }
                }
            }];
        }
    };
    
    NetServiceFailBlock failBlock = ^(NSString *taskId, NSError *error) {
        if (fail) {
            fail(error);
        }
    };
    
    [self.httpService sy_httpRequestWithType:SYHttpRequestKeyType_Login params:params success:successBlock failure:failBlock];
}

- (void)getAnchorListForType:(LiveType)type
                     succsee:(ArrayCompletion)succsee
                        fail:(ErrorDicComplete)fail
{
    
}

- (void)getUserInfoWith:(NSString * _Nonnull)uid
                success:(UserInfoCompletion _Nullable)success
                   fail:(ErrorComplete _Nullable)fail
{
    NSDictionary *params = [ParameterHelper parametersForRequest:Http_GetUserInfo additionInfo:@{kUid:uid}];
    
    NetServiceSuccessBlock successBlock = ^(NSString *taskId, id _Nullable respObjc) {
        NSNumber *code = [respObjc objectForKey:kCode];
        if (![code isEqualToNumber:[NSNumber numberWithInt:[ksuccessCode intValue]]]) {
            if (fail) {
                NSError *error = [[NSError alloc] initWithDomain:[NSString stringWithFormat:@"%s",__func__] code:[code integerValue] userInfo:respObjc];
                fail(error);
            }
        } else {
            NSDictionary *userInfo = [respObjc objectForKey:kData];
            LiveUserModel *user = (LiveUserModel *)[LiveUserModel yy_modelWithJSON:userInfo];
            
            if (success) {
                success(user);
            }
        }
    };
    
    NetServiceFailBlock failBlock = ^(NSString *taskId, NSError *error) {
        if (fail) {
            fail(error);
        }
    };
    
    [self.httpService sy_httpRequestWithType:SYHttpRequestKeyType_GetUserInfo params:params success:successBlock failure:failBlock];
}

- (SYHummerManager *)hummerManager
{
    if (!_hummerManager) {
        _hummerManager = [SYHummerManager sharedManager];
    }
    
    return _hummerManager;
}

- (SYHttpService *)httpService
{
    if (!_httpService) {
        _httpService = [SYHttpService shareInstance];
    }
    return _httpService;
}

@end
