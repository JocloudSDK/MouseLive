//
//  NetWorkQuality.h
//  MouseLive
//
//  Created by 张建平 on 2020/3/26.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ThunderEngine.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetWorkQuality : UIView

@property (nonatomic, copy) NSString* uid;  // 用户 uid
@property (nonatomic) ThunderLiveRtcNetworkQuality uploadNetQuality; // 上行网络情况
@property (nonatomic) ThunderLiveRtcNetworkQuality downloadNetQuality; // 下行网络情况

@end

NS_ASSUME_NONNULL_END
