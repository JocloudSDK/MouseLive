//
//  LiveBottonToolView.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/3.
//  Copyright © 2020 sy. All rights reserved.
//

#import "AudioLiveBottonToolView.h"

#define  TOOL_W 36
@interface AudioLiveBottonToolView()
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
/**变声按钮*/
@property (nonatomic, strong)UIButton *whineButton;


@end

@implementation AudioLiveBottonToolView

- (instancetype)initWithAnchor:(BOOL)isAnchor
{
    if (self = [super init]) {
    
        self.isAnchor = isAnchor;
        [self setupAudioToos];
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
    
    //语音房布局
    UIButton *codeButton = [self.rightBgView.subviews lastObject];
    UIButton *feedbackButton = [self.rightBgView.subviews objectAtIndex:2];
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
    [self.whineButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.right.mas_equalTo(feedbackButton.mas_left).offset(-8);
        make.width.mas_equalTo(TOOL_W);
    }];
    [self.mircButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.right.mas_equalTo(self.whineButton.mas_left).offset(-8);
        make.width.mas_equalTo(TOOL_W);
    }];
}

/**
 语音房
 */
- (void)setupAudioToos
{
    for (UIView *view in self.rightBgView.subviews) {
        [view removeFromSuperview];
    }
    [self.rightBgView addSubview:self.mircButton];
    [self.rightBgView addSubview:self.whineButton];
    NSArray *imageNames = @[@"live_tool_feedback", @"live_tool_code"];
    for (int i = 0; i < 2; i++) {
        UIButton *toolBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        toolBtn.backgroundColor = [UIColor clearColor];
        [toolBtn setImage:[UIImage imageNamed:imageNames[i]] forState:UIControlStateNormal];
        toolBtn.tag = i + 3;
        [toolBtn addTarget:self action:@selector(audioToolclick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.rightBgView addSubview:toolBtn];
    }
    
}

/**音频房按钮被点击*/
- (void)audioToolclick:(UIButton *)button
{
    button.selected = !button.selected;
    AudioLiveToolType type = button.tag;
    self.clickToolBlock(type, button.selected,button);
}


- (void)setTalkButtonTitle:(NSString *)talkButtonTitle
{
    _talkButtonTitle = talkButtonTitle;
    self.talkLabel.text = _talkButtonTitle;
}

/**
 音频房
 观众未连麦时隐藏前两个按钮
 */
- (void)setLocalRuningMirc:(BOOL)localRuningMirc
{
    _localRuningMirc = localRuningMirc;
    if (!_localRuningMirc) {
        self.mircButton.hidden = YES;
        self.whineButton.hidden = YES;
        NSString *para = @"观众断开连麦";
        YYLogFuncEntry([self class], _cmd, para);
        if (self.delegate && [self.delegate respondsToSelector:@selector(closeLocalMirc)]) {
            [self.delegate closeLocalMirc];
        }
    } else {
        self.mircButton.hidden  = NO;
        self.whineButton.hidden = NO;
        //上麦克风的逻辑mircEnable
    }
}

- (UIButton *)whineButton
{
    if (!_whineButton) {
        _whineButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _whineButton.backgroundColor = [UIColor clearColor];
        [_whineButton setImage:[UIImage imageNamed:@"audio_ whine"] forState:UIControlStateNormal];
        [_whineButton setImage:[UIImage imageNamed:@"audio_ whine_s"] forState:UIControlStateSelected];
        _whineButton.tag = 2;
        [_whineButton addTarget:self action:@selector(audioToolclick:) forControlEvents:UIControlEventTouchUpInside];
        if (!self.isAnchor) {
            _whineButton.hidden = YES;
        }
    }
    return _whineButton;
}


- (UIButton *)mircButton
{
    if (!_mircButton) {
        _mircButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _mircButton.backgroundColor = [UIColor clearColor];
        [_mircButton setImage:[UIImage imageNamed:@"micr_silence"] forState:UIControlStateNormal];
        [_mircButton setImage:[UIImage imageNamed:@"micr_silence_s"] forState:UIControlStateSelected];
        _mircButton.tag = 1;
        [_mircButton addTarget:self action:@selector(audioToolclick:) forControlEvents:UIControlEventTouchUpInside];
        if (!self.isAnchor) {
            _mircButton.hidden = YES;
        }
        
    }
    return _mircButton;
}

- (void)setMircEnable:(BOOL)mircEnable
{
    _mircEnable = mircEnable;
    self.mircButton.selected = NO;
    self.mircButton.userInteractionEnabled = mircEnable;
    if (!_mircEnable) {
        //黄色图标不可点击
        [self.mircButton setImage:[UIImage imageNamed:@"audioMicrTool_close"] forState:UIControlStateNormal];
        NSString *para =  @"麦克风按钮不可点击";
        YYLogFuncEntry([self class], _cmd, para);
        if (self.localRuningMirc && self.delegate && [self.delegate respondsToSelector:@selector(closeLocalMirc)]) {
            [self.delegate closeLocalMirc];
        }
    } else {
        [self.mircButton setImage:[UIImage imageNamed:@"micr_silence"] forState:UIControlStateNormal];
        LiveUserModel *localUser = [LiveUserListManager objectForPrimaryKey:LoginUserUidString];
        //同步本地麦克风图标
        self.mircButton.selected = !localUser.SelfMicEnable;
        //连麦观众麦克风控制
        if (!self.mircButton.hidden) {
            if (!self.mircButton.selected) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(openLocalMirc)]) {
                    [self.delegate openLocalMirc];
                }
                NSString *para = @"麦克风开启状态";
                YYLogFuncEntry([self class], _cmd, para);
            } else {
                NSString *para = @"麦克风关闭状态";
                YYLogFuncEntry([self class], _cmd, para);
                if (self.delegate && [self.delegate respondsToSelector:@selector(closeLocalMirc)]) {
                    [self.delegate closeLocalMirc];
                }
            }
        }
    }
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
