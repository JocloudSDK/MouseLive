//
//  AudioViewController.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/4/27.
//  Copyright © 2020 sy. All rights reserved.
//

#import "AudioViewController.h"
#import "AudioContentView.h"
#import "BaseLiveContentView.h"

@interface AudioViewController ()<BaseLiveContentViewDelegate,AudioContentViewDelegate,VideoOrAudioLiveViewProtocol,SYThunderDelegate,LiveManagerSignalDelegate,LiveManagerDelegate,AudioLiveBottonToolViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong)AudioContentView *audioContentView;

@end

@implementation AudioViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self cofigAudioRoom];
}

- (LiveType)liveType
{
    return LiveTypeAudio;
}

#pragma mark - 麦克风控制

- (void)setup
{
    [super setup];
    //添加背景
    self.view.layer.contents = (id)[UIImage imageNamed:@"bg_color.png"].CGImage;
    self.audioContentView = [[AudioContentView alloc]initWithRoomId:self.roomModel.RoomId];
    [self.view addSubview:self.audioContentView];
    [self.audioContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    //设置代理
    self.audioContentView.delegate = self;
    self.audioContentView.baseDelegate = self;
    
    self.baseContentView = self.audioContentView.baseContentView;
    self.baseContentView.chatTextField.delegate = self;
}

- (void)cofigAudioRoom
{
    [self.liveManager addThunderDelegate:self];
    [self.liveManager joinMediaRoom:self.config.ownerRoomId uid:self.config.localUid roomType:LiveTypeAudio];
    [self startUpLive];
}

- (void)startUpLive
{
    LiveUserModel *localUser = [LiveUserListManager objectForPrimaryKey:LoginUserUidString];
    if (localUser) {
        if (!([localUser.LinkUid isEqualToString:@"0"]&& [localUser.LinkRoomId isEqualToString:@"0"])) {
          //自己正在连麦中
            [self refreshToolViewWithLocalRuningMirc:YES mircEnable:localUser.MicEnable];
        }else {
          //自己未连麦主播
            if (!self.isAnchor) {
                [self refreshToolViewWithLocalRuningMirc:NO mircEnable:localUser.MicEnable];
            }
        }
    } else {
        //初始化时自己还未加入房间
        [self refreshToolViewWithLocalRuningMirc:NO mircEnable:YES];
    }

    //刷新音聊房头像
    [self.audioContentView refreshCollectionView];
    //显示码率
    [self.baseContentView showCodeView];
}

#pragma mark - 退出直播
- (void)quit
{
    NSString *param1 = @"quit start";
    YYLogFuncEntry([self class], _cmd, param1);
    //取消代理
    [super quit];
    LiveUserModel *localUser = [LiveUserListManager objectForPrimaryKey:LoginUserUidString];
    //自己如果正在连麦中 先断开连麦
    if (![localUser.LinkUid isEqualToString:@"0"] && ![localUser.LinkRoomId isEqualToString:@"0"] && !self.isAnchor) {
        [self.liveManager hungupWithUser:self.roomModel.ROwner.Uid roomId:self.roomModel.ROwner.RoomId complete:nil];
    }
    
    [self.baseContentView stopTimer];
    
    //关闭音乐 变声恢复初始状态
    [self.liveManager closeAuidoFile];
    [self.liveManager leaveRoom];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyChangeWhineView object:@"YES"];
    //删除房间数据
    [LiveUserListManager clearLiveRoom];
    if (self.isResponsBackblock) {
           self.backBlock();
           YYLogDebug(@"[MouseLive-VideoViewController] quit backBlock");
       } else {
           [self.navigationController popViewControllerAnimated:NO];
           YYLogDebug(@"[MouseLive-VideoViewController] quit popViewControllerAnimated");
       }
       YYLogDebug(@"[MouseLive-VideoViewController] quit exit");
    NSString *param = @"quit exit";
    YYLogFuncEntry([self class], _cmd, param);
    
}

