//
//  DBHTabBar.h
//  MouseLive
//
//  Created by 张建平 on 2020/3/3.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DBHTabBar;

@protocol DBHTabBarDelegate <UITabBarDelegate>

@optional

- (void)tabBarDidClickPlusButton:(DBHTabBar *)tabBar;

@end

@interface DBHTabBar : UITabBar

@property (nonatomic, weak) id<DBHTabBarDelegate> myDelegate;

@end

NS_ASSUME_NONNULL_END
