//
//  HMRChatRoom+SYAdditions.m
//  MouseLive
//
//  Created by 张建平 on 2020/3/17.
//  Copyright © 2020 sy. All rights reserved.
//

#import "HMRChatRoom+SYAdditions.h"
#include <objc/message.h>


static char const * const kSYRoomOwnerKey = "kSYRoomOwnerKey";


@implementation HMRChatRoom (SYAdditions)

- (HMRUser *)sy_roomOwner
{
    return objc_getAssociatedObject(self, kSYRoomOwnerKey);
}

- (void)setSy_roomOwner:(HMRUser *)roomOwner
{
    objc_setAssociatedObject(self, kSYRoomOwnerKey, roomOwner, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)sy_roomOwnerIsMe
{
    return [HMRUser getMe].ID == self.sy_roomOwner.ID;
}


@end
