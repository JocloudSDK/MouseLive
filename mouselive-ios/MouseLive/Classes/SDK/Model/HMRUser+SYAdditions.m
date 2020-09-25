//
//  HMRUser+SYAdditions.m
//  MouseLive
//
//  Created by 张建平 on 2020/3/17.
//  Copyright © 2020 sy. All rights reserved.
//

#import "HMRUser+SYAdditions.h"

@implementation HMRUser (SYAdditions)

- (BOOL)sy_isMe
{
    return self.ID == [HMRUser getMe].ID;
}

@end
