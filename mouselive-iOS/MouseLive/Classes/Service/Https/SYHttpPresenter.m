//
//  HttpPresenter.m
//  MVP
//
//  Created by baoshan on 17/2/8.
//  Copyright © 2017年 hans. All rights reserved.
//

#import "SYHttpPresenter.h"

@implementation SYHttpPresenter
- (instancetype) initWithView:(id)view
{
    if (self = [super initWithView:view]) {
        _httpClient = [SYHttpService shareInstance];
        [_httpClient addObserver:self];
    }
    return self;
}
#pragma mark - HttpResponseHandle
- (void)onSuccess:(id)responseObject
{
    
}

- (void)onFail:(id)clientInfo requestType:(SYHttpRequestKeyType)type error:(NSError *)error
{
    
}

@end
