//
//  LoginManager.m
//  MouseLive
//
//  Created by 张骥 on 2020/5/14.
//  Copyright © 2020 sy. All rights reserved.
//

#import "LoginManager.h"
#import "SYHttpService.h"
#import "SYHummerManager.h"
#import "SYToken.h"

@interface LoginManager()

@property(nonatomic, strong) SYHttpService* httpService;
@property(nonatomic, strong) SYHummerManager *hummerManager;

@end

@implementation LoginManager

+ (instancetype)shareManager
{
    static LoginManager* manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (SYHttpService *)httpService
{
    if (!_httpService) {
        _httpService = [[SYHttpService alloc]init];
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

- (void)login:(DicCompletion)success fail:(ErrorDicComplete)fail
{
    NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey:kUid];
    if (!uid) {
        uid = @"0";
    }
    
    NSDictionary *params = @{
        kUid:@([uid intValue]),
        kDevName:[UIDevice currentDevice].name,
        kDevUUID:[UIDevice currentDevice].identifierForVendor.UUIDString,
        kValidTime:@([SYToken sharedInstance].validTime),
    };
    
    NetServiceSuccessBlock successBlock = ^(NSString *taskId ,id  _Nullable respObjc) {
        NSNumber *code = [respObjc objectForKey:kCode];
<<<<<<< HEAD
        if (![code isEqualToNumber:[NSNumber numberWithInt:[ksuccessCode intValue]]]) {
            YYLogError(@"Hummer failure");
        }else{
            NSDictionary* userInfo = [respObjc objectForKey:kData];
            NSString* uid = (NSString*)[userInfo objectForKey:kUid];
            NSString* token = (NSString*)[userInfo objectForKey:kToken];
=======
        if ([code isEqualToNumber:[NSNumber numberWithInt:[ksuccessCode intValue]]]) {
            NSDictionary *userInfo = [respObjc objectForKey:kData];
            NSString *uid = (NSString *)[userInfo objectForKey:kUid];
            NSString *token = (NSString *)[userInfo objectForKey:kToken];
>>>>>>> dev_v1.2.0_feature
            
            [[NSUserDefaults standardUserDefaults] setObject:uid forKey:kUid];
            [[NSUserDefaults standardUserDefaults] setObject:token forKey:kToken];
            
            [SYToken sharedInstance].thToken = token;
            [SYToken sharedInstance].localUid = uid;
            
            [self.hummerManager loginWithUid:uid completionHandler:^(NSError * _Nullable error) {
                YYLogError(@"Hummer failure%@",error);
                if (error) {
                    if (fail) {
                        fail(error, nil, @"Hummer login failed");
                    }
                } else {
                    if (success) {
                        success(respObjc);
                    }
                }
            }];
        }
    };
    
    NetServiceFailBlock failBlock = ^(NSString *taskId, NSError *error) {
        if (fail) {
            fail(error,nil,nil);
        }
    };
    
    [self.httpService sy_httpRequestWithType:SYHttpRequestKeyType_Login params:params success:successBlock failure:failBlock];
}

@end
