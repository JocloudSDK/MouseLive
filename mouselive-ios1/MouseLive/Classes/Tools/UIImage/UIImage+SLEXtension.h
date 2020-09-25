//
//  UIImage+SLEXtension.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/3.
//  Copyright © 2020 sy. All rights reserved.
//



#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, GradientDirection) {
    GradientDirectionTopToBottom = 0,    // 从上往下 渐变
    GradientDirectionLeftToRight,        // 从左往右
    GradientDirectionBottomToTop,      // 从下往上
    GradientDirectionRightToLeft      // 从右往左
};
NS_ASSUME_NONNULL_BEGIN

@interface UIImage (SLEXtension)
/**
 *  生成一张高斯模糊的图片
 *
 *  @param image 原图
 *  @param blur  模糊程度 (0~1)
 *
 *  @return 高斯模糊图片
 */
+ (UIImage *)yy_blurImage:(UIImage *)image blur:(CGFloat)blur;

/**
 *  根据颜色生成一张图片
 *
 *  @param color 颜色
 *  @param size  图片大小
 *
 *  @return 图片
 */
+ (UIImage *)yy_imageWithColor:(UIColor *)color size:(CGSize)size;

/**
 *  生成圆角的图片
 *
 *  @param originImage 原始图片
 *  @param borderColor 边框原色
 *  @param borderWidth 边框宽度
 *
 *  @return 圆形图片
 */
+ (UIImage *)yy_circleImage:(UIImage *)originImage borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth;
/**
 *  @brief  生成渐变色图片
 *
 *  @param  bounds  图片的大小
 *  @param  colors      渐变颜色组
 *  @param  gradientType     渐变方向
 *
 *  @return 图片
 */
+ (UIImage *)yy_gradientImageWithBounds:(CGRect)bounds andColors:(NSArray *)colors andGradientType:(GradientDirection)gradientType;
@end

NS_ASSUME_NONNULL_END