//刷新房间人数
- (void)refreshPeopleCount
{
    self.audioContentView.peopleCount = self.roomModel.onlineUserList.count;
}

- (void)refreshAudioCollectionView
{
    [self.audioContentView refreshCollectionView];
}
//更新连麦者底部栏
- (void)refreshToolViewWithLocalRuningMirc:(BOOL)localRuningMirc mircEnable:(BOOL)enabel
{
    self.baseContentView.mircEnable = enabel;
    self.baseContentView.localRuningMirc = localRuningMirc;
    [self.baseContentView refreshBottomToolView];
    [self.audioContentView updateLinkMircButtonSelectedStatus:localRuningMirc];
}
#pragma mark - LiveManager Signal Delegate
//主播能收到
- (void)liveManager:(LiveManager *)manager didBeInvitedBy:(NSString *)uid roomId:(NSString *)roomId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Uid != %@ AND LinkUid != %@ AND LinkRoomId != %@", self.roomModel.ROwner.Uid,@"0",@"0"];

    NSArray *filteredArray = [self.roomModel.onlineUserList filteredArrayUsingPredicate:predicate];
                              
    if (filteredArray.count < 8) {
        [self.livePresenter willShowApplayViewWithUid:uid roomid:roomId];
        NSString *paras = [NSString stringWithFormat:@"显示%@连麦弹出申请框",uid];
        YYLogFuncEntry([self class], _cmd, paras);
    } else {
        //取消其它任务请求
        [self.liveManager clearBeInvitedQueue];
        NSString *paras = [NSString stringWithFormat:@"取消和%@连麦弹出申请框",uid];
        YYLogFuncEntry([self class], _cmd, paras);
    }
}

//主播同意连麦 连麦者能收到
- (void)liveManager:(LiveManager *)manager didInviteAcceptBy:(NSString *)uid roomId:(NSString *)roomId
{
    //隐藏15s倒计时
    [self.baseContentView updateLinkHudHiddenStatus:YES];
    //更新连麦者底部栏
    [self.livePresenter willLinkAudioWithUid:LoginUserUidString];
  
}

//广播 连麦者和观众都能收到
- (void)liveManager:(LiveManager * _Nonnull)manager anchorConnectedWith:(NSString * _Nonnull)uid roomId:(NSString * _Nonnull)roomId
{
    //更新数据
    [self.livePresenter willLinkAudioWithUid:uid];
    //发弹幕
    [self.livePresenter willSendChatMessageWithUid:uid message:NSLocalizedString(@"have a seat.", nil)];
}

//广播 主播和观众都能收到 或 连麦者和观众都能收到 
- (void)liveManager:(LiveManager * _Nonnull)manager anchorDisconnectedWith:(NSString * _Nonnull)uid roomId:(NSString * _Nonnull)roomId
{
    //更新数据
    [self.livePresenter willDisconnectAudioWithUid:uid];
    //发弹幕
    [self.livePresenter willSendChatMessageWithUid:uid message:NSLocalizedString(@"left the seat.", nil)];
    
}
//挂断连麦者 单播
- (void)liveManager:(LiveManager *)manager didReceiveHungupRequestFrom:(NSString *)uid roomId:(NSString *)roomId
{
    //连麦者收到主播挂断的单播
    if (!self.isAnchor) {
        //关闭连麦者远端流
        [self.liveManager enableLocalAudio:NO];
        //更新连麦者底部栏
        [self refreshToolViewWithLocalRuningMirc:NO mircEnable:YES];
        NSString *para = @"关闭连麦者远端流 更新连麦者底部栏";
        YYLogFuncEntry([self class], _cmd, para);
    }
}

