//
//  LiveAnchorListTableViewCell.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/20.
//  Copyright © 2020 sy. All rights reserved.
//

#import "LiveAnchorListTableViewCell.h"
#import "LiveUserModel.h"

@interface LiveAnchorListTableViewCell()

@property (nonatomic, weak) IBOutlet UIImageView *headerImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *roleLabel;

@end
@implementation LiveAnchorListTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.headerImageView.layer.cornerRadius = 22;
    self.headerImageView.layer.masksToBounds = YES;
    self.nameLabel.font = [UIFont fontWithName:FONT_Regular size:14.0f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)resetCell
{
    self.headerImageView.image = nil;
    self.nameLabel.text = nil;
    self.roleLabel.text = nil;
}

- (void)configCellWithUserModel:(LiveUserModel *)model
{
    [self resetCell];
    if (model.isAnchor) {
        self.roleLabel.textColor = [UIColor sl_colorWithHexString:@"#0DBE9E"];
        self.roleLabel.text =[NSString stringWithFormat:@"(%@)", NSLocalizedString(@"List_Owner",nil)];
    } else {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@""];//管理员 禁言中
        if (model.isAdmin) {
            
            NSString *adminstr = [NSString stringWithFormat:@"(%@)", NSLocalizedString(@"List_Admin",nil)];
            NSAttributedString *adminAttributedstr = [[NSAttributedString alloc]initWithString:adminstr attributes:@{NSForegroundColorAttributeName: [UIColor sl_colorWithHexString:@"#0DBE9E"]}];
            [str appendAttributedString:adminAttributedstr];
            
        }
        
        if (model.isMuted) {
            NSString *mutedstr = [NSString stringWithFormat:@"(%@)", NSLocalizedString(@"Banned",nil)];
            NSAttributedString *mutedAttributedstr = [[NSAttributedString alloc]initWithString:mutedstr attributes:@{NSForegroundColorAttributeName:  [UIColor sl_colorWithHexString:@"#FF6800"]}];
            [str appendAttributedString:mutedAttributedstr];
        }
        
        self.roleLabel.attributedText = str;
       
    }
    [self.headerImageView yy_setImageWithURL:[NSURL URLWithString:model.Cover] placeholder:PLACEHOLDER_IMAGE options:YYWebImageOptionIgnoreDiskCache completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
    }];
    self.nameLabel.text = model.NickName;
}
@end
