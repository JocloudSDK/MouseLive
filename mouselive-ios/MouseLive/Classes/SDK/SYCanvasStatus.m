//
//  SYCanvasStatus.m
//  SCloudMeet
//
//  Created by iPhuan on 2019/8/9.
//  Copyright © 2019 SY. All rights reserved.
//


#import "SYCanvasStatus.h"

@interface SYCanvasStatus ()

@end

@implementation SYCanvasStatus


- (void)updateStatusOnRemoteStreamStopped:(BOOL)stopped remoteStreamType:(SYRemoteStreamType)streamType
{
    if (stopped) {
        // 保留计算减1
        _livingRetainCount--;
    } else {
        // 保留计算加1
        _livingRetainCount++;
    }
    
    if (streamType == SYRemoteStreamTypeAudio) {
        self.isRemoteCanvasAudioStreamStoped = stopped;
    }
}

@end
