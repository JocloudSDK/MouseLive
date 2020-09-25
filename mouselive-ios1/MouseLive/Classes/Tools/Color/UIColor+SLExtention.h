//
//  UIColor+SLExtention.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/10.
//  Copyright © 2020 sy. All rights reserved.
//



#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (SLExtention)
//设置RGB颜色
+ (UIColor *)sl_red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(CGFloat)alpha;
//将颜色转换成RGB
+ (NSArray *)sl_convertColorToRGB:(UIColor *)color;
//设置十六进制颜色
+ (UIColor *)sl_colorWithHex:(NSInteger)hex;
+ (UIColor *)sl_colorWithHexString:(NSString *)hexString;
@end

NS_ASSUME_NONNULL_END
