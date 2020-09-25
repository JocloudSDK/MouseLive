//
//  LiveCodeRateView.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/4.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkQualityStauts.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveCodeRateView : UIView
@property (nonatomic, weak) IBOutlet UILabel *upQualityLabel;
@property (nonatomic, weak) IBOutlet UILabel *upLabel;
@property (nonatomic, weak) IBOutlet UILabel *upDetailLabel;
@property (nonatomic, weak) IBOutlet UILabel *downQualityLabel;
@property (nonatomic, weak) IBOutlet UILabel *downLabel;
@property (nonatomic, weak) IBOutlet UILabel *downDetailLabel;
@property (nonatomic, assign)LiveType type;
@property (nonatomic, copy)NSString *userDetailString;
@property (nonatomic, strong) NetworkQualityStauts *qualityModel;

+ (instancetype)liveCodeRateView;


//更新码率
- (void)refreshCodeView;
@end

NS_ASSUME_NONNULL_END
