//
//  VideoPresenter.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/5/21.
//  Copyright © 2020 sy. All rights reserved.
//

#import "VideoOrAudioPresenter.h"
#import "UserManager.h"
//网络失败次数
static NSInteger createRoomRequstErrorCount = 1;
static NSInteger setChatIdRequstErrorCount  = 1;
static NSInteger getChatIdRequstErrorCount  = 1;

@interface VideoOrAudioPresenter()
@property (nonatomic, strong)NSMutableArray *requestIds;
@property (nonatomic, copy)NSString *ownerUid;//主播ID
@property (nonatomic, strong)NSDictionary *createRoomParams; //创建房间参数
@property (nonatomic, strong)NSDictionary *setChatIdParams;
@property (nonatomic, strong)NSDictionary *getChatIdParams;

@end

@implementation VideoOrAudioPresenter

- (void)cancelRequestWithRequestIDList
{
    [self.httpClient cancelRequestWithRequestIDList:self.requestIds];
}

- (void)fetchRoomInfoWithParam:(NSDictionary *)param
{
    NSString *requestId = [self.httpClient sy_httpRequestWithType:SYHttpRequestKeyType_RoomInfo params:param];
    [self.requestIds addObject:requestId];
}

- (void)fetchAnchorListWithParam:(NSDictionary *)param
{
    NSString *requestId = [self.httpClient sy_httpRequestWithType:SYHttpRequestKeyType_AnchorList params:param];
    [self.requestIds addObject:requestId];
}

- (void)fetchUserInfoDataWithUid:(NSString *)uid
{
    NSDictionary *parmas = @{kUid: uid};
    NSString *requestId = [self.httpClient sy_httpRequestWithType:SYHttpRequestKeyType_GetUserInfo params:parmas];
    [self.requestIds addObject:requestId];
}

- (void)fetchCreateRoomWithParams:(NSDictionary *)params
{
    self.createRoomParams = params;
    NSString *requestId = [self.httpClient sy_httpRequestWithType:SYHttpRequestKeyType_CreateRoom params:params];
    [self.requestIds addObject:requestId];
}

- (void)fetchSetchatIdWithParams:(NSDictionary *)params
{
    self.setChatIdParams = params;
    NSString *requestId = [self.httpClient sy_httpRequestWithType:SYHttpRequestKeyType_SetChatId params:params];
    [self.requestIds addObject:requestId];
}
- (void)fetchGetchatIdWithParams:(NSDictionary *)params
{
    self.getChatIdParams = params;
    NSString *requestId = [self.httpClient sy_httpRequestWithType:SYHttpRequestKeyType_GetChatId params:params];
    [self.requestIds addObject:requestId];
}

- (void)willSendChatMessageWithUid:(NSString *)uid message:(NSString *)msg
{
    
    //用户离开
    if ([msg isEqualToString:NSLocalizedString(@"left", nil)]) {
        [self handelUserLeaveWithUid:uid];
        
    } else if ([msg isEqualToString:NSLocalizedString(@"joined", nil)]) {
        //用户加入
        [self handelUserJoinWithUid:uid];
    } else if ([msg isEqualToString:NSLocalizedString(@"have a seat.", nil)]) {
        //音聊房人员连麦成功弹幕消息
        [self audioJoinSendMessageWithUid:uid];
        
    } else if ([msg isEqualToString:NSLocalizedString(@"left the seat.", nil)]) {
        //连麦者离开 还在房间
        [self audioLeaveSendMessageWithUid:uid];
    } else if ([msg isEqualToString:NSLocalizedString(@"is kicked", nil)]) {
        //踢出直播间
        [self handelUserKickedOutWithUid:uid];
    } else if ([msg isEqualToString:NSLocalizedString(@"is banned", nil)] || [msg isEqualToString: NSLocalizedString(@"is unbanned", nil)]) {
        //禁言 解禁言
        [self handelUserMutedWithUid:uid msg:msg];
    } else if ([msg isEqualToString:NSLocalizedString(@"is not admin now",  nil)] || [msg isEqualToString: NSLocalizedString(@"is admin now", nil)]) {
        //升管 降管
        [self handelUserRoleWithUid:uid msg:msg];
    } else {
        [self handelRemoteSendMessage:msg];
    }
}

//发送弹幕广播消息
- (void)willsendBroadcastMessage:(NSString *)msg
{
    LiveUserModel *user = [LiveUserListManager objectForPrimaryKey:LoginUserUidString];
    if (!user) {
        user = [UserManager shareManager].currentUser;
        [LiveUserListManager createOrUpdateOnLineUserWithModel:user];
    }
    NSString *type = @"Msg";
    if ([msg isEqualToString:NSLocalizedString(@"Broadcaster will be right back.",@"【主播暂时离开一下下，很快回来哦！】")]) {
        type = @"Notice";
    }
    NSDictionary *messageDict = @{
        @"NickName":user.NickName,
        @"Uid" :user.Uid,
        @"message":msg,
        @"type":type
    };
    NSMutableString *sendString = [[NSMutableString alloc]initWithString:[NSString yy_stringFromJsonObject:messageDict]];
    NSAttributedString *messageString = [self fectoryChatMessageWithMessageString:sendString isjoinOrLeave:NO];
    if ([_view respondsToSelector:@selector(didsendBroadcastJsonString:)]) {
        NSString *para = [NSString stringWithFormat:@"发送广播弹幕消息:%@",msg];
        YYLogFuncEntry([self class],_cmd,para);
        [_view didsendBroadcastJsonString:sendString];
    }
   
    if ([_view respondsToSelector:@selector(didSendChatMessageWithAttributedString:)]) {
        NSString *para = [NSString stringWithFormat:@"发送弹幕消息:%@",msg];
        YYLogFuncEntry([self class],_cmd,para);
        if (!([msg isEqualToString:NSLocalizedString(@"Broadcaster will be right back.",@"【主播暂时离开一下下，很快回来哦！】")] && [[LiveUserListManager defaultManager].ROwner.Uid isEqualToString:LoginUserUidString])) {
            [_view didSendChatMessageWithAttributedString:messageString];
        }
    }
}

