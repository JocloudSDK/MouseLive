//
//  SYThunderManagerNew.m
//  SCloudMeet
//
//  Created by iPhuan on 2019/8/7.
//  Copyright © 2019 SY. All rights reserved.
//


#import "SYThunderManagerNew.h"
#import "SYUtils.h"
#import "SYCommonMacros.h"
#import "SYAppInfo.h"
#import "SYToken.h"
#import "WaterMarkAdapter.h"

@interface SYThunderManagerNew () <ThunderRtcLogDelegate, ThunderAudioFilePlayerDelegate,ThunderEventDelegate>
@property (nonatomic, strong, readwrite) ThunderEngine *engine;
@property (nonatomic, strong, readwrite) SYVideoCanvas *localVideoCanvas;
@property (nonatomic, strong, readwrite) NSString *logPath;
@property (nonatomic, assign, readwrite) ThunderPublishVideoMode publishMode;
@property (nonatomic, copy, readwrite) NSString *localUid;   // 本地用户uid
@property (nonatomic, copy) NSString *roomId; // 进入的房间
@property (nonatomic, weak) ThunderAudioFilePlayer *audioPlayer;
@property (nonatomic, assign) BOOL isInit;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isAudioMuted;
@property (nonatomic, assign) ThunderSourceType sourceType;
@property (nonatomic, copy) NSString *mixTask; // 混画的 task 标示
@property (nonatomic, copy) NSString *pushUrl; // 推流 CDN url
@property (nonatomic, strong) LiveTranscoding *liveTranscoding; // 混画配置
@property (nonatomic, weak) id<ThunderVideoCaptureFrameObserver>videoCaptureFrameObserverDelegate;



@end

@implementation SYThunderManagerNew

+ (instancetype)sharedManager
{
    static SYThunderManagerNew *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        _publishMode = THUNDERPUBLISH_VIDEO_MODE_HIGHQULITY; // 默认高清挡
        self.isInit = NO;
    }
    return self;
}


#pragma mark - Public

- (void)setupEngineWithDelegate:(id<ThunderEventDelegate>)delegate
{
    if (!self.isInit) {
        self.isInit = YES;
        YYLogDebug(@"[MouseLive-Thunder] setupEngineWithDelegate, entry");
        self.engine = [ThunderEngine createEngine:[SYAppInfo sharedInstance].appId sceneId:0 delegate:delegate];
        
        // 设置区域：默认值（国内）
        [_engine setArea:THUNDER_AREA_DEFAULT];
        
        // 设置区域：国外
        //    [_engine setArea:THUNDER_AREA_FOREIGN];
        // 打开用户音量回调，500毫秒回调一次
        [_engine setAudioVolumeIndication:500 moreThanThd:0 lessThanThd:0 smooth:0];
        
        // 打开麦克风音量回调
        [_engine enableCaptureVolumeIndication:500 moreThanThd:0 lessThanThd:0 smooth:0];
        
        // 处理App退出时未退出房间的异常
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [self.engine leaveRoom];
            
            [self.engine destroyAudioFilePlayer:self.audioPlayer];
            
            // 销毁引擎
            [ThunderEngine destroyEngine];
        }];
        
        self.pushUrl = nil;
        self.mixTask = nil;
        
        // 设置SDK日志存储路径
        NSArray *logPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
        NSString *docPath = [logPath lastObject];
        self.logPath = [docPath stringByAppendingString:kLogFilePath];
        [_engine setLogFilePath: _logPath];
        YYLogDebug(@"[MouseLive-Thunder] setupEngineWithDelegate, exit");
    }
}

- (void)destroyEngine
{
    // 销毁引擎
    [ThunderEngine destroyEngine];
}

