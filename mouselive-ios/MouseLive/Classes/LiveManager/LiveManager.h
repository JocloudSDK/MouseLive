//
//  LiveManager.h
//  MouseLive
//
//  Created by 张骥 on 2020/5/14.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypeAlias.h"
#import "SYHttpService.h"
#import "SYHummerManager.h"
#import "SYThunderManagerNew.h"
#import "LiveRoomInfoModel.h"
#import "LiveManagerEvent.h"
#import "SYThunderEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveManager : NSObject

+ (instancetype)shareManager;

- (void)addDelegate:(id<LiveManagerDelegate>)delegate;

- (void)removeDelegate:(id<LiveManagerDelegate>)delegate;

- (void)addSignalDelegate:(id<LiveManagerSignalDelegate>)delegate;

- (void)removeSignalDelegate:(id<LiveManagerSignalDelegate>)delegate;

- (void)addThunderDelegate:(id<SYThunderDelegate>)delagate;

- (void)removeThunderDelegate:(id<SYThunderDelegate>)delagate;

#pragma mark - Http methods
/// @brief 登录业务服务器
/// login to business server
- (void)login:(UserInfoCompletion _Nullable)success
         fail:(ErrorComplete _Nullable)fail;

/// @brief 获取房间列表
/// get room list for defferent type
/// @param type 房间类型 room type
- (void)getRoomListOfType:(LiveType)type;

- (void)getRoomListOfType:(LiveType)type
                  success:(ArrayCompletion _Nullable)success
                     fail:(ErrorComplete _Nullable)fail;

/// @brief 创建房间（业务服务器）
/// create room(send 'create room' to business server)
/// @param type 房间类型  room type
/// @param mode 推流类型 RTC / CDN 视频房需要填，音频房填 RTC
/// publish mode RTC / CDN for video room, RTC for audio room
- (void)createRoomForType:(LiveType)type
              publishMode:(PublishMode)mode;

- (void)createRoomForType:(LiveType)type
              publishMode:(PublishMode)mode
                  success:(RoomInfoCompletion  _Nullable)success
                     fail:(ErrorComplete _Nullable)fail;

/// @brief 创建房间（Hummer)
/// create chat room(Hummer)
/// 在创建业务房间之后调用
/// should call after business room created
- (void)createChatRoom;

- (void)createChatRoomSuccess:(StrCompletion _Nullable)success
                         fail:(ErrorComplete _Nullable)fail;

/// @brief 获取房间信息
/// get room info
/// @param roomId 房间号
/// @param type 房间类型
- (void)getRoomInfo:(NSString *)roomId
               Type:(LiveType)type;

- (void)getRoomInfo:(NSString *)roomId
               Type:(LiveType)type
            success:(RoomInfoCompletion _Nullable)success
               fail:(ErrorComplete _Nullable)fail;

/// @brief 加入Hummer房间
/// join chat room(Hummer)
/// 观众调用
- (void)joinChatRoom;

- (void)joinChatRoomSuccess:(StrCompletion _Nullable)success
                       fail:(ErrorComplete _Nullable)fail;

/// @brief 获取用户信息
/// get user info
/// @param uid 用户ID
- (void)getUserInfoWith:(NSString * _Nonnull)uid;

- (void)getUserInfoWith:(NSString * _Nonnull)uid
                success:(UserInfoCompletion _Nullable)success
                   fail:(ErrorComplete _Nullable)fail;

/// @brief 离开房间
/// leave room
- (void)leaveRoom;

#pragma mark - Media methods (Thunder)

/// @brief 加入Thunder房间
/// Join media room (Thunder)
/// @param roomId 房间ID 主播通过CreateRoom返回，观众通过GetRoom返回
/// author call creatRoom to get it, audience call getRoomInfo to get it
/// @param uid 用户ID Login 返回
/// call login to get it
/// @param roomType 房间类型
- (void)joinMediaRoom:(NSString *)roomId uid:(NSString *)uid roomType:(LiveType)roomType;

/// @brief 本地视频推流管理
/// publish or unpublish local video stream
/// @param enable YES/NO: 推流/不推流
- (void)enableLocalVideo:(BOOL)enable;

