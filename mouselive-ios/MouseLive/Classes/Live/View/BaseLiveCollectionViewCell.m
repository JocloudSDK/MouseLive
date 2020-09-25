//
//  VideoLiveCollectionViewCell.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/3.
//  Copyright © 2020 sy. All rights reserved.
//

#import "BaseLiveCollectionViewCell.h"
#import "LiveAnchorView.h"
#import "LiveBottonToolView.h"
#import "LivePublicTalkView.h"
#import "LiveCodeRateView.h"
#import "LiveBottomSettingView.h"
#import "GearPickView.h"
#import "AudioContentView.h"
#import "PublishViewController.h"
#import "ApplyAlertView.h"
#import "LiveUserView.h"


@interface BaseLiveCollectionViewCell()<LiveBGDelegate>


/**显示码流*/
@property (nonatomic, strong) LiveCodeRateView *codeRateView;
/** 留言区*/
@property (nonatomic, weak) LivePublicTalkView *talkTableView;

/**底部工具栏*/
@property (nonatomic, strong) LiveBottonToolView *toolView;
/**主播信息栏*/

@property (nonatomic, strong) LiveAnchorView *anchorView;
/**底部设置栏*/
@property (nonatomic, strong)LiveBottomSettingView *settingView;
//档位选择pickview
@property (nonatomic, strong)GearPickView *gearPickView;
//申请连麦
@property (nonatomic, strong)ApplyAlertView *applyView;
/**观众信息*/
@property (nonatomic, strong)LiveUserView *userView;

/** 直播开始前的占位图片 */
@property(nonatomic, strong) UIImageView *placeHolderView;


@end

@implementation BaseLiveCollectionViewCell

- (LiveUserView *)userView
{
    if (!_userView) {
        _userView = [LiveUserView userView];
        [self.contentView insertSubview:_userView aboveSubview:self.liveContentView];
        
        [_userView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(@0);
            make.centerY.equalTo(@-100);
            make.width.equalTo(@(USERVIEW_W));
            make.height.equalTo(@(USERVIEW_H));
        }];
        _userView.transform = CGAffineTransformMakeScale(0.3, 0.3);
        typeof (self) weakSelf = self;
        
        [_userView setCloseBlock:^{
            [weakSelf hiddenUserView];
        }];
        
    }
    return _userView;
}

/**直播页面*/
- (LiveBGView *)livebgView
{
    if (!_livebgView) {
        _livebgView = [[LiveBGView alloc]initWithFrame:self.contentView.bounds anchor:self.isAnchor delegate:self limit:self.limit haveVideo:self.haveVideo];
        [self.contentView addSubview:_livebgView];
    }
    return _livebgView;
}

- (ApplyAlertView *)applyView
{
    if (!_applyView) {
        _applyView = [ApplyAlertView applyAlertView];
        [self.contentView insertSubview:_applyView aboveSubview:self.liveContentView];
        
        [_applyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(@0);
            make.centerY.equalTo(@-100);
            make.width.equalTo(@(USERVIEW_W));
            make.height.equalTo(@(ApplyView_H));
        }];
        _applyView.transform = CGAffineTransformMakeScale(0.3, 0.3);
        typeof (self) weakSelf = self;
        [_applyView setCloseBlock:^{
            [weakSelf hiddenMircApplay];
        }];
        
    }
    return _applyView;
}
#pragma mark - 清晰度档位
- (GearPickView *)gearPickView
{
    if (!_gearPickView) {
        _gearPickView = [GearPickView gearPickView];
        [self.contentView insertSubview:_gearPickView aboveSubview:self.liveContentView];
        [_gearPickView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.mas_equalTo(SCREEN_HEIGHT);
            make.height.mas_equalTo(Gear_H);
            make.width.mas_equalTo(SCREEN_WIDTH);
        }];
    }
    return _gearPickView;
}

#pragma mark - 设置弹出栏
- (LiveBottomSettingView *)settingView
{
    if (!_settingView) {
        _settingView = [LiveBottomSettingView bottomSettingView];
        [self.contentView insertSubview:_settingView aboveSubview:self.liveContentView];
        [_settingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-8);
            make.top.mas_equalTo(SCREEN_HEIGHT);
            make.width.equalTo(@(Setting_W));
            make.height.equalTo(@(Setting_H));
        }];
        typeof (self)weakSelf = self;
        _settingView.settingBlock = ^(BottomSettingType type) {
            switch (type) {
                case BottomSettingTypeChangeCamera://切换摄像头
                    
                    break;
                case BottomSettingTypeMirroring:   //镜像
                    
                    break;
                case BottomSettingTypeGear:        //档位
                    NSLog(@"切换档位");
                    [weakSelf showGearView];
                    break;
                case BottomSettingTypeSkinCare:    //美颜
                    
                    break;
                default:
                    break;
            }
        };
        
    }
    return _settingView;
}

