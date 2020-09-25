//
//  WSBaseRequest.m
//  MouseLive
//
//  Created by 张建平 on 2020/4/23.
//  Copyright © 2020 sy. All rights reserved.
//

#import "WSBaseRequest.h"
#import "SYAppInfo.h"

@implementation WSBaseRequest

- (instancetype)init
{
    if (self = [super init]) {
        self.AppId = (int)[SYAppInfo sharedInstance].appId.longLongValue;
    }
    return self;
}

@end
