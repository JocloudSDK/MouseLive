//
//  SYDataEnvironment.h
//  MouseLive
//
//  Created by 张建平 on 2020/3/17.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYDataEnvironment : NSObject

+ (instancetype)sharedDataEnvironment;

// 获取信令和Thunder共用Token
- (NSString *)getTokenWithUid:(UInt64)uid;
- (NSString *)getTokenWithStingUid:(NSString *)uid;

@end

NS_ASSUME_NONNULL_END
