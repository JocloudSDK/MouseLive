//
//  VideoViewController.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/4/27.
//  Copyright © 2020 sy. All rights reserved.
//

#import "VideoViewController.h"
#import "VideoViewController+SYAddEffect.h"
#import "VideoContentView.h"
#import "SYPlayer.h"
#import "SYHummerManager.h"
#import "SYThunderManagerNew.h"
#import "SYThunderEvent.h"
#import "LivePresenter.h"

@interface VideoViewController()<LiveBGDelegate,LiveProtocol,UITextFieldDelegate,SYHummerManagerObserver,SYPlayerDelegate,UIGestureRecognizerDelegate,VideoContentViewDelegate,BaseLiveContentViewDelegate
#if USE_BEATIFY
,ThunderVideoCaptureFrameObserver, SYEffectViewDelegate>
#else
>
#endif

@property (nonatomic, strong) VideoContentView *videoContentView;

@property (nonatomic, strong)SYEffectView *effectView;

@property(nonatomic, strong)  SYPlayer *player;

@property(nonatomic, assign)  BOOL isFrontCamera;

@property(nonatomic, assign)  BOOL isMirror;
//当前正在连麦的观众
@property(nonatomic, copy) NSString *currentVideoMircUid;
//当前正在连麦房间
@property(nonatomic, copy) NSString *currentVideoMircRoomId;

@end

@implementation VideoViewController

- (LiveType)liveType
{
    return LiveTypeVideo;
}

//初始化UI
- (void)setup
{
    [super setup];
    self.isFrontCamera = YES;
    self.isMirror = NO;
    if (self.publishMode == PUBLISH_STREAM_CDN) {
        self.url = self.liveRoomInfo.RDownStream;
        UIView *view = [[UIView alloc]initWithFrame:self.view.bounds];
        
        self.player = [[SYPlayer alloc]initPlayerWirhUrl:self.url view:view delegate:self];
        
        [self.view addSubview:view];
    }
    self.videoContentView = [[VideoContentView alloc]initWithRoomId:self.roomModel.RoomId];
    [self.view addSubview:self.videoContentView];
    [self.videoContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [self.view bringSubviewToFront:self.videoContentView];
    
    self.videoContentView.publishMode = self.publishMode;
    //设置代理
    self.videoContentView.delegate = self;
    self.videoContentView.baseDelegate = self;
    
    self.baseContentView = self.videoContentView.baseContentView;
    self.baseContentView.chatTextField.delegate = self;
    
}

//配置语音房开播信息
- (void)cofigVideoRoom
{
#if USE_REALM
    //根据成员列表刷新主播头像
    [self.videoContentView refreshAnchorView];
    if (self.isAnchor) {
        //主播
        if (self.publishMode == PUBLISH_STREAM_CDN) {
            [self.liveBG joinRoomWithConfig:self.config pushUrl:self.roomModel.RUpStream];
        } else {
            [self.liveBG joinRoomWithConfig:self.config pushUrl:nil];
        }
    } else {
        //观众
        if (self.publishMode == PUBLISH_STREAM_CDN) {
            [self.player start];
        } else if (self.publishMode == PUBLISH_STREAM_RTC) {
            [self startUpLive];
            if ([SYHummerManager sharedManager].isAllMuted) {
                self.baseContentView.ismute = YES;
            }
        }
    }
#endif
}

//观众进入房间同步房间当前状态
- (void)startUpLive
{
    RLMLiveUserModel *roomOwner = [self.roomModel.userList objectsWhere:@"Uid == %@",self.roomModel.ROwner.Uid].lastObject;
    if (![roomOwner.LinkUid isEqualToString:@"0"] && ![roomOwner.LinkRoomId isEqualToString:@"0"]) {
        //设置底部工具栏  自己不可以连麦
        self.baseContentView.mircEnable = NO;
        self.baseContentView.localRuningMirc = NO;
        [self.baseContentView refreshBottonToolView];
        self.config.anchroSecondUid = roomOwner.LinkUid;
        self.config.anchroSecondRoomId = roomOwner.LinkRoomId;
        [self.liveBG joinRoomWithConfig:self.config pushUrl:nil];
        YYLogDebug(@"[MouseLive-VideoViewController] startUpLive anchroSecondUid:%@ anchroSecondRoomId:%@",self.config.anchroSecondUid,self.config.anchroSecondRoomId);
    } else {//当前无连麦观众
        //刷新底部工具栏
        self.baseContentView.mircEnable = YES;
        self.baseContentView.localRuningMirc = NO;
        [self.baseContentView refreshBottonToolView];
        [self.liveBG joinRoomWithConfig:self.config pushUrl:nil];
    }
}

#pragma mark - 进入视频房间 //待废弃
- (void)startUpLiveWithMircUserListArray:(NSArray *)mircUserListArray
{
    WeakSelf
    if (mircUserListArray.count) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Uid == %@", self.liveRoomInfo.ROwner.Uid];
        NSArray *filteredArray = [mircUserListArray filteredArrayUsingPredicate:predicate];
        if (filteredArray.count > 0) {
            LiveUserModel *mircUser = filteredArray.lastObject;
            //当前有正在连麦的观众
            if (![mircUser.LinkUid isEqualToString:@"0"] && ![mircUser.LinkRoomId isEqualToString:@"0"]) {
                //设置底部工具栏  自己不可以连麦
                self.baseContentView.mircEnable = NO;
                self.baseContentView.localRuningMirc = NO;
                [self.baseContentView refreshBottonToolView];
                
                LiveDefaultConfig *config = [[LiveDefaultConfig alloc]init];
                config.localUid = LoginUserUidString;
                config.ownerRoomId = weakSelf.liveRoomInfo.RoomId;
                config.anchroMainUid = mircUser.Uid;
                config.anchroMainRoomId = weakSelf.liveRoomInfo.RoomId;
                config.anchroSecondUid = mircUser.LinkUid;
                config.anchroSecondRoomId = mircUser.LinkRoomId;
                [self.liveBG joinRoomWithConfig:config pushUrl:nil];
                
            } else {
                //自己首次开播或当前无连麦观众
                if (!self.isAnchor) {
                    self.baseContentView.mircEnable = YES;
                    self.baseContentView.localRuningMirc = NO;
                    [self.baseContentView refreshBottonToolView];
                }
                
                self.config.ownerRoomId = weakSelf.liveRoomInfo.RoomId;
                [self.liveBG joinRoomWithConfig:weakSelf.config pushUrl:nil];
            }
        }
    } else {
        //房间里面没人也一样进来
        //自己首次开播或当前无连麦观众
        if (!self.isAnchor) {
            self.baseContentView.mircEnable = YES;
            self.baseContentView.localRuningMirc = NO;
            [self.baseContentView refreshBottonToolView];
        }
        self.config.ownerRoomId = weakSelf.liveRoomInfo.RoomId;
        [self.liveBG joinRoomWithConfig:weakSelf.config pushUrl:nil];
    }
}