/// 用户麦克风状态被某人改变 主播自己改变麦克风 主播收不到
- (void)liveManager:(LiveManager * _Nonnull)manager didUserMicStatusChanged:(NSString * _Nonnull)uid byOther:(NSString * _Nonnull)otherUid status:(BOOL)status
{
    //改变数据 回调中更新视图
    [self.livePresenter beEnabledMicWithUid:uid byOther:otherUid enable:status];
    //自己被主播关闭麦克风
    if ([uid isEqualToString:LoginUserUidString]) {
        //关闭本地音频推流
        [self.liveManager enableLocalAudio:status];
        NSString *para = status ? @"自己被关闭麦克风": @"自己被打开麦克风";
        YYLogFuncEntry([self class], _cmd, para);
        //更新底部工具栏
        [self refreshToolViewWithLocalRuningMirc:YES mircEnable:status];
    }
}

/// 房间mic状态改变 都能收到 首次进入房间不一定能收到回调
- (void)liveManager:(LiveManager * _Nonnull)manager didRoomMicStatusChanged:(BOOL)micOn
{
    //改变数据 更新视图
    [self.livePresenter offAllRemoteUserMic:!micOn];
    NSString *para = micOn ?@"全员开麦" :@"全员闭麦";
    YYLogFuncEntry([self class], _cmd, para);
}

#pragma mark - BaseLiveContentViewDelegate
//控制码率显示 隐藏
- (void)refreshCodeViewHiddenStatus:(BOOL)selecte
{
    if (selecte) {
        //隐藏码率
        [self.baseContentView hiddenCodeView];
    } else {
        //非主播显示自己的码率
        [self.baseContentView showCodeView];
    }
}

//开启或关闭麦克风
- (void)refreshMicButtonStatus:(UIButton * _Nonnull)mircButton
{
    WeakSelf
    // 设置是自己关麦的
    if (mircButton.selected) {
        [self.liveManager enableMicWithUid:LoginUserUidString enable:NO complete:^(NSError * _Nullable error) {
            if (!error) {
                [weakSelf closeLocalMirc];
                //更新数据
                [weakSelf.livePresenter enableMicWithUid:LoginUserUidString enable:NO];
            } else {
                mircButton.selected = NO;
                [weakSelf openLocalMirc];
            }
        }];
    }
    else {
        [self.liveManager enableMicWithUid:LoginUserUidString enable:YES complete:^(NSError * _Nullable error) {
            if (!error) {
                [weakSelf openLocalMirc];
                //更新数据
                [weakSelf.livePresenter enableMicWithUid:LoginUserUidString enable:YES];
            } else {
                mircButton.selected = YES;
                [weakSelf closeLocalMirc];

            }
        }];
    }
    NSString *param = [NSString stringWithFormat:@"自己关麦 status:%d",!mircButton.selected];
    YYLogFuncEntry([self class], _cmd, param);
}

//闭麦 开麦 下麦
- (void)mircManagerActionWithModel:(LiveUserModel *)userMode mircType:(ManagementUserType)type
{
    WeakSelf
    NSString *uid = userMode.Uid;
    switch (type) {
        case ManagementUserTypeCloseMirc: {//闭麦

            [self.liveManager enableMicWithUid:uid enable:NO complete:^(NSError * _Nullable error) {
                if (!error) {
                    //改变数据
                    [weakSelf.livePresenter beEnabledMicWithUid:uid byOther:self.roomModel.ROwner.Uid enable:NO];
                    NSString *param = [NSString stringWithFormat:@"uid:%@ success",uid];
                    YYLogFuncEntry([self class], _cmd, param);
                } else {
                    [MBProgressHUD yy_showError:@"闭麦操作失败" toView:self.view];
                    NSString *param = [NSString stringWithFormat:@"uid:%@ error:%@",uid,error];
                    YYLogFuncEntry([self class], _cmd, param);
                }
            }];
        }
            break;
        case ManagementUserTypeOpenMirc: {// 开麦

            [self.liveManager enableMicWithUid:uid enable:YES complete:^(NSError * _Nullable error) {
                if (!error) {
                    //改变数据
                    [weakSelf.livePresenter beEnabledMicWithUid:uid byOther:self.roomModel.ROwner.Uid enable:YES];
                    NSString *param = [NSString stringWithFormat:@"uid:%@ success",uid];
                    YYLogFuncEntry([self class], _cmd, param);
                    
                } else {
                    [MBProgressHUD yy_showError:@"开麦操作失败" toView:self.view];
                    NSString *param = [NSString stringWithFormat:@"uid:%@ error:%@",uid,error];
                    YYLogFuncEntry([self class], _cmd, param);
                }
            }];
        }
            break;
        case ManagementUserTypeDownMirc: {//下麦

            [self.liveManager hungupWithUser:uid roomId:self.config.ownerRoomId complete:^(NSError * _Nullable error) {
                if (!error) {
                    //刷新数据
                    [weakSelf.livePresenter willDisconnectAudioWithUid:uid];
                    //主播端发弹幕
                    [self.livePresenter willSendChatMessageWithUid:uid message:NSLocalizedString(@"left the seat.", nil)];
                }
            }];
        }
            break;
        default:
            break;
    }
    
}

