//
//  LiveBottomSettingView.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/9.
//  Copyright © 2020 sy. All rights reserved.
//

#import "LiveBottomSettingView.h"
@interface LiveBottomSettingView()
/** 档位*/
@property (nonatomic, weak) IBOutlet UIButton *gearBtn;
@property (nonatomic, weak) IBOutlet UIView *bgView;
@property (nonatomic, weak) IBOutlet UIButton *SwitchBtn;
@property (nonatomic, weak) IBOutlet UIButton *mirrorBtn;
@property (nonatomic, weak) IBOutlet UIButton *magicBtn;

@end
@implementation LiveBottomSettingView

+ (instancetype)bottomSettingView
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}
- (IBAction)buttonAction:(UIButton *)sender
{
    self.hidden = YES;
    if (self.settingBlock) {
        self.settingBlock((BottomSettingType)sender.tag,sender);
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.gearBtn.tintColor = [UIColor whiteColor];
    [self.gearBtn setTitle:NSLocalizedString(@"Quality", nil) forState:UIControlStateNormal];
    [self.SwitchBtn setTitle:NSLocalizedString(@"Switch", nil) forState:UIControlStateNormal];
    [self.mirrorBtn setTitle:NSLocalizedString(@"Mirror", nil) forState:UIControlStateNormal];
    [self.magicBtn setTitle:NSLocalizedString(@"Magic", nil) forState:UIControlStateNormal];
    
    
}

- (void)setIsCanSettingGear:(BOOL)isCanSettingGear
{
    _isCanSettingGear = isCanSettingGear;
    self.gearBtn.userInteractionEnabled = _isCanSettingGear;
    if (_isCanSettingGear) {
        [self.gearBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.gearBtn.tintColor = [UIColor whiteColor];
    } else {
        self.gearBtn.tintColor = [UIColor lightGrayColor];
        [self.gearBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}

@end
