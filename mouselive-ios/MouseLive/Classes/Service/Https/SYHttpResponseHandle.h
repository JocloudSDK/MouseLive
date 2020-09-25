//
//  HttpResponseHandle.h
//  MVP
//
//  Created by baoshan on 17/2/8.
//  Copyright © 2017年 hans. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PublicEnum.h"

@protocol SYHttpResponseHandle <NSObject>

@required
/**
 响应成功

 @param responseObject 返回的数据
 @param type 请求路径
 */
- (void)onSuccess:(id)responseObject requestType:(SYHttpRequestKeyType)type;

/**
 响应失败

 @param clientInfo 返回的数据
 @param type 请求路径
 */
- (void)onFail:(id)clientInfo
        requestType:(SYHttpRequestKeyType)type
        error:(NSError *)error;
@end
