//
//  VideoLiveViewProtocol.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/5/21.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiveUserListManager.h"

@protocol VideoOrAudioLiveViewProtocol <NSObject>
//请求房间信息成功
- (void)onfetchRoomInfoSuccess:(LiveRoomInfoModel *)roomModel;
//请求房间信息失败
- (void)onfetchRoomInfoFail:(NSString *) errorCode des:(NSString *)des;
//请求主播列表成功
- (void)onfetchAnchorListSuccess:(NSArray<LiveUserModel *> *)dataArray;
//请求主播列表失败
- (void)onfetchAnchorListFail:(NSString *) errorCode des:(NSString *)des;
//请求用户详情成功
- (void)onfetchUserInfoSuccess:(LiveUserModel *)userModel;
//请求用户详情失败
- (void)onfetchUserInfoFail:(NSString *) errorCode des:(NSString *)des;
//请求创建房间成功
- (void)onfetchCreateRoomSuccess:(LiveRoomInfoModel *)roomModel;
//请求创建房间失败
- (void)onfetchCreateRoomFail:(NSString *) errorCode des:(NSString *)des;
//set chatId 失败
- (void)onfetchSetchatIdFail:(NSString *) errorCode des:(NSString *)des;
//get chatId 失败
- (void)onfetchGetchatIdFail:(NSString *) errorCode des:(NSString *)des;
//get chatId 成功
- (void)onfetchGetchatIdSuccess:(id)data;
//业务相关
//发送弹幕
- (void)didSendChatMessageWithAttributedString:(NSAttributedString *)string;
//发送广播弹幕消息
- (void)didsendBroadcastJsonString:(NSString *)string;
//显示连麦申请弹出框 成功
- (void)didShowApplayViewWithModel:(LiveUserModel *)model;
//显示连麦申请弹出框 失败
- (void)didShowApplayViewError:(NSString *)des;
//刷新禁言列表
- (void)didChangeAllMuteStatus;
//音频房连麦
- (void)didRefreshAudioLinkUserView;
//音频房全员开麦 闭麦
- (void)didChangeAllMircStatus:(BOOL)mircOff;
//音聊房断开连麦
- (void)didDisconnectWithUid:(NSString *)uid;
//将要展示跨房间PK主播的信息
- (void)didShowPKAnchor;
//音聊房刷新麦克风状态
- (void)didRefreshMircStatusWithUid:(NSString *)uid;
//刷新房间人数
- (void)refreshLiveRoomPeople:(NSInteger)count;
//更新成员列表
- (void)didRefreshUserListView;

@end

