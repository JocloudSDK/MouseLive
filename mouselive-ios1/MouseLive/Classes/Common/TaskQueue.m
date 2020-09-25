//
//  TaskQueue.m
//  MouseLive
//
//  Created by 张建平 on 2020/4/1.
//  Copyright © 2020 sy. All rights reserved.
//

#import "TaskQueue.h"

static NSString * const g_TaskId = @"taskid";
static NSString * const g_Object = @"object";
static NSString * const g_Execute = @"execute";

static NSInteger CONDITION;

@interface TaskQueue()

@property (nonatomic, strong) dispatch_queue_t taskQueue;
@property (nonatomic, strong) NSMutableArray *taskArray;
@property (nonatomic, strong) NSThread *thread;
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, assign) int taskId;
@property (nonatomic, strong) NSConditionLock *condition;

@end

@implementation TaskQueue

- (instancetype)initWithName:(NSString *)name
{
    if (self = [super init]) {
        NSString *str = [NSString stringWithFormat:@"com.sy.task.queue.%@", name];
        self.taskQueue = dispatch_queue_create([str UTF8String], DISPATCH_QUEUE_SERIAL);
        self.taskArray = [[NSMutableArray alloc] init];
        self.taskId = 0;
        self.condition = [[NSConditionLock alloc] initWithCondition:CONDITION];
    }
    return self;
}

- (void)start
{
    [self.taskArray removeAllObjects];
    self.isRunning = YES;
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

- (void)removeAllTask
{
    __weak typeof (self) weakSelf = self;
    dispatch_sync(self.taskQueue, ^{
        [weakSelf.taskArray removeAllObjects];
    });
}

- (NSNumber *)getNextTaskId
{
    __block int taskId = 0;
    __weak typeof (self) weakSelf = self;
    dispatch_sync(self.taskQueue, ^{
        taskId = weakSelf.taskId++;
    });
    return @(taskId);
}


- (void)addTaskWithTaskId:(NSNumber *)taskId object:(id)object delegate:(id<TaskQueueDelegate>)delegate
{
    if (self.isRunning) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:object forKey:g_Object];
        [dic setObject:delegate forKey:g_Execute];
        
        __weak typeof (self) weakSelf = self;
        dispatch_sync(self.taskQueue, ^{
            [dic setObject:taskId forKey:g_TaskId];
            [weakSelf.taskArray addObject:dic];
        });
        [self.condition unlockWithCondition:CONDITION];
    }
}

- (NSNumber *)addTaskWithObject:(id)object delegate:(id<TaskQueueDelegate>)delegate
{
    __block int taskId = 0;
    if (self.isRunning) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:object forKey:g_Object];
        [dic setValue:delegate forKey:g_Execute];
        
        __weak typeof (self) weakSelf = self;
        dispatch_sync(self.taskQueue, ^{
            taskId = weakSelf.taskId++;
            [dic setValue:@(taskId) forKey:g_TaskId];
            [weakSelf.taskArray addObject:dic];
        });
        [self.condition unlockWithCondition:CONDITION];
    }
    return @(taskId);
}

- (void)cancelTask:(NSArray<NSNumber *> *)taskIdArray
{
    __weak typeof (self) weakSelf = self;
    dispatch_sync(self.taskQueue, ^{
        for (NSNumber* taskId in taskIdArray) {
            int index = -1;
            for (NSInteger i = 0; i < weakSelf.taskArray.count; i++) {
                NSMutableDictionary *dic = (NSMutableDictionary *)weakSelf.taskArray[i];
                if ([(NSNumber *)[dic valueForKey:g_TaskId] intValue] == [taskId intValue]) {
                    index = (int)i;
                    break;
                }
            }
            if (index != -1) {
                [weakSelf.taskArray removeObjectAtIndex:index];
            }
        }
    });
}

- (id)nextTask
{
    __block id next = nil;
    __weak typeof (self) weakSelf = self;
    dispatch_sync(self.taskQueue, ^{
        if (weakSelf.taskArray.count != 0) {
            next = weakSelf.taskArray[0];
            [weakSelf.taskArray removeObjectAtIndex:0];
        }
    });
    return next;
}

#pragma mark - thread run

- (void)run
{
    NSLog(@"run entry");
    dispatch_queue_t queue = dispatch_get_main_queue();

    while (self.isRunning) {
        NSMutableDictionary *dic = (NSMutableDictionary *)[self nextTask];
        if (dic == nil) {
            [self.condition lockWhenCondition:CONDITION];
            continue;
        }
        
        dispatch_async(queue, ^{
            int taskid = [(NSNumber *)[dic valueForKey:g_TaskId] intValue];
            id object = [dic valueForKey:g_Object];
            id<TaskQueueDelegate> delegate = (id<TaskQueueDelegate>)[dic valueForKey:g_Execute];
            if (delegate) {
                if ([delegate respondsToSelector:@selector(executeWithReq:object:)]) {
                    [delegate performSelector:@selector(executeWithReq:object:) withObject:@(taskid) withObject:object];
                }
            }
        });
    }
    
    NSLog(@"run exit");
}

@end
