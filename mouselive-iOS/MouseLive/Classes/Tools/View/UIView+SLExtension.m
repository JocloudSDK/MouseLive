//
//  UIView+SLExtension.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/2.
//  Copyright © 2020 sy. All rights reserved.
//

#import "UIView+SLExtension.h"
#import <objc/runtime.h>

@implementation UIView (SLExtension)
- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setYy_y:(CGFloat)yy_y
{
    CGRect frame = self.frame;
    frame.origin.y = yy_y;
    self.frame= frame;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setYy_height:(CGFloat)yy_height
{
    CGRect frame = self.frame;
    frame.size.height = yy_height;
    self.frame = frame;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (CGFloat)yy_y
{
    return self.frame.origin.y;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (CGFloat)yy_height
{
    return self.frame.size.height;
}

- (CGSize)size
{
    return self.frame.size;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

+ (void)yy_maskViewToBounds:(UIView *)view
{
      view.layer.cornerRadius = view.yy_height * 0.5;
      view.layer.masksToBounds = YES;
}

+ (void)yy_maskViewToBounds:(UIView *)view radius:(CGFloat)cornerRadius
{
    if (cornerRadius == 1) {
        [UIView yy_maskViewToBounds:view];
    }
    view.layer.cornerRadius = cornerRadius;
    view.layer.masksToBounds = YES;
}

@end

