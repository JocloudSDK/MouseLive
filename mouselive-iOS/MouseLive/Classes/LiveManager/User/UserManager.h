//
//  UserManager.h
//  MouseLive
//
//  Created by 张骥 on 2020/5/15.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiveUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserManager : NSObject

@property(nonatomic, strong)LiveUserModel* currentUser;

+ (instancetype)shareManager;

- (void)login:(UserInfoCompletion _Nullable)success
         fail:(ErrorComplete _Nullable)fail;

- (void)getAnchorListForType:(LiveType)type
                     succsee:(ArrayCompletion)succsee
                        fail:(ErrorDicComplete)fail;

- (void)getUserInfoWith:(NSString * _Nonnull)uid
                success:(UserInfoCompletion _Nullable)success
                   fail:(ErrorComplete _Nullable)fail;

@end

NS_ASSUME_NONNULL_END
