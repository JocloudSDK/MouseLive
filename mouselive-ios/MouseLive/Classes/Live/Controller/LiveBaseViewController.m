//
//  LiveBaseViewController.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/4/27.
//  Copyright © 2020 sy. All rights reserved.
//

#import "LiveBaseViewController.h"
#import "BaseLiveContentView.h"
#import "FeedBackViewController.h"
#import "SYAppStatusManager.h"

@interface LiveBaseViewController ()<BaseLiveContentViewDelegate,UITextFieldDelegate,VideoOrAudioLiveViewProtocol, LiveManagerSignalDelegate,LiveManagerDelegate,SYAppStatusManagerDelegate>
@property (nonatomic, strong)SYAppStatusManager *appStatusManager;
@end

@implementation LiveBaseViewController

//初始化方法 如果不用Realm数据库 这里替换为自己维护的房间信息单例
- (instancetype)initWithRoomModel:(LiveUserListManager *)roomModel
{
    if (self = [super init]) {
        self.roomModel = roomModel;
        if ([roomModel.ROwner.Uid isEqualToString:LoginUserUidString]) {
            self.isAnchor = YES;
        }
        if (roomModel.RPublishMode == 1) {
            self.publishMode = PUBLISH_STREAM_RTC;
        } else if (roomModel.RPublishMode == 2) {
            self.publishMode = PUBLISH_STREAM_CDN;
        }
        LiveDefaultConfig *config = [[LiveDefaultConfig alloc]init];
        config.ownerRoomId = roomModel.RoomId;
        config.localUid = LoginUserUidString;
        config.anchroMainUid = roomModel.ROwner.Uid;
        config.anchroMainRoomId = roomModel.RoomId;
        self.config = config;
    }
    return self;
}

#pragma mark - Life cycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //不熄屏设置
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.liveManager addDelegate:self];
    [self.liveManager addSignalDelegate:self];
//    [self.appStatusManager addDelegate:self forKey:NSStringFromClass(self.class)];
    [self.appStatusManager stratMonitor];
    [self setup];
    if (self.isAnchor) {
        [self createChatRoom];
    } else {
        //观众进入房间
        [self audiencejoinRoom];
    }
}

//子类做UI的初始化操作
- (void)setup
{
    
}

#pragma mark -主播创建聊天室
- (void)createChatRoom
{
    [self.liveManager createChatRoomSuccess:^(NSString * _Nullable str) {
        [LiveUserListManager beginWriteTransaction];
        self.roomModel.RChatId = str;
        [LiveUserListManager commitWriteTransaction];
        [self.appStatusManager addDelegate:self forKey:NSStringFromClass(self.class)];
    } fail:^(NSError * _Nullable error) {
        [self quit];
        YYLogError(@"Hummer启动失败 %@",error);
    }];
}

#pragma mark -观众进入直播房间
- (void)audiencejoinRoom
{
    [self.liveManager joinChatRoomSuccess:nil fail:^(NSError * _Nullable error) {
        [MBProgressHUD yy_showError:@"进入聊天室失败，请尝试重新进入直播间" toView:self.view];
    }];
}

#pragma mark - 退出直播
- (void)quit
{
    //注销http代理
    [self.livePresenter detachView];
    [self.liveManager removeDelegate:self];
    [self.liveManager removeSignalDelegate:self];
    [self.appStatusManager removeDelegateForKey:NSStringFromClass(self.class)];
    YYLogDebug(@"[MouseLive LiveBaseViewController] quit");
    
}
#pragma mark- 同步mute admin信息
//获取mute信息
- (void)fetchUsersConfigs
{
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    for (LiveUserModel *user in [LiveUserListManager defaultManager].onlineUserList) {
        [tempArray addObject:user.Uid];
    }
    WeakSelf
    [self.liveManager fetchMuteStatusOfUsers:tempArray complete:^(NSArray<NSString *> * _Nullable muteUsers, NSError * _Nullable error) {
        if (!error) {
            for (NSString *uid in muteUsers) {
                [weakSelf.livePresenter muteUser:uid mute:YES];
            }
        }
        [weakSelf refreshBaseViewMutedStatus];
        [weakSelf fetchRoleUsers];
    }];
}

