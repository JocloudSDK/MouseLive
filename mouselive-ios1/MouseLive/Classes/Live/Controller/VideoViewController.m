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
#import "SYThunderEvent.h"
#import "VideoSession.h"
#import "UserManager.h"
#import "VideoViewLayer.h"

@interface VideoViewController()<UITextFieldDelegate,SYPlayerDelegate,UIGestureRecognizerDelegate,VideoContentViewDelegate,VideoLiveBottonToolViewDelegate,LiveManagerDelegate, LiveManagerSignalDelegate, SYThunderDelegate, BaseLiveContentViewDelegate
#if USE_BEATIFY
,ThunderVideoCaptureFrameObserver, SYEffectViewDelegate>
#else
>
#endif

@property (nonatomic, strong) VideoContentView *videoContentView;
@property (nonatomic, strong) SYEffectView *effectView;

@property(nonatomic, strong)  SYPlayer *player;

@property(nonatomic, assign)  BOOL isFrontCamera;

@property(nonatomic, assign)  BOOL isMirror;
//当前正在连麦的观众
@property(nonatomic, copy) NSString *currentVideoMircUid;
//当前正在连麦房间
@property(nonatomic, copy) NSString *currentVideoMircRoomId;

//房主的View
@property(nonatomic, strong) VideoSession *hostVideoSession;
//连麦者的View
@property(nonatomic, strong) VideoSession *linkVideoSeesion;

@end

@implementation VideoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self cofigVideoRoom];
}

- (LiveType)liveType
{
    return LiveTypeVideo;
}

- (SYPlayer *)player
{
    if (!_player) {
        _player = [[SYPlayer alloc] initPlayerWirhUrl:self.roomModel.RDownStream view:self.hostVideoSession.hostView delegate:self];
    }
    
    return _player;
}

- (VideoSession *)hostVideoSession
{
    if (!_hostVideoSession) {
        VideoSession *session = [VideoSession newInstanceWithHungupButton:NO withClickBlock:nil];
         
        [self.view insertSubview:session atIndex:0];
        [VideoViewLayer layoutFullSession:session inContainerView:self.view];
        _hostVideoSession = session;
    }
    
    return _hostVideoSession;
}

