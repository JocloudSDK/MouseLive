//
//  UIImageView+SLExtension.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/3.
//  Copyright © 2020 sy. All rights reserved.
//

#import "UIImageView+SLExtension.h"



@implementation UIImageView (SLExtension)

- (void)yy_playGifAnim:(NSArray *)images
{
    if (!images.count) {
        return;
    }
    //动画图片数组
    self.animationImages = images;
    //执行一次完整动画所需的时长
    self.animationDuration = 0.5;
    //动画重复次数, 设置成0 就是无限循环
    self.animationRepeatCount = 0;
    [self startAnimating];
}

// 停止动画
- (void)yy_stopGifAnim
{
    if (self.isAnimating) {
        [self stopAnimating];
    }
    [self removeFromSuperview];
}
@end