/// @brief 开启本地预览
/// start local preview
- (void)startPreview;

/// @brief 本地音频推流管理
/// publish or unpublish local audio stream
/// @param enable YES/NO: 推流/不推流
- (void)enableLocalAudio:(BOOL)enable;

/// @brief 推流到CDN
/// publish CDN stream to url
/// @param url 推流地址
- (void)publishStreamToUrl:(NSString * _Nonnull)url;

/// @brief 停止推流到CDN
/// stop publish CDN stream to url
/// @param url 推流地址
- (void)stopPublishStreamToUrl:(NSString * _Nonnull)url;

/// @brief 是否接受远端视频流
/// subscribe or unsubscribe remote video stream
/// @param enable YES/NO: 接受/不接受
- (void)enableRemoteVideoStream:(BOOL)enable;

/// @brief 是否接受远端音频流
/// subscribe or unsubscribe remote audio stream
/// @param enable YES/NO: 接受/不接受
- (void)enableRemoteAudioStream:(BOOL)enable;

/// @brief 设置本地渲染视图
/// set render view for loacl user
/// @param uid 用户ID
/// @param view 用于渲染是视图
- (void)setupLocalUser:(NSString *)uid videoView:(UIView *_Nonnull)view;

/// @brief 设置远端渲染视图
/// set render view for remote user
/// @param uid 用户ID
/// @param view 用于渲染是视图
- (void)setupRemoteUser:(NSString *)uid videoView:(UIView *_Nullable)view;

/// @brief 切换前后摄像头
/// switch camera
/// @param isFront 是否是前置
- (void)switchFrontCamera:(BOOL)isFront;

/// @brief 设置镜像模式
/// set mirror mode
/// @param preview 本地渲染镜像
/// @param publish 推流数据镜像
- (void)setMirrorPreview:(BOOL)preview publish:(BOOL)publish;

/// @brief 关闭/打开 本地麦克风
/// turn on/off local microphone
/// @param micOff YES/NO: 关闭/打开
- (void)offLocalMic:(BOOL)micOff;

/// @brief 设置耳返
/// enable/disable in ear monitor
/// @param enable YES/NO
- (void)setEnableInEarMonitor:(BOOL)enable;

/// @brief 设置音效
/// set voice effect
/// @param voice 音效
- (void)setVoiceChanger:(ThunderRtcVoiceChangerMode)voice;

/// @brief 订阅跨房间流
/// subscribe stream from different room
/// @param roomId 房间ID
/// @param uid 用户ID
- (int)addSubscribe:(NSString * _Nonnull)roomId uid:(NSString * _Nonnull)uid;

/// @brief 取消跨房间流
/// unsubscribe stram from different room
/// @param roomId 房间ID
/// @param uid 用户ID
- (int)removeSubscribe:(NSString * _Nonnull)roomId uid:(NSString * _Nonnull)uid;

/// @brief 打开音频文件
/// open audio file with path
/// @param path 文件路径
- (void)openAuidoFileWithPath:(NSString * _Nonnull)path;

/// @brief 关闭音频文件
/// close audio file
- (void)closeAuidoFile;

/// @brief 设置音频文件播放音量
/// set audio file play volume
/// @param volume 音量
- (void)setAudioFilePlayVolume:(uint32_t)volume;

/// @brief 暂停播放
/// pause audio file play
- (void)pauseAudioFile;

/// @brief 重新播放
/// resume audio file play
- (void)resumeAudioFile;

- (CGFloat)currentPlayprogress;

/// @brief 注册视频数据回调
/// register video capture frame observer
- (void)registerVideoCaptureFrameObserver:(nullable id<ThunderVideoCaptureFrameObserver>)delegate;

#pragma mark - Signaling methods (Hummer & WS)

/// @brief 禁言远端用户
/// mute/unmute remote user
/// @param uid 用户ID
/// @param mute YES/NO 禁言/取消禁言
- (void)muteRemoteUser:(NSString *)uid mute:(BOOL)mute;