//初始化UI
- (void)setup
{
    [super setup];
    self.isFrontCamera = YES;
    self.isMirror = YES;
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
    [self.liveManager addThunderDelegate:self];
    
    if (self.isAnchor) {
        //主播
        [self.liveManager joinMediaRoom:self.config.ownerRoomId uid:self.config.localUid roomType:LiveTypeVideo];
        
        [self.liveManager setupLocalUser:self.config.localUid videoView:self.hostVideoSession.hostView];
    } else {
        //观众
        if (self.publishMode == PUBLISH_STREAM_CDN) {
            [self.player start];
        } else if (self.publishMode == PUBLISH_STREAM_RTC) {
            [self.liveManager joinMediaRoom:self.config.ownerRoomId uid:LoginUserUidString roomType:LiveTypeVideo];
        }
    }
}
//观众进入房间同步房间当前状态
- (void)startUpLive
{
    LiveUserModel *roomOwner = [LiveUserListManager objectForPrimaryKey:self.roomModel.ROwner.Uid];
    if (![roomOwner.LinkUid isEqualToString:@"0"] && ![roomOwner.LinkRoomId isEqualToString:@"0"]) {
             //非主播 非连麦者 不可再连麦
        if (![LoginUserUidString isEqualToString:roomOwner.LinkUid] && ![LoginUserUidString isEqualToString:roomOwner.Uid]) {
            [self refreshToolWithMircEnable:NO localRuningMirc:NO];
            NSString *para = @"当前主播正在连麦中，自己不能连麦";
            YYLogFuncEntry([self class], _cmd, para);
        }
        self.config.anchroSecondUid = roomOwner.LinkUid;
        self.config.anchroSecondRoomId = roomOwner.LinkRoomId;
        NSString *para = [NSString stringWithFormat:@"anchroSecondUid:%@ anchroSecondRoomId:%@",self.config.anchroSecondUid,self.config.anchroSecondRoomId];
        YYLogFuncEntry([self class], _cmd, para);
    } else {//当前无连麦观众
        //更新连麦观众配置信息
        self.config.anchroSecondUid = @"";
        self.config.anchroSecondRoomId = @"";
        //刷新底部工具栏
        [self refreshToolWithMircEnable:YES localRuningMirc:NO];
        NSString *para = @"当前无连麦中，可以与主播连麦";
        YYLogFuncEntry([self class], _cmd, para);
    }
    [self setupVideoSessionView];
}
//启动本地视图
- (void)setupVideoSessionView
{
    WeakSelf
    //当前有人连麦或pk
    if (self.config.anchroSecondUid.length) {
        VideoSession *videoSession =  [VideoSession newInstanceWithHungupButton:self.isAnchor withClickBlock:^(LiveUserModel * _Nonnull userInfo) {
            [weakSelf anchorHungupUser:userInfo];
        }];
        
        //添加远端视图
        if (self.config.localUid == self.config.anchroSecondUid) {
            [self.liveManager setupLocalUser:self.config.anchroSecondUid  videoView:videoSession.hostView];
        } else {
            [self.liveManager setupRemoteUser:self.config.anchroSecondUid videoView:videoSession.hostView];
        }
       
        if ([self.config.anchroMainRoomId isEqualToString:self.config.anchroSecondRoomId]) {
            videoSession.userInfo = [LiveUserListManager objectForPrimaryKey:self.config.anchroSecondUid];
            //连麦
        } else {
            //pk
            if ([LiveUserListManager defaultManager].pkAnchor) {
              videoSession.userInfo = [LiveUserListManager defaultManager].pkAnchor;
            } else {
                [self.livePresenter willShowPKAnchorWithUid:self.config.anchroSecondUid];
            }
            [self.liveManager addSubscribe:self.config.anchroSecondRoomId uid:self.config.anchroSecondUid];
        }
        
        self.linkVideoSeesion = videoSession;
        NSString *para = @"当前为连麦状态中";
        YYLogFuncEntry([self class], _cmd, para);
    } else {
        //删除连麦者视图
        [self.linkVideoSeesion removeFromSuperview];
        self.linkVideoSeesion = nil;
        NSString *para = @"删除连麦者视图";
        YYLogFuncEntry([self class], _cmd, para);
    }
    [VideoViewLayer layoutLeftSession:self.hostVideoSession rightSession:self.linkVideoSeesion inContainerView:self.videoContentView withTopView:self.videoContentView.anchorView];
    [self refreshCodeView];
   
}

//主播挂断连麦者
- (void)anchorHungupUser:(LiveUserModel *)user
{
    if (self.isAnchor) {
        //挂断连麦
        [self.liveManager hungupWithUser:user.Uid roomId:user.RoomId complete:^(NSError * _Nullable error) {
            if (!error) {
                if (![user.RoomId isEqualToString:self.config.anchroMainRoomId]) {
                    //pk 取消订阅
                    [self.liveManager removeSubscribe:user.RoomId uid:user.Uid];
                }
                //同步config数据
                self.config.anchroSecondUid = @"";
                self.config.anchroSecondRoomId = @"";
                //移除连麦者视图
                [self.liveManager setupRemoteUser:user.Uid videoView:nil];
                [self.linkVideoSeesion removeFromSuperview];
                //更新媒体视图布局
                [VideoViewLayer layoutLeftSession:self.hostVideoSession rightSession:nil inContainerView:self.view withTopView:self.videoContentView.anchorView];
                //更新底部工具栏
                [self refreshToolWithMircEnable:YES localRuningMirc:NO];
                YYLogDebug(@"[MouseLive-VideoViewController] anchorHungupUser:%@ success!",user.Uid);
                
            } else {
                YYLogError(@"[MouseLive-VideoViewController] anchorHungupUser error:%@",error);
            }
        }];
    }
}

//更新底部工具栏
- (void)refreshToolWithMircEnable:(BOOL)MircEnable localRuningMirc:(BOOL)localRuningMirc
{
    self.baseContentView.mircEnable = MircEnable;
    self.baseContentView.localRuningMirc = localRuningMirc;
    [self.baseContentView refreshBottomToolView];
}

