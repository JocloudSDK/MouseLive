//
//  CustomNavigationController.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/10.
//  Copyright © 2020 sy. All rights reserved.
//

#import "CustomNavigationController.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
}
// 重写自定义的UINavigationController中的push方法
// 处理tabbar的显示隐藏
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
     if (self.childViewControllers.count==1) {
         viewController.hidesBottomBarWhenPushed = YES; //viewController是将要被push的控制器
     }
     [super pushViewController:viewController animated:animated];
}

@end
