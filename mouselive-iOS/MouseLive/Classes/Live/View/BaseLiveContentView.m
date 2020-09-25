//
//  BaseLiveContentView.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/4/26.
//  Copyright © 2020 sy. All rights reserved.
//

#import "BaseLiveContentView.h"
#import "LiveCodeRateView.h"
#import "ApplyAlertView.h"
#import "LiveUserView.h"
#import "LiveUserListView.h"
#import "UserManager.h"

@interface BaseLiveContentView ()
@property (nonatomic, strong) UIView *view;
/**显示码流*/
@property (nonatomic, strong) LiveCodeRateView *bottomCodeRateView;
/**观众列表页*/
@property (nonatomic, strong) LiveUserListView *userListView;
//留言区
@property (nonatomic, strong) LivePublicTalkView *talkTableView;
/**连接中状态条*/
@property(nonatomic, strong) UILabel *linkHUD;
/**码率左uid*/
@property(nonatomic, copy) NSString *codeLeftUid;
/**码率右uid*/
@property(nonatomic, copy) NSString *codeRightUid;

@property(nonatomic, strong)LiveUserListManager *roomModel;
//申请连麦
@property (nonatomic, strong) ApplyAlertView *applyView;
/**观众信息*/
@property (nonatomic, strong) LiveUserView *userView;
//15s计时器
@property (nullable, nonatomic, strong) dispatch_source_t timer;
//网络状态框
@property (nonatomic, strong) UIView *netAlertView;
@end

@implementation BaseLiveContentView

- (instancetype)initWithRoomid:(NSString *)roomId view:(nonnull UIView *)view
{
    if (self = [super init]) {
        self.view = view;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        self.roomId = roomId;
        self.roomModel = [LiveUserListManager defaultManager];
        if ([self.roomModel.ROwner.Uid isEqualToString:LoginUserUidString]) {
            self.isAnchor = YES;
        } else {
            self.isAnchor = NO;
        }
        self.liveType = self.roomModel.RType;
        self.userListViewIsHidden = YES;
        [self setup];
        
    }
    return self;
}
- (instancetype)initWithLiveType:(LiveType)liveType isAnchor:(BOOL) isAnchor
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        self.isAnchor = isAnchor;
        self.liveType = liveType;
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.talkTableView.hidden = NO;
    if (self.liveType == LiveTypeVideo) {
        [self.audioToolView removeFromSuperview];
        self.videoToolView.hidden = NO;
    } else if (self.liveType == LiveTypeAudio) {
        [self.videoToolView removeFromSuperview];
        self.audioToolView.hidden = NO;
    }
    self.chatTextField.hidden = NO;
    self.linkHUD.hidden = YES;
    self.applyView.hidden = YES;
    self.userView.hidden = YES;
    self.userListView.hidden = YES;
    //更新码率约束
    [self updateViewConstraints];
}

- (NSMutableArray *)talkDataArray
{
    if (!_talkDataArray) {
        _talkDataArray = [[NSMutableArray alloc]initWithArray:self.talkTableView.dataArray];
    }
    return _talkDataArray;
}

-(void)setDelegate:(id<BaseLiveContentViewDelegate,AudioLiveBottonToolViewDelegate>)delegate
{
    _delegate = delegate;
    self.audioToolView.delegate = delegate;
    self.videoToolView.delegate = delegate;
}
#pragma mark - 底部工具栏 1主播闭麦 2主播pk/观众连麦 3设置 4反馈 5码率 6变声
- (AudioLiveBottonToolView *)audioToolView
{
    WeakSelf
    if (!_audioToolView) {
        _audioToolView = [[AudioLiveBottonToolView alloc]initWithAnchor:self.isAnchor];
        _audioToolView.delegate = self.delegate;
        [self.view addSubview:_audioToolView];
        [_audioToolView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(@0);
            make.bottom.equalTo(@(-TabbarSafeBottomMargin));
            make.height.equalTo(@(Live_Tool_H));
        }];
        
        [_audioToolView setClickToolBlock:^(AudioLiveToolType type,BOOL selected,UIButton *button) {
            [weakSelf hiddenMircApplayWithUid:self.applyView.model.Uid];
            [weakSelf hiddenUserView];
            
            switch (type) {
                case AudioLiveToolTypeMicr: {//关闭麦克风
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(refreshMicButtonStatus:)]) {
                        [weakSelf.delegate refreshMicButtonStatus:button];
                    }
                }
                    break;
                case AudioLiveToolTypeWhine: {//变声
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(audioWhineButtonAction)]) {
                        [weakSelf.delegate audioWhineButtonAction];
                    }
                }
                    break;
                case AudioLiveToolTypeFeedback: {//反馈
                    
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(feedbackButtonAction:)]) {
                        [weakSelf.delegate feedbackButtonAction:button];
                    }
                }
                    break;
                case AudioLiveToolTypeCodeRate: {//码率
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(refreshCodeViewHiddenStatus:)]) {
                        [weakSelf.delegate refreshCodeViewHiddenStatus:selected];
                    }
                }
                    break;
                    
                    
                default:
                    break;
            }
        }];
    }
    return _audioToolView;
}

