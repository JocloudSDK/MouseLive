//
//  SYThunderEvent.m
//  MouseLive
//
//  Created by 张建平 on 2020/3/31.
//  Copyright © 2020 sy. All rights reserved.
//

#import "SYThunderEvent.h"
#import "SYThunderManagerNew.h"

@interface SYThunderEvent() <ThunderEventDelegate>

@end

@implementation SYThunderEvent

+ (instancetype)sharedManager
{
    static SYThunderEvent *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [[SYThunderManagerNew sharedManager] setupEngineWithDelegate:instance];
    });
    return instance;
}

- (void)setDelegate:(id<SYThunderDelegate>)delegate
{
    _delegate = delegate;
}

/**
 @brief 进入房间回调
 @param [OUT] room 房间名
 @param [OUT] uid 用户id
 @param [OUT] elapsed 表示进房间耗时，从调用joinRoom到发生此事件经过的时间（毫秒）
 @remark 调用joinRoom后，收到此通知表示与服务器连接正常，可以调用需要"进房间成功"才能调用的接口
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine
    onJoinRoomSuccess:(nonnull NSString *)room
              withUid:(nonnull NSString *)uid
              elapsed:(NSInteger)elapsed
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onJoinRoomSuccess:withUid:elapsed:)]) {
        [self.delegate thunderEngine:engine onJoinRoomSuccess:room withUid:uid elapsed:elapsed];
    }
}

/**
@brief 离开房间通知
@remark 调用leaveRoom，正常退出房间就会收到此通知
*/
- (void)thunderEngine: (ThunderEngine * _Nonnull)engine onLeaveRoomWithStats:(ThunderRtcRoomStats * _Nonnull)stats
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onLeaveRoomWithStats:)]) {
        [self.delegate thunderEngine:engine onLeaveRoomWithStats:stats];
    }
}

