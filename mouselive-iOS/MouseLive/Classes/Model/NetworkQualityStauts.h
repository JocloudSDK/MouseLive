//
//  NetworkQualityStauts.h
//  MouseLive
//
//  Created by 张建平 on 2020/3/22.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ThunderEngine.h>
#import "NetWorkQuality.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetworkQualityStauts : NSObject

@property (nonatomic) CGFloat audioUpload;  // A 音频上行
@property (nonatomic) CGFloat audioDownload; // A 音频下行
@property (nonatomic) CGFloat videoUpload; // V 视频上行
@property (nonatomic) CGFloat videoDownload; // V 视频下行
@property (nonatomic) CGFloat upload; // 上行
@property (nonatomic) CGFloat download; // 下行
//是否显示上下行
@property (nonatomic, assign)BOOL isShowCodeDetail;
@property (nonatomic, strong) NetWorkQuality *netWorkQuality; // 上行/下行网络请求

@end

NS_ASSUME_NONNULL_END
