//
//  NSDictionary+AddAction.h
//  MouseLive
//
//  Created by 张建平 on 2020/3/10.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionary (AddAction)

- (void)yy_setAction:(SEL)action forKey:(id<NSCopying>)key;
    
- (BOOL)yy_invokeActionWithKey:(id<NSCopying>)key target:(id)target object:(nullable id)object;

@end

NS_ASSUME_NONNULL_END
