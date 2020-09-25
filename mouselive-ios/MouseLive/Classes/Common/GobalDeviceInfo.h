//
//  GobalDeviceInfo.h
//  MouseLive
//
//  Created by 张建平 on 2020/3/4.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define GOBAL_IS_US_REGION [[GobalInfoPlist sharedInstance].language isEqualToString:@"en_US"]
#define GOBAL_IS_ZH_REGION [[GobalInfoPlist sharedInstance].language isEqualToString:@"en_CN"]

#define GOBAL_IS_US_LANGUAGE [[GobalInfoPlist sharedInstance].language isEqualToString:@"en-US"]
#define GOBAL_IS_ZH_LANGUAGE [[GobalInfoPlist sharedInstance].language isEqualToString:@"zh-Hans-US"]

@interface GobalDeviceInfo : NSObject

@property (nonatomic, readonly) NSString* projectName;
@property (nonatomic, readonly) NSString *projectVersion;
@property (nonatomic, readonly) NSString *region;
@property (nonatomic, readonly) NSString *language;
@property (nonatomic, readonly) NSString *platfrom;
@property (nonatomic, readonly) NSString *phoneVersion;

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