- (VideoLiveBottonToolView *)videoToolView
{
    WeakSelf
    if (!_videoToolView) {
        _videoToolView = [[VideoLiveBottonToolView alloc] initWithAnchor:self.isAnchor];
        [self.view addSubview:_videoToolView];
        _videoToolView.delegate = self.delegate;
        [_videoToolView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(@0);
            make.bottom.equalTo(@(-TabbarSafeBottomMargin));
            make.height.equalTo(@(Live_Tool_H));
        }];
        
        [_videoToolView setClickToolBlock:^(VideoLiveToolType type,BOOL selected,UIButton *button) {
            [weakSelf hiddenMircApplayWithUid:weakSelf.applyView.model.Uid];
            [weakSelf hiddenUserView];
            if (type != VideoLiveToolTypeSetting) {
                [[NSNotificationCenter defaultCenter]postNotificationName:kNotifySettingViewHidden object:nil];
            }
            switch (type) {
                case VideoLiveToolTypeMicr: {//关闭麦克风
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(refreshMicButtonStatus:)]) {
                        [weakSelf.delegate refreshMicButtonStatus:button];
                    }
                }
                    break;
                case VideoLiveToolTypeLinkmicr: {//主播pk 观众连麦
                    if (!selected) {
                        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(startConnectOtherUser:)]) {
                            [weakSelf.delegate startConnectOtherUser:button];
                        }
                    }
                }
                    break;
                case VideoLiveToolTypeSetting: {////设置
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(settingButtonAction:)]) {
                        [weakSelf.delegate settingButtonAction:button];
                    }
                }
                    break;
                case VideoLiveToolTypeFeedback: {//反馈
                    
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(feedbackButtonAction:)]) {
                        [weakSelf.delegate feedbackButtonAction:button];
                    }
                }
                    break;
                case VideoLiveToolTypeCodeRate: {//码率
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(refreshCodeViewHiddenStatus:)]) {
                        [weakSelf.delegate refreshCodeViewHiddenStatus:selected];
                    }
                }
                    break;
                    
                    
                default:
                    break;
            }
        }];
    }
    return _videoToolView;
}

