//
//  Task.m
//  MouseLive
//
//  Created by 张建平 on 2020/4/11.
//  Copyright © 2020 sy. All rights reserved.
//

#import "Task.h"

@interface Task()

@property (nonatomic, strong) NSTimer* timeOut;
@property (nonatomic, assign) BOOL isTimeOut;
@property (nonatomic, assign) int limit;
@property (nonatomic, assign) int runCount;
@property (nonatomic, assign) int token;

@end

@implementation Task

+ (BOOL)RunTaskWithAction:(TaskAction)action success:(TaskSuccess)success failed:(TaskFailed)failed before:(TaskRunBefore)before after:(TaskRunAfter)after
{
    // 1. 判断输入的内容是否可以
    if (!action || !success) {
        YYLogError(@"[MouseLive-Task] RunTaskWithAction, action or success is nil");
        return NO;
    }
    
    
    
    // 2. 创建 promise
    AnyPromise *promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolver) {
        // for test
        action(@"", resolver);
    }];
    
    // 3. 执行 before 操作
    if (before) {
        before();
    }
    
    // 4. 执行 promise then 和 catch
    promise.thenInBackground(^(id resp) {
        // 4.1 如果成功，返回到主线程上
        return [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
            resolve(resp);
        }];
    }).then(^(id resp) {
        // 4.2 就返回 success
        if (success) {
            success(resp);
            
            // 5. 执行完毕，执行 after 操作
            if (after) {
                after();
            }
        }
    }).catch(^(NSError* error) {
        // 4.2 如果是失败，task 上 runCount 增加 1，并启用定时器，
        if (failed) {
            failed(error);
            
            // 5. 执行完毕，执行 after 操作
            if (after) {
                after();
            }
        }
    });
    
    return YES;
}

#pragma mark -- for test

- (AnyPromise *)promise:(BOOL)b
{
    return [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
        NSLog(@"begin  1");
        resolve(@(b));
    }];
}

- (void)test:(BOOL)input
{
    [self promise:input].thenInBackground(^(id bs) {
        NSLog(@"begin  2");
        BOOL b = [bs boolValue];
        if (b) {
            NSLog(@"begin  3");
            return [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
                NSLog(@"begin  4");
                resolve(@(b));
            }];
        }
        else {
            NSLog(@"begin  5");
            return [AnyPromise promiseWithValue:[NSError errorWithDomain:@"321321" code:123 userInfo:nil]];
        }
    }).then(^(id b) {
        NSLog(@"begin  6");
        NSLog(@"123, b:%@", b);
    }).catch(^(NSError* error) {
        NSLog(@"begin  7");
        NSLog(@"error:%@", error);
    });
}

- (IBAction)btnClickStop:(id)sender
{
    [self test:YES];}

- (IBAction)btnClickStart:(id)sender
{
    [self test:NO];
}

@end
