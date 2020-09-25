//
//  VideoContentView.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/4/26.
//  Copyright © 2020 sy. All rights reserved.
//

#import "VideoContentView.h"
#import "PeopleHeader.h"
#import "SYPlayer.h"
#import "LiveBottomSettingView.h"
#import "GearPickView.h"
#import "LiveUserListManager.h"


#define LIVE_BG_VIEW_SMALL_TOP 84
#define LIVE_BG_VIEW_SMALL_LEFT 0
#define LIVE_BG_VIEW_SMALL_RIGHT (self.bgView.frame.size.width) / 2
#define LIVE_BG_VIEW_SMALL_HEIGHT @(310 * [UIScreen mainScreen].bounds.size.height / 667)
#define LIVE_BG_VIEW_SMALL_WIDTH @((self.bgView.frame.size.width) / 2)

@interface VideoContentView ()<ThunderVideoCaptureFrameObserver, SYEffectViewDelegate>

@property (nonatomic, strong)LiveUserListManager *roomModel;
//主播信息栏

//主播挂断按钮
@property(nonatomic, strong) UIButton *hungUpButton;

//连麦者的头像视图
@property (nullable, nonatomic, strong)PeopleHeader *headerView;

@property(nonatomic, strong)  SYPlayer *player;
/**底部设置栏*/
@property (nonatomic, strong)LiveBottomSettingView *settingView;
//档位选择pickview
@property (nonatomic, strong) GearPickView *gearPickView;

#if USE_BEATIFY
@property (nonatomic, strong) SYEffectView *effectView;
#endif

@end

@implementation VideoContentView
- (instancetype)initWithRoomId:(NSString *)roomId
{
   self = [super init];
    if (self) {
        
        LiveUserListManager *roomModel = [LiveUserListManager defaultManager];
        self.roomModel = roomModel;
        if ([roomModel.ROwner.Uid isEqualToString:LoginUserUidString]) {
            self.isAnchor = YES;
        } else {
            self.isAnchor = NO;
        }
        [self setup];
        [self refreshView];
    }
    return self;
}
- (instancetype)initWithIsAnchor:(BOOL)isAnchor
{
   
    self = [super init];
    if (self) {
        self.isAnchor = isAnchor;
        [self setup];
    }
    return self;
}

- (void)setup
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hidenSettingView) name:kNotifySettingViewHidden object:nil];
    [self baseContentView];
    self.anchorView.hidden = NO;
    self.headerView.hidden = YES;
    self.hungUpButton.hidden = YES;
    #if USE_BEATIFY
        [self addEffectView];
    #endif
    
    self.userInteractionEnabled = YES;
}

- (BaseLiveContentView *)baseContentView
{
    if (!_baseContentView) {
        _baseContentView = [[BaseLiveContentView alloc]initWithRoomid:self.roomModel.RoomId view:self];
    }
    return _baseContentView;
}
#pragma mark - 播放器
- (UIButton *)hungUpButton
{
    if (!_hungUpButton) {
        _hungUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_hungUpButton];
        [_hungUpButton setTitle:NSLocalizedString(@"Video_Disconnect", nil) forState:UIControlStateNormal];// Disconnect
        CGFloat wh =[NSLocalizedString(@"Video_Disconnect", nil) boundingRectWithSize:CGSizeMake(1000, 13) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:FONT_Regular size:12.0f]} context:nil].size.width;
        [_hungUpButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@-12);
            make.top.mas_equalTo(LIVE_BG_VIEW_SMALL_HEIGHT.longLongValue + LIVE_BG_VIEW_SMALL_TOP - 25);
            make.size.mas_equalTo(CGSizeMake(wh > 46 ? wh + 5 : 46, 20));
        }];
        [_hungUpButton addTarget:self action:@selector(hungUpAction) forControlEvents:UIControlEventTouchUpInside];
        
        [_hungUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _hungUpButton.titleLabel.font = [UIFont fontWithName:FONT_Regular size:12.0f];
        _hungUpButton.layer.cornerRadius = 10;
        _hungUpButton.layer.masksToBounds = YES;
        UIImage *bgImage = [UIImage yy_gradientImageWithBounds:CGRectMake(0,0,46,20) andColors:@[[UIColor colorWithRed:23/255.0 green:202/255.0 blue:205/255.0 alpha:1.0],[UIColor colorWithRed:1/255.0 green:220/255.0 blue:149/255.0 alpha:1.0]] andGradientType:GradientDirectionLeftToRight];
        [_hungUpButton setBackgroundImage:bgImage forState:UIControlStateNormal];
        _hungUpButton.hidden = YES;
    }
    return _hungUpButton;
}

