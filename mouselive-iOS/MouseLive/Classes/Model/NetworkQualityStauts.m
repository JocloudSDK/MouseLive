//
//  NetworkQualityStauts.m
//  MouseLive
//
//  Created by 张建平 on 2020/3/22.
//  Copyright © 2020 sy. All rights reserved.
//

#import "NetworkQualityStauts.h"

@implementation NetworkQualityStauts

- (NetWorkQuality *)netWorkQuality
{
    if (!_netWorkQuality) {
        _netWorkQuality = [[NetWorkQuality alloc]init];
    }
    return _netWorkQuality;
}

@end