#pragma mark - 显示码率
- (LiveCodeRateView *)codeRateView
{
    if (!_codeRateView) {
        _codeRateView = [LiveCodeRateView liveCodeRateView];
        [self.contentView insertSubview:_codeRateView aboveSubview:self.liveContentView];
        _codeRateView.hidden = YES;
        [_codeRateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(8);
            make.top.equalTo(@((Anchor_H + StatusBarHeight + 8)));
            make.size.mas_equalTo(CGSizeMake(CodeView_W, CodeView_H));
        }];
        
    }
    return _codeRateView;
}
#pragma mark - 公聊
- (LivePublicTalkView *)talkTableView
{
    if (!_talkTableView) {
        LivePublicTalkView *talkTableView = [[LivePublicTalkView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        talkTableView.backgroundColor = [UIColor clearColor];
        [self.contentView insertSubview:talkTableView aboveSubview:self.liveContentView];
        [talkTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.width.equalTo(@(SCREEN_WIDTH));
            make.bottom.mas_equalTo(self.toolView.mas_top).offset(-10);
            make.height.equalTo(@(PubTalk_H));
        }];
        _talkTableView = talkTableView;
    }
    return _talkTableView;
}
#pragma mark - 主播信息
- (LiveAnchorView *)anchorView
{
    if (!_anchorView) {
        LiveAnchorView *anchorView = [LiveAnchorView liveAnchorView];
        [self.contentView insertSubview:anchorView aboveSubview:self.liveContentView];
        [anchorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(@0);
            make.height.equalTo(@(Anchor_H));
            make.top.equalTo(@StatusBarHeight);
        }];
        anchorView.quitBlock = ^{
            [self quit];
        };
        
        _anchorView = anchorView;
    }
    return _anchorView;
}

#pragma mark - 底部工具栏
- (LiveBottonToolView *)toolView
{
    if (!_toolView) {
        LiveBottonToolView *toolView = [[LiveBottonToolView alloc] init];
        [self.contentView insertSubview:toolView aboveSubview:self.liveContentView];
        [toolView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(@0);
            make.bottom.equalTo(@(-TabbarSafeBottomMargin));
            make.height.equalTo(@(Live_Tool_H));
        }];
        [toolView setClickToolBlock:^(LiveToolType type) {
            switch (type) {
                    
                case LiveToolTypeClosemicr: {//主播闭麦

                    [self.parentVc showHint:@"直播已结束"];
                    [self quit];
                }
                    break;
                case LiveToolTypeLinkmicr: {//主播pk 观众连麦

                    [self linkMicr];
                }
                    
                    break;
                case LiveToolTypeSetting: {////设置

                    [self hiddenMircApplay];
                    [self showSettingView];
                }
                    break;
                case LiveToolTypeFeedback: {//反馈

                    [self hiddenMircApplay];
                    
                    [self pushFeedBackViewController];
                    
                }
                    break;
                case LiveToolTypeCodeRate: {//码率

                    [self hiddenMircApplay];
                    self.codeRateView.hidden = !self.codeRateView.hidden;
                    
                }
                    break;
                    
                default:
                    break;
            }
        }];
        _toolView = toolView;
    }
    return _toolView;
}

#pragma mark - contentView addSubview
#pragma mark -音聊
- (AudioContentView *)audioContentView
{
    if (!_audioContentView) {
        AudioContentView *audioContentView = [AudioContentView audioContentView];
        [self.contentView addSubview:audioContentView];
        [audioContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.top.mas_equalTo(120);
            make.bottom.mas_equalTo(0);
        }];
        _audioContentView = audioContentView;
        
    }
    return _audioContentView;
}

#pragma  mark - 视频聊

- (UIImageView *)placeHolderView
{
    if (!_placeHolderView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = self.contentView.bounds;
        imageView.backgroundColor = [UIColor greenColor];
        [self.contentView addSubview:imageView];
        _placeHolderView = imageView;
        [self.parentVc showGifLoding:nil inView:self.placeHolderView];
        _placeHolderView.userInteractionEnabled = YES;
        // 强制布局
        [_placeHolderView layoutIfNeeded];
    }
    return _placeHolderView;
}

#pragma mark - 初始化方法
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupLiveView];
        [self startLive];
        //档位选择
        self.gearPickView.hidden = YES;
        //主播信息
        self.anchorView.hidden = NO;
        //底部工具栏
        self.toolView.hidden = NO;
        //设置菜单栏
        self.settingView.hidden = YES;
        [self.talkTableView reloadData];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingGear:) name:kNotifySettingGear object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickUser:) name:kNotifyClickUser object:nil];
        
    }
    return self;
}

