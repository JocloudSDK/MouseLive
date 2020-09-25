//
//  VideoPresenter.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/5/21.
//  Copyright © 2020 sy. All rights reserved.
//

#import "SYHttpPresenter.h"
#import "VideoOrAudioLiveViewProtocol.h"

@interface VideoOrAudioPresenter : SYHttpPresenter <id<VideoOrAudioLiveViewProtocol>>

//http 相关
//请求房间详情
- (void)fetchRoomInfoWithParam:(NSDictionary *)param;
//主播pk列表
- (void)fetchAnchorListWithParam:(NSDictionary *)param;
//请求用户信息
- (void)fetchUserInfoDataWithUid:(NSString *)uid;
//创建直播间
- (void)fetchCreateRoomWithParams:(NSDictionary *)params;
//set chatID
- (void)fetchSetchatIdWithParams:(NSDictionary *)params;
//get chatID
- (void)fetchGetchatIdWithParams:(NSDictionary *)params;

//业务相关

//将要发送弹幕
- (void)willSendChatMessageWithUid:(NSString *)uid message:(NSString *)msg;
//将要发送广播弹幕消息
- (void)willsendBroadcastMessage:(NSString *)msg;
//将要显示连麦申请弹出框
- (void)willShowApplayViewWithUid:(NSString *)uid roomid:(NSString *)roomid;
//将要全员禁言
- (void)willChangeAllMuteStatus:(BOOL)ismute;
//禁言或解禁言某人
- (void)muteUser:(NSString *)uid mute:(BOOL)ismute;
//升管理或降管理
- (void)adminUser:(NSString *)uid admin:(BOOL)isAdmin;
//主播或者管理员操作闭麦 开麦
- (void)enableMicWithUid:(NSString *)uid enable:(BOOL)enable;
//所有观众被闭麦开麦
- (void)offAllRemoteUserMic:(BOOL)mircoff;
//观众被闭麦开麦
- (void)beEnabledMicWithUid:(NSString *)uid byOther:(NSString * _Nonnull)otherUid enable:(BOOL)enable;
//音频房将要和某人连麦
- (void)willLinkAudioWithUid:(NSString *)uid;
//音聊房将要和某人断开连麦
- (void)willDisconnectAudioWithUid:(NSString *)uid;
//将要展示跨房间PK主播的信息
- (void)willShowPKAnchorWithUid:(NSString *)uid;
//踢出
- (void)kickOutUser:(NSString *)uid;
//取消多任务
- (void)cancelRequestWithRequestIDList;

@end

