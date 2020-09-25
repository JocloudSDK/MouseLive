//
//  MBProgressHUD+MJ.h
//
//  Created by mj on 13-4-18.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (HM)
+ (void)yy_showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)yy_showError:(NSString *)error toView:(UIView *)view;
//只提示文字
+ (void)yy_showToast:(NSString *)text toView:(UIView *)view;

+ (MBProgressHUD *)yy_showMessage:(NSString *)message toView:(UIView *)view;


+ (void)yy_showSuccess:(NSString *)success;
+ (void)yy_showError:(NSString *)error;

+ (MBProgressHUD *)yy_showMessage:(NSString *)message;
+ (void)yy_showError:(NSString *)error toView:(UIView *)view withAfterDelay:(CGFloat)afterDelay;
+ (void)yy_hideHUDForView:(UIView *)view;
+ (void)yy_hideHUD;

@end
