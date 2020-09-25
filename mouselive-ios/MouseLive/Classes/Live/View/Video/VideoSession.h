//
//  VideoSession.h
//  MouseLive
//
//  Created by 张骥 on 2020/5/27.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveUserModel.h"
#import "NetworkQualityStauts.h"
#import "LiveCodeRateView.h"

typedef void (^ClickBlocK)(LiveUserModel * _Nonnull userInfo);

NS_ASSUME_NONNULL_BEGIN

@interface VideoSession : UIView

@property (nonatomic, weak) IBOutlet UIView *hostView;
@property (nonatomic, weak) LiveCodeRateView *codeRateView;
@property (nonatomic, strong) LiveUserModel *userInfo;
@property (nonatomic, strong) NetworkQualityStauts *qualityModel;



+ (instancetype)newInstanceWithHungupButton:(BOOL)hasButton withClickBlock:(ClickBlocK _Nullable)clickBlock;

- (void)hiddenQuqlityView:(BOOL)hidden;

- (void)refreshCodeView;
@end

NS_ASSUME_NONNULL_END
