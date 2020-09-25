//
//  UIView+SLExtension.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/2.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (SLExtension)
///** X */
//@property (nonatomic, assign) CGFloat x;

/** Y */
@property (nonatomic, assign) CGFloat yy_y;
//
///** Width */
//@property (nonatomic, assign) CGFloat width;

/** Height */
@property (nonatomic, assign) CGFloat yy_height;
//
///** size */
//@property (nonatomic, assign) CGSize size;
//
///** centerX */
//@property (nonatomic, assign) CGFloat centerX;
//
///** centerY */
//@property (nonatomic, assign) CGFloat centerY;

+ (void)yy_maskViewToBounds:(UIView *)view;
+ (void)yy_maskViewToBounds:(UIView *)view radius:(CGFloat)cornerRadius;

@end

NS_ASSUME_NONNULL_END
