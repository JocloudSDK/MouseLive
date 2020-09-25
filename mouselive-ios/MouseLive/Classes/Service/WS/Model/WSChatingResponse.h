//
//  WSChatingResponse.h
//  MouseLive
//
//  Created by 张建平 on 2020/3/29.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface WSChatingResponse : WSBaseRequest

@property (nonatomic, copy) NSString* TraceId;
@property (nonatomic, assign) int MaxLinkNum;

@end

NS_ASSUME_NONNULL_END