- (void)muteRemoteUser:(NSString *)uid mute:(BOOL)mute complete:(SendComplete _Nullable)complete;

/// @brief 禁言全部远端用户
/// mute/unmute all remote users
/// @param mute YES/NO 禁言/取消禁言
- (void)muteAllRemoteUser:(BOOL)mute complete:(SendComplete _Nullable)complete;

/// @brief 禁麦远端用户
/// trun on/off remote user's microphone
/// @param uid 用户ID
/// @param micOff YES/NO 禁麦/取消禁麦
- (void)offRemoteUserMic:(NSString *)uid micOff:(BOOL)micOff complete:(SendComplete _Nullable)complete;

/// @brief 禁麦全部远端用户
/// tron on/off all remote users' microphone
/// @param micOff YES/NO 禁麦/取消禁麦
- (void)offAllRemoteUserMic:(BOOL)micOff complete:(SendComplete _Nullable)complete;

/// @brief 设置管理员
/// set administrator role for user
/// @param uid 用户ID
/// @param isAdmin YES/NO 设置管理员权限/取消管理员权限
- (void)setUserRole:(NSString * _Nonnull)uid isAdmin:(BOOL)isAdmin complete:(SendComplete _Nullable)complete;

/// @brief 踢出某人
/// kick off user
/// @param uid 用户ID
- (void)kickUserWithUid:(NSString * _Nonnull)uid complete:(SendComplete _Nullable)complete;

/// @brief 发送广播消息
/// send message to all users in the room
/// @param message 消息
- (void)sendRoomMessage:(NSString *)message;

- (void)sendRoomMessage:(NSString *)message complete:(SendComplete _Nullable)complete;

/// @brief 获取Hummer房间属性 AllMute AllMic 通过回调返回
/// check AllMute and AllMic status of the room
- (void)fetchChatRoomStatus:(SendComplete _Nullable)complete;

/// @brief 获取mute user
/// check the mute users in the room
/// @paras users 传入uid 的 array
- (void)fetchMuteStatusOfUsers:(NSArray<NSString *> * _Nullable)users
                      complete:(void(^)(NSArray<NSString *> * _Nullable muteUsers, NSError * _Nullable error))complete;

/// @brief 获取管理员
/// check the administrators
/// @paras users 传入uid 的 array
- (void)fetchAdminOfUsers:(NSArray<NSString *> * _Nullable)users
                 complete:(void(^)(NSArray<NSString *> * _Nullable admins, NSError * _Nullable error))complete;

/// @brief 发送点对点消息
/// send message to user
/// @param message 消息
/// @param uid 用户ID
- (void)sendMessage:(NSString *)message toUser:(NSString *)uid;

- (void)sendMessage:(NSString *)message toUser:(NSString *)uid complete:(SendComplete _Nullable)complete;

/// @brief 申请连麦
/// apply connection to user
/// @param uid 用户ID
/// @param roomId 房间ID
- (void)applyConnectToUser:(NSString *)uid
                    roomId:(NSString * _Nonnull)roomId
                  complete:(SendComplete _Nullable)complete;

/// @brief 接受连麦申请
/// accept connection request
/// @param uid 用户ID
- (void)acceptConnectWithUser:(NSString *)uid
                     complete:(SendComplete _Nullable)complete;

/// @brief 拒绝连麦
/// refuse connnection request
/// @param uid 用户ID
- (void)refuseConnectWithUser:(NSString *)uid
                     complete:(SendComplete _Nullable)complete;

/// @brief 清空所以未处理连麦请求，当达到连麦上线的时候主动调用
/// clear connection request queue
- (void)clearBeInvitedQueue;

/// @brief 挂断连麦
/// hungup connection
/// @param uid 用户ID
/// @param roomId 房间ID
- (void)hungupWithUser:(NSString *)uid
                roomId:(NSString *)roomId
              complete:(SendComplete _Nullable)complete;

/// 
- (void)enableMicWithUid:(NSString * _Nonnull)uid
                  enable:(BOOL)enable
                complete:(SendComplete _Nullable)complete;

@end

NS_ASSUME_NONNULL_END