//改变码率显示
- (void)refreshCodeView
{
    if (!self.linkVideoSeesion) {
        //显示媒体层码率
        [self.hostVideoSession hiddenQuqlityView:NO];
        if (self.isAnchor) {
            //隐藏本地层码率
            [self.baseContentView hiddenCodeView];
        }  else {
            //显示本地层码率
            [self.baseContentView showCodeView];
        }
    } else {
        //连麦者是自己
        if ([self.config.anchroSecondUid isEqualToString:LoginUserUidString]) {
            //隐藏本地码率
            [self.baseContentView hiddenCodeView];
            //显示媒体层码率
            [self.hostVideoSession hiddenQuqlityView:NO];
            [self.linkVideoSeesion hiddenQuqlityView:NO];
        } else {
            //显示本地码率
            //显示媒体层码率
            [self.hostVideoSession hiddenQuqlityView:NO];
            [self.linkVideoSeesion hiddenQuqlityView:NO];
            if (!self.isAnchor) {
                [self.baseContentView showCodeView];
            }
        }
    }
}

//刷新房间人数
- (void)refreshPeopleCount
{
    self.videoContentView.peopleCount = self.roomModel.onlineUserList.count;
}

#pragma mark - 退出直播
- (void)quit
{
    [super quit];
    //摄像头复位
    if (!self.isFrontCamera) {
    [self.liveManager switchFrontCamera:YES];
    }
    if (self.config.anchroSecondUid.length || self.config.anchroSecondRoomId.length) {
        if ([self.config.anchroSecondUid isEqualToString:LoginUserUidString]) {
            if ([self.config.anchroSecondRoomId isEqualToString:self.roomModel.RoomId]) {
                //连麦者挂断主播
                [self.liveManager hungupWithUser:self.config.anchroMainUid roomId:self.config.anchroMainRoomId complete:nil];
            } else {
                //跨房间连麦挂断连麦
                [self.liveManager hungupWithUser:self.config.anchroSecondUid roomId:self.config.anchroSecondRoomId complete:nil];
            }
        }
    }
    [self.baseContentView stopTimer];
    
    [self.liveManager leaveRoom];
   
    if (self.publishMode == PUBLISH_STREAM_CDN) {
        if (self.isAnchor) {
            [self.liveManager stopPublishStreamToUrl:self.roomModel.RUpStream];
        } else {
            [self.player stop];
        }
    }
    
#if USE_BEATIFY
    [self sy_destroyAllEffects];
    [self.liveManager registerVideoCaptureFrameObserver:nil];
#endif
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
}