- (void)setupIsVideo:(BOOL)haveVideo
{
    YYLogDebug(@"[MouseLive-Thunder] setupIsVideo, entry, haveVideo:%d", haveVideo);
    if (haveVideo) {
        YYLogDebug(@"[MouseLive-Thunder] setupIsVideo set Video");
        
        // 设置音频属性。
        int ret = [_engine setAudioConfig:THUNDER_AUDIO_CONFIG_MUSIC_STANDARD // 采样率，码率，编码模式和声道数：44.1 KHz采样率，音乐编码, 双声道，编码码率约 40；
                               commutMode:THUNDER_COMMUT_MODE_DEFAULT            // 交互模式
                             scenarioMode:THUNDER_SCENARIO_MODE_DEFAULT];     // 场景模式：默认
        
        YYLogDebug(@"[MouseLive-Thunder] setupIsVideo setAudioConfig THUNDER_AUDIO_CONFIG_MUSIC_STANDARD, THUNDER_COMMUT_MODE_DEFAULT, THUNDER_SCENARIO_MODE_DEFAULT, ret = %d", ret);
        
        _publishMode = THUNDERPUBLISH_VIDEO_MODE_HIGHQULITY;
        
        [self setupPublishMode];
        [self switchFrontCamera:YES];
        YYLogDebug(@"[MouseLive-Thunder] setupIsVideo Front camera");
        
        [self switchMirror:NO];
        
        if (self.videoCaptureFrameObserverDelegate) {
            ret = [_engine registerVideoCaptureFrameObserver:self.videoCaptureFrameObserverDelegate];
            YYLogDebug(@"[MouseLive-Thunder] setupIsVideo registerVideoCaptureFrameObserver");
        }
        
        YYLogDebug(@"[MouseLive-Thunder] setupIsVideo set Video, end");
    }
    else {
        YYLogDebug(@"[MouseLive-Thunder] setupIsVideo set audio");
        
        // 设置音频属性。
        int ret = [_engine setAudioConfig:THUNDER_AUDIO_CONFIG_MUSIC_STANDARD // 采样率，码率，编码模式和声道数：44.1 KHz采样率，音乐编码, 双声道，编码码率约 40；
                               commutMode:THUNDER_COMMUT_MODE_HIGH            // 交互模式：强交互模式
                             scenarioMode:THUNDER_SCENARIO_MODE_DEFAULT];     // 场景模式：默认
        YYLogDebug(@"[MouseLive-Thunder] setupIsVideo setAudioConfig THUNDER_AUDIO_CONFIG_MUSIC_STANDARD, THUNDER_COMMUT_MODE_HIGH, THUNDER_SCENARIO_MODE_DEFAULT, ret = %d", ret);
        YYLogDebug(@"[MouseLive-Thunder] setupIsVideo set audio, end");
        
    }
    
    // 默认关闭耳返
    [self setEnableInEarMonitor:NO];
    YYLogDebug(@"[MouseLive-Thunder] setupIsVideo setEnableInEarMonitor no");
    
    [self setVoiceChanger:THUNDER_VOICE_CHANGER_NONE];
    YYLogDebug(@"[MouseLive-Thunder] setupIsVideo setVoiceChanger THUNDER_VOICE_CHANGER_NONE");
    
    // 如果有推流，并且有混画任务
    YYLogDebug(@"[MouseLive-Thunder] setupIsVideo pushUrl:%@, mixTask:%@", self.pushUrl, self.mixTask);
    if (self.pushUrl && self.mixTask) {
    //        int ret = [_engine addPublishOriginStreamUrl:self.pushUrl];
        [_engine setLiveTranscodingTask:self.mixTask transcoding:self.liveTranscoding];
        int ret = [_engine addPublishTranscodingStreamUrl:self.mixTask url:self.pushUrl];
        YYLogDebug(@"[MouseLive-Thunder] setupIsVideo addPublishTranscodingStreamUrl ret:%d", ret);
    }
    
    YYLogDebug(@"[MouseLive-Thunder] setupIsVideo, exit");
}