- (void)willShowApplayViewWithUid:(NSString *)uid roomid:(NSString *)roomid
{
    LiveUserListManager *roomModel = [LiveUserListManager defaultManager];
    LiveUserModel *user = [LiveUserListManager objectForPrimaryKey:uid];
    //同房间 观众连麦
    if ([roomid isEqualToString:roomModel.RoomId]) {
        if (user) {
            if ([_view respondsToSelector:@selector(didShowApplayViewWithModel:)]) {
                [_view didShowApplayViewWithModel:user];
            }
            NSString *param = [NSString stringWithFormat:@"收到用户:%@连麦请求",uid];
            YYLogFuncEntry([self class],_cmd, param);
        } else {
            if ([_view respondsToSelector:@selector(didShowApplayViewError:)]) {
                [_view didShowApplayViewError:@"用户不存在"];
            }
            NSString *param = [NSString stringWithFormat:@"用户:%@不存在",uid];
            YYLogFuncEntry([self class],_cmd, param);
        }
    } else {
        // 如果不是自己的房间，就需要获取其他房间的用户信息
        NSString *requestId =  [self.httpClient sy_httpRequestWithType:SYHttpRequestKeyType_GetUserInfo params:@{kUid:@(uid.longLongValue)} success:^(NSString *taskId, id  _Nullable respObjc) {
            NSDictionary *respObj = (NSDictionary *)respObjc;
            NSString *code = [NSString stringWithFormat:@"%@",respObj[kCode]];
            if ([code isEqualToString:ksuccessCode]) {
                NSString *param = [NSString stringWithFormat:@"跨房间用户:uid:%@,roomId:%@ success",uid,roomid];
                YYLogFuncEntry([self class],_cmd, param);
                LiveUserModel *tempUser = [LiveUserModel mj_objectWithKeyValues:respObj[kData]];
                tempUser.isAnchor = YES;
                //存储连麦主播信息
                [LiveUserListManager beginWriteTransaction];
                [LiveUserListManager defaultManager].pkAnchor = tempUser;
                [LiveUserListManager defaultManager].pkAnchor.RoomId = roomid;
                [LiveUserListManager commitWriteTransaction];
                if ([self->_view respondsToSelector:@selector(didShowApplayViewWithModel:)]) {
                    
                    [self->_view didShowApplayViewWithModel:[LiveUserListManager defaultManager].pkAnchor];
                }
            } else {
                if ([self->_view respondsToSelector:@selector(didShowApplayViewError:)]) {
                    
                    [self->_view didShowApplayViewError:@"用户不存在"];
                }
                NSString *param = [NSString stringWithFormat:@"跨房间用户:uid:%@,roomId:%@ error:%@",uid,roomid,respObj[kMsg]];
                YYLogFuncEntry([self class],_cmd, param);
            }
        } failure:^(NSString *taskId, NSError *error) {
            if ([self->_view respondsToSelector:@selector(didShowApplayViewError:)]) {
                
                [self->_view didShowApplayViewError:@"用户不存在"];
            }
            NSString *param = [NSString stringWithFormat:@"跨房间用户:uid:%@,roomId:%@ error:%@",uid,roomid,error.domain];
            YYLogFuncEntry([self class],_cmd, param);
        }];
        [self.requestIds addObject:requestId];
    }
}

- (void)willChangeAllMuteStatus:(BOOL)ismute
{
    [LiveUserListManager allMuteStatus:ismute];
  
    if ([_view respondsToSelector:@selector(didChangeAllMuteStatus)]) {
        NSString *para = @"改变全员禁言状态";
        YYLogFuncEntry([self class], _cmd, para);
        [_view didChangeAllMuteStatus];
    }
    YYLogFuncEntry([self class],_cmd, nil);
}

- (void)muteUser:(NSString *)uid mute:(BOOL)ismute
{
    [LiveUserListManager muteOnlineUserWithUid:uid mute:ismute];
    //刷新成员列表
    if ([_view respondsToSelector:@selector(didRefreshUserListView)]) {
        NSString *para = [NSString stringWithFormat:@"改变用户%@禁言状态刷新观众列表",uid];
        YYLogFuncEntry([self class], _cmd, para);
        [_view didRefreshUserListView];
    }
    
}

- (void)adminUser:(NSString *)uid admin:(BOOL)isAdmin
{
    [LiveUserListManager adminOnlineUserWithUid:uid admin:isAdmin];
    //刷新成员列表
    if ([_view respondsToSelector:@selector(didRefreshUserListView)]) {
        NSString *para = [NSString stringWithFormat:@"改变用户%@管理员状态刷新观众列表",uid];
        YYLogFuncEntry([self class], _cmd, para);
          [_view didRefreshUserListView];
      }
}
- (void)kickOutUser:(NSString *)uid
{
    [LiveUserListManager deleteOnLineUserWithUid:uid];
    //刷新人数
    if ([_view respondsToSelector:@selector(refreshLiveRoomPeople:)]) {
        NSString *para = [NSString stringWithFormat:@"踢出用户%@刷新房间人数",uid];
        YYLogFuncEntry([self class], _cmd, para);
        [_view refreshLiveRoomPeople:[LiveUserListManager defaultManager].onlineUserList.count];
    }
    //刷新成员列表
    if ([_view respondsToSelector:@selector(didRefreshUserListView)]) {
        NSString *para = [NSString stringWithFormat:@"踢出用户%@刷新观众列表",uid];
        YYLogFuncEntry([self class], _cmd, para);
        [_view didRefreshUserListView];
      }
}

