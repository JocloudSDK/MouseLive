//
//  LiveUserListManager.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/5/12.
//  Copyright © 2020 sy. All rights reserved.
//

#import "LiveUserListManager.h"
#import "LiveRoomInfoModel.h"

@interface LiveUserListManager()
//线程安全锁
@property (nonatomic, strong)NSLock *lock;
//在线用户
@property (nonatomic, strong)NSMutableDictionary *onlineUsers;
//离线用户
@property (nonatomic, strong)NSMutableDictionary *offlineUsers;
@end
@implementation LiveUserListManager

+ (instancetype)defaultManager
{
    static dispatch_once_t onceToken;
    static LiveUserListManager *room = nil;
    dispatch_once(&onceToken, ^{
        room = [[[self class] alloc] init];
        room.lock = [[NSLock alloc]init];
        room.onlineUsers = [[NSMutableDictionary alloc]init];
        room.offlineUsers = [[NSMutableDictionary alloc]init];
    });
    return room;
}

+ (BOOL)isAvailable
{
    BOOL ret = YES;
    [LiveUserListManager beginWriteTransaction];
    ret = [LiveUserListManager defaultManager].RoomId.length ? YES : NO;
    [LiveUserListManager commitWriteTransaction];
    return ret;
}

+ (LiveUserListManager *)sy_ModelWithLiveRoomInfoModel:(LiveRoomInfoModel *)model
{
    
    LiveUserListManager *room = [LiveUserListManager defaultManager];
    [LiveUserListManager beginWriteTransaction];
    room.AppId = model.AppId;
    room.RoomId = model.RoomId;
    room.RName = model.RName;
    room.RLiving = model.RLiving;
    room.RType= model.RType;
    room.RLevel= model.RLevel;
    room.RCover= model.RCover;
    room.RCount= model.RCount;
    room.RChatId= model.RChatId;
    room.RNotice= model.RNotice;
    room.CreateTm= model.CreateTm;
    room.ROwner = model.ROwner;
    room.ROwner.RoomId = room.RoomId;
    room.ROwner.isAnchor = YES;
    room.RPublishMode= model.RPublishMode;
    room.RDownStream= model.RDownStream;
    room.RUpStream= room.RUpStream ? room.RUpStream : model.RUpStream;
    [room.onlineUsers yy_setNotNullObject:room.ROwner ForKey:room.ROwner.Uid];
    [LiveUserListManager commitWriteTransaction];
    return room;
}

+ (void)beginWriteTransaction
{
    //加锁
    [[LiveUserListManager defaultManager].lock lock];
    
}

+ (void)commitWriteTransaction
{
    //解锁
    [[LiveUserListManager defaultManager].lock unlock];
}

- (NSArray *)onlineUserList
{
    if (![LiveUserListManager isAvailable]) {
        return nil;
    }
    NSArray *array = nil;
    [LiveUserListManager  beginWriteTransaction];
    array = [[LiveUserListManager defaultManager].onlineUsers allValues];
    [LiveUserListManager commitWriteTransaction];
    return array;
}

- (NSArray *)offlineUserList
{
    if (![LiveUserListManager isAvailable]) {
        return nil;
    }
    NSArray *array = nil;
    [LiveUserListManager  beginWriteTransaction];
    array = [[LiveUserListManager defaultManager].offlineUsers allValues];
    [LiveUserListManager commitWriteTransaction];
    return array;
}

