//
//  VideoViewLayer.m
//  MouseLive
//
//  Created by 张骥 on 2020/5/27.
//  Copyright © 2020 sy. All rights reserved.
//

#import "VideoViewLayer.h"

#define LIVE_PADDING 5

@implementation VideoViewLayer

+ (void)layoutFullSession:(VideoSession *)fullsession inContainerView:(UIView *)container
{
    [fullsession mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(container).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

+ (void)layoutLeftSession:(VideoSession *)leftSession rightSession:(VideoSession *)rightession inContainerView:(UIView *)container withTopView:(UIView *)topView
{
    [leftSession removeFromSuperview];
    [rightession removeFromSuperview];
    [container insertSubview:leftSession atIndex:0];
    
    if (rightession) {
        [container insertSubview:rightession atIndex:0];
        [leftSession mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(container).mas_offset(0);
            make.top.equalTo(topView.mas_bottom).mas_offset(LIVE_PADDING);
            make.right.equalTo(rightession.mas_left).mas_offset(-LIVE_PADDING);
            make.height.equalTo(leftSession.mas_width).multipliedBy(16.0 / 9.0);
            make.width.equalTo(rightession);
        }];
        [rightession mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(container).mas_offset(0);
            make.height.equalTo(leftSession);
            make.top.equalTo(topView.mas_bottom).mas_offset(LIVE_PADDING);
        }];
        [leftSession.codeRateView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(48);
            
        }];
        [rightession.codeRateView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(48);
            
        }];
    } else {
        [leftSession mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        [leftSession.codeRateView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(topView.frame.origin.y + topView.yy_height + LIVE_PADDING);
        }];
    }
}

@end
