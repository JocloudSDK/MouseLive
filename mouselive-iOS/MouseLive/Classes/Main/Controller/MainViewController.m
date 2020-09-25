//
//  MainViewController.m
//  MouseLive
//
//  Created by 张建平 on 2020/2/26.
//  Copyright © 2020 sy. All rights reserved.
//

#import "MainViewController.h"
#import <objc/message.h>
#import "CustomNavigationController.h"
#import "StartViewController.h"
#import <MBProgressHUD+SYHUD.h>
#import "DBHTabBar.h"

#define COLORFROM16(RGB, A) [UIColor colorWithRed:((float)((RGB & 0xFF0000) >> 16)) / 255.0 green:((float)((RGB & 0xFF00) >> 8)) / 255.0 blue:((float)(RGB & 0xFF)) / 255.0 alpha:A]


@interface MainViewController ()<DBHTabBarDelegate>

@property (nonatomic, strong) NSArray *vcTitleArray;
@property (nonatomic, strong) NSArray *vcItemArray;
@property (nonatomic, strong) NSArray *vcSelItemArray;
@property (nonatomic, strong) NSArray *vcClassArray;

@end

static MainViewController * _instance;

@implementation MainViewController

+ (instancetype)instance
{
    static dispatch_once_t onceToken;
       dispatch_once(&onceToken, ^{
           _instance = [[MainViewController alloc]init];
           
       });
       return _instance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addAllChildViewController];
    self.tabBar.translucent = NO;


    DBHTabBar *tabBar = [[DBHTabBar alloc] init];
    //取消tabBar的透明效果
    tabBar.translucent = NO;
    // 设置tabBar的代理
    tabBar.myDelegate = self;
    // KVC：如果要修系统的某些属性，但被设为readOnly，就是用KVC，即setValue：forKey：。
    [self setValue:tabBar forKey:@"tabBar"];
    
    [self sendUserInfoService];
}

- (void)sendUserInfoService
{
    // TODO: login
}



- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //设置TabBar的TintColor
    self.tabBar.tintColor = [UIColor colorWithRed:89/255.0 green:217/255.0 blue:247/255.0 alpha:1.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
/**
 *  点击了加号按钮
 */
- (void)tabBarDidClickPlusButton:(DBHTabBar *)tabBar
{
    // 跳转到 start 页面
    StartViewController *vc = [[StartViewController alloc] init];
    CustomNavigationController *nav = [[CustomNavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;

    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Private Methods
// 初始化所有的子控制器
- (void)addAllChildViewController
{
    for (NSInteger i = 0; i < self.vcClassArray.count; i++) {
        NSString *name = self.vcClassArray[i];
        const char *className = [name UTF8String];
        Class class = objc_getClass(className);
        if (!class) {
            Class superClass = [NSObject class];
            class = objc_allocateClassPair(superClass, className, 0);
        }
        UIViewController *vc = nil;
        if (class) {
            id instance = [[class alloc] init];
            vc = (UIViewController *)(instance);
             [vc.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor sl_colorWithHexString:@"#2FD98C"]} forState:UIControlStateSelected];
            [vc.tabBarItem setSelectedImage:[[UIImage imageNamed:self.vcSelItemArray[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            [vc.tabBarItem setImage:[[UIImage imageNamed:self.vcItemArray[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        }
        
        CustomNavigationController *nav = [[CustomNavigationController alloc] initWithRootViewController:vc];
      
        nav.tabBarItem.title = self.vcTitleArray[i];
       
        nav.navigationBarHidden = YES;
        nav.navigationBar.translucent = NO;
        nav.navigationBar.shadowImage = [[UIImage alloc] init];
        [nav.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [nav.navigationBar setTintColor:[UIColor whiteColor]];
        [nav.navigationBar setBarTintColor:COLORFROM16(0x62ac93, 1)];
        [nav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
        
        [self addChildViewController:nav];
    }
}


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
 
}

#pragma mark - Getters And Setters
- (NSArray *)vcClassArray
{
    if (!_vcClassArray) {
        _vcClassArray = @[@"SYHomeViewController",@"FeedBackViewController"];
    }
    return _vcClassArray;
}

- (NSArray *)vcTitleArray
{
    if (!_vcTitleArray) {

        _vcTitleArray = @[ NSLocalizedString(@"Live", nil),  NSLocalizedString(@"Feedback", nil)];
    }
    return _vcTitleArray;
}

- (NSArray *)vcItemArray
{
    if (!_vcItemArray) {
        _vcItemArray = @[@"toolbar_live", @"toolbar_feedback"];
    }
    return _vcItemArray;
}

- (NSArray *)vcSelItemArray
{
    if (!_vcSelItemArray) {
        _vcSelItemArray = @[@"toolbar_live_sel", @"toolbar_feedback_sel"];
    }
    return _vcSelItemArray;
}

@end
