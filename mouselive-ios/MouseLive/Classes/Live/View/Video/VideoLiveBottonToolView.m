//
//  LiveBottonToolView.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/3.
//  Copyright © 2020 sy. All rights reserved.
//

#import "VideoLiveBottonToolView.h"

#define  TOOL_W 36
@interface VideoLiveBottonToolView()
//是否是主播
@property (nonatomic, assign)BOOL isAnchor;
/** 工具背景*/
@property (nonatomic, weak) UIView *rightBgView;
/** 公聊区背景*/
@property (nonatomic, weak) UIView *talkBgView;
/** 公聊区*/
@property (nonatomic, strong)UILabel *talkLabel;
/** 底部工具*/
/**麦克风按钮*/
@property (nonatomic, strong)UIButton *mircButton;
/**连麦按钮*/
@property (nonatomic, strong)UIButton *linkButton;
/**设置按钮*/
@property (nonatomic, strong)UIButton *settingButton;

@end

@implementation VideoLiveBottonToolView

- (instancetype)initWithAnchor:(BOOL)isAnchor
{
    if (self = [super init]) {
        self.isAnchor = isAnchor;
        [self setupVideoTools];
        [self updateConstraints];
    }
    return self;
}

- (UIView *)talkBgView
{
    if (!_talkBgView) {
        UIView *talkBgView = [[UIView alloc]init];
        talkBgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        _talkBgView = talkBgView;
        [self addSubview:_talkBgView];
    }
    return _talkBgView;
}

- (UIView *)rightBgView
{
    if (!_rightBgView) {
        UIView *rightBgView = [[UIView alloc]init];
        _rightBgView = rightBgView;
        [self addSubview:_rightBgView];
    }
    return _rightBgView;
}


- (UILabel *)talkLabel
{
    if (!_talkLabel) {
        _talkLabel = [[UILabel alloc]init];
        _talkLabel.userInteractionEnabled = YES;
        _talkLabel.text = NSLocalizedString(@"Hey~", nil);
        _talkLabel.textColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.8];
        _talkLabel.font = [UIFont fontWithName:FONT_Regular size:14.0f];
        [_talkLabel setAdjustsFontSizeToFitWidth:YES];
        [self.talkBgView addSubview:_talkLabel];
    }
    return _talkLabel;
}


- (void)updateConstraints
{
    [super updateConstraints];
    
    [self.talkBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@-13);
        make.left.equalTo(@6);
        make.height.equalTo(@36);
        make.width.equalTo(@(88 * SCREEN_WIDTH/360));
    }];
    [UIView yy_maskViewToBounds:self.talkBgView radius:18.0f];
    
    [self.talkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.right.equalTo(@-15);
        make.top.equalTo(@0);
        make.height.equalTo(@36);
    }];
    
    CGFloat margin = 8;
    CGFloat W = (self.rightBgView.subviews.count - 1)* (TOOL_W + margin) + TOOL_W;
    [self.rightBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.talkBgView);
        make.width.mas_equalTo(W);
        make.height.equalTo(@36);
        make.right.equalTo(self).offset(-8);
    }];
    
    //视频房 布局
    UIButton *codeButton = [self.rightBgView.subviews lastObject];
    UIButton *feedbackButton = [self.rightBgView.subviews objectAtIndex:3];
    [codeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.right.mas_equalTo(-8);
        make.width.mas_equalTo(TOOL_W);
    }];
    [feedbackButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.right.mas_equalTo(codeButton.mas_left).offset(-8);
        make.width.mas_equalTo(TOOL_W);
    }];
    [self.settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.right.mas_equalTo(feedbackButton.mas_left).offset(-8);
        make.width.mas_equalTo(TOOL_W);
    }];
    
    [self.linkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.right.mas_equalTo(self.settingButton.mas_left).offset(-8);
        make.width.mas_equalTo(TOOL_W);
    }];
    
    [self.mircButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.right.mas_equalTo(self.linkButton.mas_left).offset(-8);
        make.width.mas_equalTo(TOOL_W);
    }];
    if ([LiveUserListManager defaultManager].RPublishMode == PUBLISH_STREAM_CDN) {
        if ([[LiveUserListManager defaultManager].ROwner.Uid isEqualToString:LoginUserUidString]) {
            self.linkButton.hidden = YES;
            [self.linkButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.mas_equalTo(0);
                make.right.mas_equalTo(self.linkButton.mas_left).offset(-8);
                make.width.mas_equalTo(0);
            }];
        } else {
            self.mircButton.hidden = YES;
            self.linkButton.hidden = YES;
            self.settingButton.hidden = YES;
        }
    }
}
/**
 视频房底部按钮
 */
- (void)setupVideoTools
{
    for (UIView *v in self.rightBgView.subviews) {
        [v removeFromSuperview];
    }
    [self.rightBgView addSubview:self.mircButton];
    [self.rightBgView addSubview:self.linkButton];
    [self.rightBgView addSubview:self.settingButton];
    NSArray *imageNames = @[@"live_tool_feedback", @"live_tool_code"];
    for (int i = 0; i < 2; i++) {
        UIButton *toolBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        toolBtn.backgroundColor = [UIColor clearColor];
        [toolBtn setImage:[UIImage imageNamed:imageNames[i]] forState:UIControlStateNormal];
        toolBtn.tag = i + 4;
        [toolBtn addTarget:self action:@selector(videoToolclick:) forControlEvents:UIControlEventTouchUpInside];
        [self.rightBgView addSubview:toolBtn];
    }
}

/**视频房按钮被点击*/
- (void)videoToolclick:(UIButton *)button
{
    if (![button isEqual:self.linkButton]) {
        button.selected = !button.selected;
    }
    if (self.clickToolBlock) {
        self.clickToolBlock(button.tag, button.selected,button);
    }
}

