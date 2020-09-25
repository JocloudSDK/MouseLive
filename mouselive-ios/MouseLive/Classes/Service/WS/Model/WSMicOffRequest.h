//
//  WSMicOffRequest.h
//  MouseLive
//
//  Created by 张建平 on 2020/3/26.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSInviteRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface WSMicOffRequest : WSInviteRequest

@property (nonatomic) BOOL MicEnable; // 是否闭麦/开麦

@end

NS_ASSUME_NONNULL_END