- (void)joinMediaRoom:(NSString * _Nonnull)roomId uid:(NSString * _Nonnull)uid roomType:(LiveType)roomType
{
    self.isPlaying = NO;
    self.isAudioMuted = NO;
    self.localUid = uid;
    self.roomId = roomId;
    
    switch (roomType) {
        case LiveTypeVideo:
            [_engine setMediaMode:THUNDER_CONFIG_NORMAL];
            [_engine setRoomMode:THUNDER_ROOM_CONFIG_COMMUNICATION];
            [_engine setLocalVideoMirrorMode:THUNDER_VIDEO_MIRROR_MODE_PREVIEW_PUBLISH_BOTH_MIRROR];
            break;
        case LiveTypeAudio:
            [_engine setMediaMode:THUNDER_CONFIG_ONLY_AUDIO];
            [_engine setRoomMode:THUNDER_ROOM_CONFIG_MULTIAUDIOROOM];
            break;
        default:
            break;
    }
    
    [_engine joinRoom:[SYToken sharedInstance].thToken roomName:roomId uid:uid];
}

- (void)setupPublishMode
{
    YYLogDebug(@"[MouseLive-Thunder] setupPublishMode entry");
    ThunderVideoEncoderConfiguration *videoEncoderConfiguration = [[ThunderVideoEncoderConfiguration alloc] init];
    // 设置开播玩法为视频连麦开播
    videoEncoderConfiguration.playType = THUNDERPUBLISH_PLAY_INTERACT;
    // 设置视频编码类型
    videoEncoderConfiguration.publishMode = _publishMode;
    
    // 每次进房间都需要再次设置，否则会使用默认配置
    [_engine setVideoEncoderConfig:videoEncoderConfiguration];
    
    YYLogDebug(@"[MouseLive-Thunder] setVideoEncoderConfig playType THUNDERPUBLISH_PLAY_INTERACT");
    YYLogDebug(@"[MouseLive-Thunder] setVideoEncoderConfig publishMode:%d", _publishMode);
    YYLogDebug(@"[MouseLive-Thunder] setupPublishMode exit");
}


- (void)leaveRoom
{
    YYLogDebug(@"[MouseLive-Thunder] leaveRoom entry");
    
    // 关闭耳返
    [self setEnableInEarMonitor:NO];
    
    // 移除推流任务
    if (self.pushUrl && self.mixTask) {
        YYLogDebug(@"[MouseLive-Thunder] leaveRoom remove push url");
        [_engine removePublishOriginStreamUrl:self.pushUrl];
//        [_engine removePublishTranscodingStreamUrl:self.mixTask url:self.pushUrl];
        [_engine removeLiveTranscodingTask:self.mixTask];
        self.mixTask = nil;
        self.pushUrl = nil;
    }
    [_engine setAudioSourceType:THUNDER_AUDIO_MIX];
    [_engine stopLocalAudioStream:YES];
    [_engine stopLocalVideoStream:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.engine stopVideoPreview];
    });
    
    // 如果注册摄像机数据返回，在离开房间前，需要移除注册
    if (self.videoCaptureFrameObserverDelegate) {
        YYLogDebug(@"[MouseLive-Thunder] leaveRoom registerVideoCaptureFrameObserver nil");
        [_engine registerVideoCaptureFrameObserver:nil];
        self.videoCaptureFrameObserverDelegate = nil;
    }
    
    [_engine leaveRoom];
    YYLogDebug(@"[MouseLive-Thunder] leaveRoom exit");
}

- (void)enableVideoLive
{
    YYLogDebug(@"[MouseLive-Thunder] enableVideoLive entry");
    // 开启视频预览
    int ret = [_engine startVideoPreview];
    YYLogDebug(@"[MouseLive-Thunder] enableVideoLive startVideoPreview ret = %d", ret);
    
    // 启用视频模块, 开启本地视频流发送
    ret = [_engine stopLocalVideoStream:NO];
    YYLogDebug(@"[MouseLive-Thunder] enableVideoLive stopLocalVideoStream NO ret = %d", ret);
    
    // 打开音频采集，并开播到频道
    ret = [_engine stopLocalAudioStream:NO];
    YYLogDebug(@"[MouseLive-Thunder] enableVideoLive stopLocalAudioStream NO ret = %d", ret);
    
    YYLogDebug(@"[MouseLive-Thunder] enableVideoLive exit");
}

