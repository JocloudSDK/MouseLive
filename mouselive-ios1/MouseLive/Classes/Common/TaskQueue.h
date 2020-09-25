//
//  TaskQueue.h
//  MouseLive
//
//  Created by 张建平 on 2020/4/1.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TaskQueueDelegate <NSObject>

- (void)executeWithReq:(NSNumber *)req object:(id)object;

@end

@interface TaskQueue : NSObject

- (instancetype)initWithName:(NSString *)name;

/// 打开线程
- (void)start;

/// 关闭线程，去除所有任务
- (void)stop;

/// 获取下一个 任务 id -- 与 addTaskWithTaskId 成对使用
/// @return 任务 id
- (NSNumber *)getNextTaskId;

/// 加入任务
/// @param taskId 任务 id， 通过 getNextTaskId 获取
/// @param object 任务执行时的 入参
/// @param delegate 回调
- (void)addTaskWithTaskId:(NSNumber *)taskId object:(id)object delegate:(id<TaskQueueDelegate>)delegate;

/// 加入任务
/// @param object 任务执行时的 入参
/// @param delegate 回调
/// @return 返回 任务 id
- (NSNumber *)addTaskWithObject:(id)object delegate:(id<TaskQueueDelegate>)delegate;

/// 取消任务
/// @param taskIdArray 要取消任务队列
- (void)cancelTask:(NSArray<NSNumber *> *)taskIdArray;

/// 去除所有任务
- (void)removeAllTask;

@end

NS_ASSUME_NONNULL_END

