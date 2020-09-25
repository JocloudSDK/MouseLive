//
//  DeviceInfo.m
//  MouseLive
//
//  Created by 张建平 on 2020/2/28.
//  Copyright © 2020 sy. All rights reserved.
//

#import "GobalViewBound.h"
#import <UIKit/UIKit.h>

@interface GobalViewBound()

@property (nonatomic, assign, readwrite) int navBarHeight;
@property (nonatomic, assign, readwrite) int statusBarHeight;
@property (nonatomic, assign, readwrite) int tarBarHeight;
@property (nonatomic, assign, readwrite) int navContentBarHeight;
@property (nonatomic, assign, readwrite) int screenWidth;
@property (nonatomic, assign, readwrite) int screenHeight;
@property (nonatomic, assign, readwrite) int dataViewTitleHeight;
@property (nonatomic, assign, readwrite) int bannerCellHeight;

@end

@implementation GobalViewBound

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.navBarHeight = k_Height_NavBar;
        self.statusBarHeight = k_Height_StatusBar;
        self.tarBarHeight = k_Height_TabBar;
        self.navContentBarHeight = k_Height_NavContentBar;
        self.screenWidth = [UIScreen mainScreen].bounds.size.width;
        self.screenHeight = [UIScreen mainScreen].bounds.size.height;
        
#define TitleHeight(x) MIN(MAX(x, 40), 50)
        
        self.dataViewTitleHeight = TitleHeight(51);
        self.bannerCellHeight = 160;
    }
    return self;
}


@end