//更新底部禁言状态
- (void)refreshBaseViewMutedStatus
{
    LiveUserModel *localUser = [LiveUserListManager objectForPrimaryKey:LoginUserUidString];
    self.baseContentView.ismute = localUser.isMuted;
    NSString *para = localUser.isMuted ?@"自己已被禁言":@"自己未被禁言";
    YYLogFuncEntry([self class], _cmd, para);
}

//获取role信息
- (void)fetchRoleUsers
{
   NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    for (LiveUserModel *user in [LiveUserListManager defaultManager].onlineUserList) {
        [tempArray addObject:user.Uid];
    }
    WeakSelf
    [self.liveManager fetchAdminOfUsers:tempArray complete:^(NSArray<NSString *> * _Nullable admins, NSError * _Nullable error) {
        for (NSString *uid in admins) {
            [weakSelf.livePresenter adminUser:uid admin:YES];
        }
    }];
}
#pragma mark - UITextFieldDelegate 聊天
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (self.baseContentView.chatTextField.text.length == 0) {
        [textField resignFirstResponder];
    } else {
        [self.livePresenter willsendBroadcastMessage:textField.text];
        textField.text = nil;
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}


#pragma mark - BaseLiveContentViewDelegate
//反馈页面
- (void)feedbackButtonAction:(UIButton * _Nonnull)feedbackButton
{
    FeedBackViewController *vc = [[FeedBackViewController alloc]init];
    [vc setBackButton];
    [self.navigationController pushViewController:vc animated:YES];
}

//全员禁言
- (void)setRoomAllmuteStatus:(BOOL)isMuted button:(UIButton *)button
{
    WeakSelf
    [self.liveManager muteAllRemoteUser:isMuted complete:^(NSError * _Nullable error) {
        if (!error) {
            button.selected = !button.selected;
            [weakSelf.livePresenter willChangeAllMuteStatus:isMuted];
        }
    }];
}

- (void)unmuteRemoteUser:(LiveUserModel *)user
{
    WeakSelf
    [self.liveManager muteRemoteUser:user.Uid mute:NO complete:^(NSError * _Nullable error) {
        if (!error) {
            [weakSelf.livePresenter muteUser:user.Uid mute:NO];
        }
    }];
}

- (void)mutedRemoteUser:(LiveUserModel *)user
{
    WeakSelf
    [self.liveManager muteRemoteUser:user.Uid mute:YES complete:^(NSError * _Nullable error) {
        if (!error) {
            [weakSelf.livePresenter muteUser:user.Uid mute:YES];
        }
    }];
}
- (void)addAdminRemoteUser:(LiveUserModel *)user
{
    WeakSelf
    [self.liveManager setUserRole:user.Uid isAdmin:YES complete:^(NSError * _Nullable error) {
        if (!error) {
            [weakSelf.livePresenter adminUser:user.Uid admin:YES];
        }
    }];
    
}
- (void)removeAdminRemoteUser:(LiveUserModel *)user
{
    WeakSelf
    [self.liveManager setUserRole:user.Uid isAdmin:NO complete:^(NSError * _Nullable error) {
        if (!error) {
            [weakSelf.livePresenter adminUser:user.Uid admin:NO];
        }
    }];
}

- (void)kickOutRemoteUser:(LiveUserModel *)user
{
    WeakSelf
    [self.liveManager kickUserWithUid:user.Uid complete:^(NSError * _Nullable error) {
        if (!error) {
        [weakSelf.livePresenter kickOutUser:user.Uid];
        }
    }];
}

#pragma mark- VideoOrAudioLiveViewProtocol

- (void)onfetchCreateRoomFail:(NSString *) errorCode des:(NSString *)des
{
    YYLogDebug(@"主播创建聊天室失败%@",des);
    [MBProgressHUD yy_showError:des];
    [self quit];
}

