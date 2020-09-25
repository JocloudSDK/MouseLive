//
//  BaseViewController.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/10.
//  Copyright © 2020 sy. All rights reserved.
//

#import "BaseViewController.h"
#import "MainViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //关闭左滑返回
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

@end
