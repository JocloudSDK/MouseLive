//
//  LiveCollectionCell.m
//  MouseLive
//
//  Created by 张建平 on 2020/3/2.
//  Copyright © 2020 sy. All rights reserved.
//

#import "LiveCollectionCell.h"
#import "Masonry.h"
#import "SYCommonMacros.h"
#import "YYCGUtilities.h"
#import <UIImage+YYWebImage.h>


@interface LiveCollectionCell()

@property (nonatomic, strong) UILabel* userNameLabel;
@property (nonatomic, strong) UILabel *roomNameLabel;
@property (nonatomic, strong) UILabel *viewerCountLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *peopleIcon;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *roomName;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, assign) int viewerCount;

@end


@implementation LiveCollectionCell


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame: frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(0);
            make.bottom.equalTo(self).offset(-23);
            make.left.equalTo(self).offset(0);
            make.right.equalTo(self).offset(0);
        }];
        
        UIView *titileBGView = [[UIView alloc] init];
        //设置view 背景渐变颜色
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0].CGColor, (__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor];
        gradientLayer.locations = @[@0.0, @1.0];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1.0);
        gradientLayer.frame = CGRectMake(0, 0, (SCREEN_WIDTH - 24)/2, 30);
        [titileBGView.layer addSublayer:gradientLayer];
        [self addSubview:titileBGView];
        
        
        [titileBGView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@30);
            make.bottom.equalTo(self.imageView);
            make.left.equalTo(self.imageView);
            make.right.equalTo(self.imageView);
        }];
        
        [titileBGView addSubview:self.userNameLabel];
        [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.top.equalTo(@0);
            make.width.equalTo(@((SCREEN_WIDTH - 24)/4));
            make.left.equalTo(titileBGView).offset(4);
        }];
        [titileBGView addSubview:self.peopleIcon];
        [self.peopleIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-4);
            make.centerY.equalTo(@0);
            make.size.mas_equalTo(CGSizeMake(10, 10));
        }];
        
        [titileBGView addSubview:self.viewerCountLabel];
        [self.viewerCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(@0);
            make.right.equalTo(self.peopleIcon.mas_left).offset(-2);
        }];
        
        [self addSubview:self.roomNameLabel];
        [self.roomNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.imageView.mas_bottom).offset(3);
            make.bottom.equalTo(@0);
            make.left.mas_equalTo(self.imageView.mas_left).offset(4);
            make.right.mas_equalTo(self.imageView.mas_right).offset(-4);
        }];
    }
    return self;
}

#pragma mark - set / get

- (UIImageView *)peopleIcon
{
    if (!_peopleIcon) {
        _peopleIcon = [[UIImageView alloc]init];
        _peopleIcon.image = [UIImage imageNamed:@"home_pepple_count"];
    }
    return _peopleIcon;
}

- (UILabel *)userNameLabel
{
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] init];
        _userNameLabel.text = self.userName;
        _userNameLabel.textColor = [UIColor sl_red:255 green:255 blue:255 alpha:0.7];
        [_userNameLabel setTextAlignment:NSTextAlignmentLeft];
        [_userNameLabel setFont:[UIFont fontWithName:FONT_Regular size:12.0f]];
    }
    return _userNameLabel;
}

- (UILabel *)roomNameLabel
{
    if (!_roomNameLabel) {
        _roomNameLabel = [[UILabel alloc] init];
        _roomNameLabel.textColor = COLOR_TEXT_BLACK;
        [_roomNameLabel setTextAlignment:NSTextAlignmentLeft];
        [_roomNameLabel setFont:[UIFont fontWithName:FONT_Regular size:16.0f]];
    }
    return _roomNameLabel;
}

- (UILabel *)viewerCountLabel
{
    if (!_viewerCountLabel) {
        _viewerCountLabel = [[UILabel alloc] init];
        _viewerCountLabel.textColor = [UIColor sl_red:255 green:255 blue:255 alpha:0.7];
        _viewerCountLabel.text = [NSString stringWithFormat:@"%d", self.viewerCount];
        [_viewerCountLabel setTextAlignment:NSTextAlignmentRight];
        [_viewerCountLabel setFont:[UIFont fontWithName:FONT_Semibold size:14.0f]];
    }
    
    return _viewerCountLabel;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        UIImage *im = [UIImage imageNamed:@"home_live_ placeholder"];
        _imageView = [[UIImageView alloc] initWithImage:im];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (void)setRoomModel:(LiveRoomInfoModel *)roomModel
{
    _roomModel = roomModel;
    [self.imageView yy_setImageWithURL:[NSURL URLWithString:roomModel.RCover] placeholder:[UIImage imageNamed:@"home_live_ placeholder"]];
    self.roomNameLabel.text = roomModel.RName;
    self.viewerCountLabel.text = [NSString stringWithFormat:@"%@", roomModel.RCount];
    self.userNameLabel.text = roomModel.ROwner.NickName;
    
}
@end