- (void)willLinkAudioWithUid:(NSString *)uid
{
    [LiveUserListManager linkWithUid:uid];
    if ([_view respondsToSelector:@selector(didRefreshAudioLinkUserView)]) {
        NSString *para = [NSString stringWithFormat:@"连麦用户%@",uid];
        YYLogFuncEntry([self class], _cmd, para);
        [_view didRefreshAudioLinkUserView];
    }
}

- (void)willDisconnectAudioWithUid:(NSString *)uid
{
    [LiveUserListManager disConnectWithUid:uid];
    if ([_view respondsToSelector:@selector(didDisconnectWithUid:)]) {
        [_view didDisconnectWithUid:uid];
        NSString *para = [NSString stringWithFormat:@"断开连麦用户%@",uid];
        YYLogFuncEntry([self class], _cmd, para);
    }
}

- (void)willShowPKAnchorWithUid:(NSString *)uid
{
    // 如果不是自己的房间，就需要获取其他房间的用户信息
    NSString *requestId =  [self.httpClient sy_httpRequestWithType:SYHttpRequestKeyType_GetUserInfo params:@{kUid:@(uid.longLongValue)} success:^(NSString *taskId, id  _Nullable respObjc) {
        NSDictionary *respObj = (NSDictionary *)respObjc;
        NSString *code = [NSString stringWithFormat:@"%@",respObj[kCode]];
        if ([code isEqualToString:ksuccessCode]) {
            NSString *param = [NSString stringWithFormat:@"跨房间用户:uid:%@, success",uid];
            YYLogFuncEntry([self class],_cmd, param);
            LiveUserModel *tempUser = [LiveUserModel mj_objectWithKeyValues:respObj[kData]];
            tempUser.isAnchor = YES;
            //存储连麦主播信息
            [LiveUserListManager beginWriteTransaction];
            [LiveUserListManager defaultManager].pkAnchor = tempUser;
            [LiveUserListManager commitWriteTransaction];
            if ([self->_view respondsToSelector:@selector(didShowPKAnchor)]) {
                
                [self->_view didShowPKAnchor];
            }
        } else {
            if ([self->_view respondsToSelector:@selector(didShowApplayViewError:)]) {
                
                [self->_view didShowApplayViewError:@"用户不存在"];
            }
            NSString *param = [NSString stringWithFormat:@"跨房间用户:uid:%@, error:%@",uid,respObj[kMsg]];
            YYLogFuncEntry([self class],_cmd, param);
        }
    } failure:^(NSString *taskId, NSError *error) {
        if ([self->_view respondsToSelector:@selector(didShowApplayViewError:)]) {
            
            [self->_view didShowApplayViewError:@"用户不存在"];
        }
        NSString *param = [NSString stringWithFormat:@"跨房间用户:uid:%@, error:%@",uid,error.domain];
        YYLogFuncEntry([self class],_cmd, param);
    }];
    [self.requestIds addObject:requestId];
}

- (void)enableMicWithUid:(NSString *)uid enable:(BOOL)enable
{
    [LiveUserListManager selfMircEnableWithUid:uid enable:enable];
    if ([_view respondsToSelector:@selector(didRefreshMircStatusWithUid:)]) {
        NSString *para = @"用户自己操作麦克风";
        YYLogFuncEntry([self class], _cmd, para);
        [_view didRefreshMircStatusWithUid:uid];
    }
}

- (void)beEnabledMicWithUid:(NSString *)uid byOther:(NSString * _Nonnull)otherUid enable:(BOOL)enable
{
    if ([uid isEqualToString:otherUid]) {
        [LiveUserListManager selfMircEnableWithUid:uid enable:enable];
    } else {
        [LiveUserListManager mircEnableWithUid:uid enable:enable];
    }
    if ([_view respondsToSelector:@selector(didRefreshMircStatusWithUid:)]) {
        NSString *para = [NSString stringWithFormat:@"改变用户%@麦克风状态刷新音聊房视图",uid];
        YYLogFuncEntry([self class], _cmd, para);
        [_view didRefreshMircStatusWithUid:uid];
    }
}

- (void)offAllRemoteUserMic:(BOOL)mircoff
{
    [LiveUserListManager allMircStatus:mircoff];
    //刷新音频房连麦者头像上麦克风的状态
    if ([_view respondsToSelector:@selector(didChangeAllMircStatus:)]) {
        NSString *para =[NSString stringWithFormat:@"%@,刷新全员头像上的麦克风状态和底部栏麦克风状态",mircoff ? @"全员闭麦":@"全员开麦"];
        YYLogFuncEntry([self class], _cmd, para);
        [_view didChangeAllMircStatus:mircoff];
    }
    
}
#pragma mark - SYHttpResponseHandle

- (void)onSuccess:(id)responseObject requestType:(SYHttpRequestKeyType)type
{
    if (type == SYHttpRequestKeyType_RoomInfo) {
        [self handelRoomInfoSuccessResponse:responseObject];
    } else if (type == SYHttpRequestKeyType_AnchorList) {
        [self handelAnchorListSuccessResponse:responseObject];
    } else if (type == SYHttpRequestKeyType_GetUserInfo) {
        [self handelUserInfoSuccessResponse:responseObject];
    } else if (type == SYHttpRequestKeyType_CreateRoom) {
        [self handelCreateRoomSuccessResponse:responseObject];
    } else if (type == SYHttpRequestKeyType_GetChatId) {
        [self handelGetChatIdSuccessResponse:responseObject];
    }
    
}

