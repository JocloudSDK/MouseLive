//
//  SYRoomInfo.h
//  MouseLive
//
//  Created by 张骥 on 2020/5/15.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYLiveUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface SYRoomInfo : NSObject

@property(nonatomic, copy)NSString* AppId;
@property(nonatomic, copy)NSString *RoomId;
@property(nonatomic, copy)NSString *RName;
@property(nonatomic, copy)NSString *RCover;
@property(nonatomic, copy)NSString *RChatId;

@property(nonatomic, assign)BOOL RLiving;
@property(nonatomic, assign)BOOL RMicEnable;
@property(nonatomic, assign)RoomType RType;
@property(nonatomic, assign)QulityLevel RLevel;
@property(nonatomic, assign)int RCount;

@property(nonatomic, assign)LivePublishMode RPublishMode;
@property(nullable, nonatomic, copy)NSString *RUpStream;
@property(nullable, nonatomic, copy)NSString *RDownStream;

@property(nonatomic, copy)NSString *RNotice;

@property(nonatomic, copy)NSString *CreateTm;
@property(nonatomic, copy)NSString *UpdateTm;

@property(nonatomic, strong)SYLiveRoomUser *ROwner;

@end

NS_ASSUME_NONNULL_END
