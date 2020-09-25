//
//  TaskQueueWaitForComplete.m
//  MouseLive
//
//  Created by 张建平 on 2020/3/11.
//  Copyright © 2020 sy. All rights reserved.
//

#import "TaskQueueWaitForComplete.h"

static NSString * const g_TaskId = @"taskid";
static NSString * const g_Object = @"object";
static NSString * const g_Execute = @"execute";

static NSInteger CONDITION;

@interface TaskQueueWaitForComplete()

@property (nonatomic, strong) dispatch_queue_t taskQueue;
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;
@property (nonatomic, strong) NSMutableArray *taskArray;
@property (nonatomic, strong) NSThread *thread;
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, assign) int taskId;
@property (nonatomic, strong) NSConditionLock *condition;
@property (nonatomic, assign) BOOL runTask;

@end

@implementation TaskQueueWaitForComplete

- (instancetype)init
{
    if (self = [super init]) {
        self.taskQueue = dispatch_queue_create("com.sy.task.queue.add", DISPATCH_QUEUE_SERIAL);
        self.dispatchQueue = dispatch_queue_create("com.sy.task.queue.dispathch", DISPATCH_QUEUE_SERIAL);
        self.taskArray = [[NSMutableArray alloc] init];
        self.taskId = 0;
        self.condition = [[NSConditionLock alloc] initWithCondition:CONDITION];
    }
    return self;
}

- (void)start
{
    self.isRunning = YES;
    self.runTask = NO;
    self.thread = [[NSThread alloc]initWithTarget:self selector:@selector(run) object:nil];
    [self.thread start];
}

- (void)stop
{
    NSLog(@"stop entry");
    if (self.thread) {
        if ([self.thread isExecuting]) {
            NSLog(@"stop entry 1");
            self.isRunning = NO;
            self.runTask = NO;
            [self.condition unlockWithCondition:CONDITION];
            [self.thread cancel];
        }
    }
    
    self.thread = nil;
    __weak typeof (self) weakSelf = self;
    dispatch_sync(self.taskQueue, ^{
        [weakSelf.taskArray removeAllObjects];
    });
    NSLog(@"stop exit");
}

- (NSNumber *)addTaskWithObject:(id)object delegate:(id<TaskQueueWaitForCompleteDelegate>)delegate
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:object forKey:g_Object];
    [dic setValue:delegate forKey:g_Execute];

    __block int taskId;
    __weak typeof (self) weakSelf = self;
    dispatch_sync(self.taskQueue, ^{
        taskId = weakSelf.taskId++;
        [dic setValue:@(taskId) forKey:g_TaskId];
        [weakSelf.taskArray addObject:dic];
    });
    
    YYLogDebug(@"[TaskQueue::addTaskWithObject] task:%d", taskId);
    if (!self.runTask) {
        YYLogDebug(@"[TaskQueue::addTaskWithObject] unlockWithCondition, task:%d", taskId);
        [self.condition unlockWithCondition:CONDITION];
    }
    return @(taskId);
}

- (void)completeTask:(NSNumber *)taskId
{
    __weak typeof (self) weakSelf = self;
    dispatch_sync(self.taskQueue, ^{
        NSMutableDictionary* task = weakSelf.taskArray.firstObject;
        while (task) {
            if ([(NSNumber *)[task valueForKey:g_TaskId] intValue] != [taskId intValue]) {
                [weakSelf.taskArray removeObject:task];
                task = weakSelf.taskArray.firstObject;
            } else {
                [weakSelf.taskArray removeObject:task];
                break;
            }
        }
    });
    
    YYLogDebug(@"[TaskQueue::completeTask] task:%@", taskId);
    [self.condition unlockWithCondition:CONDITION];
}

- (id)nextTask
{
    __block id next = nil;
    __weak typeof (self) weakSelf = self;
    dispatch_sync(self.taskQueue, ^{
        if (weakSelf.taskArray.count != 0) {
            next = weakSelf.taskArray[0];
        }
    });
    return next;
}

#pragma mark - thread run

- (void)run
{
    NSLog(@"run entry");
    while (self.isRunning) {
        NSMutableDictionary *dic = (NSMutableDictionary *)[self nextTask];
        if (dic == nil) {
            [self.condition lockWhenCondition:CONDITION];
            continue;
        }
        
        self.runTask = YES;
        __block int taskid = 0;
        dispatch_sync(self.dispatchQueue, ^{
            taskid = [(NSNumber *)[dic valueForKey:g_TaskId] intValue];
            YYLogDebug(@"[TaskQueue::run] task:%d", taskid);
            id object = [dic valueForKey:g_Object];
            id<TaskQueueWaitForCompleteDelegate> delegate = (id<TaskQueueWaitForCompleteDelegate>)[dic valueForKey:g_Execute];
            if (delegate) {
                if ([delegate respondsToSelector:@selector(executeWithReq:object:)]) {
                    [delegate performSelector:@selector(executeWithReq:object:) withObject:@(taskid) withObject:object];
                }
            }
        });

        // 等待任务完成
        YYLogDebug(@"[TaskQueue::run] wait for complete. task:%d", taskid);
        [self.condition lockWhenCondition:CONDITION];
        sleep(1);
        YYLogDebug(@"[TaskQueue::run] complete. task:%d", taskid);
        self.runTask = NO;
    }
    
    NSLog(@"run exit");
}

@end