#pragma mark - 退出直播
- (void)quit
{
    [super quit];
    [[SYThunderManagerNew sharedManager].engine registerVideoCaptureFrameObserver:nil];
    
    if (self.baseContentView.timer) {
        dispatch_cancel(self.baseContentView.timer);
        self.baseContentView.timer = nil;
    }
    [self.liveBG leaveRoom];
    [self.player stop];
    
    [[SYHummerManager sharedManager] leaveChatRoomWithCompletionHandler:^(NSError * _Nullable error) {
        YYLogDebug(@"[MouseLive-VideoViewController] quit leaveChatRoomWithCompletionHandler error:%@",error);
    }];
#if USE_BEATIFY
    [self sy_destroyAllEffects];
#endif
    if (self.isResponsBackblock) {
        self.backBlock();
        YYLogDebug(@"[MouseLive-VideoViewController] quit backBlock");
    } else {
        [self.navigationController popViewControllerAnimated:NO];
        YYLogDebug(@"[MouseLive-VideoViewController] quit popViewControllerAnimated");
    }
    YYLogDebug(@"[MouseLive-VideoViewController] quit exit");
}

#pragma mark - 美颜
//添加美颜
#if USE_BEATIFY
- (void)videoLiveAddEffectView:(SYEffectView * _Nonnull)effectView
{
    self.effectView = effectView;
    //配置美颜
    [self registerVideoCaptureFrameObserver];
    YYLogDebug(@"[MouseLive-VideoViewController] videoLiveAddEffectView exit");
}
#pragma mark - ThunderVideoCaptureFrameObserver
- (ThunderVideoCaptureFrameDataType)needThunderVideoCaptureFrameDataType
{
    //    return THUNDER_VIDEO_CAPTURE_DATATYPE_TEXTURE;
    return THUNDER_VIDEO_CAPTURE_DATATYPE_PIXELBUFFER;
}

