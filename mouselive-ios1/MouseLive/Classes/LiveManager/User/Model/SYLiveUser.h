//
//  SYLIveUser.h
//  MouseLive
//
//  Created by 张骥 on 2020/5/15.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYBaseUser : NSObject

@property(nonatomic, copy)NSString* Uid;
@property(nonatomic, copy)NSString *NickName;
@property(nonatomic, copy)NSString *Cover;

@end

@interface SYLiveAnchorUser : SYBaseUser

@property(nonatomic, copy)NSString* roomId;

@end

@interface SYLiveRoomUser : SYBaseUser

@property(nonatomic, copy)NSString* LinkUid;
@property(nonatomic, copy)NSString *LinkRoomId;
@property(nonatomic, assign)BOOL MicEnable;
@property(nonatomic, assign)BOOL SelfMicEnable;
@property(nonatomic, assign)BOOL IsAnchor;

@end

NS_ASSUME_NONNULL_END