+ (LiveUserModel *)objectForPrimaryKey:(NSString *)uid
{
    if (![LiveUserListManager isAvailable]) {
        return nil;
    }
    [LiveUserListManager beginWriteTransaction];
    LiveUserModel *user = [[LiveUserListManager defaultManager].offlineUsers objectForKey:uid];
    if (!user) {
        user = [[LiveUserListManager defaultManager].onlineUsers objectForKey:uid];
    }
    [LiveUserListManager commitWriteTransaction];
    return user;
}
//新增或更新在线用户
+ (LiveUserModel *)createOrUpdateOnLineUserWithModel:(LiveUserModel *)model
{
    if (![LiveUserListManager isAvailable]) {
        return nil;
    }
    [LiveUserListManager beginWriteTransaction];
    LiveUserModel *user = [[LiveUserListManager defaultManager].offlineUsers objectForKey:model.Uid];
    if (!user) {
        user = [[LiveUserListManager defaultManager].onlineUsers objectForKey:model.Uid];
        if (user) {
            //更新
            user = [LiveUserListManager updateUser:user WithModel:model];
            NSString *para = [NSString stringWithFormat:@"更新用户UID%@ nickName:%@信息",user.Uid,user.NickName];
            YYLogFuncEntry([self class], _cmd, para);
        } else {
            //新增
            user = model;
            user.RoomId = [LiveUserListManager defaultManager].RoomId;
            if ([LiveUserListManager defaultManager].allMute) {
                user.isMuted = YES;
            }
            user.MicEnable = ![LiveUserListManager defaultManager].allMircOff;
            user.SelfMicEnable = YES;
            [[LiveUserListManager defaultManager].onlineUsers yy_setNotNullObject:user ForKey:model.Uid];
            NSString *para = [NSString stringWithFormat:@"新增用户UID%@ nickName:%@加入聊天室",user.Uid,user.NickName];
            YYLogFuncEntry([self class], _cmd, para);
        }
    } else {
        //更新
        user = [LiveUserListManager updateUser:user WithModel:model];
        [[LiveUserListManager defaultManager].onlineUsers yy_setNotNullObject:user ForKey:model.Uid];
        NSString *para = [NSString stringWithFormat:@"离线用户UID%@ nickName:%@加入聊天室",user.Uid,user.NickName];
        YYLogFuncEntry([self class], _cmd, para);
        [[LiveUserListManager defaultManager].offlineUsers removeObjectForKey:model.Uid];
    }
    [LiveUserListManager commitWriteTransaction];
    return user;
}

+ (LiveUserModel *)updateUser:(LiveUserModel *)user WithModel:(LiveUserModel *)model
{
    user.NickName = model.NickName;
    user.Cover = model.Cover;
    user.RoomId = [LiveUserListManager defaultManager].RoomId;
    if ([user.Uid isEqualToString:[LiveUserListManager defaultManager].ROwner.Uid]) {
        user.isAnchor = YES;
    } else {
        user.isAnchor = model.isAnchor;
    }
    user.LinkUid = model.LinkUid;
    user.LinkRoomId = model.LinkRoomId;
    user.MicEnable = model.MicEnable;
    user.MicEnable = ![LiveUserListManager defaultManager].allMircOff;
    user.SelfMicEnable = model.SelfMicEnable;
    
    user.AnchorLocalLock = model.AnchorLocalLock;
    user.isMuted = model.isMuted;
    if ([LiveUserListManager defaultManager].allMute) {
        user.isMuted = YES;
    }
    user.isSpeaking = model.isSpeaking;
    return user;
}

//新增或更新在线用户
+ (void)createOrUpdateOnLineUserWithArray:(NSArray <LiveUserModel *> *)users
{
    if (![LiveUserListManager isAvailable]) {
        return;
    }
    for (LiveUserModel *model in users) {
        [LiveUserListManager createOrUpdateOnLineUserWithModel:model];
    }
}

+ (void)adminOnlineUserWithUid:(NSString *)uid admin:(BOOL)isAdmin
{
    [LiveUserListManager beginWriteTransaction];
    LiveUserModel *model = [[LiveUserListManager defaultManager].onlineUsers objectForKey:uid];
    model.isAdmin = isAdmin;
    [LiveUserListManager commitWriteTransaction];
}

+ (void)muteOnlineUserWithUid:(NSString *)uid mute:(BOOL)ismute
{
    [LiveUserListManager beginWriteTransaction];
    LiveUserModel *model = [[LiveUserListManager defaultManager].onlineUsers objectForKey:uid];
    model.isMuted = ismute;
    [LiveUserListManager commitWriteTransaction];
}

