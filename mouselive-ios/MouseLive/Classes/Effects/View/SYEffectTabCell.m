//
//  SYEffectTabCell.m
//  MouseLive
//
//  Created by GasparChu on 2020/4/17.
//  Copyright © 2020 sy. All rights reserved.
//

#import "SYEffectTabCell.h"
#import "SYEffectsModel.h"

@interface SYEffectTabCell ()

@property (nonatomic, weak) IBOutlet UILabel *tabLabel;
@property (nonatomic, weak) IBOutlet UIView *selectedView;

@end

@implementation SYEffectTabCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setData:(SYEffectsModel *)data
{
    self.tabLabel.text = NSLocalizedString(data.GroupType, nil);
    self.selectedView.hidden = !data.isSelected;
    if (data.isSelected) {
        self.tabLabel.textColor = [UIColor colorWithRed:48/255.0 green:221/255.0 blue:189/255.0 alpha:1];
    } else {
        self.tabLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.6];
    }
}

@end