- (void)onFail:(id)clientInfo requestType:(SYHttpRequestKeyType)type error:(NSError *)error
{
    if (type == SYHttpRequestKeyType_RoomInfo) {
        NSString *param = [NSString stringWithFormat:@"GetRoomInfo error:%@",error.domain];
        YYLogFuncEntry([self class],_cmd, param);
        if ([_view respondsToSelector:@selector(onfetchRoomInfoFail:des:)]) {
            [_view onfetchRoomInfoFail:[NSString stringWithFormat:@"%ld",(long)error.code] des:error.domain];
        }
    } else if (type == SYHttpRequestKeyType_AnchorList) {
        NSString *param = [NSString stringWithFormat:@"AnchorList error:%@",error.domain];
        YYLogFuncEntry([self class],_cmd, param);
        if ([_view respondsToSelector:@selector(onfetchRoomInfoFail:des:)]) {
            [_view onfetchAnchorListFail:[NSString stringWithFormat:@"%ld",(long)error.code] des:error.domain];
        }
    } else if (type == SYHttpRequestKeyType_GetUserInfo) {
        NSString *param = [NSString stringWithFormat:@"GetUserInfo error:%@",error.domain];
        YYLogFuncEntry([self class],_cmd, param);
        if ([_view respondsToSelector:@selector(onfetchUserInfoFail:des:)]) {
            [_view onfetchUserInfoFail:[NSString stringWithFormat:@"%ld",(long)error.code] des:error.domain];
        }
    } else if (type == SYHttpRequestKeyType_CreateRoom) {
        if (createRoomRequstErrorCount < 3) {
            [self fetchCreateRoomWithParams:self.createRoomParams];
            createRoomRequstErrorCount += 1;
        } else {
            NSString *param = [NSString stringWithFormat:@"CreateRoom error:%@",error.domain];
            YYLogFuncEntry([self class],_cmd, param);
            
            if ([_view respondsToSelector:@selector(onfetchCreateRoomFail:des:)]) {
                [_view onfetchCreateRoomFail:[NSString stringWithFormat:@"%ld",(long)error.code] des:error.domain];
            }
        }
    } else if (type == SYHttpRequestKeyType_SetChatId) {
        if (setChatIdRequstErrorCount < 3) {
            [self fetchSetchatIdWithParams:self.setChatIdParams];
            setChatIdRequstErrorCount += 1;
        } else {
            NSString *param = [NSString stringWithFormat:@"SetChatId error:%@",error.domain];
            YYLogFuncEntry([self class],_cmd, param);
            YYLogFuncEntry([self class],_cmd, param);
            if ([_view respondsToSelector:@selector(onfetchSetchatIdFail:des:)]) {
                [_view onfetchSetchatIdFail:[NSString stringWithFormat:@"%ld",(long)error.code] des:error.domain];
            }
        }
    } else if (type == SYHttpRequestKeyType_GetChatId) {
        if (setChatIdRequstErrorCount < 3) {
            [self fetchSetchatIdWithParams:self.getChatIdParams];
            getChatIdRequstErrorCount += 1;
        } else {
            
            NSString *param = [NSString stringWithFormat:@"GetChatId error:%@",error.domain];
            YYLogFuncEntry([self class],_cmd, param);
            YYLogFuncEntry([self class],_cmd, param);
            if ([_view respondsToSelector:@selector(onfetchGetchatIdFail:des:)]) {
                [_view onfetchGetchatIdFail:[NSString stringWithFormat:@"%ld",(long)error.code] des:error.domain];
            }
        }
    }
}

//请求房间信息成功
- (void)handelRoomInfoSuccessResponse:(id)responseObject
{
    NSDictionary *respObjc = (NSDictionary *)responseObject;
    NSString *code = [NSString stringWithFormat:@"%@",respObjc[kCode]];
    if ([code isEqualToString:ksuccessCode]) {
        NSString *param = @"success";
        YYLogFuncEntry([self class],_cmd, param);
        //数据处理
        LiveRoomInfoModel *roomModel = [LiveRoomInfoModel mj_objectWithKeyValues:respObjc[kData][kRoomInfo]];
        [LiveUserListManager sy_ModelWithLiveRoomInfoModel:roomModel];
        
        for (NSDictionary *userDict in [respObjc objectForKey:kData][kUserList]) {
            LiveUserModel *user = [LiveUserListManager objectForPrimaryKey:[NSString stringWithFormat:@"%@",userDict[kUid]]];
            if (!user) {
                user = [LiveUserModel mj_objectWithKeyValues:userDict];
            } else {
                LiveUserModel *tempUser = [LiveUserModel mj_objectWithKeyValues:userDict];
                user.Cover = tempUser.Cover;
                user.LinkRoomId = tempUser.LinkRoomId;
                if ([LiveUserListManager defaultManager].allMircOff) {
                user.MicEnable = NO;
                } else {
                user.MicEnable = tempUser.MicEnable;
                }
                user.NickName = tempUser.NickName;
                user.SelfMicEnable = tempUser.SelfMicEnable;
                if ([user.Uid isEqualToString:roomModel.ROwner.Uid]) {
                    user.isAnchor = YES;
                }
            }
            //添加用户
            if ([[LiveUserListManager defaultManager].onlineUserList indexOfObject:user] == NSNotFound) {
                [LiveUserListManager createOrUpdateOnLineUserWithModel:user];
            }
        }
        
        
        if ([_view respondsToSelector:@selector(onfetchRoomInfoSuccess:)]) {
            [_view onfetchRoomInfoSuccess:roomModel];
        }
    } else {
        NSString *param = [NSString stringWithFormat:@"error:%@",respObjc[kMsg]];
        YYLogFuncEntry([self class],_cmd, param);
        if ([_view respondsToSelector:@selector(onfetchRoomInfoFail:des:)]) {
            [_view onfetchRoomInfoFail:code des:respObjc[kMsg]];
        }
    }
}

