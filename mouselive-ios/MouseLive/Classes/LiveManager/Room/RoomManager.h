//
//  RoomManager.h
//  MouseLive
//
//  Created by 张骥 on 2020/5/15.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiveRoomInfoModel.h"
#import "LiveUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RoomManager : NSObject

@property(nonatomic, assign)BOOL isInRoom;
@property(nonatomic, assign)BOOL isAnchor;
@property(nullable, nonatomic, strong)LiveRoomInfoModel *currentRoomInfo;
@property(nullable, nonatomic, copy)NSMutableArray<LiveUserModel *> *userList;

+ (instancetype)shareManager;

- (void)getRoomListOfType:(LiveType)type
                  success:(ArrayCompletion _Nullable)success
                     fail:(ErrorComplete _Nullable)fail;

- (void)createRoomForType:(LiveType)type
              publishMode:(PublishMode)mode
                  success:(RoomInfoCompletion _Nullable)success
                     fail:(ErrorComplete _Nullable)fail;

- (void)createChatRoomSuccess:(StrCompletion _Nullable)success
                         fail:(ErrorComplete _Nullable)fail;

- (void)getRoomInfo:(NSString *)roomId
               Type:(LiveType)type
            success:(RoomInfoCompletion _Nullable)success
               fail:(ErrorComplete _Nullable)fail;

- (void)joinChatRoomSuccess:(StrCompletion _Nullable)success
                       fail:(ErrorComplete _Nullable)fail;


- (void)leaveRoom;
@end

NS_ASSUME_NONNULL_END
