//
//  AppDelegate.h
//  MouseLive
//
//  Created by 张建平 on 2020/2/26.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow * window;
@property (strong, readonly) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