- (SYVideoCanvas *)createVideoCanvasWithUid:(NSString *)uid isLocalCanvas:(BOOL)isLocalCanvas
{
    YYLogDebug(@"[MouseLive-Thunder] createVideoCanvasWithUid entry, uid:%@", uid);
    // 创建视频视图
    SYVideoCanvas *canvas = [[SYVideoCanvas alloc] init];
    canvas.isLocalCanvas = isLocalCanvas;
    
    // 必须创建canvas时设置其view
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor blackColor];
    canvas.view = view;
    
    // 设置视频布局
    [canvas setRenderMode:THUNDER_RENDER_MODE_CLIP_TO_BOUNDS];
    YYLogDebug(@"[MouseLive-Thunder] createVideoCanvasWithUid canvas setRenderMode  THUNDER_RENDER_MODE_CLIP_TO_BOUNDS");
    
    // 设置用户uid
    [canvas setUid:uid];
    
    if (isLocalCanvas) {
        
        YYLogDebug(@"[MouseLive-Thunder] createVideoCanvasWithUid LocalCanvas");
        
        // 设置本地视图
        [_engine setLocalVideoCanvas:canvas];
        // 设置本地视图显示模式
        [_engine setLocalCanvasScaleMode:THUNDER_RENDER_MODE_CLIP_TO_BOUNDS];
        
        YYLogDebug(@"[MouseLive-Thunder] createVideoCanvasWithUid setLocalVideoCanvas");
        YYLogDebug(@"[MouseLive-Thunder] createVideoCanvasWithUid setLocalCanvasScaleMode  mode  THUNDER_RENDER_MODE_CLIP_TO_BOUNDS");
        
        self.localVideoCanvas = canvas;
        
    } else {
        YYLogDebug(@"[MouseLive-Thunder] createVideoCanvasWithUid RemoteCanvas");
        // 设置远端视图
        [_engine setRemoteVideoCanvas:canvas];
        // 设置远端视图显示模式
        [_engine setRemoteCanvasScaleMode:uid mode:THUNDER_RENDER_MODE_CLIP_TO_BOUNDS];
        
        YYLogDebug(@"[MouseLive-Thunder] createVideoCanvasWithUid setRemoteVideoCanvas");
        YYLogDebug(@"[MouseLive-Thunder] createVideoCanvasWithUid setRemoteCanvasScaleMode  mode  THUNDER_RENDER_MODE_CLIP_TO_BOUNDS");
    }
    
    YYLogDebug(@"[MouseLive-Thunder] createVideoCanvasWithUid exit");
    
    return canvas;
}

- (void)clearCanvasViewWithUID:(NSString *)uid
{
    YYLogDebug(@"[MouseLive-Thunder] clearCanvasViewWithUID entry, uid:%@", uid);
    
    // 创建视频视图
    SYVideoCanvas *canvas = [[SYVideoCanvas alloc] init];
    
    // 当用户退出房间后，需要将view置为nil，否则用户重新进入房间会导致以前的view指向野指针
    canvas.view = nil;
    
    // 设置视频布局
    [canvas setRenderMode:THUNDER_RENDER_MODE_CLIP_TO_BOUNDS];
    
    // 设置用户uid
    [canvas setUid:uid];
    
    // 设置远端视图
    [_engine setRemoteVideoCanvas:canvas];
    // 设置远端视图显示模式
    [_engine setRemoteCanvasScaleMode:uid mode:THUNDER_RENDER_MODE_CLIP_TO_BOUNDS];
    
    YYLogDebug(@"[MouseLive-Thunder] clearCanvasViewWithUID setRenderMode   THUNDER_RENDER_MODE_CLIP_TO_BOUNDS");
    YYLogDebug(@"[MouseLive-Thunder] clearCanvasViewWithUID setRemoteVideoCanvas canvas, view is nil");
    YYLogDebug(@"[MouseLive-Thunder] clearCanvasViewWithUID setRemoteCanvasScaleMode  THUNDER_RENDER_MODE_CLIP_TO_BOUNDS");
    YYLogDebug(@"[MouseLive-Thunder] clearCanvasViewWithUID exit");
}

