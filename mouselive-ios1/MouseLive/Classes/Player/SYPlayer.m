//
//  SYPlayer.m
//  TestAliPlayer
//
//  Created by Zhang Ji on 2020/4/17.
//  Copyright © 2020 Zhang Ji. All rights reserved.
//

#import "SYPlayer.h"
#import "AliyunPlayer/AliyunPlayer.h"

@interface SYPlayer()<AVPDelegate>

@property(nonatomic, strong) UIView* playView;
@property(nonatomic, strong) AliPlayer *player;
@property(nonatomic, strong) NSString *url;

@end

@implementation SYPlayer

- (instancetype) initPlayerWirhUrl:(NSString *)url view:(UIView *)view delegate:(nullable id<SYPlayerDelegate>)delegate
{
    if (self = [super init]) {
        self.player = [[AliPlayer alloc] init];
        self.playView = view;
        self.url = url;
        self.player.delegate = self;
        
        if (delegate) {
            self.delegate = delegate;
        }
        
        [self setupPlayer];
    }
    
    return self;
}

- (void)setupPlayer
{
    self.player.playerView = self.playView;
    AVPUrlSource *source = [[AVPUrlSource alloc] urlWithString:self.url];
    
    self.player.scalingMode = AVP_SCALINGMODE_SCALEASPECTFILL;
    
    [self.player setUrlSource:source];
    
}


- (CGSize)size
{
    return CGSizeMake(self.player.width, self.player.height);
}

- (void)setRenderMode: (AVPScalingMode)mode
{
    self.player.scalingMode = mode;
}

- (void)start
{
    [self.player prepare];
    [self.player start];
}

- (void)pause
{
    [self.player pause];
}

- (void)stop
{
    [self.player stop];
}

- (void)upadteUrl: (NSString *)url
{
    [self.player stop];
    
    AVPUrlSource *source = [[AVPUrlSource alloc] urlWithString:url];
    self.url = url;
    
    [self.player setUrlSource:source];
    [self.player prepare];
    
    [self.player start];
}


- (void)muteAudioStream:(BOOL)isMute
{
    self.player.muted = isMute;
}

- (void)destory
{
    [self.player destroy];
    self.player = nil;
}

- (void)onPlayerEvent:(AliPlayer *)player eventType:(AVPEventType)eventType
{
    if ([self.delegate respondsToSelector:@selector(onPlayEvent:eventType:)]) {
        [self.delegate onPlayEvent:self eventType:eventType];
    }
}

- (void)onError:(AliPlayer *)player errorModel:(AVPErrorModel *)errorModel
{
    if ([self.delegate respondsToSelector:@selector(onError:errorModel:)]) {
        [self.delegate onError:self errorModel:errorModel];
    }
}

- (void)onPlayerStatusChanged:(SYPlayer *)player oldStatus:(AVPStatus)oldStatus newStatus:(AVPStatus)newStatus
{
    if ([self.delegate respondsToSelector:@selector(onPlayerStatusChanged:oldStatus:newStatus:)]) {
        [self.delegate onPlayerStatusChanged:self oldStatus:oldStatus newStatus:newStatus];
    }
}

- (void)onVideoSizeChanged:(AliPlayer *)player width:(int)width height:(int)height rotation:(int)rotation
{
    if ([self.delegate respondsToSelector:@selector(onVideoSizeChanged:size:)]) {
        [self.delegate onVideoSizeChanged:self size:CGSizeMake(width, height)];
    }
}

@end
