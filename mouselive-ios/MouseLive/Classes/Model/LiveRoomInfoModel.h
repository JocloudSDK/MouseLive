//
//  LiveRoomInfoModel.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/16.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiveUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveRoomInfoModel : NSObject

@property (nonatomic, copy) NSString *AppId;
@property (nonatomic, copy) NSString *RoomId;
@property (nonatomic, copy) NSString *RName;
@property (nonatomic, assign) BOOL RLiving;
@property (nonatomic, assign) LiveType RType;
@property (nonatomic, assign) QulityLevel RLevel;
@property (nonatomic, copy) NSString *RCover;
@property (nonatomic, copy) NSString *RCount;
@property (nonatomic, copy) NSString *RChatId;
@property (nonatomic, copy) NSString *RNotice;
@property (nonatomic, copy) NSString *CreateTm;
/**静音状态 true麦克风开启状态 false 麦克风关闭状态*/
@property (nonatomic, assign) BOOL MicEnable;
@property (nonatomic, assign) BOOL RMicEnable;  // 房间是否全部禁麦/开麦
@property (nonatomic, strong) LiveUserModel *ROwner;
// 1 RTC模式 2 CDN模式（RTMP一对多）
@property (nonatomic, assign) NSInteger RPublishMode;

@property (nonatomic, copy) NSString *RDownStream;//拉流地址
@property (nonatomic, copy) NSString *RUpStream; //推流地址

@end

NS_ASSUME_NONNULL_END