//主播同意连麦
- (void)acceptLinkMircWithUid:(NSString *)uid roomId:(NSString * _Nonnull)roomId
{
    WeakSelf
    [self.liveManager acceptConnectWithUser:uid complete:^(NSError * _Nullable error) {
        if (!error) {
            //刷新音频视图
            [weakSelf.livePresenter willLinkAudioWithUid:uid];
            //主播弹幕
            [self.livePresenter willSendChatMessageWithUid:uid message:NSLocalizedString(@"have a seat.", nil)];
            NSString *param = [NSString stringWithFormat:@"同意连麦用户 Uid:%@",uid];
            YYLogFuncEntry([self class], _cmd, param);
        } else {
            [MBProgressHUD yy_showError:error.domain];
            NSString *param = [NSString stringWithFormat:@"同意连麦用户 error:%@",error];
            
            YYLogFuncEntry([self class], _cmd, param);
        }
    }];
}

//主播拒绝连麦
- (void)refuseLinkMircWithUid:(NSString *)uid
{
    [self.liveManager refuseConnectWithUser:uid complete:^(NSError * _Nullable error) {
        if (!error) {
            NSString *param = [NSString stringWithFormat:@"断开连麦 uid:%@",uid];
            YYLogFuncEntry([self class], _cmd, param);
        } else {
            NSString *param = [NSString stringWithFormat:@"断开连麦 uid:%@,error:%@",uid,error];
            YYLogFuncEntry([self class], _cmd, param);
        }
    }];
}

#pragma mark- AudioContentViewDelegate

//关闭直播间
- (void)audioLiveCloseRoom
{
    NSString *param = @"start";
    YYLogFuncEntry([self class], _cmd, param);
    
    [self quit];
    NSString *param1 = @"exit";
    YYLogFuncEntry([self class], _cmd, param1);
}

//打开观众列表
- (void)audioLiveOpenUserList
{
    NSDictionary *params = @{
        kUid:@(LoginUserUidString.integerValue),
        kRoomId:@(self.roomModel.RoomId.integerValue),
        kRType:@(self.roomModel.RType),
    };
    //请求观众列表
    [self.livePresenter fetchRoomInfoWithParam:params];
    self.baseContentView.userListViewIsHidden = NO;
    [self.baseContentView updateUserListViewStatus];
    YYLogFuncEntry([self class], _cmd, nil);
}

//上麦
- (void)audioConnectAnchor
{
    //显示倒计时
    [self.baseContentView updateLinkHudHiddenStatus:NO];
    [self.liveManager applyConnectToUser:self.config.anchroMainUid roomId:self.config.anchroMainRoomId complete:^(NSError * _Nullable error) {
    }];
    YYLogFuncEntry([self class], _cmd, nil);
}

