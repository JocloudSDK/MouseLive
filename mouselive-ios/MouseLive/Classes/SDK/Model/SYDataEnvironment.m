//
//  SYDataEnvironment.m
//  MouseLive
//
//  Created by 张建平 on 2020/3/17.
//  Copyright © 2020 sy. All rights reserved.
//

#import "SYDataEnvironment.h"
#import "SYTokenHelper.h"
#import "SYAppInfo.h"

@interface SYDataEnvironment ()

@property (nonatomic, strong) NSMutableDictionary *tokenData;

@end

@implementation SYDataEnvironment

+ (instancetype)sharedDataEnvironment
{
    static SYDataEnvironment *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - Public

- (NSString *)getTokenWithUid:(UInt64)uid
{
    NSString *stringUid = [NSString stringWithFormat:@"%llu", uid];
    return [self getTokenWithStingUid:stringUid];
}

- (NSString *)getTokenWithStingUid:(NSString *)uid
{
    NSString *token = self.tokenData[uid];
    if (token.length) {
        return token;
    }
    
    __block NSString *result = @"";
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    
    SYTokenRequestParams *params = [SYTokenRequestParams defaultParams];
    params.appId = [SYAppInfo sharedInstance].appId;
    params.uid = uid;
    params.validTime = 24*60*60;
    [SYTokenHelper requestTokenWithParams:params completionHandler:^(BOOL success, NSString *token) {
        if (success) {
            result = token;
            self.tokenData[uid] = result;
        }
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return result;
}


#pragma mark - Get

- (NSMutableDictionary *)tokenData
{
    if (_tokenData == nil) {
        _tokenData = [[NSMutableDictionary alloc] init];
    }
    return _tokenData;
}


@end