- (NSInteger)switchFrontCamera:(BOOL)isFront
{
    //  调用成功返回 0，失败返回 < 0
    YYLogDebug(@"[MouseLive-Thunder] switchFrontCamera isFront:%d", isFront);
    return [_engine switchFrontCamera:isFront];
}

- (void)switchMirror:(BOOL)isMirror
{
    // 镜像是，正常打开前置摄像头，认为是镜像的
    // 如果 THUNDER_VIDEO_MIRROR_MODE_PREVIEW_PUBLISH_BOTH_MIRROR 就是看着都是正常的
    // 如果 THUNDER_VIDEO_MIRROR_MODE_PREVIEW_PUBLISH_BOTH_NO_MIRROR 看着就是镜像的
    ThunderVideoMirrorMode mode = !isMirror ? THUNDER_VIDEO_MIRROR_MODE_PREVIEW_PUBLISH_BOTH_MIRROR : THUNDER_VIDEO_MIRROR_MODE_PREVIEW_PUBLISH_BOTH_NO_MIRROR;
    YYLogDebug(@"[MouseLive-Thunder] switchMirror isMirror:%d, mode:%ld", isMirror, (long)mode);
    [_engine setLocalVideoMirrorMode:mode];
}

- (void)setVoiceChanger:(ThunderRtcVoiceChangerMode)voice
{
    YYLogDebug(@"[MouseLive-Thunder] setVoiceChanger voice:%d", (int)voice);
    [_engine setVoiceChanger:(int)voice];
}

- (void)disableRemoteVideo:(NSString *)uid disabled:(BOOL)disabled
{
    YYLogDebug(@"[MouseLive-Thunder] disableRemoteVideo uid:%@, disabled:%d", uid, disabled);
    [_engine stopRemoteVideoStream:uid stopped:disabled];
}

- (void)switchPublishMode:(ThunderPublishVideoMode)publishMode
{
    YYLogDebug(@"[MouseLive-Thunder] switchPublishMode entry, publishMode:%d", (int)publishMode);
    self.publishMode = publishMode;
    [self setupPublishMode];
    YYLogDebug(@"[MouseLive-Thunder] switchPublishMode exit");
}

- (int)addSubscribe:(NSString * _Nonnull)roomId uid:(NSString * _Nonnull)uid
{
    YYLogDebug(@"[MouseLive-Thunder] addSubscribe roomId:%@, uid:%@", roomId, uid);
    return [_engine addSubscribe:roomId uid:uid];
}

- (int)removeSubscribe:(NSString * _Nonnull)roomId uid:(NSString * _Nonnull)uid
{
    YYLogDebug(@"[MouseLive-Thunder] removeSubscribe roomId:%@, uid:%@", roomId, uid);
    return [_engine removeSubscribe:roomId uid:uid];
}

// 打开音频文件
- (void)openAuidoFileWithPath:(NSString * _Nonnull)path
{
    YYLogDebug(@"[MouseLive-Thunder] audioPlayer entry");
    if (!self.isPlaying) {
        self.isPlaying = YES;

        [_engine stopLocalAudioStream:(_isAudioMuted && !_isPlaying)];
        
        [self.engine setAudioSourceType:self.sourceType];

        [self.audioPlayer open:path];
        [self.audioPlayer enablePublish:YES]; // 开启推送
        [self.audioPlayer play];

        YYLogDebug(@"[MouseLive-Thunder] openAuidoFileWithPath path:%@", path);
        YYLogDebug(@"[MouseLive-Thunder] setAudioSourceType THUNDER_AUDIO_MIX");
        YYLogDebug(@"[MouseLive-Thunder] audioPlayer open");
        YYLogDebug(@"[MouseLive-Thunder] audioPlayer enablePublish YES");
        YYLogDebug(@"[MouseLive-Thunder] audioPlayer setLooping -1");
        YYLogDebug(@"[MouseLive-Thunder] audioPlayer play");
    }
    YYLogDebug(@"[MouseLive-Thunder] audioPlayer exit");
}

