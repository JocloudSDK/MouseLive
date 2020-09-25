//
//  LiveDefaultConfig.h
//  MouseLive
//
//  Created by 张建平 on 2020/3/10.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveDefaultConfig : NSObject

@property (nonatomic, copy) NSString* localUid;  // 本人 uid
@property (nonatomic, copy) NSString *ownerRoomId;  // 进入房间的 roomid
@property (nonatomic, copy) NSString *anchroMainRoomId;
@property (nonatomic, copy) NSString *anchroMainUid;
@property (nonatomic, copy) NSString *anchroSecondRoomId;
@property (nonatomic, copy) NSString *anchroSecondUid;

- (NSString *)string;

@end

NS_ASSUME_NONNULL_END
