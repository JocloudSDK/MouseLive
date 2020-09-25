//
//  PeopleHeader.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/4/1.
//  Copyright © 2020 sy. All rights reserved.
//

#import "PeopleHeader.h"
@interface PeopleHeader()
@property (nonatomic, weak) IBOutlet UIImageView *headerImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@end

@implementation PeopleHeader

+ (instancetype)shareInstance
{
    return [[NSBundle mainBundle]loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.layer.cornerRadius = 20;
    self.layer.masksToBounds = YES;
    self.headerImageView.layer.cornerRadius = 16;
    self.headerImageView.layer.masksToBounds = YES;
}

- (void)setModel:(LiveUserModel *)model
{
    [self.headerImageView yy_setImageWithURL:[NSURL URLWithString:model.Cover] placeholder:PLACEHOLDER_IMAGE];
    self.nameLabel.text = model.NickName;
    CGFloat namelbWidth =[model.NickName boundingRectWithSize:CGSizeMake(1000, 14) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil].size.width;
    //42
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(45 + namelbWidth);
    }];
    YYLogDebug(@"[MouseLive  PeopleHeader] namelbWidth %ld",namelbWidth);
    
}
@end