- (CVPixelBufferRef)onVideoCaptureFrame:(EAGLContext *)glContext PixelBuffer:(CVPixelBufferRef)pixelBuf
{
    if (!pixelBuf) {
        return pixelBuf;
    }
    CVPixelBufferRef outPixelBuf = [self sy_renderPixelBufferRef:pixelBuf context:glContext];
    return outPixelBuf;
}

- (BOOL)onVideoCaptureFrame:(EAGLContext *)context PixelBuffer:(CVPixelBufferRef)pixelBuffer SourceTextureID:(unsigned int)srcTextureID DestinationTextureID:(unsigned int)dstTextureID TextureFormat:(int)textureFormat TextureTarget:(int)textureTarget TextureWidth:(int)width TextureHeight:(int)height
{
    if (pixelBuffer) {
        [self sy_renderPixelBufferRef:pixelBuffer context:context sourceTextureID:srcTextureID destinationTextureID:dstTextureID textureFormat:textureFormat textureTarget:textureTarget textureWidth:width textureHeight:height];
    }
    return YES;
}

/// 注册视频预处理
- (void)registerVideoCaptureFrameObserver
{
    // 先初始化 thunder
    [SYThunderEvent sharedManager];
    [[SYThunderManagerNew sharedManager] registerVideoCaptureFrameObserver:self];
    self.effectView.delegate = self;
}

- (void)destroyEffects
{
    [self sy_destroyAllEffects];
    [self.videoContentView hiddenCurrentView];
    [self.effectView hiddenEffectView];
    // 重新设置初始数据
    [self.effectView setData:[self sy_getEffectsData]];
}
#endif

#pragma mark - VideoContentViewDelegate

//切换摄像头
- (void)videoLiveChangeCamera:(UIButton * _Nonnull)button
{
    self.isFrontCamera = !self.isFrontCamera;
    [[SYThunderManagerNew sharedManager] switchFrontCamera:self.isFrontCamera];
    YYLogDebug(@"[MouseLive VideoViewController] videoLiveChangeCamera 切换摄像头 isFrontCamera:%d",self.isFrontCamera);
}

//改变镜像
- (void)videoLiveChangeMirroring:(UIButton * _Nonnull)button
{
    self.isMirror = !self.isMirror;
    [[SYThunderManagerNew sharedManager] switchMirror:self.isMirror];
    YYLogDebug(@"[MouseLive VideoViewController] videoLiveChangeMirroring 改变镜像 isMirror:%d",self.isMirror);
}

//关闭直播间
- (void)videoLiveCloseRoom
{
    YYLogDebug(@"[MouseLive VideoViewController] videoLiveCloseRoom start");
    [self quit];
    YYLogDebug(@"[MouseLive VideoViewController] videoLiveCloseRoom exit");
}

//挂断连麦
- (void)videoLiveHungupMirc
{
    WeakSelf
    [self.liveBG disconnectWithUid:self.currentVideoMircUid roomid:self.currentVideoMircRoomId complete:^(NSError * _Nullable error) {
        if (!error) {
            weakSelf.videoContentView.isHiddenHungupButton = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyChangeToolButtonState object:@{@"uid":@"",@"state":@"OFF"}];
            YYLogDebug(@"[MouseLive VideoViewController] videoLiveHungupMirc uid:%@",self.currentVideoMircUid);
        } else {
            YYLogError(@"[MouseLive VideoViewController] videoLiveHungupMirc error:%@",error);
        }
    }];
}

//打开观众列表
- (void)videoLiveOpenUserList
{
    //请求观众列表
    [[LivePresenter shareInstance]fetchRoomInfoWithType:LiveTypeVideo config:self.config];
    self.baseContentView.userListViewIsHidden = NO;
    [self.baseContentView updateUserListViewStatus];
    YYLogDebug(@"[MouseLive VideoViewController] videoLiveOpenUserList config:%@",self.config);
}

