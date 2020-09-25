//
//  SYStickerCell.m
//  MouseLive
//
//  Created by GasparChu on 2020/4/23.
//  Copyright © 2020 sy. All rights reserved.
//

#import "SYStickerCell.h"

@interface SYStickerCell ()

@property (nonatomic, weak) IBOutlet UIImageView *selectedImgView;
@property (nonatomic, weak) IBOutlet UIImageView *imgView;
@property (nonatomic, weak) IBOutlet UIImageView *selectedMutiImgView;
@property (nonatomic, weak) IBOutlet UIImageView *downloadImgView;
@property (nonatomic, weak) IBOutlet UIView *loadingVIew;
@property (nonatomic, weak) IBOutlet UIImageView *loadingImgView;

@end

@implementation SYStickerCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setThumb:(NSString *)thumb selected:(BOOL)selected selectedMuti:(BOOL)selectedMuti downloaded:(BOOL)downloaded
{
    self.selectedImgView.hidden = !selected;
    self.downloadImgView.hidden = downloaded;
    if (selected) {
        self.selectedMutiImgView.hidden = !selectedMuti;
    } else {
        self.selectedMutiImgView.hidden = YES;
    }
    if (!thumb.length) {
        self.imgView.image = [UIImage imageNamed:@"effect_disable"];
    } else {
        [self.imgView yy_setImageWithURL:[NSURL URLWithString:thumb] placeholder:nil];
    }
}

- (void)downloadEffectAndShowLoading
{
    self.downloadImgView.hidden = YES;
    self.loadingVIew.hidden = NO;
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 1.5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = MAXFLOAT;
    [self.loadingImgView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)downloadSuccessAndStopLoading
{
    [self.loadingImgView.layer removeAllAnimations];
    self.downloadImgView.hidden = YES;
    self.loadingVIew.hidden = YES;
}

- (void)downloadFailureAndStopLoading
{
    [self.loadingImgView.layer removeAllAnimations];
    self.downloadImgView.hidden = NO;
    self.loadingVIew.hidden = YES;
}

@end
