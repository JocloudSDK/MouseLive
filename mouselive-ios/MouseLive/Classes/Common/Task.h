//
//  Task.h
//  MouseLive
//
//  Created by 张建平 on 2020/4/11.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PromiseKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TaskSuccess)(id body);
typedef void(^TaskFailed)(NSError* error);
typedef void(^TaskRunBefore)();
typedef void(^TaskRunAfter)();
typedef void(^TaskResolver)(PMKResolver);
typedef void(^TaskAction)(id inputBody, TaskResolver resolveBlock);
typedef AnyPromise *(^TaskActionReturnPromise)(TaskResolver resolveBlock);

@interface Task : NSObject

+ (Task *)initWithActionArray;

+ (BOOL)RunTaskWithAction:(TaskAction)action success:(TaskSuccess)success failed:(TaskFailed)failed before:(TaskRunBefore)before after:(TaskRunAfter)after;

@end

NS_ASSUME_NONNULL_END