//下麦
- (void)audioDisconnectAnchor
{
    
    WeakSelf
    //关闭本地流
    [self.liveManager enableLocalAudio:NO];
    [self.liveManager hungupWithUser:self.roomModel.ROwner.Uid roomId:self.roomModel.ROwner.RoomId complete:^(NSError * _Nullable error) {
        if (!error) {
            //更新数据
            [weakSelf.livePresenter willDisconnectAudioWithUid:LoginUserUidString];
            //发弹幕
            [weakSelf.livePresenter willSendChatMessageWithUid:LoginUserUidString message:NSLocalizedString(@"left the seat.", nil)];
            //更新底部栏
            LiveUserModel *localUser = [LiveUserListManager objectForPrimaryKey:LoginUserUidString];
            [weakSelf refreshToolViewWithLocalRuningMirc:NO mircEnable:localUser.MicEnable];
        }
    }];
    YYLogFuncEntry([self class], _cmd, nil);
    
}

//变声事件
- (void)audioWhineButtonAction
{
    [self.audioContentView updateWhineViewHiddenStatus:NO];
    NSString *param = @"打开变声";
    YYLogFuncEntry([self class], _cmd, param);
}

//播放音乐
- (void)audioManagerMusicPlay:(BOOL)play
{
    //音乐播放
    if (play) {
        [self.liveManager resumeAudioFile];
    } else {
        //暂停bo
        [self.liveManager pauseAudioFile];
    }
    NSString *param = play ? @"播放音乐" :@"暂停音乐";
    YYLogFuncEntry([self class], _cmd, param);
}

//全员闭麦
- (void)audioManagerMircStatus:(UIButton *)sender
{
    WeakSelf
    [self.liveManager offAllRemoteUserMic:sender.selected complete:^(NSError * _Nullable error) {
        if (error) {
            sender.selected = !sender.selected;
            [weakSelf.livePresenter offAllRemoteUserMic:sender.selected];
        }
    }];
}
#pragma mark - AudioLiveBottonToolViewDelegate

- (void)openLocalMirc
{
    //开启远端流
    [self.liveManager offLocalMic:NO];
    NSString *para = @"开启远端流";
    YYLogFuncEntry([self class], _cmd, para);
}

- (void)closeLocalMirc
{
    [self.liveManager offLocalMic:YES];
    NSString *para = @"关闭远端流";
    YYLogFuncEntry([self class], _cmd, para);
}

#pragma mark- VideoOrAudioLiveViewProtocol
//刷新房间人数
- (void)refreshLiveRoomPeople:(NSInteger)count
{
    self.audioContentView.peopleCount = count;
    
}

- (void)onfetchRoomInfoSuccess:(LiveRoomInfoModel *)roomModel
{
    //刷新用户列表
    [self.baseContentView updateUserListViewStatus];
}

- (void)onfetchRoomInfoFail:(NSString *)errorCode des:(NSString *)des
{
    [MBProgressHUD yy_showError:des toView:self.view];
}
//有人连麦 刷新视图
- (void)didRefreshAudioLinkUserView
{
    [self.audioContentView refreshCollectionView];
    LiveUserModel *localUser = [LiveUserListManager objectForPrimaryKey:LoginUserUidString];
    if (localUser.LinkUid.length && ![localUser.LinkUid isEqualToString:@"0"]) {
        [self refreshToolViewWithLocalRuningMirc:YES mircEnable:localUser.MicEnable];
    }
    NSString *para = @"连麦用户";
    YYLogFuncEntry([self class], _cmd, para);
}

//有人下麦 刷新视图
- (void)didDisconnectWithUid:(NSString *)uid
{
    [self.audioContentView refreshCollectionView];
}

//刷新麦克风状态
- (void)didRefreshMircStatusWithUid:(NSString *)uid
{
    [self.audioContentView refreshOnlineUserMircStatusWithUid:uid];
    NSString *para = [NSString stringWithFormat:@"改变用户%@麦克风状态刷新音聊房视图",uid];
    YYLogFuncEntry([self class], _cmd, para);
    
}

