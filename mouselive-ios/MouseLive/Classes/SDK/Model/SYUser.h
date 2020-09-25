//
//  SYUser.h
//  MouseLive
//
//  Created by 张建平 on 2020/3/17.
//  Copyright © 2020 sy. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "HMRUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface SYUser : NSObject
@property (nonatomic, strong, readonly) HMRUser *hummerUser;     // 对应SDK的User
@property (nonatomic, assign) BOOL isMuted;                      // 是否是我的消息
@property (nonatomic, assign) BOOL isRoomOwner;                  // 是否是房主
@property (nonatomic, assign) BOOL isAdmin;    // 是否是管理员
@property (nonatomic, assign, readonly) BOOL isMe;               // 是否是自己

- (instancetype)initWithHummerUser:(HMRUser *)hummerUser;


@end


NS_ASSUME_NONNULL_END