//发弹幕消息
- (void)didSendChatMessageWithAttributedString:(NSAttributedString *)string
{
    [self.baseContentView.talkDataArray addObject: string];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.baseContentView refreshTalkPublicTabelView];
        NSString *para = string.string;
        YYLogFuncEntry([self class],_cmd,para);
    });
}
//发广播消息
- (void)didsendBroadcastJsonString:(NSString *)string
{
    [self.liveManager sendRoomMessage:string complete:^(NSError * _Nullable error) {
        if (!error) {
            NSString *param = [NSString stringWithFormat:@"发送消息成功 %@",string];
            YYLogFuncEntry([self class],_cmd,param);
        } else {
            NSString *param = [NSString stringWithFormat:@"发送消息失败 %@",string];
            YYLogFuncEntry([self class],_cmd,param);
        }
    }];
}

//显示连麦弹出框 失败
- (void)didShowApplayViewError:(NSString *)des
{
    [MBProgressHUD yy_showSuccess:@"用户不存在"];
    YYLogFuncEntry([self class],_cmd,des);
}

//显示连麦弹出框 成功
- (void)didShowApplayViewWithModel:(LiveUserModel *)model
{
    [self.baseContentView showMircApplay:model];
    YYLogFuncEntry([self class],_cmd,nil);
}

//刷新禁言列表
- (void)didChangeAllMuteStatus
{
    if (!self.baseContentView.userListViewIsHidden) {
     [self.baseContentView updateUserListViewStatus];
        NSString *para = @"全员禁言刷新观众列表";
        YYLogFuncEntry([self class],_cmd,para);
    }
    
}
//刷新成员列表
- (void)didRefreshUserListView
{
    if (!self.baseContentView.userListViewIsHidden) {
        [self.baseContentView updateUserListViewStatus];
        NSString *para = @"刷新观众列表";
        YYLogFuncEntry([self class],_cmd,para);
    }
}
#pragma mark - LiveManager Signal Delegate
//TODO:连续请求 第一个连麦后 取消所有的请求
- (void)liveManager:(LiveManager *)manager didBeInvitedBy:(NSString *)uid roomId:(NSString *)roomId
{
    [self.livePresenter willShowApplayViewWithUid:uid roomid:roomId];
}

- (void)liveManager:(LiveManager *)manager didInviteTimeoutBy:(NSString *)uid roomId:(NSString *)roomId
{
    [self.baseContentView updateLinkHudHiddenStatus:YES];
}

- (void)liveManager:(LiveManager *)manager didInviteCancelBy:(NSString *)uid roomId:(NSString *)roomId
{
    [self.baseContentView hiddenMircApplayWithUid:uid];
}

- (void)liveManager:(LiveManager *)manager didInviteRefuseBy:(NSString *)uid roomId:(NSString *)roomId
{
    //隐藏15s倒计时
    [self.baseContentView updateLinkHudHiddenStatus:YES];
    //主播拒绝了你的连麦申请
    [MBProgressHUD yy_showSuccess:NSLocalizedString(@"You're rejected by the owner.", nil)  toView:self.view];
}

- (void)liveManager:(LiveManager *)manager didInviteRunningBy:(NSString *)uid roomId:(NSString *)roomId
{
    //隐藏15s倒计时
       [self.baseContentView updateLinkHudHiddenStatus:YES];
    if (self.liveType == LiveTypeAudio) {
       [MBProgressHUD yy_showSuccess:NSLocalizedString(@"Seats are full.", nil)  toView:self.view];
    } else {
       [MBProgressHUD yy_showSuccess:NSLocalizedString(@"The remote user is not available for connection.", nil)  toView:self.view];
    }
}
//用户进入
- (void)liveManager:(LiveManager *)manager didUserJoin:(NSString *)uid
{
    [self.livePresenter willSendChatMessageWithUid:uid message:NSLocalizedString(@"joined", nil)];
}

//用户退出
- (void)liveManager:(LiveManager *)manager didUserLeave:(NSString *)uid
{
    //主播离开直播间
    if ([uid isEqualToString:self.roomModel.ROwner.Uid]) {
        [self quit];
    //房主直播已结束
     [MBProgressHUD yy_showSuccess:NSLocalizedString(@"Broadcast ended.", nil)];
    } else {
    //发弹幕
    [self.livePresenter willSendChatMessageWithUid:uid message:NSLocalizedString(@"left", nil)];
    }
}

