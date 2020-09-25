//
//  SYAppInfo.h
//  LiveBroadcasting
//
//  Created by ashawn on 2019/5/24.
//  Copyright © 2019 Gocy. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SYAppInfo : NSObject

@property (nonatomic, copy, readonly) NSString *appId;          // 从聚联云官网申请的Appid

@property (nonatomic, copy, readonly) NSString *appName;        // 应用名称
@property (nonatomic, copy, readonly) NSString *appVersion;     // 版本号
@property (nonatomic, copy, readonly) NSString *appBuild;       // 构建号
@property (nonatomic, copy, readonly) NSString *appBundleId;    // appid
@property (nonatomic, copy, readonly) NSString *compAppId;      // 应用标识
@property (nonatomic, copy, readonly) NSString *feedbackAppId;  // 反馈 appid
@property (nonatomic, copy, readonly) NSString *scheme;         // app 的scheme
@property (nonatomic, readonly) BOOL enableSCLog;         // 是否托管聚联云日志
@property (nonatomic, copy, readonly) NSString *appArea;         // 地区
@property (nonatomic, copy, readonly) NSString *gitVersion; // git version
@property (nonatomic, copy, readonly) NSString *gitBranch; // git branch

@property (nonatomic, copy, readwrite) NSString *ofSerialNumber;  // 美颜 SDK 序列号(请联系技术同学申请)

@property (nonatomic, copy, readonly) NSString *SvrVer;
@property (nonatomic, copy, readonly) NSString *DevName;
@property (nonatomic, copy, readonly) NSString *DevUUID;

+ (instancetype)sharedInstance;

@end
