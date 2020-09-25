//
//  SYThunderManagerNew.h
//  SCloudMeet
//
//  Created by iPhuan on 2019/8/7.
//  Copyright © 2019 SY. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "ThunderEngine.h"
#import "SYVideoCanvas.h"
#import "MixVideoConfig.h"
#import "WaterMarkAdapter.h"

@interface SYThunderManagerNew : NSObject
@property (nonatomic, strong, readonly) ThunderEngine *engine;            // SDK引擎
@property (nonatomic, strong, readonly) SYVideoCanvas *localVideoCanvas;  // 视频视图
@property (nonatomic, strong, readonly) NSString *logPath;                // 日志路径
@property (nonatomic, copy, readonly) NSString *appId;                    // AppId
@property (nonatomic, readonly) NSString *localUid;                           // 本地用户uid
@property (nonatomic, assign, readonly) ThunderPublishVideoMode publishMode;        // 视频编码类型
@property (nonatomic, assign) CGFloat currentPlayprogress; //当前播放进度

@property (nonatomic,strong,readwrite) WaterMarkAdapter* waterMarkAdapter;

+ (instancetype)sharedManager;

/// 初始化 SDK
/// @param delegate 观察者
- (void)setupEngineWithDelegate:(id<ThunderEventDelegate>)delegate;

/// 销毁SDK
- (void)destroyEngine;

/// 启动配置
/// @param haveVideo 是否是 video
- (void)setupIsVideo:(BOOL)haveVideo;

/// 退出房间
- (void)leaveRoom;

/// 开启直播
- (void)enableVideoLive;

// 创建本地或者远程视频视图

/// 创建本地或者远程视频视图
/// @param uid 用户 uid
/// @param isLocalCanvas 是否是本地
- (SYVideoCanvas *)createVideoCanvasWithUid:(NSString *)uid isLocalCanvas:(BOOL)isLocalCanvas;

/// 切换摄像头
/// @param isFront yes - 前置摄像头; no - 后置摄像头
- (NSInteger)switchFrontCamera:(BOOL)isFront;

/// 设置镜像
/// 镜像：正常打开前置摄像头，认为是镜像的，主播自己观看是镜像的； 观众观看是正常的;
/// @param isMirror yes - 镜像; no - 非镜像
- (void)switchMirror:(BOOL)isMirror;

/// 设置音效
/// @param voice 音效，查看 ThunderRtcVoiceChangerMode。 默认是关闭的
- (void)setVoiceChanger:(ThunderRtcVoiceChangerMode)voice;

/// 关闭接收远程视频流
/// @param uid 远程 uid
/// @param disabled yes - 关闭；no - 打开
- (void)disableRemoteVideo:(NSString *)uid disabled:(BOOL)disabled;

// 请求token -- 是否有用？
- (void)requestTokenWithRoomId:(NSString *)roomId Uid:(NSString *)uid completionHandler:(void (^)(BOOL success))completionHandler;

/// 更新token -- 是否有用？
- (void)updateToken;

/// 切换视频编码类型, 切换档位
/// @param publishMode ThunderPublishVideoMode
- (void)switchPublishMode:(ThunderPublishVideoMode)publishMode;

/// 清除canvasView
/// @param uid 清除的视图 uid
- (void)clearCanvasViewWithUID:(NSString *)uid;

/// 跨房间订阅
/// @param roomId 被订阅的用户 roomid
/// @param uid 被订阅的用户 uid
- (int)addSubscribe:(NSString * _Nonnull)roomId uid:(NSString * _Nonnull)uid;

/// 跨房间取消订阅
/// @param roomId 被取消订阅的用户 roomid
/// @param uid 被取消订阅的用户 uid
- (int)removeSubscribe:(NSString * _Nonnull)roomId uid:(NSString * _Nonnull)uid;

/// 打开音频文件
/// @param path 文件路径
- (void)openAuidoFileWithPath:(NSString * _Nonnull)path;

/// 关闭音频文件
- (void)closeAuidoFile;

/// 设置当前文件的播放音量
/// @param volume 播放音量 [0-100]
- (void)setAudioFilePlayVolume:(uint32_t)volume;

/// 暂停音频文件播放
- (void)pauseAudioFile;

/// 继续音频文件播放
- (void)resumeAudioFile;

/// 设置水印
/// @param url 水印图片的地址，必须是 PNG
/// @param rect 水印图片的大小和位置
- (void)setVideoWatermarkWithThunderImage:(ThunderImage * _Nonnull)thunderImage;


/// 耳返开关
/// @param enabled YES 打开；NO 关闭
- (void)setEnableInEarMonitor:(BOOL)enabled;

/// 设置混画任务，主要是在有 CDN 推流的时候使用
/// @param config 配置选项，查看 MixVideoConfig
- (void)setMixCanvasWith:(NSArray<MixVideoConfig *> * _Nonnull)config;

/// 获取推流视频的分辨率宽度
- (int)getVideoWidth;

/// 获取推流视频的分辨率高度
- (int)getVideoHeight;

/// 更新 token
/// @param token token
- (void)updateToken:(NSString * _Nonnull)token;

/// 设置本地视频预处理回调接口，不用在移除注册，在调用离开房间的时候，在调用 thunder 引擎的移除
/// @param delegate 本地视频帧预处理接口，可用于自定义的美颜等处理。
- (void)registerVideoCaptureFrameObserver:(nullable id<ThunderVideoCaptureFrameObserver>)delegate;

#pragma mark - New API

/// 关闭本地音频流推送
/// @param enabled yes - 打开推流；no - 关闭推流
- (void)enableLocalAudioStream:(BOOL)enabled;

- (void)disableLocalAudioCapture:(BOOL)disabled;

- (void)setupLocalUser:(NSString * _Nonnull)uid videoView:(UIView * _Nonnull)view;

- (void)setupRemoteUser:(NSString * _Nonnull)uid videoView:(UIView * _Nullable)view;

- (void)setMirrorPreview:(BOOL)preview publish:(BOOL)publish;

- (void)joinMediaRoom:(NSString * _Nonnull)roomId uid:(NSString * _Nonnull)uid roomType:(LiveType)roomType;

@end