#pragma mark - 公聊
- (LivePublicTalkView *)talkTableView
{
    if (!_talkTableView) {
        _talkTableView = [[LivePublicTalkView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _talkTableView.backgroundColor = [UIColor clearColor];
//        _talkTableView.userInteractionEnabled = NO;
        [self.view addSubview:_talkTableView];
        WeakSelf
        [_talkTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            if (self.liveType == LiveTypeAudio) {
                make.bottom.mas_equalTo(weakSelf.audioToolView.mas_top).offset(-10);
                
            } else if (self.liveType == LiveTypeVideo) {
                make.bottom.mas_equalTo(weakSelf.videoToolView.mas_top).offset(-10);
            }
            make.height.equalTo(@(PubTalk_H));
        }];
    }
    return _talkTableView;
}


- (UILabel *)linkHUD
{
    if (!_linkHUD) {
        _linkHUD = [[UILabel alloc]init];
        [self.view addSubview:_linkHUD];
        [_linkHUD mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        _linkHUD.text = [NSString stringWithFormat:@"%@(15s)",NSLocalizedString(@"Connecting...",nil)];
        _linkHUD.textColor = [UIColor whiteColor];
        _linkHUD.textAlignment = NSTextAlignmentCenter;
        _linkHUD.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        // 防止点击
        _linkHUD.userInteractionEnabled = YES;
    }
    return _linkHUD;
}

- (UITextField *)chatTextField
{
    //88 * SCREEN_WIDTH/360
    if (!_chatTextField) {
        _chatTextField = [[UITextField alloc]initWithFrame:CGRectMake(0,SCREEN_HEIGHT - TabbarSafeBottomMargin - Live_Tool_H,SCREEN_WIDTH, Live_Tool_H)];
        _chatTextField.backgroundColor = [UIColor clearColor];
        _chatTextField.returnKeyType = UIReturnKeyDone;
        _chatTextField.alpha = 0.1;
        if (self.liveType == LiveTypeVideo) {
            [self.view insertSubview:_chatTextField belowSubview:self.videoToolView];
            
        } else if (self.liveType == LiveTypeAudio) {
            [self.view insertSubview:_chatTextField belowSubview:self.audioToolView];
        }
    }
    return _chatTextField;
}

#pragma mark - 用户列表 1主播pk 2用户弹出框
- (LiveUserListView *)userListView
{
    if (!_userListView) {
        _userListView = [LiveUserListView liveUserListView];
        [self.view addSubview:_userListView];
        _userListView.roomId = self.roomId;
        [_userListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.mas_equalTo(SCREEN_HEIGHT);
            make.height.mas_equalTo(SCREEN_HEIGHT);
            make.width.mas_equalTo(SCREEN_WIDTH);
        }];
        
        WeakSelf
        _userListView.clickBlock = ^(BOOL isAnchor, LiveUserModel   * _Nonnull model) {
            
            if (weakSelf.isAnchor) {
                [weakSelf hidenUserListView];
            }
            if (isAnchor) {
                //主播pk
                LiveUserModel *m = (LiveUserModel *)model;
                [LiveUserListManager beginWriteTransaction];
                m.isAnchor = YES;
                [LiveUserListManager defaultManager].pkAnchor = m;
                [LiveUserListManager commitWriteTransaction];
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(pkConnectWithUid:roomId:)]) {
                    [weakSelf.delegate pkConnectWithUid:m.Uid roomId:m.RoomId];
                }
                [weakSelf showLinkHud];
                NSString *param = [NSString stringWithFormat:@"PK uid:%@, roomId:%@",m.Uid,m.RoomId];
                YYLogFuncEntry([weakSelf class],_cmd,param);
            } else {
                LiveUserModel *localUser = [LiveUserListManager objectForPrimaryKey:LoginUserUidString];
                if (localUser.isAnchor) {
                    if (!model.isAnchor) {
                        weakSelf.userView.viewTyle = LiveUserViewTypeThreeStyle;
                        [weakSelf showUserViewWithUid:model.Uid];
                    }
                }
                if (localUser.isAdmin) {
                    if (!model.isAdmin && !model.isAnchor) {
                        weakSelf.userView.viewTyle = LiveUserViewTypeTwoAdminStyle;
                        [weakSelf showUserViewWithUid:model.Uid];
                    }
                }
            }
        };
        
        _userListView.allMuteBlock = ^(UIButton *button) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(setRoomAllmuteStatus:button:)]) {
                [weakSelf.delegate setRoomAllmuteStatus:!button.selected button:button];
            }
        };
    }
    return _userListView;
}
#pragma mark - 用户弹出框 禁言 踢出 升管
- (LiveUserView *)userView
{
    if (!_userView) {
        _userView = [LiveUserView userView];
        _userView.viewTyle = LiveUserViewTypeThreeStyle;
        [self.view addSubview:_userView];
        _userView.hidden = YES;
        [_userView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(@0);
            make.width.equalTo(@(USERVIEW_W));
            make.height.equalTo(@(USERVIEW_H));
        }];
        WeakSelf
        [_userView setManagementBlock:^(LiveUserModel * _Nullable userModel, ManagementUserType type) {
            [weakSelf hiddenUserView];
            switch (type) {
                case ManagementUserTypeCloseMirc: {//闭麦
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(mircManagerActionWithModel:mircType:)]) {
                        [weakSelf.delegate mircManagerActionWithModel:userModel mircType:ManagementUserTypeCloseMirc];
                    }
                }
                    break;
                case ManagementUserTypeOpenMirc: {// 开麦
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(mircManagerActionWithModel:mircType:)]) {
                        [weakSelf.delegate mircManagerActionWithModel:userModel mircType:ManagementUserTypeOpenMirc];
                    }
                }
                    break;
                case ManagementUserTypeDownMirc: {//下麦
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(mircManagerActionWithModel:mircType:)]) {
                        [weakSelf.delegate mircManagerActionWithModel:userModel mircType:ManagementUserTypeDownMirc];
                    }
                }
                    break;
                case ManagementUserTypeMute: {//禁言
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(mutedRemoteUser:)]) {
                        [weakSelf.delegate mutedRemoteUser:userModel];
                    }
                    
                }
                    break;
                case ManagementUserTypeUnmute: {//解禁言
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(unmuteRemoteUser:)]) {
                        [weakSelf.delegate unmuteRemoteUser:userModel];
                    }
                    
                }
                    break;
                case ManagementUserTypeAddAdmin: {//升管
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(addAdminRemoteUser:)]) {
                        [weakSelf.delegate addAdminRemoteUser:userModel];
                    }
                    
                }
                    break;
                case ManagementUserTypeRemoveAdmin: {//降管
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(removeAdminRemoteUser:)]) {
                        [weakSelf.delegate removeAdminRemoteUser:userModel];
                    }
                }
                    break;
                case ManagementUserTypeKick: {//踢出
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(kickOutRemoteUser:)]) {
                        [weakSelf.delegate kickOutRemoteUser:userModel];
                    }
                    
                }
                    break;
                default:
                    break;
            }
        }];
        
    }
    return _userView;
}