//请求主播pk列表成功
- (void)handelAnchorListSuccessResponse:(id)responseObject
{
    NSDictionary *respObjc = (NSDictionary *)responseObject;
    NSString *code = [NSString stringWithFormat:@"%@",respObjc[kCode]];
    
    if ([code isEqualToString:ksuccessCode]) {
        NSString *param = @"success";
        YYLogFuncEntry([self class],_cmd, param);
        NSMutableArray *temArray = [[NSMutableArray alloc]init];
        for (NSDictionary *anchorDict in [respObjc objectForKey:kData]) {
            //过滤掉主播自己
            if ([[LiveUserListManager defaultManager].ROwner.Uid isEqualToString:LoginUserUidString] && [[NSString stringWithFormat:@"%@",anchorDict[@"AId"]] isEqualToString:LoginUserUidString]) {
                continue;
            }
            NSMutableDictionary *temDict = [[NSMutableDictionary alloc]init];
            [temDict yy_setNotNullObject:anchorDict[@"ACover"] ForKey:kCover];
            [temDict yy_setNotNullObject:anchorDict[@"AId"] ForKey:kUid];
            [temDict yy_setNotNullObject:anchorDict[@"AName"] ForKey:kNickName];
            [temDict yy_setNotNullObject:anchorDict[@"ARoom"] ForKey:kRoomId];
            [temArray addObject:temDict];
        }
        NSArray *dataArray = [LiveUserModel mj_objectArrayWithKeyValuesArray:temArray];
        if ([_view respondsToSelector:@selector(onfetchAnchorListSuccess:)]) {
            [_view onfetchAnchorListSuccess:dataArray];
        }
    } else {
        NSString *param = [NSString stringWithFormat:@"error:%@",respObjc[kMsg]];
        YYLogFuncEntry([self class],_cmd, param);
        if ([_view respondsToSelector:@selector(onfetchAnchorListFail:des:)]) {
            [_view onfetchAnchorListFail:code des:respObjc[kMsg]];
        }
    }
}

//请求用户详情成功
- (void)handelUserInfoSuccessResponse:(id)responseObject
{
    NSDictionary *respObjc = (NSDictionary *)responseObject;
    NSString *code = [NSString stringWithFormat:@"%@",respObjc[kCode]];
    if ([code isEqualToString:ksuccessCode]) {
        NSString *param = @"success";
        YYLogFuncEntry([self class],_cmd, param);
        
        LiveUserModel *tempUser = [LiveUserModel mj_objectWithKeyValues:respObjc[kData]];
        
        LiveUserModel *user = [LiveUserListManager objectForPrimaryKey:tempUser.Uid];
        if (!user) {
            user = tempUser;
        } else {
            user.Cover = tempUser.Cover;
            user.NickName = tempUser.NickName;
            user.LinkUid = tempUser.LinkUid;
            user.LinkRoomId = tempUser.LinkRoomId;
            user.SelfMicEnable = tempUser.SelfMicEnable;
            user.MicEnable = tempUser.MicEnable;
        }
        [LiveUserListManager createOrUpdateOnLineUserWithModel:user];
        if ([_view respondsToSelector:@selector(onfetchUserInfoSuccess:)]) {
            [_view onfetchUserInfoSuccess:user];
        }
        
    } else {
        NSString *param = [NSString stringWithFormat:@"error:%@",respObjc[kMsg]];
        YYLogFuncEntry([self class],_cmd, param);
        if ([_view respondsToSelector:@selector(onfetchUserInfoFail:des:)]) {
            [_view onfetchUserInfoFail:code des:respObjc[kMsg]];
        }
    }
    
}

//创建房间成功
- (void)handelCreateRoomSuccessResponse:(id)responseObject
{
    NSDictionary *respObjc = (NSDictionary *)responseObject;
    NSString *code = [NSString stringWithFormat:@"%@",respObjc[kCode]];
    
    if ([code isEqualToString:ksuccessCode]) {
        NSString *param = @"success";
        YYLogFuncEntry([self class],_cmd, param);
        
        LiveRoomInfoModel *roomModel = [LiveRoomInfoModel mj_objectWithKeyValues:[respObjc objectForKey:kData]];
        [LiveUserListManager sy_ModelWithLiveRoomInfoModel:roomModel];
        
        if ([_view respondsToSelector:@selector(onfetchCreateRoomSuccess:)]) {
            [_view onfetchCreateRoomSuccess:roomModel];
        }
        
    } else {
        NSString *param = [NSString stringWithFormat:@"error:%@",respObjc[kMsg]];
        YYLogFuncEntry([self class],_cmd, param);
        
        if ([_view respondsToSelector:@selector(onfetchCreateRoomFail:des:)]) {
            [_view onfetchCreateRoomFail:code des:respObjc[kMsg]];
        }
        
    }
}

