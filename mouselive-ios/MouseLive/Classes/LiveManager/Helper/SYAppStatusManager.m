//
//  SYAppStatusManager.m
//  MouseLive
//
//  Created by 张骥 on 2020/4/22.
//  Copyright © 2020 sy. All rights reserved.
//

#import "SYAppStatusManager.h"
#import <AVFoundation/AVFoundation.h>

@interface SYAppStatusManager()

@property(nonatomic, strong) NSMutableDictionary *delegates;
@property(nonatomic, assign) BOOL isActivity;

@end

@implementation SYAppStatusManager

+ (instancetype)shareManager
{
    static dispatch_once_t token;
    static SYAppStatusManager* manager;
    dispatch_once(&token, ^{
        if (!manager) {
            manager = [[SYAppStatusManager alloc] init];
        }
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isActivity = true;
    }
    return self;
}

- (NSMutableDictionary *)delegates
{
    if (!_delegates) {
        _delegates = [[NSMutableDictionary alloc] init];
    }
    
    return _delegates;
}

- (void)addDelegate:(id<SYAppStatusManagerDelegate>)delegate forKey:(NSString *)key
{
    [[self delegates] setObject:delegate forKey:key];
}

- (void)removeDelegateForKey:(NSString *)key
{
    [[self delegates] removeObjectForKey:key];
}

- (void)stratMonitor
{
    [self addObseerver];
}

- (void)stopMonitor
{
    [self removeObserver];
}

- (void)destory;
{
    [[self delegates] removeAllObjects];
    [self removeObserver];
}

- (void)addObseerver
{
    // enter backgroud & lock screen
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResginActive) name:UIApplicationWillResignActiveNotification object:nil];
    // return foreground & unlock screen
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActice) name:UIApplicationDidBecomeActiveNotification object:nil];
    // will terminate
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willTerminate) name:UIApplicationWillTerminateNotification object:nil];
    // to monitor terminate when app in background
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
    }];
    // to monitor the audiosession interruption by phone call
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionWasInterrupted:) name:AVAudioSessionInterruptionNotification object:nil];
}

- (void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willResginActive
{
    if (!_isActivity) {
        return;
    }
    _isActivity = false;
    for (id<SYAppStatusManagerDelegate> delegate in [[self delegates] allValues]) {
        if ([delegate respondsToSelector:@selector(SYAppWillResignActive:)]) {
            [delegate SYAppWillResignActive:self];
        }
    }
}

- (void)didBecomeActice
{
    if (_isActivity) {
        return;
    }
    _isActivity = true;
    for (id<SYAppStatusManagerDelegate> delegate in [[self delegates] allValues]) {
        if ([delegate respondsToSelector:@selector(SYAppDidBecomeActive:)]) {
            [delegate SYAppDidBecomeActive:self];
        }
    }
}

- (void)willTerminate
{
    for (id<SYAppStatusManagerDelegate> delegate in [[self delegates] allValues]) {
        if ([delegate respondsToSelector:@selector(SYAppWillTerminate:)]) {
            [delegate SYAppWillTerminate:self];
        }
    }
}

- (void)audioSessionWasInterrupted:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *interptionTypeValue = [userInfo valueForKey:AVAudioSessionInterruptionTypeKey];
    NSInteger interuptionType = [interptionTypeValue integerValue];
    
    for (id<SYAppStatusManagerDelegate> delegate in [[self delegates] allValues]) {
        if (interuptionType == AVAudioSessionInterruptionTypeBegan) {
            if ([delegate respondsToSelector:@selector(SYAppInterruptionBegan:)]) {
                [delegate SYAppInterruptionBegan:self];
            }
        } else if (interuptionType == AVAudioSessionInterruptionTypeEnded) {
            if ([delegate respondsToSelector:@selector(SYAppInterruptionEnded:)]) {
                [delegate SYAppInterruptionEnded:self];
            }
        }
    }
}
@end
