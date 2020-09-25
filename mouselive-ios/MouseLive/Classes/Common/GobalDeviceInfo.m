//
//  GobalDeviceInfo.m
//  MouseLive
//
//  Created by 张建平 on 2020/3/4.
//  Copyright © 2020 sy. All rights reserved.
//

#import "GobalDeviceInfo.h"
#import <sys/utsname.h>
#import <UIKit/UIDevice.h>

@interface GobalDeviceInfo()

@property (nonatomic, readwrite) NSString* projectName;
@property (nonatomic, readwrite) NSString *projectVersion;
@property (nonatomic, readwrite) NSString *region;
@property (nonatomic, readwrite) NSString *language;
@property (nonatomic, readwrite) NSString *platfrom;
@property (nonatomic, readwrite) NSString *phoneVersion;

@end

@implementation GobalDeviceInfo

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
    if (self = [super init]) {
        NSDictionary *dict = [[NSBundle mainBundle] infoDictionary];
        self.projectName = dict[@"CFBundleExecutable"];
        self.projectVersion = dict[@"CFBundleShortVersionString"];
        self.region = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
        self.language = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] firstObject];
        self.platfrom = [self iphoneType];
        self.phoneVersion = [[UIDevice currentDevice] systemVersion];
    }
    return self;
}

- (NSString *)iphoneType
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];

    NSLog(@"platform = %@", platform);
    if ([platform isEqualToString:@"iPhone1,1"]) {
         return @"iPhone 2G";
    }
    if ([platform isEqualToString:@"iPhone1,2"]) {
         return @"iPhone 3G";
    }
    if ([platform isEqualToString:@"iPhone2,1"]) {
         return @"iPhone 3GS";
    }
    if ([platform isEqualToString:@"iPhone3,1"]) {
         return @"iPhone 4";
    }
    if ([platform isEqualToString:@"iPhone3,2"]) {
         return @"iPhone 4";
    }
    if ([platform isEqualToString:@"iPhone3,3"]) {
         return @"iPhone 4";
    }
    if ([platform isEqualToString:@"iPhone4,1"]) {
         return @"iPhone 4S";
    }
    if ([platform isEqualToString:@"iPhone5,1"]) {
         return @"iPhone 5";
    }
    if ([platform isEqualToString:@"iPhone5,2"]) {
         return @"iPhone 5";
    }
    if ([platform isEqualToString:@"iPhone5,3"]) {
         return @"iPhone 5c";
    }
    if ([platform isEqualToString:@"iPhone5,4"]) {
         return @"iPhone 5c";
    }
    if ([platform isEqualToString:@"iPhone6,1"]) {
         return @"iPhone 5s";
    }
    if ([platform isEqualToString:@"iPhone6,2"]) {
         return @"iPhone 5s";
    }
    if ([platform isEqualToString:@"iPhone7,1"]) {
         return @"iPhone 6 Plus";
    }
    if ([platform isEqualToString:@"iPhone7,2"]) {
         return @"iPhone 6";
    }
    if ([platform isEqualToString:@"iPhone8,1"]) {
         return @"iPhone 6s";
    }
    if ([platform isEqualToString:@"iPhone8,2"]) {
         return @"iPhone 6s Plus";
    }
    if ([platform isEqualToString:@"iPhone8,4"]) {
         return @"iPhone SE";
    }
    if ([platform isEqualToString:@"iPhone9,1"]) {
         return @"iPhone 7";
    }
    if ([platform isEqualToString:@"iPhone9,2"]) {
         return @"iPhone 7 Plus";
    }
    if ([platform isEqualToString:@"iPod1,1"]) {
           return @"iPod Touch 1G";
    }
    if ([platform isEqualToString:@"iPod2,1"]) {
           return @"iPod Touch 2G";
    }
    if ([platform isEqualToString:@"iPod3,1"]) {
           return @"iPod Touch 3G";
    }
    if ([platform isEqualToString:@"iPod4,1"]) {
           return @"iPod Touch 4G";
    }
    if ([platform isEqualToString:@"iPod5,1"]) {
           return @"iPod Touch 5G";
    }
    if ([platform isEqualToString:@"iPad1,1"]) {
           return @"iPad 1G";
    }
    if ([platform isEqualToString:@"iPad2,1"]) {
           return @"iPad 2";
    }
    if ([platform isEqualToString:@"iPad2,2"]) {
           return @"iPad 2";
    }
    if ([platform isEqualToString:@"iPad2,3"]) {
           return @"iPad 2";
    }
    if ([platform isEqualToString:@"iPad2,4"]) {
           return @"iPad 2";
    }
    if ([platform isEqualToString:@"iPad2,5"]) {
           return @"iPad Mini 1G";
    }
    if ([platform isEqualToString:@"iPad2,6"]) {
           return @"iPad Mini 1G";
    }
    if ([platform isEqualToString:@"iPad2,7"]) {
           return @"iPad Mini 1G";
    }
    if ([platform isEqualToString:@"iPad3,1"]) {
           return @"iPad 3";
    }
    if ([platform isEqualToString:@"iPad3,2"]) {
           return @"iPad 3";
    }
    if ([platform isEqualToString:@"iPad3,3"]) {
           return @"iPad 3";
    }
    if ([platform isEqualToString:@"iPad3,4"]) {
           return @"iPad 4";
    }
    if ([platform isEqualToString:@"iPad3,5"]) {
           return @"iPad 4";
    }
    if ([platform isEqualToString:@"iPad3,6"]) {
           return @"iPad 4";
    }
    if ([platform isEqualToString:@"iPad4,1"]) {
           return @"iPad Air";
    }
    if ([platform isEqualToString:@"iPad4,2"]) {
           return @"iPad Air";
    }
    if ([platform isEqualToString:@"iPad4,3"]) {
           return @"iPad Air";
    }
    if ([platform isEqualToString:@"iPad4,4"]) {
           return @"iPad Mini 2G";
    }
    if ([platform isEqualToString:@"iPad4,5"]) {
           return @"iPad Mini 2G";
    }
    if ([platform isEqualToString:@"iPad4,6"]) {
           return @"iPad Mini 2G";
    }
    if ([platform isEqualToString:@"i386"]) {
              return @"iPhone Simulator";
    }
    if ([platform isEqualToString:@"x86_64"]) {
            return @"iPhone Simulator";
    }
    return platform;
}

@end
