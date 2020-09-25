//
//  SYVideoCanvas.h
//  SCloudMeet
//
//  Created by iPhuan on 2019/8/8.
//  Copyright © 2019 SY. All rights reserved.
//


#import "ThunderEngine.h"
#import "SYCanvasStatus.h"

@interface SYVideoCanvas : ThunderVideoCanvas
@property (nonatomic, assign) BOOL isLocalCanvas;     // 是否本地Canvas
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) SYCanvasStatus *status; // 用于记录音视频流的状态


@end