- (void)handelGetChatIdSuccessResponse:(id)responseObject
{
    NSDictionary *respObjc = (NSDictionary *)responseObject;
    NSString *code = [NSString stringWithFormat:@"%@",respObjc[kCode]];
    if ([code isEqualToString:ksuccessCode]) {
        NSString *param = @"success";
        YYLogFuncEntry([self class],_cmd, param);
        //数据存储
        id roomId = [respObjc objectForKey:@"RChatId"];
        [LiveUserListManager beginWriteTransaction];
        [LiveUserListManager defaultManager].RChatId = [NSString stringWithFormat:@"%@",roomId];
        [LiveUserListManager commitWriteTransaction];
        //刷新人数
        [self handelRoomPeopleCountWithRoomModel:[LiveUserListManager defaultManager]];
    } else {
        NSString *param = [NSString stringWithFormat:@"error:%@",respObjc[kMsg]];
        YYLogFuncEntry([self class],_cmd, param);
    }
}

//用户离开
- (void)handelUserLeaveWithUid:(NSString *)uid
{
    LiveUserModel *user = [LiveUserListManager objectForPrimaryKey:uid];
    if (!user) {
        NSString *param = [NSString stringWithFormat:@"error:用户%@不存在",uid];
        YYLogFuncEntry([self class],_cmd, param);
        return;
    }
    if ([self->_view respondsToSelector:@selector(didSendChatMessageWithAttributedString:)]) {
        NSDictionary *messageDict = @{
            @"NickName":user.NickName,
            @"Uid" :user.Uid,
            @"message":NSLocalizedString(@"left", nil) // @"离开"
        };
        NSAttributedString *messageString = [self fectoryChatMessageWithMessageString:[NSString yy_stringFromJsonObject:messageDict] isjoinOrLeave:YES];
        
        LiveUserListManager *roomModel = [LiveUserListManager defaultManager];
        LiveUserModel *leaveUser = [LiveUserListManager objectForPrimaryKey:uid];
        if (leaveUser) {
            //离开的用户为连麦用户
            //音频房
            [LiveUserListManager disConnectWithUid:uid];
            if ([_view respondsToSelector:@selector(didDisconnectWithUid:)]) {
                [_view didDisconnectWithUid:uid];
                NSString *para = [NSString stringWithFormat:@"断开连麦用户%@",uid];
                YYLogFuncEntry([self class], _cmd, para);
            }
            //用户表删除
            [LiveUserListManager deleteOnLineUserWithUid:uid];
            //刷新人数
            [self handelRoomPeopleCountWithRoomModel:roomModel];
            if ([self->_view respondsToSelector:@selector(didRefreshUserListView)]) {
                [self->_view didRefreshUserListView];
            }
            
        }
        
        [self->_view didSendChatMessageWithAttributedString:messageString];
    }
}

//用户加入
- (void)handelUserJoinWithUid:(NSString *)uid
{
    LiveUserListManager *roomModel = [LiveUserListManager defaultManager];
    LiveUserModel *user = [LiveUserListManager objectForPrimaryKey:uid];
    if (!user) {
        user = [[LiveUserModel alloc]init];
        user.Uid = uid;
        user.LinkUid = @"0";
        user.LinkRoomId = @"0";
    }
    if (!user.NickName) {
        NSString *requestId =  [self.httpClient sy_httpRequestWithType:SYHttpRequestKeyType_GetUserInfo params:@{kUid:@(uid.longLongValue)} success:^(NSString *taskId, id  _Nullable respObjc) {
            NSDictionary *respObj = (NSDictionary *)respObjc;
            NSString *code = [NSString stringWithFormat:@"%@",respObj[kCode]];
            if ([code isEqualToString:ksuccessCode]) {
                LiveUserModel *tempUser = [LiveUserModel mj_objectWithKeyValues:respObj[kData]];
                user.Cover = tempUser.Cover;
                user.LinkRoomId = tempUser.LinkRoomId;
                user.NickName = tempUser.NickName;
                if ([user.Uid isEqualToString:[LiveUserListManager defaultManager].ROwner.Uid]) {
                    user.isAnchor = YES;
                }
                //更新数据 添加到online表中
                [LiveUserListManager createOrUpdateOnLineUserWithModel:user];
                
                //刷新人数
                if ([self->_view respondsToSelector:@selector(refreshLiveRoomPeople:)]) {
                    NSUInteger count = roomModel.onlineUserList.count;
                    [self->_view refreshLiveRoomPeople:count];
                }
                //刷新成员列表
                if ([self->_view respondsToSelector:@selector(didRefreshUserListView)]) {
                    [self->_view didRefreshUserListView];
                }
                if ([self->_view respondsToSelector:@selector(didSendChatMessageWithAttributedString:)]) {
                    NSDictionary *messageDict = @{
                        @"NickName":tempUser.NickName,
                        @"Uid" :tempUser.Uid,
                        @"message":NSLocalizedString(@"joined", nil) // @"离开"
                    };
                    NSAttributedString *messageString = [self fectoryChatMessageWithMessageString:[NSString yy_stringFromJsonObject:messageDict] isjoinOrLeave:YES];
                    [self->_view didSendChatMessageWithAttributedString:messageString];
                }
            } else {
                NSString *param = [NSString stringWithFormat:@"error:%@",respObj[kMsg]];
                YYLogFuncEntry([self class],_cmd, param);
                
            }
        } failure:^(NSString *taskId, NSError *error) {
            NSString *param = [NSString stringWithFormat:@"error:%@",error.domain];
            YYLogFuncEntry([self class],_cmd, param);
            
        }];
        [self.requestIds addObject:requestId];
    } else {
        //添加到online表中
        [LiveUserListManager createOrUpdateOnLineUserWithModel:user];
        //刷新人数
        if ([_view respondsToSelector:@selector(refreshLiveRoomPeople:)]) {
            NSUInteger count = roomModel.onlineUserList.count;
            [_view refreshLiveRoomPeople:count];
        }
        //刷新成员列表
        if ([self->_view respondsToSelector:@selector(didRefreshUserListView)]) {
            [self->_view didRefreshUserListView];
        }
        //用户表中已经存过此用户 只是在offline表中
        if ([self->_view respondsToSelector:@selector(didSendChatMessageWithAttributedString:)]) {
            NSDictionary *messageDict = @{
                @"NickName":user.NickName,
                @"Uid" :user.Uid,
                @"message":NSLocalizedString(@"joined", nil) // @"离开"
            };
            NSAttributedString *messageString = [self fectoryChatMessageWithMessageString:[NSString yy_stringFromJsonObject:messageDict] isjoinOrLeave:YES];
            [self->_view didSendChatMessageWithAttributedString:messageString];
        }
    }
}

