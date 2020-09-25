//
//  UIViewController+SLExtension.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/3.
//  Copyright © 2020 sy. All rights reserved.
//

#import "UIViewController+SLExtension.h"
#import "UIImageView+SLExtension.h"
#import <objc/message.h>


static const void *GifKey = &GifKey;

@implementation UIViewController (SLExtension)
- (UIImageView *)yy_gifView
{
    return objc_getAssociatedObject(self, GifKey);
}

- (void)setYy_gifView:(UIImageView *)gifView
{
    objc_setAssociatedObject(self, GifKey, gifView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
// 显示GIF加载动画
- (void)yy_showGifLoding:(nullable NSArray *)images inView:(UIView *)view
{
    if (!images.count) {
        images = @[[UIImage imageNamed:@"hold1_60x72"], [UIImage imageNamed:@"hold2_60x72"], [UIImage imageNamed:@"hold3_60x72"]];
    }
    UIImageView *gifView = [[UIImageView alloc] init];
    if (!view) {
        view = self.view;
    }
    [view addSubview:gifView];
    [gifView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(@0);
        make.width.equalTo(@60);
        make.height.equalTo(@70);
    }];
    self.yy_gifView = gifView;
    [gifView yy_playGifAnim:images];
    
}
// 取消GIF加载动画
- (void)yy_hideGufLoding
{
    [self.yy_gifView yy_stopGifAnim];
    self.yy_gifView = nil;
}

- (BOOL)yy_isNotEmpty:(NSArray *)array
{
    if ([array isKindOfClass:[NSArray class]] && array.count) {
        return YES;
    }
    return NO;
}

@end
