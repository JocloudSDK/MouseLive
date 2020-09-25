//
//  SYHttpService.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/5/21.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYHttpResponseHandle.h"
#define HttpTimeoutInterval 30

/** 成功返回值*/
typedef void(^NetServiceSuccessBlock) (NSString *taskId, id _Nullable respObjc);

/**失败返回值*/
typedef void (^NetServiceFailBlock)(NSString *taskId, NSError *error); 

@protocol SYHttpResponseHandle;

@interface SYHttpService : NSObject

/**
 构造方法
 */
+ (instancetype)shareInstance;

/// 添加观察者
/// @param delegate 观察者
- (void)addObserver:(id<SYHttpResponseHandle>) delegate;

/// 移除观察者
/// @param delegate 观察者
- (void)removeObserver:(id<SYHttpResponseHandle>) delegate;

//block 返回方法
- (NSString *)sy_httpRequestWithType:(SYHttpRequestKeyType)type params:(NSDictionary *)params success:(NetServiceSuccessBlock)success failure:(NetServiceFailBlock)failure;

//代理返回
- (NSString *)sy_httpRequestWithType:(SYHttpRequestKeyType)type params:(NSDictionary *)params;

/**
 根据请求 ID 取消该任务
 
 @param requestID 任务请求 ID
 */
- (void)cancelRequestWithRequestID:(nonnull NSString *)requestID;


/**
 根据请求 ID 列表 取消任务
 
 @param requestIDList 任务请求 ID 列表
 */
- (void)cancelRequestWithRequestIDList:(nonnull NSArray<NSString *> *)requestIDList;

//取消全部任务
- (void)cancelAllRequest;
@end