//连麦者离开 还在房间
- (void)audioLeaveSendMessageWithUid:(NSString *)uid
{
    //音聊房发弹幕消息 不存在跨房间
    LiveUserModel *userModel = [LiveUserListManager objectForPrimaryKey:uid];
    NSDictionary *messageDict = @{
        @"NickName":userModel.NickName,
        @"Uid" :userModel.Uid,
        @"message":NSLocalizedString(@"left the seat.", nil),
        @"type":@"Notice"
    };
    NSAttributedString *messageString = [self fectoryChatMessageWithMessageString:[NSString yy_stringFromJsonObject:messageDict] isjoinOrLeave:NO];
    if ([self->_view respondsToSelector:@selector(didSendChatMessageWithAttributedString:)]) {
        
        [self->_view didSendChatMessageWithAttributedString:messageString];
    }
    NSString *param = @"success";
    YYLogFuncEntry([self class],_cmd, param);
    
}

//音聊房人员连麦成功弹幕消息
- (void)audioJoinSendMessageWithUid:(NSString *)uid;
{
    LiveUserModel *user = [LiveUserListManager objectForPrimaryKey:uid];
    if (!user) {
        user = [[LiveUserModel alloc]init];
        user.Uid = uid;
        user.LinkUid = @"0";
        user.LinkRoomId = @"0";
        [LiveUserListManager createOrUpdateOnLineUserWithModel:user];
    }
    if (!user.NickName) {
        NSString *requestId = [self.httpClient sy_httpRequestWithType:SYHttpRequestKeyType_GetUserInfo params:@{kUid:uid} success:^(NSString *taskId, id  _Nullable respObjc) {
            NSDictionary *respObj = (NSDictionary *)respObjc;
            NSString *code = [NSString stringWithFormat:@"%@",respObj[kCode]];
            if ([code isEqualToString:ksuccessCode]) {
                
                
                LiveUserModel *tempUser = [LiveUserModel mj_objectWithKeyValues:respObj];
                user.Cover = tempUser.Cover;
                user.LinkRoomId = tempUser.LinkRoomId;
                user.MicEnable = tempUser.MicEnable;
                user.NickName = tempUser.NickName;
                user.SelfMicEnable = tempUser.SelfMicEnable;
                if ([user.Uid isEqualToString:[LiveUserListManager defaultManager].ROwner.Uid]) {
                    user.isAnchor = YES;
                }
                //更新数据
                [LiveUserListManager createOrUpdateOnLineUserWithModel:user];
                if ([self->_view respondsToSelector:@selector(didSendChatMessageWithAttributedString:)]) {
                    NSDictionary *messageDict = @{
                        @"NickName":user.NickName,
                        @"Uid" :user.Uid,
                        @"message":NSLocalizedString(@"have a seat.", nil),
                        @"type": @"Notice"
                    };
                    NSAttributedString *messageString = [self fectoryChatMessageWithMessageString:[NSString yy_stringFromJsonObject:messageDict] isjoinOrLeave:NO];
                    [self->_view didSendChatMessageWithAttributedString:messageString];
                }
            } else {
                NSString *param = [NSString stringWithFormat:@"error:%@",respObj[kMsg]];
                YYLogFuncEntry([self class],_cmd, param);
                
            }
        } failure:^(NSString *taskId, NSError *error) {
            NSString *param = [NSString stringWithFormat:@"error:%@",error.domain];
            YYLogFuncEntry([self class],_cmd, param);
        }];
        [self.requestIds addObject:requestId];
    } else {
        NSDictionary *messageDict = @{
            @"NickName":user.NickName,
            @"Uid" :user.Uid,
            @"message":NSLocalizedString(@"have a seat.", nil),
            @"type": @"Notice"
        };
        NSAttributedString *messageString = [self fectoryChatMessageWithMessageString:[NSString yy_stringFromJsonObject:messageDict] isjoinOrLeave:NO];
        [self->_view didSendChatMessageWithAttributedString:messageString];
    }
}

- (void)handelUserKickedOutWithUid:(NSString *)uid
{
  LiveUserModel *user = [LiveUserListManager objectForPrimaryKey:uid];
    if (!user) {
        NSString *param = [NSString stringWithFormat:@"error:用户%@不存在",uid];
        YYLogFuncEntry([self class],_cmd, param);
        return;
        
    }
    if ([self->_view respondsToSelector:@selector(didSendChatMessageWithAttributedString:)]) {
        NSDictionary *messageDict = @{
            @"NickName":user.NickName,
            @"Uid" :user.Uid,
            @"message":NSLocalizedString(@"is kicked", nil), // @"离开"
            @"type":@"Notice"
        };
        NSAttributedString *messageString = [self fectoryChatMessageWithMessageString:[NSString yy_stringFromJsonObject:messageDict] isjoinOrLeave:NO];
        
        LiveUserListManager *roomModel = [LiveUserListManager defaultManager];
        if ([LiveUserListManager objectForPrimaryKey:uid]) {
            //用户表删除
            [LiveUserListManager deleteOnLineUserWithUid:uid];
            //刷新人数
            [self handelRoomPeopleCountWithRoomModel:roomModel];
        }
        
        [self->_view didSendChatMessageWithAttributedString:messageString];
    }
}

