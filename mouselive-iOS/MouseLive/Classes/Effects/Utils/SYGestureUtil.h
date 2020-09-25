//
//  SYGestureUtil.h
//  MouseLive
//
//  Created by GasparChu on 2020/4/22.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYEffectProtocol.h"
#import <vector>

NS_ASSUME_NONNULL_BEGIN

/// 手势特效工具类
@interface SYGestureUtil : NSObject<SYEffectProtocol, SYGestureProtocol>

/// 获取所有手势特效
- (std::vector<OFHandle>)getGestureEffects;

@end

NS_ASSUME_NONNULL_END
