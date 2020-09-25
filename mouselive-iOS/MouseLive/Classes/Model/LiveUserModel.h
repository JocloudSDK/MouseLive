//
//  LiveUserModel.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/3.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveUserModel : NSObject

/**用户ID*/
@property (nonatomic, copy) NSString   *Uid;
/** 昵称 */
@property (nonatomic, copy) NSString *NickName;
/** 照片地址 */
@property (nonatomic, copy) NSString *Cover;
/**用户所在的房间ID*/
@property (nonatomic, copy) NSString *RoomId;
/**是否是主播*/
@property (nonatomic, assign) BOOL isAnchor;

// 当前用户和谁连麦，如果是和主播连麦，就是主播 uid
@property (nonatomic, copy) NSString *LinkUid;

// 当前用户和谁连麦，如果是和主播连麦，就是主播 roomid
@property (nonatomic, copy) NSString *LinkRoomId;

@property (nonatomic, assign)BOOL MicEnable;  // 主播把其他人禁麦/开麦

@property (nonatomic, assign) BOOL SelfMicEnable; // 用户自己开麦/闭麦，默认是开麦

@property (nonatomic, assign) BOOL AnchorLocalLock; // 主播修单独修改本地用户 mic 的锁， 只在用户是主播的时候有用

// 对用用户，不管是全员禁言或者是单独禁言，都是禁言。
@property (nonatomic, assign) BOOL isMuted;

// 是否是管理员;
@property (nonatomic, assign) BOOL isAdmin;
//是否在说话
@property (nonatomic, assign) BOOL isSpeaking;


@end

NS_ASSUME_NONNULL_END
