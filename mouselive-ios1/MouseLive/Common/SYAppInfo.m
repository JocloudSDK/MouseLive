//
//  SYAppInfo.m
//  LiveBroadcasting
//
//  Created by ashawn on 2019/5/24.
//  Copyright © 2019 Gocy. All rights reserved.
//

#import "SYAppInfo.h"
#import "SYAppId.h"

@interface SYAppInfo ()

@property (nonatomic, copy, readwrite) NSString *appId;          // 平台部服务的 appid
@property (nonatomic, copy, readwrite) NSString *appName;        // 应用名称
@property (nonatomic, copy, readwrite) NSString *appVersion;     // 版本号
@property (nonatomic, copy, readwrite) NSString *appBuild;       // 构建号
@property (nonatomic, copy, readwrite) NSString *appBundleId;    // appid
@property (nonatomic, copy, readwrite) NSString *compAppId;      // 应用标识
@property (nonatomic, copy, readwrite) NSString *feedbackAppId;  // 反馈 appid
@property (nonatomic, copy, readwrite) NSString *scheme;         // app 的scheme
@property (nonatomic, readwrite) BOOL enableSCLog;         // 是否托管聚联云日志
@property (nonatomic, copy, readwrite) NSString *appArea;         // 地区
@property (nonatomic, copy, readwrite) NSString *gitVersion; // git version
@property (nonatomic, copy, readwrite) NSString *gitBranch; // git branch

@property (nonatomic, copy, readwrite) NSString *SvrVer;
@property (nonatomic, copy, readwrite) NSString *DevName;
@property (nonatomic, copy, readwrite) NSString *DevUUID;

@end


@implementation SYAppInfo

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.appId = kSYAppId;

        self.appName = @"mouseLive-ios";
        self.appVersion = [self _valueInPlistForKey:@"CFBundleShortVersionString"];
        self.appBuild = [self _valueInPlistForKey:(NSString *)kCFBundleVersionKey];
        self.appBundleId = [self _valueInPlistForKey:(NSString *)kCFBundleIdentifierKey];
        self.compAppId = @"mouseLive-ios";
        self.feedbackAppId = @"mouseLive-ios";
        self.scheme = @"mouseLive";
        self.enableSCLog = YES;
        self.appArea = @"china";
        self.gitVersion = [self _valueInPlistForKey:@"SvnBuildVersion"];
        self.gitBranch = [self getGitBranch];
        self.ofSerialNumber = kOFSDKSerialNumber;
        
        self.SvrVer = @"v0.1.0";
        self.DevName = [UIDevice currentDevice].name;
        self.DevUUID = [UIDevice currentDevice].identifierForVendor.UUIDString;
        
    }
    return self;
}

- (id)_valueInPlistForKey:(NSString *)key
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [infoDictionary objectForKey:key];
}

- (NSString *)getGitBranch
{
    NSString *str = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MouseLive-user.plist" ofType:nil];
    NSDictionary *infoDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    str = [infoDictionary objectForKey:@"GitCommitBranch"];
    return str;
}

@end
