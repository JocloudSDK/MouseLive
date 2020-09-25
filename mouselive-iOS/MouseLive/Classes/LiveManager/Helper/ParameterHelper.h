//
//  ParameterHelper.h
//  MouseLive
//
//  Created by 张骥 on 2020/5/15.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ParameterHelper : NSObject

+ (NSDictionary *)parametersForRequest:(RequestType)type additionInfo:(NSDictionary * _Nullable)info;

@end

NS_ASSUME_NONNULL_END