//同意连麦
- (void)acceptLinkMircWithUid:(NSString *)uid
{
    WeakSelf
    [self.liveBG acceptWithUid:uid complete:^(NSError * _Nullable error) {
        if (!error) {
            weakSelf.currentVideoMircUid = uid;
            weakSelf.videoContentView.isHiddenHungupButton = NO;
            YYLogDebug(@"[MouseLive VideoViewController] acceptLinkMircWithUid 同意连麦用户 Uid:%@",uid);
        } else {
            [MBProgressHUD yy_showError:error.domain];
            YYLogError(@"[MouseLive VideoViewController] acceptLinkMircWithUid 同意连麦用户 error:%@",error);
        }
    }];
}

- (void)adminManagerActionWithModel:(LiveUserModel *)userModel
{
    WeakSelf
    if (userModel.isAdmin) {
        //降管
        [[SYHummerManager sharedManager] removeAdminWithUid:userModel.Uid completionHandler:^(NSError * _Nullable error) {
            if (!error) {
                userModel.isAdmin = YES;
                [weakSelf.userInfoList setUserInfo:userModel];
                YYLogDebug(@"[MouseLive VideoViewController] adminManagerActionWithModel removeAdminWithUid 降管用户 uid: %@",userModel.Uid);
            } else {
                [MBProgressHUD yy_showError:error.domain];
                YYLogError(@"[MouseLive VideoViewController] adminManagerActionWithModel removeAdminWithUid降管用户:uid %@ error:%@",userModel.Uid,error);
            }
        }];
    } else {
        //升管
        [[SYHummerManager sharedManager] addAdminWithUid:userModel.Uid completionHandler:^(NSError * _Nullable error) {
            if (!error) {
                userModel.isAdmin = YES;
                [weakSelf.userInfoList setUserInfo:userModel];
                YYLogDebug(@"[MouseLive VideoViewController] adminManagerActionWithModel addAdminWithUid 升管用户: %@",userModel.Uid);
            } else {
                [MBProgressHUD yy_showError:error.domain];
                YYLogError(@"[MouseLive VideoViewController] adminManagerActionWithModel addAdminWithUid 升管用户: %@ error:%@",userModel.Uid,error);
            }
        }];
    }
}

//踢出
- (void)kickoutActionWithModel:(LiveUserModel *)userModel
{
    WeakSelf
    [[SYHummerManager sharedManager] sendKickWithUid:userModel.Uid completionHandler:^(NSError * _Nullable error) {
        if (!error) {
            [weakSelf.userInfoList userLeave:userModel.Uid];
            YYLogDebug(@"[MouseLive VideoViewController] kickoutActionWithModel 踢出用户: %@",userModel.Uid);
        } else {
            [MBProgressHUD yy_showError:error.domain];
            YYLogError(@"[MouseLive VideoViewController] kickoutActionWithModel 踢出用户: %@ error:%@",userModel.Uid,error);
        }
    }];
}

//主播间PK
- (void)pkConnectWithUid:(NSString *)uid roomId:(NSString *)roomid
{
    WeakSelf
    [self.liveBG connectWithUid:uid roomid:roomid complete:^(NSError * _Nullable error) {
        if (!error) {
            
            weakSelf.currentVideoMircUid = uid;
            weakSelf.currentVideoMircRoomId = roomid;
            YYLogDebug(@"[MouseLive VideoViewController] pkConnectWithUid %@ currentVideoMircUid:%@ currentVideoMircRoomId:%@",uid,weakSelf.currentVideoMircUid,weakSelf.currentVideoMircRoomId);
            
        } else {
            [MBProgressHUD yy_showError:error.domain];
            YYLogError(@"[MouseLive VideoViewController] pkConnectWithUid %@ error:%@",uid,error);
            
        }
    }];
}

- (void)refreshMicButtonStatus:(UIButton * _Nonnull)mircButton
{
    // 设置是自己关麦的
    if (mircButton.selected) {
        [self.audioMicStateController handleMicOffBySelf];
    }
    else {
        [self.audioMicStateController handleMicOnBySelf];
    }
    YYLogDebug(@"[MouseLive VideoViewController] refreshMicButtonStatus 自己关麦 status:%d",mircButton.selected);
    
}

