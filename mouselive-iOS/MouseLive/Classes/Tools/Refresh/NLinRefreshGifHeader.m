//
//  NLinRefreshGifHeader.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/3.
//  Copyright © 2020 sy. All rights reserved.
//

#import "NLinRefreshGifHeader.h"

@implementation NLinRefreshGifHeader

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.lastUpdatedTimeLabel.hidden = YES;
        self.stateLabel.hidden = YES;
        [self setImages:@[[UIImage imageNamed:@"reflesh1_60x55"], [UIImage imageNamed:@"reflesh2_60x55"], [UIImage imageNamed:@"reflesh3_60x55"]]  forState:MJRefreshStateRefreshing];
        [self setImages:@[[UIImage imageNamed:@"reflesh1_60x55"], [UIImage imageNamed:@"reflesh2_60x55"], [UIImage imageNamed:@"reflesh3_60x55"]]  forState:MJRefreshStatePulling];
        [self setImages:@[[UIImage imageNamed:@"reflesh1_60x55"], [UIImage imageNamed:@"reflesh2_60x55"], [UIImage imageNamed:@"reflesh3_60x55"]]  forState:MJRefreshStateIdle];
    }
    return self;
}

- (void)placeSubviews
{
    [super placeSubviews];
    self.gifView.contentMode = UIViewContentModeCenter;
    self.gifView.frame = CGRectMake(0, 4,self.mj_w, 25);
    self.stateLabel.font = [UIFont systemFontOfSize:12];
    self.stateLabel.frame = CGRectMake(0, 40, self.mj_w, 14);
}
@end
