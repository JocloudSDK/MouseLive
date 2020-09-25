//
//  NetWorkQuality.m
//  MouseLive
//
//  Created by 张建平 on 2020/3/26.
//  Copyright © 2020 sy. All rights reserved.
//

#import "NetWorkQuality.h"

@implementation NetWorkQuality

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    if (self = [super init]) {
        self.downloadNetQuality = THUNDER_SDK_NETWORK_QUALITY_GOOD;
        self.uploadNetQuality = THUNDER_SDK_NETWORK_QUALITY_GOOD;
    }
    return self;
}

@end
