//
//  WaterMarkAdapter.m
//  MouseLive
//
//  Created by Peter Xi on 2020/6/22.
//  Copyright © 2020 sy. All rights reserved.
//

#import "WaterMarkAdapter.h"

@implementation WaterMarkAdapter

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.DEF_WIDTH = 1080;
        self.DEF_HEIGHT = 720;
    }
    return self;
}


- (ThunderImage *)createThunderBoltImage:(float)videoWidth videoHeight:(float)videoHeight rotation:(int)rotation {
    ThunderImage *water = [[ThunderImage alloc] init];
    float scale = [self getScale:videoWidth videoHeight:videoHeight rotation:rotation];
    water.rect = CGRectMake((self.startX*videoWidth/self.DEF_WIDTH), (self.startY*videoHeight/self.DEF_HEIGHT), (_width*scale), (_height*scale));
    water.url = self.imgUrl;
    return water;
    
}

- (float) getScale:(float)videoWidth videoHeight:(float)videoHeight rotation:(int)rotation {
    float widthScale =videoWidth/self.DEF_WIDTH;
    float heightScale =videoHeight/self.DEF_HEIGHT;
    return widthScale >= heightScale?widthScale:heightScale;
}


@end