//断开连麦
- (void)refuseLinkMircWithUid:(NSString *)uid
{
    WeakSelf
    [self.liveBG refuseWithUid:uid complete:^(NSError * _Nullable error) {
        if (!error) {
            YYLogDebug(@"[MouseLive VideoViewController] refuseLinkMircWithUid 断开连麦 uid:%@",uid);
            //隐藏断开按钮
            weakSelf.videoContentView.isHiddenHungupButton = YES;
        } else {
            YYLogError(@"[MouseLive VideoViewController] refuseLinkMircWithUid 断开连麦 uid:%@,error:%@",uid,error);
        }
    }];
}

//点击设置按钮
- (void)settingButtonAction:(UIButton * _Nonnull)settingButton
{
    [self.videoContentView updateSettingViewStatus:self.videoContentView.settingViewHidden];
    YYLogDebug(@"[MouseLive VideoViewController] settingButtonAction 点击设置按钮 status: %d",self.videoContentView.settingViewHidden);
    
}

//连麦或是pk
- (void)startConnectOtherUser:(UIButton * _Nonnull)linkButton
{
    
    if (self.isAnchor) {
        // 显示主播列表
        [self.videoContentView.baseContentView refreshUserListViewNeedAnchor:YES isAnchor:self.isAnchor config:self.config userInfoList:self.userInfoList];
        self.baseContentView.userListViewIsHidden = NO;
        [self.videoContentView.baseContentView updateUserListViewStatus];
        YYLogDebug(@"[MouseLive VideoViewController] startConnectOtherUser 显示主播列表 config: %@",self.config);
        
    } else {
        [self.liveBG connectWithUid:self.config.anchroMainUid roomid:self.config.anchroMainRoomId complete:^(NSError * _Nullable error) {
            if (!error) {
                [self.videoContentView.baseContentView updateLinkHudHiddenStatus:NO];
                YYLogDebug(@"[MouseLive VideoViewController] startConnectOtherUser connectWithUid %@",self.config.anchroMainUid);
            } else {
                
                YYLogError(@"[MouseLive VideoViewController] startConnectOtherUser connectWithUid %@,error:%@",self.config.anchroMainUid,error);
            }
        }];
    }
}


#pragma mark - LiveBGDelegate
#pragma mark - 显示码率
// 如果视频有人进入，会返回左边和右边的 uid，只有在 chatJoin 后才会返回，didChatLeaveWithUid 是不会返回
- (void)didShowCanvasWith:(NSString *)leftUid rightUid:(NSString *)rightUid
{
    [super didShowCanvasWith:leftUid rightUid:rightUid];
    //主播可以设置清晰度
    if ([LOCAL_USER.Uid isEqualToString:leftUid]) {
        self.videoContentView.isCanSettingGear = YES;
    }
    if (rightUid.length) {
        //是否可以设置清晰度
        if ([LOCAL_USER.Uid isEqualToString:rightUid]) {
            self.videoContentView.isCanSettingGear = YES;
            YYLogDebug(@"[MouseLive VideoViewController] didShowCanvasWith 可以设置清晰度 status:%d",self.videoContentView.isCanSettingGear);
        }
        self.videoContentView.shouldHiddenMircedHeader = NO;
        YYLogDebug(@"[MouseLive VideoViewController] didShowCanvasWith 显示连麦者头像 status:%d",self.videoContentView.shouldHiddenMircedHeader);
        //显示对方头像
        WeakSelf
        [self.userInfoList getUserInfoWithUid:rightUid complete:^(LiveUserModel * _Nonnull model) {
            weakSelf.videoContentView.mircedPeopleModel = model;
            YYLogDebug(@"[MouseLive VideoViewController] didShowCanvasWith 显示连麦者头像 user:%@",model);
        }];
    } else {
        //隐藏对方头像
        self.videoContentView.shouldHiddenMircedHeader = YES;
        YYLogDebug(@"[MouseLive VideoViewController] didShowCanvasWith 隐藏连麦者头像 status:%d",self.videoContentView.shouldHiddenMircedHeader);
    }
}

#pragma mark- 点击空白视图隐藏 touchesBegan
//统一处理点击空白视图隐藏
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.videoContentView hiddenCurrentView];
    [self.baseContentView hiddenCurrentView];
    YYLogDebug(@"[MouseLive VideoViewController] touchesBegan hiddenCurrentView");
}
@end