//禁言
- (void)shutupAction
{
    self.talkLabel.text = NSLocalizedString(@"Banned", nil);
    self.talkLabel.textColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.8];
}

//解禁言
- (void)notShutupAction
{
    _talkLabel.text = NSLocalizedString(@"Hey~", nil);
    _talkLabel.textColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.8];
}

- (void)settalkLabelTitle:(NSString *)talkLabelTitle
{
    self.talkLabel.text = talkLabelTitle;
}


/**
 视频房
 自己是否在连麦中
 1连麦中显示5个按钮
 2非连麦中显示 按照自己是否可以连麦进行设置
 */
//主播在连麦 或pk中观众不可以连麦
/**
 视频房
 1.进入房间会设置一次
 2.接收到主播断开连麦的通知后设置一次
 yes 自己可以连麦显示三个按钮
 no  自己不可以连麦显示连个按钮
 */
- (void)refreshVideoToolView
{
    if ([LiveUserListManager defaultManager].RPublishMode == PUBLISH_STREAM_CDN) {
        return;
    }
    if (self.mircEnable) {
        //自己在连麦中
        if (self.localRuningMirc) {
            self.mircButton.hidden = NO;
            self.linkButton.hidden = NO;
            self.linkButton.selected = YES;
            self.linkButton.userInteractionEnabled = NO;
            self.settingButton.hidden = NO;
            [self.mircButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(TOOL_W);
            }];
            [self.linkButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(TOOL_W);
            }];
            [self.settingButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(TOOL_W);
            }];
            
        } else {
            self.linkButton.hidden = NO;
            self.linkButton.selected = NO;
            self.linkButton.userInteractionEnabled = YES;
            [self.linkButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(TOOL_W);
            }];
            if (!self.isAnchor) {
                //1隐藏前两个按钮
                self.mircButton.hidden = YES;
                //观众端麦克风按钮状态复位
                self.mircButton.selected = NO;
                self.settingButton.hidden = YES;
                //改变宽度
                [self.mircButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(0);
                }];
                [self.settingButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(0);
                }];
                if (self.delegate && [self.delegate respondsToSelector:@selector(closeLocalMirc)]) {
                    [self.delegate closeLocalMirc];
                }
            }
        }
  
        if (!self.mircButton.hidden) {
            if (self.mircButton.selected) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(closeLocalMirc)]) {
                    [self.delegate closeLocalMirc];
                }
            } else  {
                if (self.delegate && [self.delegate respondsToSelector:@selector(openLocalMirc)]) {
                    [self.delegate openLocalMirc];
                }
            }
        }
     
    } else {
        self.linkButton.hidden = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(closeLocalMirc)]) {
            [self.delegate closeLocalMirc];
        }
    }
}



- (UIButton *)settingButton
{
    if (!_settingButton) {
        _settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _settingButton.backgroundColor = [UIColor clearColor];
        [_settingButton setImage:[UIImage imageNamed:@"live_tool_setting"] forState:UIControlStateNormal];
        [_settingButton setImage:[UIImage imageNamed:@"live_tool_setting_s"] forState:UIControlStateSelected];
        _settingButton.tag = 3;
        [_settingButton addTarget:self action:@selector(videoToolclick:) forControlEvents:UIControlEventTouchUpInside];
        if (!self.isAnchor) {
            _settingButton.hidden = YES;
        }
    }
    return _settingButton;
}

- (UIButton *)linkButton
{
    if (!_linkButton) {
        _linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _linkButton.backgroundColor = [UIColor clearColor];
        //pk
        if (self.isAnchor) {
            [_linkButton setImage:[UIImage imageNamed:@"live_tool_pk"] forState:UIControlStateNormal];
            [_linkButton setImage:[UIImage imageNamed:@"live_tool_pk_s"] forState:UIControlStateSelected];
        } else {
            //连麦
            [_linkButton setImage:[UIImage imageNamed:@"audience_mirc"] forState:UIControlStateNormal];
            [_linkButton setImage:[UIImage imageNamed:@"audience_mirc_s"] forState:UIControlStateSelected];
            _linkButton.hidden = YES;
        }
        _linkButton.tag = 2;
        [_linkButton addTarget:self action:@selector(videoToolclick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _linkButton;
}

- (UIButton *)mircButton
{
    if (!_mircButton) {
        _mircButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _mircButton.backgroundColor = [UIColor clearColor];
        [_mircButton setImage:[UIImage imageNamed:@"micr_silence"] forState:UIControlStateNormal];
        [_mircButton setImage:[UIImage imageNamed:@"micr_silence_s"] forState:UIControlStateSelected];
        _mircButton.tag = 1;
        [_mircButton addTarget:self action:@selector(videoToolclick:) forControlEvents:UIControlEventTouchUpInside];
        if (!self.isAnchor) {
            _mircButton.hidden = YES;
        }
    }
    return _mircButton;
}

- (void)setIsCdnModel:(BOOL)isCdnModel
{
    _isCdnModel = isCdnModel;
    if (_isCdnModel) {
        if (!self.isAnchor) {
            self.mircButton.hidden = YES;
            self.settingButton.hidden = YES;
        }
        self.linkButton.hidden = YES;
        [self.linkButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
        }];
        
    }
}
- (void)setTalkButtonTitle:(NSString *)talkButtonTitle
{
    _talkButtonTitle = talkButtonTitle;
    self.talkLabel.text = _talkButtonTitle;
}
//事件透传
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *v = [super hitTest:point withEvent:event];
    if ([v isEqual:self.talkLabel]) {
        return nil;
    }
    return v;
}

@end
