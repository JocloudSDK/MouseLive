//
//  SYCanvasStatus.h
//  SCloudMeet
//
//  Created by iPhuan on 2019/8/9.
//  Copyright © 2019 SY. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SYRemoteStreamType) {
    SYRemoteStreamTypeAudio = 0,        // 音频流
    SYRemoteStreamTypeVideo,            // 视频流
};

@interface SYCanvasStatus : NSObject

@property (nonatomic, copy) NSString *uid;                  // 用户uid
@property (nonatomic, copy) NSString *roomid;
@property (nonatomic, assign) NSUInteger livingRetainCount; // 用于记录连麦用户是否音频和视频都已断开，本地视频不受该参数控制
@property (nonatomic, assign) BOOL isVideoStreamStoped;     // 是否已关闭视频流发送
@property (nonatomic, assign) BOOL isAudioStreamStoped;     // 是否已关闭音频流发送
@property (nonatomic, assign) BOOL isFullScreen;            // 是否为全屏模式
@property (nonatomic, assign) BOOL isShowActionSheet;       // 是否弹出ActionSheet

@property (nonatomic, assign) BOOL isRemoteCanvasAudioStreamStoped;            // 是否远程音频流已关闭，只针对远程用户自己关闭音频流

- (void)updateStatusOnRemoteStreamStopped:(BOOL)stopped remoteStreamType:(SYRemoteStreamType)streamType;


@end
