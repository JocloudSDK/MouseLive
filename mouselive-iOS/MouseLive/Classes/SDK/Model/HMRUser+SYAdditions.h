//
//  HMRUser+SYAdditions.h
//  MouseLive
//
//  Created by 张建平 on 2020/3/17.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HMRCore/HMRCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface HMRUser (SYAdditions)

@property (nonatomic, assign, readonly) BOOL sy_isMe;         // 是否是自己

@end

NS_ASSUME_NONNULL_END
