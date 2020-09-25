//
//  LiveUserListManager.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/5/12.
//  Copyright © 2020 sy. All rights reserved.
//

#import "LiveUserModel.h"
#import "LiveRoomInfoModel.h"

@interface LiveUserListManager : NSObject
@property (nonatomic, copy) NSString *AppId;
@property (nonatomic, copy) NSString *RoomId;
@property (nonatomic, copy) NSString *RName;
@property (nonatomic, assign) BOOL RLiving;
@property (nonatomic, assign) LiveType RType;
@property (nonatomic, assign) QulityLevel RLevel;
@property (nonatomic, copy) NSString *RCover;
@property (nonatomic, copy) NSString *RCount;
@property (nonatomic, copy) NSString *RChatId;
@property (nonatomic, copy) NSString *RNotice;
@property (nonatomic, copy) NSString *CreateTm;
/**静音状态 true麦克风开启状态 false 麦克风关闭状态*/
@property (nonatomic, assign) BOOL allMute;
@property (nonatomic, assign) BOOL allMircOff;  // 房间是否全部禁麦/开麦
@property (nonatomic, strong) LiveUserModel *ROwner;
@property (nonatomic, strong) LiveUserModel *pkAnchor;//pk的其它主播
// 1 RTC模式 2 CDN模式（RTMP一对多）
@property (nonatomic, assign) NSInteger RPublishMode;

@property (nonatomic, copy) NSString *RDownStream;//拉流地址
@property (nonatomic, copy) NSString *RUpStream; //推流地址
//在线用户
@property (nonatomic, strong, readonly)NSArray *onlineUserList;
//离线用户
@property (nonatomic, strong, readonly)NSArray *offlineUserList;
//返回单例
+ (instancetype)defaultManager;
//房间是否可用
+ (BOOL)isAvailable;
//模型转换
+ (LiveUserListManager *)sy_ModelWithLiveRoomInfoModel:(LiveRoomInfoModel *)model;
//开始修改
+ (void)beginWriteTransaction;
//提交修改
+ (void)commitWriteTransaction;
//查询
+ (LiveUserModel *)objectForPrimaryKey:(NSString *)uid;
//新增或更新在线用户
+ (LiveUserModel *)createOrUpdateOnLineUserWithModel:(LiveUserModel *)model;
//新增或更新在线用户
+ (void)createOrUpdateOnLineUserWithArray:(NSArray <LiveUserModel *> *)users;
//管理员
+ (void)adminOnlineUserWithUid:(NSString *)uid admin:(BOOL)isAdmin;
//禁言
+ (void)muteOnlineUserWithUid:(NSString *)uid mute:(BOOL)ismute;
//音频房和某人连麦
+ (void)linkWithUid:(NSString *)uid;
//音聊房断开连麦
+ (void)disConnectWithUid:(NSString *)uid;
//主播或者管理员操作闭麦开麦
+ (void)mircEnableWithUid:(NSString *)uid enable:(BOOL)enable;
//自己操作闭麦开麦
+ (void)selfMircEnableWithUid:(NSString *)uid enable:(BOOL)enable;
//删除在线用户(删除的用户暂存在offline中)
+ (void)deleteOnLineUserWithUid:(NSString *)uid;
//全员禁麦 开麦
+ (void)allMircStatus:(BOOL)mircoff;
//全员 禁言 解禁言
+ (void)allMuteStatus:(BOOL)mute;
//清空房间
+ (void)clearLiveRoom;

@end