/**
 @brief SDK鉴权结果通知 关于鉴权详见官网的"用户鉴权说明"
 @param [OUT] sdkAuthResult 鉴权结果 参见ThunderRtcSdkAuthResult
 @remark 调用joinRoom之后，有上下行媒体数据，就会收到该用户的鉴权通知
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine sdkAuthResult:(ThunderRtcSdkAuthResult)sdkAuthResult
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:sdkAuthResult:)]) {
        [self.delegate thunderEngine:engine sdkAuthResult:sdkAuthResult];
    }
}

/**
 @brief 业务鉴权结果通知
 @param [OUT] bPublish 是否开播（作为主播说话）
 @param [OUT] bizAuthResult 鉴权结果 0表示成功
 @remark 当业务配置了需要业务鉴权，当媒体流上行时，就会收到该通知
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine bPublish:(BOOL)bPublish bizAuthResult:(NSInteger)bizAuthResult
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:bPublish:bizAuthResult:)]) {
        [self.delegate thunderEngine:engine bPublish:bPublish bizAuthResult:bizAuthResult];
    }
}

#pragma mark play
/**
 @brief 说话声音音量提示回调
 @param [OUT] speakers 用户Id-用户音量（未实现，音量=totalVolume）
 @param [OUT] totalVolume (混音后的)总音量 [0-100]
 @remark 设置setAudioVolumeIndication后，房间内有人说话就会收到该通知
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine
onPlayVolumeIndication:(NSArray<ThunderRtcAudioVolumeInfo *> * _Nonnull)speakers
          totalVolume:(NSInteger)totalVolume
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onPlayVolumeIndication:totalVolume:)]) {
        [self.delegate thunderEngine:engine onPlayVolumeIndication:speakers totalVolume:totalVolume];
    }
}

/**
 @brief 采集声音音量提示回调
 @param [OUT] totalVolume 采集总音量（包含麦克风采集和文件播放）
 @param [OUT] cpt 采集时间戳
 @param [OUT] micVolume 麦克风采集音量
 @
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine
onCaptureVolumeIndication:(NSInteger)totalVolume
                  cpt:(NSUInteger)cpt
            micVolume:(NSInteger)micVolume
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onCaptureVolumeIndication:cpt:micVolume:)]) {
        [self.delegate thunderEngine:engine onCaptureVolumeIndication:totalVolume cpt:cpt micVolume:micVolume];
    }
}

/**
 @brief 音频播放数据回调
 @param [OUT] uid 用户id
 @param [OUT] duration 时长
 @param [OUT] cpt 采集时间戳
 @param [OUT] pts 播放时间戳
 @param [OUT] data 解码前数据
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine
      onAudioPlayData:(nonnull NSString *)uid
             duration:(NSUInteger)duration
                  cpt:(NSUInteger)cpt
                  pts:(NSUInteger)pts
                 data:(nullable NSData *)data
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onAudioPlayData:duration:cpt:pts:data:)]) {
        [self.delegate thunderEngine:engine onAudioPlayData:uid duration:duration cpt:cpt pts:pts data:data];
    }
}

/**
 @brief 音频播放频谱数据回调
 @param [OUT] data 频谱数据,类型UInt8，数值范围[0-100]
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onAudioPlaySpectrumData:(nullable NSData *)data
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onAudioPlaySpectrumData:)]) {
        [self.delegate thunderEngine:engine onAudioPlaySpectrumData:data];
    }
}

/**
 @brief 音频采集数据回调
 @param [OUT] data 采集PCM
 @param [OUT] sampleRate 数据采样率
 @param [OUT] channel 数据声道数
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine
onAudioCapturePcmData:(nullable NSData *)data
           sampleRate:(NSUInteger)sampleRate
              channel:(NSUInteger)channel
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onAudioPlaySpectrumData:)]) {
        [self.delegate thunderEngine:engine onAudioPlaySpectrumData:data];
    }
}

/**
 @brief 渲染音频数据回调
 @param [OUT] data 渲染PCM
 @param [OUT] sampleRate 数据采样率
 @param [OUT] channel 数据声道数
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine
  onAudioRenderPcmData:(nullable NSData *)data
              duration:(NSUInteger)duration
            sampleRate:(NSUInteger)sampleRate
              channel:(NSUInteger)channel
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onAudioRenderPcmData:duration:sampleRate:channel:)]) {
        [self.delegate thunderEngine:engine onAudioRenderPcmData:data duration:duration sampleRate:sampleRate channel:channel];
    }
}

/**
 @brief 业务自定义广播消息回调
 @param [OUT] msgData 透传的消息
 @param [OUT] uid 发送该消息的uid
 @remark 主播有通过sendUserAppMsgData发送数据，进频道的观众会收到该回调
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine
  onRecvUserAppMsgData:(nonnull NSData *)msgData
                  uid:(nonnull NSString *)uid
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onRecvUserAppMsgData:uid:)]) {
        [self.delegate thunderEngine:engine onRecvUserAppMsgData:msgData uid:uid];
    }
}

/**
 @brief 业务发自定义广播消息发送失败回调
 @param [OUT] status 失败状态(1-频率太高 2-发送数据太大 3-未成功开播)
 @remark 主播有通过sendUserAppMsgData发送数据，进频道的观众会收到该通知 目前规定透传频率2次/s,发送数据大小限制在<=200Byte
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onSendAppMsgDataFailedStatus:(NSUInteger) status
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onSendAppMsgDataFailedStatus:)]) {
        [self.delegate thunderEngine:engine onSendAppMsgDataFailedStatus:status];
    }
}

/**
 @brief 远端用户音频流停止/开启回调
 @param [OUT] stopped 停止/开启，YES=停止 NO=开启
 @param [OUT] uid 远端用户uid
 @remark 调用joinRoom后，房间存的音频流及后续音频流状态发生变化时就会收到该回调
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onRemoteAudioStopped:(BOOL)stopped byUid:(nonnull NSString *)uid
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onRemoteAudioStopped:byUid:)]) {
        [self.delegate thunderEngine:engine onRemoteAudioStopped:stopped byUid:uid];
    }
}

/**
 @brief 远端用户视频流开启/停止回调
 @param [OUT] stopped 流是否已经断开（YES:断开 NO:连接）
 @param [OUT] uid 对应的uid
 @remark 调用joinRoom后，房间存的视频流及后续视频流状态发生变化时就会收到该回调
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onRemoteVideoStopped:(BOOL)stopped byUid:(nonnull NSString *)uid
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onRemoteVideoStopped:byUid:)]) {
        [self.delegate thunderEngine:engine onRemoteVideoStopped:stopped byUid:uid];
    }
}

/**
 @brief 已显示远端视频首帧回调
 @param [OUT] uid 对应的uid
 @param [OUT] size 视频尺寸(宽和高)
 @param [OUT] elapsed 实耗时间，从调用joinRoom到发生此事件经过的时间（毫秒）
 @remark 调用setRemoteVideoCanvas后，在收到视频流并在窗口显示时，会收到该回调
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine
    onRemoteVideoPlay:(nonnull NSString *)uid
    size:(CGSize)size
    elapsed:(NSInteger)elapsed
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onRemoteVideoPlay:size:elapsed:)]) {
        [self.delegate thunderEngine:engine onRemoteVideoPlay:uid size:size elapsed:elapsed];
    }
}

/**
 @brief 本地或远端视频大小和旋转信息发生改变回调
 @param [OUT] uid 对应的uid
 @param [OUT] size 视频尺寸(宽和高)
 @param [OUT] rotation 旋转信息 (0 到 360)
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine
onVideoSizeChangedOfUid:(nonnull NSString *)uid
    size:(CGSize)size
    rotation:(NSInteger)rotation
{
    YYLogDebug(@"[MouseLive-iOS] onVideoSizeChangedOfUid, uid:%@, w:%f, h:%f, rotation:%ld", uid, size.width, size.height, (long)rotation);
    if ([uid isEqual:[SYThunderManagerNew sharedManager].localUid]) { // only local uid need to set videomark
        if ([SYThunderManagerNew sharedManager].waterMarkAdapter == nil) {
            [SYThunderManagerNew sharedManager].waterMarkAdapter = [[WaterMarkAdapter alloc] init];
            [[SYThunderManagerNew sharedManager].waterMarkAdapter setImgUrl:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"watermark" ofType:@"png"]]];
//            [[NSURL fileURLWithPath:[NSBundle mainBundle] pathForResource:@"watermark" ofType:@"png"]]
            [[SYThunderManagerNew sharedManager].waterMarkAdapter setStartX:850];
            [[SYThunderManagerNew sharedManager].waterMarkAdapter setStartY:73];
            [[SYThunderManagerNew sharedManager].waterMarkAdapter setWidth:40];
            [[SYThunderManagerNew sharedManager].waterMarkAdapter setHeight:40];
        }
        ThunderImage* image = [[SYThunderManagerNew sharedManager].waterMarkAdapter createThunderBoltImage:size.width videoHeight:size.height rotation:rotation];
        YYLogDebug(@"createVideoCanvasWithUid setVideoWatermark  rect x:%f, y:%f, width:%f, height:%f", image.rect.origin.x, image.rect.origin.y, image.rect.size.width, image.rect.size.height);
        [[SYThunderManagerNew sharedManager] setVideoWatermarkWithThunderImage:image];
    }
//    if ([self.delegate respondsToSelector:@selector(thunderEngine:onVideoSizeChangedOfUid:size:rotation:)]) {
//        [self.delegate thunderEngine:engine onVideoSizeChangedOfUid:uid size:size rotation:rotation];
//    }
}

/**
 @brief 摄像头采集状态回调
 @param [OUT] status 摄像头采集状态
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onVideoCaptureStatus:(ThunderVideoCaptureStatus)status
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onVideoCaptureStatus:)]) {
        [self.delegate thunderEngine:engine onVideoCaptureStatus:status];
    }
}

/**
 @brief sdk与服务器的网络连接状态回调
 @param [OUT] status 连接状态，参见ThunderConnectionStatus
 @remark 调用joinRoom后，SDK与服务器网络连接状态发生变化时会收到该回调
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onConnectionStatus:(ThunderConnectionStatus)status
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onConnectionStatus:)]) {
        [self.delegate thunderEngine:engine onConnectionStatus:status];
    }
}

/**
 @brief 上下行流量通知 (周期性通知，每2秒通知一次)
 @param [OUT] stats 上行下流通统计信息
 @remark 用户进频道后，就会收到该回调
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onRoomStats:(nonnull RoomStats *)stats
{
    NetworkQualityStauts *networkQualityStatus = [NetworkQualityStauts alloc];
    networkQualityStatus.audioUpload = stats.txAudioBitrate / 8192;
    networkQualityStatus.audioDownload = stats.rxAudioBitrate / 8192;
    networkQualityStatus.videoUpload = stats.txVideoBitrate / 8192;
    networkQualityStatus.videoDownload = stats.rxVideoBitrate / 8192;
    networkQualityStatus.upload = stats.txBitrate / 8192;
    networkQualityStatus.download = stats.rxBitrate / 8192;
    
    if ([self.delegate respondsToSelector:@selector(thunderEngine:networkQualityStatus:)]) {
        [self.delegate thunderEngine:engine networkQualityStatus:networkQualityStatus];
    }
}

/**
 @brief 已发送本地音频首帧的回调
 @param [OUT] elapsed 从本地用户调用 joinRoom 方法直至该回调被触发的延迟（毫秒）
 @remark 用户上行音频流，就会收到该回调
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onFirstLocalAudioFrameSent:(NSInteger)elapsed
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onFirstLocalAudioFrameSent:)]) {
        [self.delegate thunderEngine:engine onFirstLocalAudioFrameSent:elapsed];
    }
}

/**
 @brief 已发送本地视频首帧的回调
 @param [OUT] elapsed 从本地用户调用 joinRoom 方法直至该回调被触发的延迟（毫秒）
 @remark 用户上行视频流，就会收到该通知
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onFirstLocalVideoFrameSent:(NSInteger)elapsed
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onFirstLocalVideoFrameSent:)]) {
        [self.delegate thunderEngine:engine onFirstLocalVideoFrameSent:elapsed];
    }
}

/**
 @brief 开播或设置转码任务后调用 addPublishOriginStreamUrl设置推原流到CDN 或调用 addPublishTranscodingStreamUrl设置推混画流到CDN后会触发此回调。
 用于通知CDN推流是否成功，若推流失败errorCode指示具体原因。
 @param [OUT] url  推流的目标url
 @param [OUT] errorCode  推流错误码
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine
  onPublishStreamToCDNStatusWithUrl:(NSString * _Nonnull)url
  errorCode:(ThunderPublishCDNErrorCode)errorCode
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onPublishStreamToCDNStatusWithUrl:errorCode:)]) {
        [self.delegate thunderEngine:engine onPublishStreamToCDNStatusWithUrl:url errorCode:errorCode];
    }
}

/**
 @brief 网络类型变化时回调
 @param [OUT] type 当前网络状态
 @remark "初始化"后，当网络类型发生变化时，会收到该回调
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onNetworkTypeChanged:(NSInteger)type
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onNetworkTypeChanged:)]) {
        [self.delegate thunderEngine:engine onNetworkTypeChanged:type];
    }
}

/*!
@brief 报告本地视频统计信息
@param stats 本地视频的统计信息，参见ThunderRtcLocalVideoStats
*/
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onLocalVideoStats:(ThunderRtcLocalVideoStats * _Nonnull)stats
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onLocalVideoStats:)]) {
        [self.delegate thunderEngine:engine onLocalVideoStats:stats];
    }
}

