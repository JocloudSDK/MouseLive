//
//  AudioCollectionViewCell.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/6.
//  Copyright © 2020 sy. All rights reserved.
//

#import "AudioCollectionViewCell.h"

@interface AudioCollectionViewCell()
@property (nonatomic, weak) IBOutlet UIImageView *bgheaderImageview;

@property (nonatomic, weak) IBOutlet UIImageView *headerImageview;
@property (nonatomic, weak) IBOutlet UIImageView *microImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
 

@end

@implementation AudioCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.nameLabel.text = [self localizedStringWithIndexPath:self.indexPath];
  

}

- (NSString *)localizedStringWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return NSLocalizedString(@"No.1", nil);
    } else if (indexPath.row == 1) {
        return NSLocalizedString(@"No.2", nil);

    } else if (indexPath.row == 2) {
        return NSLocalizedString(@"No.3", nil);

    } else if (indexPath.row == 3) {
        return NSLocalizedString(@"No.4", nil);

    } else if (indexPath.row == 4) {
        return NSLocalizedString(@"No.5", nil);

    } else if (indexPath.row == 5) {
        return NSLocalizedString(@"No.6", nil);

    } else if (indexPath.row == 6) {
        return NSLocalizedString(@"No.7", nil);

    } else if (indexPath.row == 7) {
        return NSLocalizedString(@"No.8", nil);

    }
    return @"";
}
- (void)resetCell
{
    self.nameLabel.text = [self localizedStringWithIndexPath:self.indexPath];
    self.headerImageview.image = nil;
    self.microImageView.image = nil;
}

- (void)setUserModel:(LiveUserModel *)userModel
{
    _userModel = userModel;
    [self resetCell];
    WeakSelf
    [self.headerImageview yy_setImageWithURL:[NSURL URLWithString:userModel.Cover] placeholder:nil options:YYWebImageOptionAvoidSetImage completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        if (weakSelf.userModel && image) {
            weakSelf.headerImageview.image = [UIImage yy_circleImage:image borderColor:[UIColor whiteColor] borderWidth:1];
        }
    }];
    if (userModel) {
        self.nameLabel.text = userModel.NickName;
        if (userModel.MicEnable) {
            if (userModel.SelfMicEnable) {
                [self.microImageView setImage:[UIImage imageNamed:@"audio_micr_open"]];
            } else {
                [self.microImageView setImage:[UIImage imageNamed:@"audio_mirc_close_onme"]];
            }
        }
        else {
//            if (userModel.SelfMicEnable) {
//                [self.microImageView setImage:[UIImage imageNamed:@"audio_micr_open"]];
//            } else {
                [self.microImageView setImage:[UIImage imageNamed:@"audio_micr_close"]];
//            }
        }
    } else {
        //不显示麦克风状态
        [self.microImageView setImage:nil];
    }
    
    if (userModel.isSpeaking) {
        [self shakeView];
    }
    
}

- (void)shakeView
{
    CGFloat t =4.0;
    CGAffineTransform translateRight  =CGAffineTransformTranslate(CGAffineTransformIdentity, t,0.0);
    CGAffineTransform translateLeft =CGAffineTransformTranslate(CGAffineTransformIdentity,-t,0.0);
    self.microImageView.transform = translateLeft;
    [UIView animateWithDuration:0.07 delay:0.0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:2.0];
        self.microImageView.transform = translateRight;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.microImageView.transform =CGAffineTransformIdentity;
            } completion:NULL];
        }
    }];
}
@end