#pragma mark - 点击了用户
- (void)clickUser:(NSNotification *)notify
{
    
    NSDictionary *info = notify.object;
    NSString *isAnchor = [info objectForKey:@"isAnchor"];
    if ([isAnchor isEqualToString:@"1"]) {
        LiveAnchorModel *model = [info objectForKey:@"data"];
                //主播pk
        [self.livebgView connectWithUid:model.AId roomid:model.ARoom];
        
    } else {
        //观众管理
        LiveUserModel *model = [info objectForKey:@"data"];
        [UIView animateWithDuration:0.5 animations:^{
            self.userView.transform = CGAffineTransformIdentity;
            self.userView.model = model;
        }];
    }
}

#pragma mark- 刷新主播头像信息
- (void)refreshAnchorView
{
    if (self.isAnchor) {
        NSDictionary *userInfo= [[NSUserDefaults standardUserDefaults] dictionaryForKey:kUserInfo];
        if (userInfo != nil) {
            LiveUserModel *model = [LiveUserModel mj_objectWithKeyValues:userInfo];
            self.anchorView.user = model;
        }
    }
}

#pragma mark - 添加播放页面 子类必须实现
- (void)setupLiveView
{
    self.liveContentView = self.livebgView;
}

- (void)startLive
{
    if (self.config != nil) {
        [self.livebgView removeFromSuperview];
        self.livebgView = nil;
        self.liveContentView = self.livebgView;
    }
    [self.livebgView joinRoomWithConfig:self.config];
    [self refreshAnchorView];
}
#pragma mark -  通知
- (void)settingGear:(NSNotification *)note
{
    [self hidenGearView];
    
}
#pragma mark  - 键盘出现
- (void)keyboardWillShow:(NSNotification *)note
{
    CGRect keyBoardRect=[note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:0.3 animations:^{
        self.talkTableView.transform = CGAffineTransformMakeTranslation(0,keyBoardRect.size.height  + PubTalk_H - (Live_Tool_H + TabbarSafeBottomMargin + SCREEN_HEIGHT));
    }];
}
#pragma mark - 键盘消失
- (void)keyboardWillHide:(NSNotification *)note
{
    [UIView animateWithDuration:0.3 animations:^{
        self.talkTableView.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - 退出直播
- (void)quit
{
    [self.livebgView leaveRoom];
    [self.parentVc.navigationController popViewControllerAnimated:YES];
}

#pragma mark - private
- (void)showGearView
{
    [self hidenSettingView];
    self.gearPickView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.gearPickView.transform = CGAffineTransformMakeTranslation(0, - Gear_H);
        
    }];
}

- (void)hidenGearView
{
    self.gearPickView.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.gearPickView.transform = CGAffineTransformIdentity;
    }];
}

- (void)showSettingView
{
    self.settingView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.settingView.transform = CGAffineTransformMakeTranslation(0, - Setting_H - Live_Tool_H - TabbarSafeBottomMargin - 8);
    }];
    
}

- (void)hidenSettingView
{
    self.settingView.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.settingView.transform = CGAffineTransformIdentity;
    }];
}

- (void)pushFeedBackViewController
{
    PublishViewController *vc = [[PublishViewController alloc]init];
    [vc setBackButton];
    [self.parentVc.navigationController pushViewController:vc animated:YES];
}
//申请连麦
- (void)linkMicr
{
    //1.主播pk弹出主播列表
    if (self.isAnchor) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyClickUserList object:nil userInfo:nil];
    } else {
    //2观众连麦
        [self.livebgView connectWithUid:self.config.localUid roomid:self.config.localRoomId];
//        [self showMircApplay];
        
    }
    //观众连麦
    
}
//显示连麦弹框
- (void)showMircApplay:(LiveAnchorModel *)model
{
    [UIView animateWithDuration:0.5 animations:^{
        self.applyView.transform = CGAffineTransformIdentity;
        self.applyView.model = model;
    }];
}
//隐藏连麦弹框
- (void)hiddenMircApplay
{
    if (self.applyView) {
        [UIView animateWithDuration:0.5 animations:^{
            self.applyView.transform = CGAffineTransformMakeScale(0.3, 0.3);
        } completion:^(BOOL finished) {
            [self.applyView removeFromSuperview];
            self.applyView = nil;
        }];
    }
    
}

- (void)hiddenUserView
{
    if (self.userView) {
        [UIView animateWithDuration:0.5 animations:^{
            self.userView.transform = CGAffineTransformMakeScale(0.3, 0.3);
        } completion:^(BOOL finished) {
            [self.userView removeFromSuperview];
            self.userView = nil;
        }];
    }
}


@end
