//
//  SYUser.m
//  MouseLive
//
//  Created by 张建平 on 2020/3/17.
//  Copyright © 2020 sy. All rights reserved.
//

#import "SYUser.h"
#import "HMRUser+SYAdditions.h"

@interface SYUser ()
@property (nonatomic, strong, readwrite) HMRUser *hummerUser;

@end

@implementation SYUser

- (instancetype)initWithHummerUser:(HMRUser *)hummerUser
{
    self = [super init];
    if (self) {
        _hummerUser = hummerUser;
    }
    return self;
}

#pragma mark - Get

- (BOOL)isMe
{
    return _hummerUser.sy_isMe;
}

@end