+ (void)linkWithUid:(NSString *)uid
{
    [LiveUserListManager beginWriteTransaction];
    LiveUserModel *model = [[LiveUserListManager defaultManager].onlineUsers objectForKey:uid];
    model.LinkUid =  [LiveUserListManager defaultManager].ROwner.Uid;
    model.LinkRoomId = [LiveUserListManager defaultManager].RoomId;
    model.MicEnable = ![LiveUserListManager defaultManager].allMircOff;
    [LiveUserListManager commitWriteTransaction];
}

+ (void)disConnectWithUid:(NSString *)uid
{
    [LiveUserListManager beginWriteTransaction];
    LiveUserModel *model = [[LiveUserListManager defaultManager].onlineUsers objectForKey:uid];
    model.LinkUid =  @"0";
    model.LinkRoomId = @"0";
    model.MicEnable = model.MicEnable;
    model.SelfMicEnable = YES;
    [LiveUserListManager commitWriteTransaction];
}

+ (void)mircEnableWithUid:(NSString *)uid enable:(BOOL)enable
{
    [LiveUserListManager beginWriteTransaction];
    LiveUserModel *model = [[LiveUserListManager defaultManager].onlineUsers objectForKey:uid];
    model.MicEnable = enable;
    model.SelfMicEnable = YES;
    [LiveUserListManager commitWriteTransaction];
}

+ (void)selfMircEnableWithUid:(NSString *)uid enable:(BOOL)enable
{
    [LiveUserListManager beginWriteTransaction];
    LiveUserModel *model = [[LiveUserListManager defaultManager].onlineUsers objectForKey:uid];
//    model.MicEnable = ![LiveUserListManager defaultManager].allMircOff;
    model.SelfMicEnable = enable;
    [LiveUserListManager commitWriteTransaction];
}

//删除在线用户(删除的用户暂存在offline中)
+ (void)deleteOnLineUserWithUid:(NSString *)uid
{
    if (![LiveUserListManager isAvailable]) {
        return ;
    }
    [LiveUserListManager beginWriteTransaction];
    LiveUserModel *user = [[LiveUserListManager defaultManager].onlineUsers objectForKey:uid];
    if (user) {
        [[LiveUserListManager defaultManager].onlineUsers removeObjectForKey:uid];
        [[LiveUserListManager defaultManager].offlineUsers yy_setNotNullObject:user ForKey:uid];
    }
    [LiveUserListManager commitWriteTransaction];
}

+ (void)allMuteStatus:(BOOL)mute
{
    [LiveUserListManager beginWriteTransaction];
    [LiveUserListManager defaultManager].allMute = mute;
    for (LiveUserModel *model in [LiveUserListManager defaultManager].onlineUsers.allValues) {
        if (!model.isAnchor) {
            //非主播全员禁言
            model.isMuted = mute;
        }
    }
    [LiveUserListManager commitWriteTransaction];
}

+ (void)allMircStatus:(BOOL)mircoff
{
    [LiveUserListManager beginWriteTransaction];
    [LiveUserListManager defaultManager].allMircOff = mircoff;
    for (LiveUserModel *model in [LiveUserListManager defaultManager].onlineUsers.allValues) {
        model.MicEnable = !mircoff;
    }
    [LiveUserListManager commitWriteTransaction];
}
+ (void)clearLiveRoom
{
    if (![LiveUserListManager isAvailable]) {
        return ;
    }
    LiveUserListManager *room = [LiveUserListManager defaultManager];
    [LiveUserListManager beginWriteTransaction];
    room.AppId = nil;
    room.RoomId = nil;
    room.RName = nil;
    room.RLiving = NO;
    room.RType= nil;
    room.RLevel= nil;
    room.RCover= nil;
    room.RCount= nil;
    room.RChatId= nil;
    room.RNotice= nil;
    room.CreateTm= nil;
    room.allMircOff = NO;
    room.allMute = NO;
    room.ROwner = nil;
    room.RPublishMode = 0;
    room.RDownStream= nil;
    room.RUpStream= nil;
    [room.onlineUsers removeAllObjects];
    [room.offlineUsers removeAllObjects];
    [LiveUserListManager commitWriteTransaction];
}
@end
