//
//  SingletonHelper.h
//  MouseLive
//
//  Created by Peter Xi on 2020/2/28.
//  Copyright © 2020 sy. All rights reserved.
//

#ifndef SingletonHelper_h
#define SingletonHelper_h

#define kSingletonInterface    + (instancetype)sharedInstance;

#define kSingletonImplementation \
+ (instancetype)sharedInstance { \
    static id instance = nil; \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        instance = [[super allocWithZone:NULL] init]; \
    }); \
    return instance; \
} \
\
+ (instancetype)allocWithZone:(struct _NSZone *)zone { \
    return [[self class] sharedInstance]; \
}

#endif /* SingletonHelper_h */
