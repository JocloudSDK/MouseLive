//
//  UIColor+SYAdditions.h
//  SYLiteDevToolKit
//
//  Created by iPhuan on 2019/8/6.
//  Copyright © 2019 SY. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>




#pragma mark - UIColor

#ifndef SYColorHex
#define SYColorHex(HEX)   [UIColor colorWithHexString:HEX]
#endif

@interface UIColor (SYAdditions)


//RGB,RGBA,RRGGBB,RRGGBBAA
+ (instancetype)colorWithHexString:(NSString *)hexString;

@end



