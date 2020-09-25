//
//  SYAppStatusManager.h
//  MouseLive
//
//  Created by 张骥 on 2020/4/22.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYAppStatusManager;

@protocol SYAppStatusManagerDelegate <NSObject>
@optional

// return foreground & unlock screen
- (void)SYAppDidBecomeActive:(nonnull SYAppStatusManager *)manager;

// enter backgroud & lock screen
- (void)SYAppWillResignActive:(nonnull SYAppStatusManager *)manager;

// App will terminate
- (void)SYAppWillTerminate:(nonnull SYAppStatusManager *)manager;

// phone call began
- (void)SYAppInterruptionBegan:(nonnull SYAppStatusManager *)manager;

// phone call ended
- (void)SYAppInterruptionEnded:(nonnull SYAppStatusManager *)manager;

@end

NS_ASSUME_NONNULL_BEGIN

@interface SYAppStatusManager : NSObject

+ (instancetype)shareManager;

- (void)addDelegate:(id<SYAppStatusManagerDelegate>)delegate forKey:(NSString *)key;

- (void)removeDelegateForKey:(NSString *)key;

- (void)stratMonitor;

- (void)stopMonitor;

- (void)destory;

@end

NS_ASSUME_NONNULL_END
