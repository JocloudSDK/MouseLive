//
//  WSRoomRequest.h
//  MouseLive
//
//  Created by 张建平 on 2020/3/16.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface WSRoomRequest : WSBaseRequest

@property (nonatomic) long long Uid;
@property (nonatomic) long long LiveRoomId;
@property (nonatomic) long long ChatRoomId;

@end

NS_ASSUME_NONNULL_END