// 关闭音频文件
- (void)closeAuidoFile
{
    if (_audioPlayer) {
        [self.audioPlayer stop];
        [self.audioPlayer close];
        
        [self.engine destroyAudioFilePlayer:_audioPlayer];
//        [self.engine setAudioSourceType:THUNDER_AUDIO_MIC];
        self.isPlaying = NO;
        [self.engine setAudioSourceType:self.sourceType];
    }
    
    YYLogDebug(@"[MouseLive-Thunder] audioPlayer stop");
    YYLogDebug(@"[MouseLive-Thunder] audioPlayer close");
    YYLogDebug(@"[MouseLive-Thunder] setAudioSourceType THUNDER_AUDIO_MIC");
}

// 设置音频音量
- (void) setAudioFilePlayVolume:(uint32_t)volume
{
    YYLogDebug(@"[MouseLive-Thunder] audioPlayer setAudioFilePlayVolume:%d", volume);
    [self.audioPlayer setPlayVolume:volume];
}

/// 暂停音频文件播放
- (void)pauseAudioFile
{
    YYLogDebug(@"[MouseLive-Thunder] audioPlayer pause");
    self.isPlaying = NO;
    [_engine stopLocalAudioStream:(_isAudioMuted && !_isPlaying)];
    [self.audioPlayer pause];
}


/// 继续音频文件播放
- (void)resumeAudioFile
{
    YYLogDebug(@"[MouseLive-Thunder] audioPlayer resume");
    
    self.isPlaying = YES;
    
    [_engine stopLocalAudioStream:(_isAudioMuted && !_isPlaying)];
    
    [self.engine setAudioSourceType:self.sourceType];
    [self.audioPlayer resume];
}

- (void)setVideoWatermarkWithThunderImage:(ThunderImage *)thunderImage
{
    [self.engine setVideoWatermark:thunderImage];
}

- (void)setEnableInEarMonitor:(BOOL)enabled
{
    YYLogDebug(@"[MouseLive-Thunder] removeSubscribe setEnableInEarMonitor, enable:%d", enabled);
    [self.engine setEnableInEarMonitor:enabled];
}

#pragma mark - ThunderRtcLogDelegate

- (void)onThunderRtcLogWithLevel:(ThunderRtcLogLevel)level message:(nonnull NSString *)msg
{
    //    SYLog(@"【SYRTC】level=%ld, %@", (long)level, msg);
}

#pragma mark - ThunderAudioFilePlayerDelegate
- (void)onAudioFileVolume:(nonnull ThunderAudioFilePlayer *)player
                   volume:(uint32_t)volume
                currentMs:(uint32_t)currentMs
                  totalMs:(uint32_t)totalMs
{
    self.currentPlayprogress = (float)currentMs/(float)totalMs;
}

- (void)onAudioFilePlayError:(nonnull ThunderAudioFilePlayer *)player errorCode:(int)errorCode
{
    YYLogDebug(@"[MouseLive-Thunder] onAudioFilePlayError, errorCode:%d", errorCode);
    if (errorCode == 0) {
        if (self.isPlaying) {
            [self.audioPlayer setLooping:-1];  // 设置循环, 2.7.0 版本一定要在这里设置，后续版本可能修改掉
        }
    }
}

#pragma mark - Get and Set

