//
//  HMRChatRoom+SYAdditions.h
//  MouseLive
//
//  Created by 张建平 on 2020/3/17.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HMRChatRoom/HMRChatRoom.h>
#import <HMRCore/HMRUser.h>

NS_ASSUME_NONNULL_BEGIN

@interface HMRChatRoom (SYAdditions)

@property (nonatomic, strong) HMRUser *sy_roomOwner;        // 房主

- (BOOL)sy_roomOwnerIsMe;


@end

NS_ASSUME_NONNULL_END
