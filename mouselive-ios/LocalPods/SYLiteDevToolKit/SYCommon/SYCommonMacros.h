//
//  SYCommonMacros.h
//  iPhuanLib
//
//  Created by iPhuan on 2017/2/21.
//  Copyright © 2017年 iPhuan. All rights reserved.
//

#import "UIColor+SYAdditions.h"



#pragma mark - Geometry
/*****************************************************************************************/
#define SYScreenWidth         [UIScreen mainScreen].bounds.size.width
#define SYScreenHeight        [UIScreen mainScreen].bounds.size.height
#define SYScreenBounds        [UIScreen mainScreen].bounds

#define SYXSizeMultiple      (SYScreenHeight/667.0)
#define SYXFitSize(X)        ((X) * SYXSizeMultiple)   // 以6为参考，5，6，6P，X等比缩放，适应于纵向布局

#define SY6PSizeMultiple      (SYScreenWidth <= 375?1.0:(SYScreenWidth/375.0))
#define SY6PFitSize(X)        ((X) * SY6PSizeMultiple)  // 以6为参考，5和6保持一样的值，6P等比缩放

#define SYRatioMultiple       (SYScreenWidth/375.0)
#define SYRatioFitSize(X)     ((X) * SYRatioMultiple)  // 以6为参考，5和6P等比缩放

#define SY5SizeMultiple       (SYScreenWidth >= 375?1.0:(SYScreenWidth/375.0))
#define SY5FitSize(X)         ((X) * SY5SizeMultiple)   // 以6为参考，6和6P保持一样的值，5等比缩放



#pragma mark - UIAdapter
/*****************************************************************************************/

#define SYIsIPhoneX \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})



#define SYTopOffset          (SYIsIPhoneX ? 24 : 0)
#define SYBottomOffset       (SYIsIPhoneX ? 34 : 0)
#define SYNavBarHeight       (SYIsIPhoneX ? 88 : 64)
#define SYStatusBarHeight    (SYIsIPhoneX ? 44 : 20)
#define SYTabBarHeight       (SYIsIPhoneX ? 83 : 49)



#pragma mark - Conditional Judgment
/*****************************************************************************************/
#define SYIsKindOfString(X)           ([X isKindOfClass:[NSString class]])
#define SYIsAvailableString(X)        ([X isKindOfClass:[NSString class]] && ![@"" isEqualToString:X])
#define SYIsUnAvailableString(X)      (![X isKindOfClass:[NSString class]] || [@"" isEqualToString:X])
#define SYUnNilString(X)              ([X isKindOfClass:[NSString class]]?X:@"")
#define SYSetAvailableValueForString(string, value)   if (SYIsUnAvailableString(string)) { \
string = value; \
}

#define SYIsKindOfArray(X)            ([X isKindOfClass:[NSArray class]])
#define SYIsAvailableArray(X)         ([X isKindOfClass:[NSArray class]] && X.count)
#define SYIsUnAvailableArray(X)       (![X isKindOfClass:[NSArray class]] || X.count == 0)

#define SYIsKindOfDictionary(X)       ([X isKindOfClass:[NSDictionary class]])
#define SYIsAvailableDictionary(X)    ([X isKindOfClass:[NSDictionary class]] && X.count)
#define SYIsUnAvailableDictionary(X)  (![X isKindOfClass:[NSDictionary class]] || X.count == 0)




#pragma mark - Others
/*****************************************************************************************/
#define SYImageNamed(name)           [UIImage imageNamed:name]
#define SYColorHex(HEX)              [UIColor colorWithHexString:HEX]



#define SYColorWithRGB(R, G, B)      [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:1.0f]
#define SYColorWithRGBA(R, G, B, A)  [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:A]





#ifdef DEBUG
#define SYLog(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define SYLog(xx, ...)  ((void)0)
#endif