- (ThunderAudioFilePlayer *)audioPlayer
{
    if (!_audioPlayer) {
        _audioPlayer = [self.engine createAudioFilePlayer];
        [_audioPlayer setPlayerDelegate:self];
        [_audioPlayer enablePublish:YES];
        [_audioPlayer enableVolumeIndication:YES interval:500];
        
    }
    return _audioPlayer;
}

- (LiveTranscoding *)liveTranscoding
{
    if (!_liveTranscoding) {
        _liveTranscoding = [[LiveTranscoding alloc] init];
    }
    return _liveTranscoding;
}

- (NSString *)uuidString
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}

#pragma mark -- 设置混画
- (void)setMixCanvasWith:(NSArray<MixVideoConfig *> * _Nonnull)config
{
    YYLogDebug(@"[MouseLive-Thunder] setMixCanvasWith entry");
    
    ThunderTranscodingModeType mode = TRANSCODING_MODE_960X544;
    CGSize size = CGSizeMake(960, 544);
    switch (self.publishMode) {
        case THUNDERPUBLISH_VIDEO_MODE_FLUENCY:
            mode = TRANSCODING_MODE_320X240;
            size = CGSizeMake(320, 240);
            break;
        case THUNDERPUBLISH_VIDEO_MODE_NORMAL:
            mode = TRANSCODING_MODE_640X360;
            size = CGSizeMake(640, 360);
            break;
        case THUNDERPUBLISH_VIDEO_MODE_HIGHQULITY:
            mode = TRANSCODING_MODE_960X544;
            break;
    }
    
    // 修改成 uid， taskid 最大 20 字节的限制
    self.mixTask = [NSString stringWithFormat:@"%@", self.localUid];
    
    [self.liveTranscoding removeAllUsers];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    if (config.count == 1) {
        MixVideoConfig *video = config[0];
        float heigh = size.height;
        float width = video.rect.size.width / (video.rect.size.height / size.height);
        TranscodingUserObj *user = [[TranscodingUserObj alloc] init];
        user.uid = video.uid;
        user.roomId = video.roomId;
        user.bStandard = video.bStandard;
        user.bCrop = video.bCrop;
        
        user.layoutX = (size.width - width) / 2.0;
        user.layoutY = 0;
        user.layoutW = width;
        user.layoutH = heigh;
        
        [array addObject:user];
    } else if (config.count == 2) {
        return;
    }
    
//    for (MixVideoConfig* video in config) {
//        TranscodingUserObj* user = [[TranscodingUserObj alloc] init];
//        user.uid = video.uid;
//        user.roomId = video.roomId;
//        user.layoutX = video.rect.origin.x;
//        user.layoutY = video.rect.origin.y;
//        user.layoutW = video.rect.size.width;
//        user.layoutH = video.rect.size.height;
//        user.bStandard = video.bStandard;
//        user.bCrop = video.bCrop;
//        [array addObject:user];
//
//        YYLogDebug(@"[MouseLive-Thunder] setMixCanvasWith [%d], user uid:%@, roomid:%@, x:%f, y:%f, w:%f, h:%f", index, video.uid, video.roomId,
//                   video.rect.origin.x, video.rect.origin.y, video.rect.size.width, video.rect.size.height);
//
//        index++;
//    }
    
    [self.liveTranscoding setUsers:array];
    
    [self.liveTranscoding setTransCodingMode:mode];
    
    YYLogDebug(@"[MouseLive-Thunder] setMixCanvasWith taskId:%@, mode:%ld", self.mixTask, (long)mode);
    
    [_engine setLiveTranscodingTask:self.mixTask transcoding:self.liveTranscoding];
    YYLogDebug(@"[MouseLive-Thunder] setMixCanvasWith exit");
}

/// 获取推流视频的分辨率宽度
- (int)getVideoWidth
{
    switch (self.publishMode) {
        case THUNDERPUBLISH_VIDEO_MODE_FLUENCY:
            return 240;
        case THUNDERPUBLISH_VIDEO_MODE_NORMAL:
            return 368;
        case THUNDERPUBLISH_VIDEO_MODE_HIGHQULITY:
            return 544;
    }
    return 544;
}