/*!
@brief 报告本地音频统计信息
@param stats 本地音频的统计信息，参见ThunderRtcLocalAudioStats
*/
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onLocalAudioStats:(ThunderRtcLocalAudioStats * _Nonnull)stats
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onLocalAudioStats:)]) {
        [self.delegate thunderEngine:engine onLocalAudioStats:stats];
    }
}


/**
 @brief 音频设备采集状态回调
 @param [OUT] status 采集状态
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onAudioCaptureStatus:(NSInteger)status
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onAudioCaptureStatus:)]) {
        [self.delegate thunderEngine:engine onAudioCaptureStatus:status];
    }
}

/**
 @brief 服务器网络连接中断通告，SDK 在调用 joinRoom 后无论是否加入成功，只要 10 秒和服务器无法连接就会触发该回调
 */
- (void)thunderEngineConnectionLost:(ThunderEngine * _Nonnull)engine
{
    if ([self.delegate respondsToSelector:@selector(thunderEngineConnectionLost:)]) {
        [self.delegate thunderEngineConnectionLost:engine];
    }
}

/**
 @brief 鉴权服务即将过期回调
 @param [OUT] token 即将服务失效的Token
 @remark  用户的token快过期时会收到该回调
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onTokenWillExpire:(nonnull NSString *)token
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onTokenWillExpire:)]) {
        [self.delegate thunderEngine:engine onTokenWillExpire:token];
    }
}

/**
 @brief 鉴权过期回调
 */
