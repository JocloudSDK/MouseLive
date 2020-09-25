//
//  LiveCodeRateView.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/4.
//  Copyright © 2020 sy. All rights reserved.
//

#import "LiveCodeRateView.h"

@interface LiveCodeRateView()
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@end
/**
 @property (nonatomic) CGFloat audioUpload;  // A 音频上行
 @property (nonatomic) CGFloat audioDownload; // A 音频下行
 @property (nonatomic) CGFloat videoUpload; // V 视频上行
 @property (nonatomic) CGFloat videoDownload; // V 视频下行
 @property (nonatomic) CGFloat upload; // 上行
 @property (nonatomic) CGFloat download; // 下行
 */

@implementation LiveCodeRateView

+ (instancetype)liveCodeRateView
{
    
    return [[NSBundle mainBundle]loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
    
}

- (void)setUserDetailString:(NSString *)userDetailString
{
    _userDetailString = userDetailString;
    self.nameLabel.text = userDetailString;
}

- (void)refreshCodeView
{
    NetWorkQuality *quality = self.qualityModel.netWorkQuality;
    if ([LiveUserListManager defaultManager].RPublishMode == 1|| [[LiveUserListManager defaultManager].ROwner.Uid isEqualToString:LoginUserUidString]) {
        
        switch (quality.uploadNetQuality) {
            case THUNDER_SDK_NETWORK_QUALITY_UNKNOWN:
                self.upQualityLabel.text = [[NSLocalizedString(@"TxNetwork", @"上行质量")stringByAppendingString:@":"] stringByAppendingString:NSLocalizedString(@"Unknown", nil)];
                break;
            case THUNDER_SDK_NETWORK_QUALITY_EXCELLENT://@"网络质量:极好";
                self.upQualityLabel.text = [[NSLocalizedString(@"TxNetwork", @"上行质量")stringByAppendingString:@":"] stringByAppendingString:NSLocalizedString(@"Excellent", nil)];
                
                break;
            case THUNDER_SDK_NETWORK_QUALITY_GOOD://@"网络质量:良好";
                self.upQualityLabel.text = [[NSLocalizedString(@"TxNetwork", @"上行质量")stringByAppendingString:@":"] stringByAppendingString:NSLocalizedString(@"Good", nil)];
                
                break;
            case THUNDER_SDK_NETWORK_QUALITY_POOR: //@"网络质量:较好";
                self.upQualityLabel.text = [[NSLocalizedString(@"TxNetwork", @"上行质量")stringByAppendingString:@":"] stringByAppendingString:NSLocalizedString(@"Good", nil)];
                
                break;
            case THUNDER_SDK_NETWORK_QUALITY_BAD: //Poor @"网络质量:一般";
                self.upQualityLabel.text = [[NSLocalizedString(@"TxNetwork", @"上行质量")stringByAppendingString:@":"] stringByAppendingString:NSLocalizedString(@"Poor", nil)];
                
                break;
            case THUNDER_SDK_NETWORK_QUALITY_VBAD://Bad @"网络质量:差";
                self.upQualityLabel.text = [[NSLocalizedString(@"TxNetwork", @"上行质量")stringByAppendingString:@":"] stringByAppendingString:NSLocalizedString(@"Bad", nil)];
                break;
            case THUNDER_SDK_NETWORK_QUALITY_DOWN: //Very Bad @"网络质量:断开";
                self.upQualityLabel.text = [[NSLocalizedString(@"TxNetwork", @"上行质量")stringByAppendingString:@":"] stringByAppendingString:NSLocalizedString(@"Very Bad", nil)];
                break;
            default:
                self.upQualityLabel.text = [[NSLocalizedString(@"TxNetwork", @"上行质量")stringByAppendingString:@":"] stringByAppendingString:NSLocalizedString(@"Unknown", nil)];
                break;
        }
        switch (quality.downloadNetQuality) {
            case THUNDER_SDK_NETWORK_QUALITY_UNKNOWN:
                self.downQualityLabel.text = [[NSLocalizedString(@"RxNetwork", @"下行质量")stringByAppendingString:@":"] stringByAppendingString:NSLocalizedString(@"Unknown", nil)];
                break;
            case THUNDER_SDK_NETWORK_QUALITY_EXCELLENT:
                self.downQualityLabel.text = [[NSLocalizedString(@"RxNetwork", @"下行质量")stringByAppendingString:@":"] stringByAppendingString:NSLocalizedString(@"Excellent", nil)];
                break;
            case THUNDER_SDK_NETWORK_QUALITY_GOOD:
                self.downQualityLabel.text = [[NSLocalizedString(@"RxNetwork", @"下行质量")stringByAppendingString:@":"] stringByAppendingString:NSLocalizedString(@"Good", nil)];
                break;
            case THUNDER_SDK_NETWORK_QUALITY_POOR:
                self.downQualityLabel.text = [[NSLocalizedString(@"RxNetwork", @"下行质量")stringByAppendingString:@":"] stringByAppendingString:NSLocalizedString(@"Good", nil)];
                break;
            case THUNDER_SDK_NETWORK_QUALITY_BAD:
                self.downQualityLabel.text = [[NSLocalizedString(@"RxNetwork", @"下行质量")stringByAppendingString:@":"] stringByAppendingString:NSLocalizedString(@"Poor", nil)];
                break;
            case THUNDER_SDK_NETWORK_QUALITY_VBAD:
                self.downQualityLabel.text = [[NSLocalizedString(@"RxNetwork", @"下行质量")stringByAppendingString:@":"] stringByAppendingString:NSLocalizedString(@"Bad", nil)];
                break;
            case THUNDER_SDK_NETWORK_QUALITY_DOWN:
                self.downQualityLabel.text = [[NSLocalizedString(@"RxNetwork", @"下行质量")stringByAppendingString:@":"] stringByAppendingString:NSLocalizedString(@"Very Bad", nil)];
                break;
            default:
                self.downQualityLabel.text = [[NSLocalizedString(@"RxNetwork", @"下行质量")stringByAppendingString:@":"] stringByAppendingString:NSLocalizedString(@"Unknown", nil)];
                break;
        }
    }
    if (!self.qualityModel.isShowCodeDetail) {
        self.upLabel.text = nil;
        self.upDetailLabel.text = nil;
        self.downLabel.text = nil;
        self.downDetailLabel.text = nil;
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            if ([LiveUserListManager defaultManager].RPublishMode == 2) {
                if ([self.userDetailString containsString:@"RoomId"]) {
                    make.height.mas_equalTo(60);
                } else {
                    make.height.mas_equalTo(45);
                }
            } else {
                if ([self.userDetailString containsString:@"RoomId"]) {
                    make.height.mas_equalTo(CodeView_H - 58);
                } else {
                    make.height.mas_equalTo(CodeView_H - 70);
                }
            }
        }];
        
    } else {
        self.upLabel.text = [NSString stringWithFormat:@"%@:%.0fkb",NSLocalizedString(@"Upload", nil),self.qualityModel.upload];
        self.upDetailLabel.text = [NSString stringWithFormat:@"(A:%.0fkb/ V:%.0fkb)",self.qualityModel.audioUpload,self.qualityModel.videoUpload];
        
        self.downLabel.text = [NSString stringWithFormat:@"%@:%.0fkb",NSLocalizedString(@"Download", nil),self.qualityModel.download];
        self.downDetailLabel.text = [NSString stringWithFormat:@"(A:%.0fkb/ V:%.0fkb)",self.qualityModel.audioDownload,self.qualityModel.videoDownload];
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            if ([self.userDetailString containsString:@"RoomId"]) {
                make.height.mas_equalTo(CodeView_H + 10);
            } else {
                make.height.mas_equalTo(CodeView_H);
            }
        }];
    }
    
}
@end