#pragma mark - 同意   拒绝连麦
- (ApplyAlertView *)applyView
{
    if (!_applyView) {
        _applyView = [[ApplyAlertView alloc]initWithLiveType:self.liveType];
        [self.view addSubview:_applyView];
        _applyView.hidden = YES;
        [_applyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        WeakSelf
        _applyView.applyBlock = ^(ApplyActionType type, NSString *uid,NSString *roomId) {
            [weakSelf hiddenMircApplayWithUid:weakSelf.applyView.model.Uid];
            switch (type) {
                case ApplyActionTypeAgree: {//同意连麦
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(acceptLinkMircWithUid:roomId:)]) {
                        [weakSelf.delegate acceptLinkMircWithUid:uid roomId:roomId];
                    }
                }
                    break;
                case ApplyActionTypeReject: {//拒绝连麦
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(refuseLinkMircWithUid:)]) {
                        [weakSelf.delegate refuseLinkMircWithUid:uid];
                    }
                }
                    break;
                default:
                    break;
            }
            
        };
        
    }
    return _applyView;
}


- (UIView *)netAlertView
{
    if (!_netAlertView) {
        _netAlertView = [[UIView alloc]initWithFrame:self.view.bounds];
        [MBProgressHUD yy_showMessage:NSLocalizedString(@"Reconnecting to internet, please wait.", nil) toView:_netAlertView];
        [self.view addSubview:_netAlertView];
    }
    return _netAlertView;
}

#pragma mark - 显示码率

- (LiveCodeRateView *)bottomCodeRateView
{
    if (!_bottomCodeRateView) {
        _bottomCodeRateView = [LiveCodeRateView liveCodeRateView];
        [self.view addSubview:_bottomCodeRateView];
        _bottomCodeRateView.hidden = YES;
        WeakSelf
        [_bottomCodeRateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(weakSelf.view.mas_right).offset(-8);
            make.height.mas_equalTo(CodeView_H);
            if (self.liveType == LiveTypeVideo) {
                make.bottom.equalTo(weakSelf.videoToolView.mas_top).offset(-10);
                
            } else if (self.liveType == LiveTypeAudio) {
                make.bottom.equalTo(weakSelf.audioToolView.mas_top).offset(-10);
            }
        }];
    }
    return _bottomCodeRateView;
}

- (void)updateViewConstraints
{
    //更新底部码块视图
    WeakSelf
    if (self.liveType == LiveTypeVideo) {
        [self.bottomCodeRateView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(weakSelf.videoToolView.mas_top).offset(-10);
        }];
        
    } else if (self.liveType == LiveTypeAudio) {
        if (self.isAnchor) {
            [self.bottomCodeRateView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(weakSelf.audioToolView.mas_top).offset(-10);
            }];
        } else {
            [self.bottomCodeRateView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(weakSelf.audioToolView.mas_top).offset(-52);
            }];
        }
    }
    
}

- (void)showMircApplayWithUid:(NSString *)uid
{
    LiveUserModel *user = [LiveUserListManager objectForPrimaryKey:uid];
    
    [self.view bringSubviewToFront:self.applyView];
    
    self.applyView.hidden = NO;
    
    self.applyView.model = user;
    
}

//显示连麦弹框
- (void)showMircApplay:(id)model
{
    [self.view bringSubviewToFront:self.applyView];
    
    self.applyView.hidden = NO;
    
    self.applyView.model = model;
}