- (void)thunderEngineTokenRequest:(ThunderEngine * _Nonnull)engine
{
    if ([self.delegate respondsToSelector:@selector(thunderEngineTokenRequest:)]) {
        [self.delegate thunderEngineTokenRequest:engine];
    }
}

/**
 @brief 用户被封禁回调
 @param [OUT] status 封禁状态（YES-封禁 NO-解禁）
 @remark 用户的封禁状态变化时会收到该回调
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onUserBanned:(BOOL)status
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onUserBanned:)]) {
        [self.delegate thunderEngine:engine onUserBanned:status];
    }
}

/**
 @brief 远端用户加入回调
 @param [OUT] uid 远端用户uid
 @param [OUT] elapsed 加入耗时
 @remark 本地用户进房间后，有其它用户再进入该房间就会收到该回调，只在纯音频模式下生效
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine onUserJoined:(nonnull NSString *)uid elapsed:(NSInteger)elapsed
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onUserJoined:elapsed:)]) {
        [self.delegate thunderEngine:engine onUserJoined:uid elapsed:elapsed];
    }
}

/**
 @brief 远端用户离开当前房间回调
 @param [OUT] uid 离线用户uid
 @param [OUT] reason 离线原因
 @remark 本地用户进房间后，有其它用户退出该房间就会收到该回调，只在纯音频模式下生效
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine
        onUserOffline:(nonnull NSString *)uid
        reason:(ThunderLiveRtcUserOfflineReason)reason
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onUserOffline:reason:)]) {
        [self.delegate thunderEngine:engine onUserOffline:uid reason:reason];
    }
}

/*!
 @brief 网路上下行质量报告回调
 @param [OUT] uid 表示该回调报告的是持有该id的用户的网络质量，当uid为0时，返回的是本地用户的网络质量
 @param [OUT] txQuality 该用户的上行网络质量，参见ThunderLiveRtcNetworkQuality
 @param [OUT] rxQuality 该用户的下行网络质量，参见ThunderLiveRtcNetworkQuality
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine
     onNetworkQuality:(nonnull NSString *)uid
     txQuality:(ThunderLiveRtcNetworkQuality)txQuality
     rxQuality:(ThunderLiveRtcNetworkQuality)rxQuality
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onNetworkQuality:txQuality:rxQuality:)]) {
        [self.delegate thunderEngine:engine onNetworkQuality:uid txQuality:txQuality rxQuality:rxQuality];
    }
}

/*!
 @brief 通话中远端视频流信息回调
 @param [OUT] uid 远端用户/主播id
 @param [OUT] stats 流信息，参见ThunderRtcRemoteVideoStats
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine
        onRemoteVideoStatsOfUid:(nonnull NSString *)uid
        stats:(ThunderRtcRemoteVideoStats * _Nonnull)stats
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onRemoteVideoStatsOfUid:stats:)]) {
        [self.delegate thunderEngine:engine onRemoteVideoStatsOfUid:uid stats:stats];
    }
}

/*!
 @brief 通话中远端音频流信息回调
 @param [OUT] uid 远端用户/主播id
 @param [OUT] stats 流信息，参见ThunderRtcRemoteAudioStats
 */
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine
        onRemoteAudioStatsOfUid:(nonnull NSString *)uid
        stats:(ThunderRtcRemoteAudioStats * _Nonnull)stats
{
    if ([self.delegate respondsToSelector:@selector(thunderEngine:onRemoteAudioStatsOfUid:stats:)]) {
        [self.delegate thunderEngine:engine onRemoteAudioStatsOfUid:uid stats:stats];
    }
}

@end