#pragma mark - 美颜
//添加美颜
#if USE_BEATIFY
- (void)videoLiveAddEffectView:(SYEffectView * _Nonnull)effectView
{
    self.effectView = effectView;
//    [self sy_downloadEffectData];
    [self.view bringSubviewToFront:self.effectView];
    [self.effectView setData:[self sy_getEffectsData]];
    //配置美颜
    [self sy_setDefaultBeautyEffect];
    [self.liveManager registerVideoCaptureFrameObserver:self];
    self.effectView.delegate = self;
    YYLogFuncExit([self class], _cmd);
}
#pragma mark - ThunderVideoCaptureFrameObserver
- (ThunderVideoCaptureFrameDataType)needThunderVideoCaptureFrameDataType
{
    return THUNDER_VIDEO_CAPTURE_DATATYPE_TEXTURE;
//        return THUNDER_VIDEO_CAPTURE_DATATYPE_PIXELBUFFER;
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

- (void)destroyEffects
{
    [self sy_destroyAllEffects];
    self.videoContentView.settingViewHidden = YES;
    [self.videoContentView updateSettingViewStatus:self.videoContentView.settingViewHidden];
    [self.effectView hiddenEffectView];
    // 重新设置初始数据
    [self.effectView setData:[self sy_getEffectsData]];
}

#endif


#pragma mark - BaseLiveContentViewDelegate
//开启或关闭麦克风
- (void)refreshMicButtonStatus:(UIButton * _Nonnull)mircButton
{
      // 设置是自己关麦的
      if (mircButton.selected) {
          [self closeLocalMirc];
      }
      else {
          [self openLocalMirc];
      }
      NSString *param = [NSString stringWithFormat:@"自己关麦 status:%d",!mircButton.selected];
      YYLogFuncEntry([self class], _cmd, param);
}

#pragma mark - VideoContentViewDelegate
//切换摄像头
- (void)videoLiveChangeCamera:(UIButton * _Nonnull)button
{
    self.isFrontCamera = !self.isFrontCamera;
    [self.liveManager switchFrontCamera:self.isFrontCamera];
    YYLogDebug(@"[MouseLive VideoViewController] videoLiveChangeCamera 切换摄像头 isFrontCamera:%d",self.isFrontCamera);
}

//改变镜像
- (void)videoLiveChangeMirroring:(UIButton * _Nonnull)button
{
    self.isMirror = !self.isMirror;
    [self.liveManager setMirrorPreview:self.isMirror publish:self.isMirror];
    YYLogDebug(@"[MouseLive VideoViewController] videoLiveChangeMirroring 改变镜像 isMirror:%d",self.isMirror);
}

//关闭直播间
- (void)videoLiveCloseRoom
{
    NSString *param = @"start";
    YYLogFuncEntry([self class], _cmd, param);
    [self quit];
    NSString *param1 = @"exit";
    YYLogFuncEntry([self class], _cmd, param1);
}

//挂断连麦
- (void)videoLiveHungupMirc
{
    WeakSelf
    [self.liveManager hungupWithUser:self.currentVideoMircUid roomId:self.currentVideoMircRoomId complete:^(NSError * _Nullable error) {
        if (!error) {
            [weakSelf refreshToolWithMircEnable:YES localRuningMirc:NO];
            NSString *param = [NSString stringWithFormat:@"uid:%@",self.currentVideoMircUid];
            YYLogFuncEntry([weakSelf class], _cmd, param);
        } else {
            NSString *param = [NSString stringWithFormat:@"error:%@",error];
            YYLogFuncEntry([weakSelf class], _cmd, param);
        }
    }];
}

//打开观众列表
- (void)videoLiveOpenUserList
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
    YYLogDebug(@"[MouseLive VideoViewController] videoLiveOpenUserList");
}

//主播同意连麦 启动视频
- (void)acceptLinkMircWithUid:(NSString *)uid roomId:(NSString * _Nonnull)roomId
{
    WeakSelf
    [self.liveManager acceptConnectWithUser:uid complete:^(NSError * _Nullable error) {
        if (!error) {
            NSString *paras = [NSString stringWithFormat:@"同意连麦用户 Uid:%@",uid];
            YYLogFuncEntry([self class], _cmd, paras);
            weakSelf.currentVideoMircUid = uid;
            weakSelf.currentVideoMircRoomId = roomId;
            weakSelf.config.anchroSecondRoomId = roomId;
            weakSelf.config.anchroSecondUid = uid;
            //启动本地视图
            [weakSelf setupVideoSessionView];
            //刷新主播底部工具栏
            [weakSelf refreshToolWithMircEnable:YES localRuningMirc:YES];
        } else {
            [MBProgressHUD yy_showError:error.domain];
            YYLogError(@"[MouseLive VideoViewController] acceptLinkMircWithUid 同意连麦用户 error:%@",error);
        }
    }];
}