//挂断连麦
- (void)hungUpAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoLiveHungupMirc)]) {
        [self.delegate videoLiveHungupMirc];
    }
}

#if USE_BEATIFY
- (void)setEffectDelegate:(id<SYEffectViewDelegate>)effectDelegate
{
    _effectDelegate = effectDelegate;
    self.effectView.delegate = _effectDelegate;
}


- (void)setDelegate:(id<VideoContentViewDelegate>)delegate
{
    _delegate = delegate;
    if ([_delegate respondsToSelector:@selector(videoLiveAddEffectView:)]) {
        [_delegate videoLiveAddEffectView:self.effectView];
    }
}
#endif

- (void)setBaseDelegate:(id<BaseLiveContentViewDelegate>)baseDelegate
{
    _baseDelegate = baseDelegate;
    self.baseContentView.delegate = baseDelegate;
}
#pragma mark - 主播信息


- (PeopleHeader *)headerView
{
    if (!_headerView) {
        _headerView = [PeopleHeader shareInstance];
        [self addSubview:_headerView];
        _headerView.hidden = YES;
        [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(LIVE_BG_VIEW_SMALL_TOP + 2);
            make.left.mas_equalTo(SCREEN_WIDTH/2);
            make.size.mas_equalTo(CGSizeMake(60, 40));
        }];
    }
    return _headerView;
}

- (LiveAnchorView *)anchorView
{
    if (!_anchorView) {
        LiveAnchorView *anchorView = [LiveAnchorView liveAnchorView];
        [self addSubview:anchorView];
        
        [anchorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(@0);
            make.height.equalTo(@(Anchor_H));
            make.top.equalTo(@StatusBarHeight);
        }];
        WeakSelf
        anchorView.quitBlock = ^{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(videoLiveCloseRoom)]) {
                [weakSelf.delegate videoLiveCloseRoom];
            }
        };
        
        anchorView.iconClickBlock = ^(IconClikType type,BOOL selected) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(videoLiveOpenUserList)]) {
                [weakSelf.delegate videoLiveOpenUserList];
            }
        };
        _anchorView = anchorView;
    }
    return _anchorView;
}
#pragma mark - 清晰度档位
- (GearPickView *)gearPickView
{
    if (!_gearPickView) {
        _gearPickView = [GearPickView gearPickView];
        [self addSubview:_gearPickView];
        [_gearPickView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.mas_equalTo(SCREEN_HEIGHT);
            make.height.mas_equalTo(Gear_H);
            make.width.mas_equalTo(SCREEN_WIDTH);
        }];
    }
    return _gearPickView;
}

- (LiveBottomSettingView *)settingView
{
    if (!_settingView) {
        _settingView = [LiveBottomSettingView bottomSettingView];
        [self addSubview:_settingView];
        _settingView.hidden = YES;
        [_settingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-8);
            make.top.mas_equalTo(SCREEN_HEIGHT);
            make.width.equalTo(@(Setting_W));
            make.height.equalTo(@(Setting_H));
        }];
        WeakSelf
        _settingView.settingBlock = ^(BottomSettingType type, UIButton *button) {
            //再次点击设置按钮 让 settingview 显示
            weakSelf.settingViewHidden = NO;
            switch (type) {
                case BottomSettingTypeChangeCamera: {//切换摄像头
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(videoLiveChangeCamera:)]) {
                        [weakSelf.delegate videoLiveChangeCamera:button];
                    }
                    break;
                }
                    
                case BottomSettingTypeMirroring: {//镜像
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(videoLiveChangeMirroring:)]) {
                        [weakSelf.delegate videoLiveChangeMirroring:button];
                    }
                }
                    break;
                case BottomSettingTypeGear: {//档位
                    
                    [weakSelf showGearView];
                }
                    break;
                case BottomSettingTypeSkinCare:    //美颜
