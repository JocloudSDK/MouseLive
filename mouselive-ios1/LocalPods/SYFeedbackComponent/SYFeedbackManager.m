//
//  SYFeedbackManager.m
//  SYFeedbackComponent
//
//  Created by iPhuan on 2019/8/20.
//  Copyright © 2019 SY. All rights reserved.
//


#import "SYFeedbackManager.h"

//static NSString * const kSYFeedbackRequestUrl = @"https://isoda-inforeceiver.yy.com/userFeedback"; // 反馈接口URL, old

/// https://git.yy.com/autotest/feedback/feedback_doc/wikis/%E5%8F%8D%E9%A6%88%E7%B3%BB%E7%BB%9F%E6%8E%A5%E5%85%A5
static NSString * const kSYFeedbackRequestUrl = @"https://imobfeedback.yy.com/userFeedback"; // 反馈接口URL, new


@interface SYFeedbackManager ()

@end

@implementation SYFeedbackManager

+ (instancetype)sharedManager {
    static SYFeedbackManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupDefaultValue];
    }
    return self;
}

- (void)setupDefaultValue {
    self.requestUrl = kSYFeedbackRequestUrl;
    self.marketChannel = @"Demo";
    self.submitButtonNormalHexColor = @"#6485F9";
    self.submitButtonhighlightedHexColor = @"#3A61ED";
}



@end