- (void)handelUserMutedWithUid:(NSString *)uid msg:(NSString *)msg
{
  LiveUserModel *user = [LiveUserListManager objectForPrimaryKey:uid];
    if (!user) {
        NSString *param = [NSString stringWithFormat:@"error:用户%@不存在",uid];
        YYLogFuncEntry([self class],_cmd, param);
        return;
    }
    if ([self->_view respondsToSelector:@selector(didSendChatMessageWithAttributedString:)]) {
        NSDictionary *messageDict = @{
            @"NickName": user.NickName,
            @"Uid" : user.Uid,
            @"message":msg ,// @"被禁言" : @"被解禁",
            @"type":@"Notice"
        };
        NSAttributedString *messageString = [self fectoryChatMessageWithMessageString:[NSString yy_stringFromJsonObject:messageDict] isjoinOrLeave:NO];
        [self->_view didSendChatMessageWithAttributedString:messageString];
    }
}
- (void)handelUserRoleWithUid:(NSString *)uid msg:(NSString *)msg
{
  LiveUserModel *user = [LiveUserListManager objectForPrimaryKey:uid];
    if (!user) {
        NSString *param = [NSString stringWithFormat:@"error:用户%@不存在",uid];
        YYLogFuncEntry([self class],_cmd, param);
        return;
    }
    if ([self->_view respondsToSelector:@selector(didSendChatMessageWithAttributedString:)]) {
        NSDictionary *messageDict = @{
            @"NickName": user.NickName,
            @"Uid" : user.Uid,
            @"message":msg ,// @"被提升为管理员" : @"被降管",
            @"type":@"Notice"
        };
        NSAttributedString *messageString = [self fectoryChatMessageWithMessageString:[NSString yy_stringFromJsonObject:messageDict] isjoinOrLeave:NO];
        [self->_view didSendChatMessageWithAttributedString:messageString];
    }
}

//处理远端消息
- (void)handelRemoteSendMessage:(NSString *)msg
{
    NSAttributedString *messageString = [self fectoryChatMessageWithMessageString:msg isjoinOrLeave:NO];
    [self->_view didSendChatMessageWithAttributedString:messageString];
}

- (void)handelRoomPeopleCountWithRoomModel:(LiveUserListManager *)roomModel
{
    if ([_view respondsToSelector:@selector(refreshLiveRoomPeople:)]) {
        NSUInteger count = roomModel.onlineUserList.count;
        
        [_view refreshLiveRoomPeople:count];
    }
    YYLogFuncEntry([self class],_cmd, nil);
    
}
#pragma mark- 弹幕消息封装
/**
 1：msg 人黄，字白（自己+主播全黄色 ）
 2：主播通知 黄字
 3：进出房间 人白 字白
 4：顶部通知 白字
 */
- (NSAttributedString *)fectoryChatMessageWithMessageString:(NSString *)message isjoinOrLeave:(BOOL)state
{
    LiveUserListManager *roomModel = [LiveUserListManager defaultManager];
    self.ownerUid = roomModel.ROwner.Uid;
    NSDictionary *messageDict = [message yy_jsonObjectFromString];
    NSString *messageType = [messageDict objectForKey:@"type"];
    
    //黄色名字(人员进入退出白色) 自己发的显示 我：xx
    NSAttributedString *nameString = [[NSAttributedString alloc]initWithString:[[messageDict objectForKey:kUid] isEqualToString:LoginUserUidString] ? NSLocalizedString(@"Talk_Me", nil):[NSString stringWithFormat:@"%@   ",[messageDict objectForKey:kNickName]] attributes:@{NSForegroundColorAttributeName:state ? [UIColor whiteColor] : [UIColor sl_colorWithHexString:@"#FFDA81"]}];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithAttributedString:nameString];
    if ([messageType isEqualToString:@"Notice"] && [[messageDict objectForKey:kUid] isEqualToString:self.ownerUid]) {
        //系统消息不用拼接姓名
        attributedString = [[NSMutableAttributedString alloc]init];
    }
    UIColor *messageTextColor = [UIColor whiteColor];
    
    if ([messageType isEqualToString:@"Msg"]) {
        //自己发言或者是主播发言橙色突出字体
        if ([[messageDict objectForKey:kUid] isEqualToString:LoginUserUidString] || [[messageDict objectForKey:kUid] isEqualToString:self.ownerUid]) {
            messageTextColor = [UIColor sl_colorWithHexString:@"#FFDA81"];
            
        } else {
            //其他人 黄+白
            messageTextColor = [UIColor whiteColor];
        }
    } else if ([messageType isEqualToString:@"Notice"]) {
        //主播通知 黄色字体
        messageTextColor = [UIColor sl_colorWithHexString:@"#FFDA81"];
        
    }
    
    if (state) {
        messageTextColor = [UIColor whiteColor];
    }
    
    NSAttributedString *messageString = [[NSAttributedString alloc]initWithString:[messageDict objectForKey:kmessage] attributes:@{NSForegroundColorAttributeName:messageTextColor}];
    [attributedString appendAttributedString:messageString];
    [attributedString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]} range:NSMakeRange(0, attributedString.mutableString.length)];
    return [[NSAttributedString alloc]initWithAttributedString:attributedString];
}

@end
