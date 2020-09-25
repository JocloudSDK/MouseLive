//
//  NSDictionary+AddAction.m
//  MouseLive
//
//  Created by 张建平 on 2020/3/10.
//  Copyright © 2020 sy. All rights reserved.
//

#import "NSDictionary+AddAction.h"

@implementation NSMutableDictionary (AddAction)

- (NSValue *)createActionWithSelector:(SEL)action
{
    return [NSValue valueWithBytes:&action objCType:@encode(SEL)];
}

- (void)yy_setAction:(SEL)action forKey:(id<NSCopying>)key
{
    [self setObject:[self createActionWithSelector:action] forKey:key];
}

- (BOOL)yy_invokeActionWithKey:(id<NSCopying>)key target:(id)target object:(nullable id)object
{
    BOOL ret = NO;
    SEL action;
    NSValue *value = [self objectForKey:key];
    if (value) {
        [value getValue:&action];
        if ([target respondsToSelector:action]) {
            if (object) {
                ret = (BOOL)[target performSelector:action withObject:object];
            }
            else {
                ret = (BOOL)[target performSelector:action];
            }
        }
    }
    return ret;
}

@end
