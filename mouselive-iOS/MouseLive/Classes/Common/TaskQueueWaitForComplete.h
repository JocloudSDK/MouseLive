//
//  TaskQueueWaitForComplete.h
//  MouseLive
//
//  Created by 张建平 on 2020/3/11.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TaskQueueWaitForCompleteDelegate <NSObject>

- (void)executeWithReq:(NSNumber *)req object:(id)object;

@end

@interface TaskQueueWaitForComplete : NSObject

- (void)start;

- (void)stop;

// return taskId
- (NSNumber *)addTaskWithObject:(id)object delegate:(id<TaskQueueWaitForCompleteDelegate>)delegate;

- (void)completeTask:(NSNumber *)taskId;

@end

NS_ASSUME_NONNULL_END