//是否是全员禁言
- (void)liveManager:(LiveManager * _Nonnull)manager didRoomMuteStatusChanged:(BOOL)muted
{
    //更改数据
    [self.livePresenter willChangeAllMuteStatus:muted];
    //非主播全员禁言
    if (!self.isAnchor) {
        self.baseContentView.ismute = muted;
    }
}


//自己被踢出直播间
- (void)liveManagerDidSelfBeKicked:(LiveManager *)manager
{
    [MBProgressHUD yy_showSuccess:NSLocalizedString(@"You are kicked out", nil)];
    //退出直播间
    [self quit];
}

//其他人被踢出直播间
- (void)liveManager:(LiveManager * _Nonnull)manager didUserBeKicked:(NSString * _Nonnull)uid
{
    NSString *para = [NSString stringWithFormat:@"uid:%@被踢出",uid];
    YYLogFuncEntry([self class], _cmd, para);
    //发弹幕 更新数据 刷新人数
     [self.livePresenter willSendChatMessageWithUid:uid message:NSLocalizedString(@"is kicked", nil)];
}

/// 用户mute状态改变
- (void)liveManager:(LiveManager * _Nonnull)manager didUser:(NSString * _Nonnull)uid muteStatusChanged:(BOOL)muted
{
    
    if ([uid isEqualToString:LoginUserUidString]) {
        self.baseContentView.ismute = muted;
        NSString *paras = muted ? @"自己被禁言" : @"自己被解禁言";
        YYLogFuncEntry([self class], _cmd, paras);
    }
    //改变数据
    [self.livePresenter muteUser:uid mute:muted];
    //发弹幕
    [self.livePresenter willSendChatMessageWithUid:uid message:muted ? NSLocalizedString(@"is banned", nil) : NSLocalizedString(@"is unbanned",nil)];
}

/// 用户权限改变
- (void)liveManager:(LiveManager * _Nonnull)manager didUser:(NSString * _Nonnull)uid roleChanged:(BOOL)hasRole
{
    //改变数据
    [self.livePresenter adminUser:uid admin:hasRole];
    //发弹幕
    [self.livePresenter willSendChatMessageWithUid:uid message:hasRole ? NSLocalizedString(@"is admin now", nil): NSLocalizedString(@"is not admin now",  nil)];

}

/// 收到广播消息
- (void)liveManager:(LiveManager * _Nonnull)manager didReceivedRoomMessageFrom:(NSString * _Nonnull)uid message:(NSString * _Nonnull)message
{
    //发弹幕
    [self.livePresenter willSendChatMessageWithUid:uid message:message];
}

//网络正在连接中
- (void)liveManagerNetConnecting:(LiveManager *)manager
{
    [self.baseContentView showNetAlertView];
}

//网络已经连接成功
- (void)liveManagerDidNetConnected:(LiveManager *)manager
{
    [self.baseContentView hiddenNetAlertView];
}

//断网超过30s
- (void)liveManager:(LiveManager *)manager didNetError:(NSError *)error
{
    [self quit];
}

#pragma mark - SYAppStatusManagerDelegate
// enter backgroud & lock screen
- (void)SYAppWillResignActive:(nonnull SYAppStatusManager *)manager
{
    [self.livePresenter willsendBroadcastMessage:NSLocalizedString(@"Broadcaster will be right back.",@"【主播暂时离开一下下，很快回来哦！】")];

}

- (void)SYAppWillTerminate:(SYAppStatusManager *)manager {
    [self quit];
}

#pragma mark - LiveManager
- (LiveManager *)liveManager
{
    if (!_liveManager) {
        _liveManager = [LiveManager shareManager];
    }
    
    return _liveManager;
}

#pragma mark - VideoOrAudioPresenter
- (VideoOrAudioPresenter *)livePresenter
{
    if (!_livePresenter) {
        _livePresenter = [[VideoOrAudioPresenter alloc]initWithView:self];
    }
    return _livePresenter;
}

#pragma mark - SYAppStatusManager
- (SYAppStatusManager *)appStatusManager
{
    if (!_appStatusManager) {
        _appStatusManager = [SYAppStatusManager shareManager];
    }
    return _appStatusManager;
}
@end
