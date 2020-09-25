//
//  SYPlayer.h
//  TestAliPlayer
//
//  Created by Zhang Ji on 2020/4/17.
//  Copyright © 2020 Zhang Ji. All rights reserved.
//

@class SYPlayer;

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AliyunPlayer/AliyunPlayer.h"
#import "SYPlayerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SYPlayerDelegate <NSObject>
@optional

- (void)onError:(SYPlayer *)player errorModel:(AVPErrorModel *)errorModel;

- (void)onPlayEvent:(SYPlayer *)player eventType:(AVPEventType)eventType;

- (void)onPlayerStatusChanged:(SYPlayer *)player oldStatus:(AVPStatus)oldStatus newStatus:(AVPStatus)newStatus;

- (void)onVideoSizeChanged:(SYPlayer *)player size:(CGSize)size;

@end

@interface SYPlayer : NSObject <SYPlayerProtocol>

@property(nonatomic, weak) id<SYPlayerDelegate> delegate;

@property(nonatomic, readonly) UIView *playView;

// Video Size
@property(nonatomic, readonly) CGSize size;

- (instancetype) initPlayerWirhUrl:(NSString *)url
                           view:(UIView *)view
                        delegate:(nullable id<SYPlayerDelegate>)delegate;

- (void)start;

- (void)pause;

- (void)stop;

- (void)destory;

- (void)upadteUrl: (NSString *)url;

// set render mode for video
- (void)setRenderMode: (AVPScalingMode)mode;
 
// mute audio
- (void)muteAudioStream:(BOOL)isMute;

@end

NS_ASSUME_NONNULL_END