//隐藏连麦弹框
- (void)hiddenMircApplayWithUid:(NSString *)uid
{
    if ([uid isEqualToString:self.applyView.model.Uid]) {
        [self.view sendSubviewToBack:self.applyView];
        self.applyView.hidden = YES;
        self.applyView.model = nil;
    }
}

// 开启倒计时效果
- (void)startTimer
{
    
    if (self.timer) {
        dispatch_cancel(self.timer);
        self.timer = nil;
    }
    WeakSelf
    __block NSInteger time = 15; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(self.timer ,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(self.timer , ^{
        
        if (time <= 0) { //倒计时结束，关闭
            
            dispatch_source_cancel(weakSelf.timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮的样式
                weakSelf.linkHUD.text = [NSString stringWithFormat:@"%@(15s)",NSLocalizedString(@"Connecting...",nil)];
                
            });
            
        } else {
            
            int seconds = time % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮显示读秒效果
                weakSelf.linkHUD.text = [NSString stringWithFormat:@"%@(%.2ds)", NSLocalizedString(@"Connecting...",nil),seconds];
                
            });
            time--;
        }
    });
    dispatch_resume(self.timer);
}

//停止倒计时
- (void)stopTimer
{
    if (self.timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

//显示用户列表
- (void)showUserListView
{
    
    self.userListView.hidden = NO;
    self.userListViewIsHidden = NO;
    [self.view bringSubviewToFront:self.userListView];
    self.userListView.transform = CGAffineTransformMakeTranslation(0, - SCREEN_HEIGHT);
    
}

- (void)showNetAlertView
{
    //网络等待框延时显示
    [UIView animateWithDuration:2.0 animations:^{
      [self netAlertView];
    }];
}

- (void)hiddenNetAlertView
{
    //隐藏网络提示框
    [self.netAlertView removeFromSuperview];
    self.netAlertView = nil;
}
#pragma mark - 隐藏用户列表
- (void)hidenUserListView
{
    if (!self.userListView.hidden) {
        self.userListView.hidden = YES;
        self.userListViewIsHidden = YES;
        self.userListView.transform = CGAffineTransformIdentity;
    }
}
//显示连接中状态条 15s后自动消失
- (void)showLinkHud
{
    [self.view bringSubviewToFront:self.linkHUD];
    self.linkHUD.hidden = NO;
    [self startTimer];
    
}

//隐藏连接中状态条
- (void)hidenlinkHud
{
    [self.view sendSubviewToBack:self.linkHUD];
    self.linkHUD.hidden = YES;
    [self stopTimer];
}

- (void)showUserViewWithUid:(NSString *)uid
{
    dispatch_async(dispatch_get_main_queue(), ^{
        LiveUserModel *user = [LiveUserListManager objectForPrimaryKey:uid];
        
        [self.view bringSubviewToFront:self.userView];
        
        self.userView.hidden = NO;
        
        self.userView.model = user;
    });
}

//显示用户弹出框
- (void)showUserViewWithModel:(LiveUserModel *)model
{
    WeakSelf
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.userView.hidden = NO;
        weakSelf.userView.transform = CGAffineTransformIdentity;
        weakSelf.userView.model = model;
    }];
}

- (void)showCodeView
{
    self.bottomCodeRateView.hidden = NO;
    [self refreshCodeView];
}


- (void)hiddenCodeView
{
    self.bottomCodeRateView.hidden = YES;
}

//隐藏用户弹出框
- (void)hiddenUserView
{
    WeakSelf
    if (self.userView) {
        [UIView animateWithDuration:0.5 animations:^{
            
            weakSelf.userView.transform = CGAffineTransformMakeScale(0.3, 0.3);
            weakSelf.userView.hidden = YES;
        } completion:^(BOOL finished) {
            [weakSelf.userView removeFromSuperview];
            weakSelf.userView = nil;
        }];
    }
}


- (void)setIsmute:(BOOL)ismute
{
    _ismute = ismute;
    if (ismute) {
        [self.chatTextField resignFirstResponder];
    }
    self.chatTextField.userInteractionEnabled = !_ismute;
    
    if (self.liveType == LiveTypeVideo) {
        self.videoToolView.talkButtonTitle = _ismute ? NSLocalizedString(@"Banned",nil): NSLocalizedString(@"Hey~", nil);//@"禁言中"
        
    } else if (self.liveType == LiveTypeAudio) {
        self.audioToolView.talkButtonTitle = _ismute ? NSLocalizedString(@"Banned",nil): NSLocalizedString(@"Hey~", nil);//@"禁言中"
    }
    
}

