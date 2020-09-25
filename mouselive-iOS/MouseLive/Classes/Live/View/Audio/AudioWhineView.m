//
//  AudioWhineView.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/20.
//  Copyright © 2020 sy. All rights reserved.
//

#import "AudioWhineView.h"
#import "LiveManager.h"

@interface AudioWhineView()
@property (nonatomic, weak) IBOutlet UIView *whineView;

@property (nonatomic, weak) IBOutlet UISwitch *whineSwitch;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIStackView *stakView;
@property (nonatomic, strong)NSArray *whineButtonArray;
@property (nonatomic, strong)UIButton *selectedButton;
@property (nonatomic, assign)ThunderRtcVoiceChangerMode mode;
@property (nonatomic, weak) IBOutlet UIButton *earButton;

@end

@implementation AudioWhineView
//THUNDER_VOICE_CHANGER_NONE = 0, // 关闭模式
// THUNDER_VOICE_CHANGER_ETHEREAL = 1, // 空灵
// THUNDER_VOICE_CHANGER_THRILLER = 2, // 惊悚
// THUNDER_VOICE_CHANGER_LUBAN = 3, // 鲁班
// THUNDER_VOICE_CHANGER_LORIE = 4, // 萝莉
// THUNDER_VOICE_CHANGER_UNCLE = 5, // 大叔
// THUNDER_VOICE_CHANGER_DIEFAT = 6, // 死肥仔
// THUNDER_VOICE_CHANGER_BADBOY = 7, // 熊孩子
// THUNDER_VOICE_CHANGER_WRACRAFT = 8, // 魔兽农民
// THUNDER_VOICE_CHANGER_HEAVYMETAL = 9, // 重金属
// THUNDER_VOICE_CHANGER_COLD = 10, // 感冒
// THUNDER_VOICE_CHANGER_HEAVYMECHINERY = 11, // 重机械
// THUNDER_VOICE_CHANGER_TRAPPEDBEAST = 12, // 困兽
// THUNDER_VOICE_CHANGER_POWERCURRENT = 13, // 强电流
- (NSArray *)whineButtonArray
{
    if (!_whineButtonArray) {
        NSMutableArray *buttonArray = [NSMutableArray array];
        NSArray *titles = @[@"空灵",@"惊悚",@"鲁班",@"萝莉",@"大叔",@"死肥仔",@"熊孩子",@"魔兽农民",@"重金属",@"感冒",@"重机械",@"困兽",@"强电流"];
        for (int i = 0; i < titles.count; i ++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            if (i == 0) {
                button.selected = YES;
                self.selectedButton = button;
            }
            [button setTitle:titles[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor sl_colorWithHexString:@"#30DDBD"] forState:UIControlStateSelected];
            button.titleLabel.font = [UIFont systemFontOfSize:12.0f];
            button.tag = i + 1;
            [button addTarget:self action:@selector(whineButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [buttonArray addObject:button];
        }
        
        _whineButtonArray = buttonArray;
    }
    return _whineButtonArray;
}

+ (AudioWhineView *)shareAudioWhineView
{
    
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.whineView.layer.cornerRadius = 6.0f;
    self.whineView.layer.masksToBounds = YES;
    [self.whineSwitch setOnTintColor: [UIColor sl_colorWithHexString:@"#0DBE9E"]];
    [self createUI];
    self.mode = THUNDER_VOICE_CHANGER_ETHEREAL;
    [self.earButton setTitle:NSLocalizedString(@"Ear on", nil) forState:UIControlStateNormal];
    [self.earButton setTitle:NSLocalizedString(@"Ear close", nil) forState:UIControlStateSelected];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetWhine) name:kNotifyChangeWhineView object:nil];
    
}
//变声恢复初始状态
- (void)resetWhine
{
    for (UIButton *btn in self.whineButtonArray) {
        btn.selected = NO;
    }
    self.selectedButton = [self.whineButtonArray firstObject];
    self.selectedButton.selected = YES;
    self.whineSwitch.on = NO;
    self.earButton.selected = NO;
    [[LiveManager shareManager] setVoiceChanger:THUNDER_VOICE_CHANGER_NONE];
}
- (void)createUI
{
    [self addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.stakView);
    }];
    CGFloat wh = 60.0;
    
    for (int i = 0; i < self.whineButtonArray.count; i ++) {
        UIButton *btn = self.whineButtonArray[i];
        btn.frame =CGRectMake(i * wh, 0, wh , wh);
        btn.tag = i + 1;
        [self.scrollView addSubview:btn];
    }
    self.scrollView.contentSize = CGSizeMake(wh * self.whineButtonArray.count, wh);
    
    [self.earButton setTitle:NSLocalizedString(@"Ear open",nil) forState:UIControlStateNormal];
    [self.earButton setTitle:NSLocalizedString(@"Ear close",nil) forState:UIControlStateSelected];
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.backgroundColor = [UIColor clearColor];
    }
    return _scrollView;
}

- (void)whineButtonAction:(UIButton *)sender
{
    if (!sender.selected) {
        self.selectedButton.selected = !self.selectedButton.selected;
        sender.selected = !sender.selected;
        self.selectedButton = sender;
    }
    self.mode = sender.tag;
    
    if (self.whineSwitch.on) {
        // 如果开启了变声
        [[LiveManager shareManager] setVoiceChanger:self.mode];
    }
}

- (IBAction)switchAction:(UISwitch *)sender
{
    if (sender.on) {
        [[LiveManager shareManager] setVoiceChanger:self.mode];
    } else {
        [[LiveManager shareManager] setVoiceChanger:THUNDER_VOICE_CHANGER_NONE];
    }
}

- (IBAction)earaction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [[LiveManager shareManager]setEnableInEarMonitor:sender.selected];
}

@end
