//
//  LiveDefaultConfig.m
//  MouseLive
//
//  Created by 张建平 on 2020/3/10.
//  Copyright © 2020 sy. All rights reserved.
//

#import "LiveDefaultConfig.h"

@implementation LiveDefaultConfig

- (NSString *)string
{
    return [NSString stringWithFormat:@"localUid:%@, ownerRoomId:%@, anchroMainRoomId:%@, anchroMainUid:%@, anchroSecondRoomId:%@, anchroSecondUid:%@", self.localUid, self.ownerRoomId, self.anchroMainRoomId, self.anchroMainUid, self.anchroSecondRoomId, self.anchroSecondUid];
}

@end
