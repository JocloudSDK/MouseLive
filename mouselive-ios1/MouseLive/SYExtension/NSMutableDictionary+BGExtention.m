//
//  NSMutableDictionary+Extention.m
//  linphone
//
//  Created by 宁丽环 on 2020/4/22.
//  Copyright © 2020 sy. All rights reserved.
//

#import "NSMutableDictionary+BGExtention.h"

@implementation NSMutableDictionary (BGExtention)

- (void)yy_setNotNullObject:(id)aobj ForKey:(id)aKey
{
    if (aobj && [aobj isKindOfClass:[NSObject class]] && aKey) {
        [self setObject:aobj forKey:aKey];
    }
}

@end
