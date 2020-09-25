//
//  SYBeautyCell.m
//  MouseLive
//
//  Created by GasparChu on 2020/4/16.
//  Copyright © 2020 sy. All rights reserved.
//

#import "SYBeautyCell.h"
#import <UIImageView+YYWebImage.h>

@interface SYBeautyCell ()

@property (nonatomic, weak) IBOutlet UIImageView *selectedImgView;
@property (nonatomic, weak) IBOutlet UIImageView *imgView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@end

@implementation SYBeautyCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setName:(NSString *)name thumb:(NSString *)thumb selected:(BOOL)selected
{
    self.selectedImgView.hidden = !selected;
    if (selected) {
        self.nameLabel.textColor = [UIColor colorWithRed:48/255.0 green:221/255.0 blue:189/255.0 alpha:1];
    } else {
        self.nameLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.7];
    }
    self.nameLabel.text = NSLocalizedString(name, nil);
    [self.imgView yy_setImageWithURL:[NSURL URLWithString:thumb] placeholder:nil];
}

@end