//全员闭麦开麦
- (void)didChangeAllMircStatus:(BOOL)mircOff
{
    [self.audioContentView refreshCollectionView];
    //刷新连麦者的 底部栏
    LiveUserModel *localUser = [LiveUserListManager objectForPrimaryKey:LoginUserUidString];
    if (localUser.LinkUid.length && ![localUser.LinkUid isEqualToString:@"0"]) {
        [self refreshToolViewWithLocalRuningMirc:YES mircEnable:!mircOff];
        NSString *para =[NSString stringWithFormat:@"更新底部栏麦克风状态%@",mircOff ? @"全员闭麦":@"全员开麦"];
        YYLogFuncEntry([self class], _cmd, para);
    }
    
}

#pragma mark - LiveManager Delegate
//ws 启动成功 获取最新的 roominfo
- (void)liveManagerDidNetConnected:(LiveManager * _Nonnull)manager
{
    //隐藏网络弹框
    [super liveManagerDidNetConnected:manager];
    WeakSelf
    [self.liveManager getRoomInfo:self.roomModel.RoomId Type:LiveTypeVideo success:^(LiveRoomInfoModel * _Nullable roomInfo, NSArray<LiveUserModel *> * _Nullable userList) {
        [LiveUserListManager sy_ModelWithLiveRoomInfoModel:roomInfo];
        [LiveUserListManager createOrUpdateOnLineUserWithArray:userList];
        //配置用户信息
        [weakSelf fetchUsersConfigs];
        [weakSelf startUpLive];
        //刷新人数
        [weakSelf refreshPeopleCount];
        
    } fail:^(NSError * _Nullable error) {
        //房间已经不存在了
        if (error.code == 5042) {
            [weakSelf quit];
        }
        YYLogError(@"[MouseLive VideoViewController] liveManagerDidNetConnected  getRoomInfo error:%@",error);
    }];
    
}

#pragma mark - Thunder Delegate

//- (void)thunderEngine:(ThunderEngine * _Nonnull)engine
//onPlayVolumeIndication:(NSArray<ThunderRtcAudioVolumeInfo *> * _Nonnull)speakers
//          totalVolume:(NSInteger)totalVolume{
//    for (ThunderRtcAudioVolumeInfo *infoModel in speakers) {
//        [self.audioContentView refreshOnlineUserMircStatusWithUid:infoModel.uid];
//    }
//}

- (void) thunderEngine:(ThunderEngine *)engine onJoinRoomSuccess:(NSString *)room withUid:(NSString *)uid elapsed:(NSInteger)elapsed
{
    [self.liveManager enableRemoteAudioStream:YES];
    if (self.isAnchor) {
        [self.liveManager enableLocalAudio:YES];
    }
}
//上下行码率
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine networkQualityStatus:(nonnull NetworkQualityStauts *)networkQualityStatus
{
    
    self.baseContentView.qualityModel.audioDownload = networkQualityStatus.audioDownload;
    self.baseContentView.qualityModel.videoUpload = networkQualityStatus.videoUpload;
    self.baseContentView.qualityModel.videoDownload = networkQualityStatus.videoDownload;
    self.baseContentView.qualityModel.upload = networkQualityStatus.upload;
    self.baseContentView.qualityModel.download = networkQualityStatus.download;
    self.baseContentView.qualityModel.isShowCodeDetail = YES;
    [self.baseContentView refreshCodeView];
}

//网络质量
- (void)thunderEngine:(ThunderEngine *)engine onNetworkQuality:(NSString *)uid txQuality:(ThunderLiveRtcNetworkQuality)txQuality rxQuality:(ThunderLiveRtcNetworkQuality)rxQuality
{
    self.baseContentView.qualityModel.netWorkQuality.uploadNetQuality = txQuality;
    self.baseContentView.qualityModel.netWorkQuality.downloadNetQuality = rxQuality;
    [self.baseContentView refreshCodeView];
}

@end
