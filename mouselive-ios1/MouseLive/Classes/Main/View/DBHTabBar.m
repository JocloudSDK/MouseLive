//
//  DBHTabBar.m
//  MouseLive
//
//  Created by 张建平 on 2020/3/3.
//  Copyright © 2020 sy. All rights reserved.
//

#import "DBHTabBar.h"


@interface DBHTabBar ()

@property (nonatomic, strong) UIButton *plusButton;
@end

@implementation DBHTabBar

#pragma mark - Lifecycle
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.plusButton];
    }
    return self;
}

#pragma mark - Event Responds
/**
 * 点击了加号按钮
 */
- (void)respondsToPlusButton
{
    // 通知代理
    if ([self.delegate respondsToSelector:@selector(tabBarDidClickPlusButton:)]) {
        [self.myDelegate tabBarDidClickPlusButton:self];
    }
}

#pragma mark - Private Methods
/**
 *  重新布局系统tabBarItem
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 1.设置加号按钮的位置
    UIImage *plusimage = [UIImage imageNamed:@"Main_PlusNormal"];

    self.plusButton.center = CGPointMake(CGRectGetWidth(self.frame) * 0.5, plusimage.size.height/2 - 14.5);
    
    // 2.设置其他tabbarButton的frame
    CGFloat tabBarButtonWidth = CGRectGetWidth(self.frame) / 3;
    CGFloat tabBarButtonIndex = 0;
    for (UIView *childView in self.subviews) {
        Class class = NSClassFromString(@"UITabBarButton");
        if ([childView isKindOfClass:class]) {
            // 设置位置
            childView.frame = CGRectMake(tabBarButtonWidth * tabBarButtonIndex, CGRectGetMinY(childView.frame), tabBarButtonWidth, CGRectGetHeight(childView.frame));
            // 增加索引
            tabBarButtonIndex += (tabBarButtonIndex == 0 ? 2 : 1);
        }
    }
}
/**
 重写hitTest方法以响应点击超出tabBar的加号按钮
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (!self.clipsToBounds && !self.hidden && self.alpha > 0) {
        UIView *result = [super hitTest:point withEvent:event];
        if (result) {
            return result;
        }
        else {
            for (UIView *subview in self.subviews.reverseObjectEnumerator) {
                CGPoint subPoint = [subview convertPoint:point fromView:self];
                result = [subview hitTest:subPoint withEvent:event];
                if (result) {
                    return result;
                }
            }
        }
    }
    return nil;
}

#pragma mark - Getters And Setters
- (UIButton *)plusButton
{
    if (!_plusButton) {
        _plusButton = [[UIButton alloc] init];
        [_plusButton setImage:[UIImage imageNamed:@"Main_PlusNormal"] forState:UIControlStateNormal];
        [_plusButton setImage:[UIImage imageNamed:@"Main_PlusSelected"] forState:UIControlStateHighlighted];
        
        _plusButton.frame = CGRectMake(0, 0, _plusButton.imageView.image.size.width, _plusButton.imageView.image.size.height);
        [_plusButton addTarget:self action:@selector(respondsToPlusButton) forControlEvents:UIControlEventTouchUpInside];

    }
    return _plusButton;
}

@end