//主播间PK
- (void)pkConnectWithUid:(NSString *)uid roomId:(NSString *)roomid
{
    WeakSelf
    [self.liveManager applyConnectToUser:uid roomId:roomid complete:^(NSError * _Nullable error) {
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

//断开连麦
- (void)refuseLinkMircWithUid:(NSString *)uid
{

    [self.liveManager refuseConnectWithUser:uid complete:^(NSError * _Nullable error) {
        if (!error) {
            YYLogDebug(@"[MouseLive VideoViewController] refuseLinkMircWithUid 断开连麦 uid:%@",uid);

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
        NSDictionary *params = @{
            kUid:@(LoginUserUidString.integerValue),
            kRType:@(self.liveType),
        };
        [self.livePresenter fetchAnchorListWithParam:params];
        self.baseContentView.userListViewIsHidden = NO;
        YYLogDebug(@"[MouseLive VideoViewController] startConnectOtherUser 显示主播列表 config: %@",self.config);
        
    } else {
        [self.liveManager applyConnectToUser:self.config.anchroMainUid roomId:self.config.anchroMainRoomId complete:^(NSError * _Nullable error) {
            if (!error) {
                [self.videoContentView.baseContentView updateLinkHudHiddenStatus:NO];
                YYLogDebug(@"[MouseLive VideoViewController] startConnectOtherUser connectWithUid %@",self.config.anchroMainUid);
            } else {
                
                YYLogError(@"[MouseLive VideoViewController] startConnectOtherUser connectWithUid %@,error:%@",self.config.anchroMainUid,error);
            }
        }];
    }
}

- (void)refreshCodeViewHiddenStatus:(BOOL)selecte
{
    if (self.linkVideoSeesion) {
        if (selecte) {
            //隐藏码率
            [self.hostVideoSession hiddenQuqlityView:YES];
            [self.linkVideoSeesion hiddenQuqlityView:YES];
            if (![self.config.anchroSecondUid isEqualToString:LoginUserUidString]) {
                [self.baseContentView hiddenCodeView];
            }
        } else {
            [self.hostVideoSession hiddenQuqlityView:NO];
            [self.linkVideoSeesion hiddenQuqlityView:NO];
            if (![self.config.anchroSecondUid isEqualToString:LoginUserUidString]) {
                if (!self.isAnchor) {
                    //非主播显示自己的码率
                    [self.baseContentView showCodeView];
                }
            }
        }
    } else {
        if (selecte) {
            //隐藏码率
            [self.hostVideoSession hiddenQuqlityView:YES];
            if (!self.isAnchor) {
                [self.baseContentView hiddenCodeView];
            }
        } else {
            [self.hostVideoSession hiddenQuqlityView:NO];
            if (!self.isAnchor) {
                [self.baseContentView showCodeView];
            }
        }
    }
}

#pragma mark- VideoOrAudioLiveViewProtocol
//刷新房间人数
- (void)refreshLiveRoomPeople:(NSInteger)count
{
    self.videoContentView.peopleCount = count;
    
}

- (void)onfetchRoomInfoSuccess:(LiveUserListManager *)roomModel
{
    //刷新用户列表
    [self.baseContentView updateUserListViewStatus];
}

- (void)onfetchAnchorListSuccess:(NSArray<LiveUserModel *> *)dataArray
{
    //刷新主播列表
    [self.baseContentView updateAnchorListViewWithArray:dataArray];
}

- (void)onfetchAnchorListFail:(NSString *)errorCode des:(NSString *)des
{
    [MBProgressHUD yy_showError:des toView:self.view];
}

- (void)onfetchRoomInfoFail:(NSString *)errorCode des:(NSString *)des
{
    [MBProgressHUD yy_showError:des toView:self.view];
}

//将要展示跨房间PK主播的信息
- (void)didShowPKAnchor
{
    [LiveUserListManager beginWriteTransaction];
    [LiveUserListManager defaultManager].pkAnchor.RoomId = self.config.anchroSecondRoomId;
    [LiveUserListManager commitWriteTransaction];
    self.linkVideoSeesion.userInfo = [LiveUserListManager defaultManager].pkAnchor;
}

#pragma mark - LiveManager Signal Delegate
- (void)liveManager:(LiveManager *)manager didBeInvitedBy:(NSString *)uid roomId:(NSString *)roomId
{
    if (!self.config.anchroSecondUid.length) {
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

//对方同意连麦 某人 单播
- (void)liveManager:(LiveManager *)manager didInviteAcceptBy:(NSString *)uid roomId:(NSString *)roomId
{
    //开启远端流
    [self.liveManager enableLocalVideo:YES];
    //隐藏15s倒计时
    [self.baseContentView updateLinkHudHiddenStatus:YES];

    //更新连麦者底部栏
    [self refreshToolWithMircEnable:YES localRuningMirc:YES];

}

//连麦成功(主播端不会有回调)当前主播和谁在连麦
- (void)liveManager:(LiveManager * _Nonnull)manager anchorConnectedWith:(NSString * _Nonnull)uid roomId:(NSString * _Nonnull)roomId
{
    //隐藏其它连麦者的15s倒计时框
    [self.baseContentView updateLinkHudHiddenStatus:YES];
    self.config.anchroSecondUid = uid;
    self.config.anchroSecondRoomId = roomId;
    //刷新本地视图
    [self setupVideoSessionView];
    //更新观众底部工具栏
    if (!self.isAnchor && ![self.config.localUid isEqualToString:uid]) {
        [self refreshToolWithMircEnable:NO localRuningMirc:NO];
    }
}

//广播 当前主播和某人断开连麦
- (void)liveManager:(LiveManager * _Nonnull)manager anchorDisconnectedWith:(NSString * _Nonnull)uid roomId:(NSString * _Nonnull)roomId
{
    if (![self.config.anchroSecondRoomId isEqualToString:self.roomModel.RoomId]) {
        //pk 移除订阅
        [self.liveManager removeSubscribe:self.config.anchroSecondRoomId uid:self.config.anchroSecondUid];
    }
    self.config.anchroSecondRoomId = @"";
    self.config.anchroSecondUid = @"";
    //刷新本地视图
    [self.liveManager setupRemoteUser:uid videoView:nil];
    [self setupVideoSessionView];
    //更新观众底部工具栏
    if (![self.config.localUid isEqualToString:uid]) {
        [self refreshToolWithMircEnable:YES localRuningMirc:NO];
    }
}

//挂断连麦者 单播
- (void)liveManager:(LiveManager *)manager didReceiveHungupRequestFrom:(NSString *)uid roomId:(NSString *)roomId
{
    //挂断的不是主播 或者是PK人员 关闭连麦者的远端流
    if (!self.isAnchor) {
        //关闭远端流
        [self.liveManager enableLocalAudio:NO];
        [self.liveManager enableLocalVideo:NO];
        NSString *param = @"关闭连麦者远端流";
        YYLogFuncEntry([self class], _cmd, param);
    }
    //更新连麦者底部栏
    [self refreshToolWithMircEnable:YES localRuningMirc:NO];
}

//用户退出
- (void)liveManager:(LiveManager *)manager didUserLeave:(NSString *)uid
{
    //刷弹幕
    [super liveManager:manager didUserLeave:uid];
    
    if ([self.config.anchroSecondUid isEqualToString:uid]) {
        //更新视频图
        self.config.anchroSecondRoomId = @"";
        self.config.anchroSecondUid = @"";
        //刷新本地视图
        [self.liveManager setupRemoteUser:uid videoView:nil];
        [self setupVideoSessionView];
    }
    //更新观众底部工具栏
    if (![self.config.localUid isEqualToString:uid]) {
        [self refreshToolWithMircEnable:YES localRuningMirc:NO];
    }
}
#pragma mark - Thunder Delegate
- (void) thunderEngine:(ThunderEngine *)engine onJoinRoomSuccess:(NSString *)room withUid:(NSString *)uid elapsed:(NSInteger)elapsed
{
    [self.liveManager enableRemoteAudioStream:YES];
    [self.liveManager enableRemoteVideoStream:YES];
    if ([LoginUserUidString isEqualToString:self.roomModel.ROwner.Uid]) {
        [self.liveManager enableLocalVideo:YES];
        if (self.publishMode == PUBLISH_STREAM_CDN) {
            [self.liveManager publishStreamToUrl:self.roomModel.RUpStream];
        }
    } else {
        [self.liveManager setupRemoteUser:self.config.anchroMainUid videoView:self.hostVideoSession.hostView];
    }
}

//上下行码率
- (void)thunderEngine:(ThunderEngine * _Nonnull)engine networkQualityStatus:(nonnull NetworkQualityStauts *)networkQualityStatus
{
    
    self.hostVideoSession.qualityModel.audioUpload = networkQualityStatus.audioUpload;
    self.hostVideoSession.qualityModel.audioDownload = networkQualityStatus.audioDownload;
    self.hostVideoSession.qualityModel.videoUpload = networkQualityStatus.videoUpload;
    self.hostVideoSession.qualityModel.videoDownload = networkQualityStatus.videoDownload;
    self.hostVideoSession.qualityModel.upload = networkQualityStatus.upload;
    self.hostVideoSession.qualityModel.download = networkQualityStatus.download;
    
    if (self.linkVideoSeesion) {
        self.linkVideoSeesion.qualityModel = networkQualityStatus;
        self.linkVideoSeesion.qualityModel.audioDownload = networkQualityStatus.audioDownload;
        self.linkVideoSeesion.qualityModel.videoUpload = networkQualityStatus.videoUpload;
        self.linkVideoSeesion.qualityModel.videoDownload = networkQualityStatus.videoDownload;
        self.linkVideoSeesion.qualityModel.upload = networkQualityStatus.upload;
        self.linkVideoSeesion.qualityModel.download = networkQualityStatus.download;
    }

    self.baseContentView.qualityModel.audioDownload = networkQualityStatus.audioDownload;
    self.baseContentView.qualityModel.videoUpload = networkQualityStatus.videoUpload;
    self.baseContentView.qualityModel.videoDownload = networkQualityStatus.videoDownload;
    self.baseContentView.qualityModel.upload = networkQualityStatus.upload;
    self.baseContentView.qualityModel.download = networkQualityStatus.download;
    //观众
    if (!self.isAnchor && ! [self.config.localUid isEqualToString:self.config.anchroSecondUid]) {
        self.baseContentView.qualityModel.isShowCodeDetail = YES;
        self.hostVideoSession.qualityModel.isShowCodeDetail = NO;
        self.linkVideoSeesion.qualityModel.isShowCodeDetail = NO;
        
    } else if ( [self.config.localUid isEqualToString:self.config.anchroSecondUid]){
        //连麦者
        self.baseContentView.qualityModel.isShowCodeDetail = NO;
        self.linkVideoSeesion.qualityModel.isShowCodeDetail = YES;
        self.hostVideoSession.qualityModel.isShowCodeDetail = NO;
    } else {
        //主播
        self.baseContentView.qualityModel.isShowCodeDetail = NO;
        self.linkVideoSeesion.qualityModel.isShowCodeDetail = NO;
        self.hostVideoSession.qualityModel.isShowCodeDetail = YES;
    }
    [self.baseContentView refreshCodeView];
    [self.hostVideoSession refreshCodeView];
    [self.linkVideoSeesion refreshCodeView];

}

//网络质量
- (void)thunderEngine:(ThunderEngine *)engine onNetworkQuality:(NSString *)uid txQuality:(ThunderLiveRtcNetworkQuality)txQuality rxQuality:(ThunderLiveRtcNetworkQuality)rxQuality
{

    //自己
    if ([uid isEqualToString:@"0"]) {
        if (self.isAnchor) {
            self.hostVideoSession.qualityModel.netWorkQuality.uploadNetQuality = txQuality;
            self.hostVideoSession.qualityModel.netWorkQuality.downloadNetQuality = rxQuality;
            [self.hostVideoSession refreshCodeView];
        } else {
            self.baseContentView.qualityModel.netWorkQuality.uploadNetQuality = txQuality;
            self.baseContentView.qualityModel.netWorkQuality.downloadNetQuality = rxQuality;
            [self.baseContentView refreshCodeView];
        }
  
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

#pragma mark - VideoLiveBottonToolViewDelegate
- (void)openLocalMirc
{
    //开启远端流
    [self.liveManager enableLocalAudio:YES];
    YYLogFuncEntry([self class], _cmd, nil);
}

- (void)closeLocalMirc
{
    //关闭远端流
    [self.liveManager enableLocalAudio:NO];
    YYLogFuncEntry([self class], _cmd, nil);
}
@end