/// 获取推流视频的分辨率高度
- (int)getVideoHeight
{
    switch (self.publishMode) {
        case THUNDERPUBLISH_VIDEO_MODE_FLUENCY:
            return 320;
        case THUNDERPUBLISH_VIDEO_MODE_NORMAL:
            return 640;
        case THUNDERPUBLISH_VIDEO_MODE_HIGHQULITY:
            return 960;
    }
    return 960;
}

/// 更新 token
/// @param token token
- (void)updateToken:(NSString * _Nonnull)token
{
    YYLogDebug(@"[MouseLive-Thunder] updateToken token:%@", token);
    [_engine updateToken:token];
}


#pragma mark --New API
- (ThunderSourceType)sourceType
{
    if (_isPlaying) {
        if (_isAudioMuted) {
            return THUNDER_AUDIO_FILE;
        } else {
            return THUNDER_AUDIO_MIX;
        }
    } else {
        if (_isAudioMuted) {
            return THUNDER_AUDIO_FILE;
//            return THUNDER_SOURCE_TYPE_NONE;
        } else {
            return THUNDER_AUDIO_MIC;
        }
    }
}

/// 设置本地视频预处理回调接口
/// @param delegate 本地视频帧预处理接口，可用于自定义的美颜等处理。
- (void)registerVideoCaptureFrameObserver:(nullable id<ThunderVideoCaptureFrameObserver>)delegate
{
    self.videoCaptureFrameObserverDelegate = delegate;
}

- (void)enableLocalAudioStream:(BOOL)enabled
{
    [self.engine stopLocalAudioStream:!enabled];
}

- (void)disableLocalAudioCapture:(BOOL)disabled
{
    self.isAudioMuted = disabled;
    
    NSString *paras = [NSString stringWithFormat:@"sourceType: %ld", (long)self.sourceType];
    YYLogFuncEntry([self class], _cmd, paras);
    [self.engine setAudioSourceType:self.sourceType];
    
    [_engine stopLocalAudioStream:(_isAudioMuted && !_isPlaying)];
}

- (void)setupLocalUser:(NSString * _Nonnull)uid videoView:(UIView * _Nonnull)view;
{
    ThunderVideoCanvas *canvas = [[ThunderVideoCanvas alloc] init];
    canvas.uid = uid;
    canvas.view = view;
    canvas.renderMode = THUNDER_RENDER_MODE_CLIP_TO_BOUNDS;
    
    [self.engine setLocalVideoCanvas:canvas];
}

- (void)setupRemoteUser:(NSString * _Nonnull)uid videoView:(UIView * _Nullable)view
{
    ThunderVideoCanvas *canvas = [[ThunderVideoCanvas alloc] init];
    canvas.uid = uid;
    canvas.view = view;
    canvas.renderMode = THUNDER_RENDER_MODE_CLIP_TO_BOUNDS;
    
    [self.engine setRemoteVideoCanvas:canvas];
}

- (void)setMirrorPreview:(BOOL)preview publish:(BOOL)publish
{
    ThunderVideoMirrorMode mirrorMode;
    
    if (preview) {
        if (publish) {
            mirrorMode = THUNDER_VIDEO_MIRROR_MODE_PREVIEW_PUBLISH_BOTH_MIRROR;
        } else {
            mirrorMode = THUNDER_VIDEO_MIRROR_MODE_PREVIEW_MIRROR_PUBLISH_NO_MIRROR;
        }
    } else {
        if (publish) {
            mirrorMode = THUNDER_VIDEO_MIRROR_MODE_PREVIEW_NO_MIRROR_PUBLISH_MIRROR;
        } else {
            mirrorMode = THUNDER_VIDEO_MIRROR_MODE_PREVIEW_PUBLISH_BOTH_NO_MIRROR;
        }
    }
    
    [self.engine setLocalVideoMirrorMode:mirrorMode];
}

@end
