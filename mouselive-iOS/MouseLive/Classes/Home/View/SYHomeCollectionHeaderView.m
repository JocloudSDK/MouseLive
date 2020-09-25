//
//  SYHomeCollectionHeaderView.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/5/27.
//  Copyright © 2020 sy. All rights reserved.
//

#import "SYHomeCollectionHeaderView.h"
#import "LogoUIView.h"
//LiveTypeVideo = 1,
//LiveTypeAudio,
//LiveTypeKTV,
//LiveTypeCcommentary
@interface SYHomeCollectionHeaderView()
@property (nonatomic, weak) IBOutlet UIView *logoBgView;
@property (nonatomic, weak) IBOutlet UIView *buttonBgView;
@property (nonatomic, weak) IBOutlet UIButton *videoBtn;
@property (nonatomic, weak) IBOutlet UIButton *audioBtn;
//@property (nonatomic, weak) IBOutlet UIButton *ktvBtn;
//@property (nonatomic, weak) IBOutlet UIButton *commentaryBtn;
@property (nonatomic, strong) NSArray *buttonArray;
@property (nonatomic, strong) UIButton *selectedBtn;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lineCenterConstraint;

@end

@implementation SYHomeCollectionHeaderView

- (instancetype)init
{
    if (self = [super init]) {
        self = [[NSBundle mainBundle] loadNibNamed:@"SYHomeCollectionHeaderView" owner:nil options:nil].lastObject;
         [self setup];
    }
    return self;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, SCREEN_WIDTH, 64) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(16,16)];
       CAShapeLayer *layer = [[CAShapeLayer alloc] init];
       layer.frame = self.buttonBgView.bounds;
       layer.path = path.CGPath;
       self.buttonBgView.layer.mask = layer;
    LogoUIView *logoView  = [[LogoUIView alloc]init];
    [self.logoBgView addSubview:logoView];
    [logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
//    self.layer.cornerRadius
//    self.layer.masksToBounds
//    NSArray *titleArray = @[NSLocalizedString(@"Video", nil), NSLocalizedString(@"Audio", nil), NSLocalizedString(@"KTV", nil), NSLocalizedString(@"Commentary", nil)];

    NSArray *titleArray = @[NSLocalizedString(@"Video", nil), NSLocalizedString(@"Audio", nil)];
    for (UIButton *button in self.buttonArray) {
        NSUInteger index = [self.buttonArray indexOfObject:button];
        [button setTitle:titleArray[index] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:FONT_Light size:14.0];
        button.tag = index + 1;
        [button addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.selectedBtn = self.buttonArray.firstObject;
    self.selectedBtn.selected = YES;
    self.selectedBtn.titleLabel.font = [UIFont fontWithName:FONT_Semibold size:16.0];
    if (self.delegate && [self.delegate respondsToSelector:@selector(syHomeCollectionHeaderViewDidSelecteType:)]) {
        [self.delegate syHomeCollectionHeaderViewDidSelecteType:LiveTypeVideo];
    }

}
- (void)p_changeMultiplierOfConstraint:(NSLayoutConstraint *)constraint multiplier:(CGFloat)multiplier
{
    
    [NSLayoutConstraint deactivateConstraints:@[constraint]];
    NSLayoutConstraint *newConstraint = [NSLayoutConstraint constraintWithItem:constraint.firstItem attribute:constraint.firstAttribute relatedBy:constraint.relation toItem:constraint.secondItem attribute:constraint.secondAttribute multiplier:multiplier constant:constraint.constant];
    newConstraint.priority = constraint.priority;
    newConstraint.shouldBeArchived = constraint.shouldBeArchived;
    newConstraint.identifier = constraint.identifier;
    [NSLayoutConstraint activateConstraints:@[newConstraint]];
    self.lineCenterConstraint = newConstraint;
}

- (void)btnClicked:(UIButton *)button
{    // 1  2   3   4
    // 1/4 3/4 5/4 7/4
    [self p_changeMultiplierOfConstraint:self.lineCenterConstraint multiplier:(2.0 * button.tag - 1.0) / 2.0];
    self.selectedBtn = button;
    button.selected = !button.selected;
    for (UIButton *btn in self.buttonArray) {
        if (![btn isEqual:self.selectedBtn]) {
            btn.selected = NO;
        }
    }
    
    for (UIButton *btn in self.buttonArray) {
        if (btn.selected) {
         btn.titleLabel.font = [UIFont fontWithName:FONT_Semibold size:16.0];
        } else {
            btn.titleLabel.font = [UIFont fontWithName:FONT_Light size:14.0];
        }
    }
    LiveType type = (LiveType)button.tag;
    if (self.delegate && [self.delegate respondsToSelector:@selector(syHomeCollectionHeaderViewDidSelecteType:)]) {
        [self.delegate syHomeCollectionHeaderViewDidSelecteType:type];
    }
}

- (NSArray *)buttonArray
{
    if (!_buttonArray) {
        _buttonArray = [NSArray arrayWithObjects:_videoBtn,_audioBtn, nil];

    }
    return _buttonArray;
}
@end