#if USE_BEATIFY
                    [weakSelf showEffectView];
#endif
                    break;
                default:
                    break;
            }
        };
        
    }
    return _settingView;
}

- (void)showGearView
{
    [self hidenSettingView];
    self.gearPickView.hidden = NO;
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.gearPickView.transform = CGAffineTransformMakeTranslation(0, - Gear_H);
        
    }];
}

- (void)hidenGearView
{
    if (!self.gearPickView.hidden) {
        self.gearPickView.hidden = YES;
        WeakSelf
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.gearPickView.transform = CGAffineTransformIdentity;
        }];
    }
    
}

- (void)showSettingView
{
    self.settingView.hidden = NO;
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.settingView.transform = CGAffineTransformMakeTranslation(0, - Setting_H - Live_Tool_H - TabbarSafeBottomMargin - 8);
    }];
    self.settingViewHidden = YES;

}

- (void)hidenSettingView
{
   
    self.settingView.hidden = YES;
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.settingView.transform = CGAffineTransformIdentity;
    }];
    self.settingViewHidden = NO;
    
}


#pragma mark - 美颜
#if USE_BEATIFY
#pragma mark - Effect
- (SYEffectView *)effectView
{
    if (!_effectView) {
        SYEffectView *view = [SYEffectView loadNibView];
        view.hidden = YES;
        _effectView = view;
    }
    return _effectView;
}

- (void)addEffectView
{
    [self addSubview:self.effectView];
    [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (void)showEffectView
{
    [self.effectView showEffectView];
}
#endif

//刷新房间人数
- (void)setPeopleCount:(NSInteger)peopleCount
{
    _peopleCount = peopleCount;
    self.anchorView.peopleCount = _peopleCount;
}

//设置rtmp 或 cdn 播放模式
- (void)setPublishMode:(PublishMode)publishMode
{
    _publishMode = publishMode;
    self.anchorView.publishMode = publishMode;
    self.baseContentView.publishMode = publishMode;
}
//设置是否可以操作清晰度
- (void)setIsCanSettingGear:(BOOL)isCanSettingGear
{
    _isCanSettingGear = isCanSettingGear;
    self.settingView.isCanSettingGear = isCanSettingGear;
}
//设置连麦者头像的显示状态
- (void)setShouldHiddenMircedHeader:(BOOL)shouldHiddenMircedHeader
{
    self.headerView.hidden = shouldHiddenMircedHeader;
}
//设置连麦者的头像
- (void)setMircedPeopleModel:(LiveUserModel *)mircedPeopleModel
{
    self.headerView.model = mircedPeopleModel;
}
//设置挂断按钮的状态
- (void)setIsHiddenHungupButton:(BOOL)isHiddenHungupButton
{
    self.hungUpButton.hidden = isHiddenHungupButton;
    YYLogDebug(@"[MouseLive VideoContentView] hungUpButton.hidden %d",self.hungUpButton.hidden);
}


#pragma mark- 刷新主播头像信息
- (void)refreshAnchorViewWithModel:(LiveRoomInfoModel *)model;
{
    self.anchorView.roomInfoModel = model;
}

- (void)updateSettingViewStatus:(BOOL)hidden
{
    
    if (hidden) {
        [self hidenSettingView];
    } else {
        [self showSettingView];
    }
}

//根据数据刷新视图
- (void)refreshView
{
    [self refreshAnchorView];
}

- (void)refreshAnchorView
{
    self.anchorView.roomModel = self.roomModel;
    //房间人数
    self.peopleCount = self.roomModel.onlineUserList.count;
   
}

- (void)hiddenCurrentView
{
    [self hidenSettingView];
    [self hidenGearView];
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    UIView *v = [super hitTest:point withEvent:event];
//    if ([v isKindOfClass:NSClassFromString(@"LivePublicTalkView")]) {
//        return nil;
//    }
//    return v;
//}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.baseContentView hiddenCurrentView];
    [self hiddenCurrentView];
    //响应断开按钮
    [super touchesBegan:touches withEvent:event];
}
@end