- (void)setUserViewType:(LiveUserViewType)userViewType
{
    _userViewType = userViewType;
    self.userView.viewTyle = _userViewType;
}

- (NetworkQualityStauts *)qualityModel
{
    if (!_qualityModel) {
        _qualityModel = [[NetworkQualityStauts alloc]init];
        _qualityModel.netWorkQuality = [[NetWorkQuality alloc]init];
    }
    return _qualityModel;
}

- (void)refreshCodeView
{
    self.bottomCodeRateView.userDetailString = [NSString stringWithFormat:@"UID:%@\n%@",[UserManager shareManager].currentUser.Uid,[UserManager shareManager].currentUser.NickName];
    self.bottomCodeRateView.qualityModel = self.qualityModel;
    [self.bottomCodeRateView refreshCodeView];
}

- (void)refreshBottomToolView
{
    if (self.liveType == LiveTypeAudio) {
        self.audioToolView.mircEnable = self.mircEnable;
        //根据属性值更新视图
        self.audioToolView.localRuningMirc = self.localRuningMirc;
    } else if (self.liveType == LiveTypeVideo) {
        self.videoToolView.mircEnable = self.mircEnable;
        self.videoToolView.localRuningMirc = self.localRuningMirc;
        [self.videoToolView refreshVideoToolView];
    }
    
}

- (void)updateUserListViewStatus
{
    if (self.userListViewIsHidden) {
        [self hidenUserListView];
    } else {
        [self.userListView refreshUserViewWithRoomId:self.roomId];
        [self showUserListView];
    }
}
- (void)updateAnchorListViewWithArray:(NSArray<LiveUserModel *> *)dataArray
{
    if (self.userListViewIsHidden) {
        [self hidenUserListView];
    } else {
        //刷新视图
        [self.userListView refreshAnchorViewWithArray:dataArray];
        [self showUserListView];
    }
}
- (void)updateLinkHudHiddenStatus:(BOOL)hidden
{
    if (hidden) {
        [self hidenlinkHud];
    } else {
        [self showLinkHud];
    }
}

- (void)refreshTalkPublicTabelView
{
    self.talkTableView.dataArray = self.talkDataArray;
    [self.talkTableView reloadData];
    [self.talkTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.talkDataArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)hiddenCurrentView
{
    [self hidenUserListView];
    //收起键盘
    //输入文字清空
    self.chatTextField.text = nil;
    [self.chatTextField resignFirstResponder];
}


#pragma mark  - 键盘出现

- (void)keyboardWillShow:(NSNotification *)note
{
    NSValue *value = [note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect chatTextFieldFreame = self.chatTextField.frame;
    chatTextFieldFreame.origin.x = 0;
    chatTextFieldFreame.origin.y = SCREEN_HEIGHT - [value CGRectValue].size.height - 44;
    chatTextFieldFreame.size.height = 44;
    self.chatTextField.frame = chatTextFieldFreame;
    self.chatTextField.backgroundColor = [UIColor whiteColor];
    self.chatTextField.placeholder = NSLocalizedString(@"Hey~", nil);
    CGRect keyBoardRect=[note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    WeakSelf
    [UIView animateWithDuration:0.08 animations:^{
        weakSelf.chatTextField.alpha = 1;
        weakSelf.talkTableView.transform = CGAffineTransformMakeTranslation(0,keyBoardRect.size.height  + PubTalk_H - (Live_Tool_H + TabbarSafeBottomMargin + SCREEN_HEIGHT));
    }];
}

#pragma mark - 键盘消失
- (void)keyboardWillHide:(NSNotification *)note
{
    CGRect chatTextFieldFreame = self.chatTextField.frame;
    chatTextFieldFreame.origin.x = 0;
    chatTextFieldFreame.origin.y = SCREEN_HEIGHT - TabbarSafeBottomMargin - Live_Tool_H;
    chatTextFieldFreame.size.height = Live_Tool_H;
    self.chatTextField.frame = chatTextFieldFreame;
    self.chatTextField.backgroundColor = [UIColor clearColor];
    self.chatTextField.placeholder = nil;
    WeakSelf
    [UIView animateWithDuration:0.08 animations:^{
        weakSelf.chatTextField.alpha = 0.1;
        weakSelf.talkTableView.transform = CGAffineTransformIdentity;
        
    }];
}

@end
