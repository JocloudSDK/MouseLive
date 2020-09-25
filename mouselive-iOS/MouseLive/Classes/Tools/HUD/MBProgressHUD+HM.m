//
//  MBProgressHUD+MJ.m
//
//  Created by mj on 13-4-18.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MBProgressHUD+HM.h"

@implementation MBProgressHUD (HM)
#pragma mark 显示信息
+ (void)yy_show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    [self yy_show:text icon:icon view:view withAfterDelay:1.2f];
}

+ (void)yy_show:(NSString *)text icon:(NSString *)icon view:(UIView *)view withAfterDelay:(CGFloat)afterDelay
{
    if (view == nil) {
        view = [[UIApplication sharedApplication].windows lastObject];
    }
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    hud.detailsLabel.text = text;
    hud.detailsLabel.font = hud.label.font;
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    hud.userInteractionEnabled = NO;
    // 1秒之后再消失
    [hud hideAnimated:YES afterDelay:afterDelay];
}

#pragma mark 显示信息
+ (void)yy_showError:(NSString *)error toView:(UIView *)view withAfterDelay:(CGFloat)afterDelay
{
    [self yy_show:error icon:@"error.png" view:view withAfterDelay:afterDelay];
}
+ (void)yy_showError:(NSString *)error toView:(UIView *)view
{
    [self yy_showError:error toView:view withAfterDelay:3.0f];
}

+ (void)yy_showSuccess:(NSString *)success toView:(UIView *)view
{
    [self yy_show:success icon:@"success.png" view:view];
}

+ (void)yy_showToast:(NSString *)text toView:(UIView *)view
{
    [self yy_show:text icon:nil view:nil withAfterDelay:3.f];
}
#pragma mark 显示一些信息
+ (MBProgressHUD *)yy_showMessage:(NSString *)message toView:(UIView *)view
{
    if (view == nil) {
        view = [[UIApplication sharedApplication].windows lastObject];
    }
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
//    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    //    // YES代表需要蒙版效果
    return hud;
}

+ (void)yy_showSuccess:(NSString *)success
{
    [self yy_showSuccess:success toView:nil];
}

+ (void)yy_showError:(NSString *)error
{
    [self yy_showError:error toView:nil];
}

+ (MBProgressHUD *)yy_showMessage:(NSString *)message
{
    return [self yy_showMessage:message toView:nil];
}

+ (void)yy_hideHUDForView:(UIView *)view
{
    [self hideHUDForView:view animated:YES];
}

+ (void)yy_hideHUD
{
    [self yy_hideHUDForView:nil];
}
@end
