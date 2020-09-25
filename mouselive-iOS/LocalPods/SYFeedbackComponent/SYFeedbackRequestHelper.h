//
//  SYFeedbackRequestHelper.h
//  SYFeedbackComponent
//
//  Created by iPhuan on 2019/8/13.
//  Copyright © 2019 SY. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SYRequestFailedReason) {
    SYRequestFailedReasonZipArchiveFailed = 0,
    SYRequestFailedReasonRequestFailed,
    SYRequestFailedReasonMissingParameter
};

typedef void (^SYRequestSuccessedBlock)(void);
typedef void (^SYRequestFailedBlock)(SYRequestFailedReason failedReason);


@interface SYFeedbackRequestHelper : NSObject

+ (void)requestWithFeedbackContent:(NSString *)content uid:(NSString *)uid success:(SYRequestSuccessedBlock)success failure:(SYRequestFailedBlock)failure;

+ (void)requestWithFeedbackContent:(NSString *)content uid:(NSString *)uid contact:(NSString *)contactInfo appVersion:(NSString*)appVersion success:(SYRequestSuccessedBlock)success failure:(SYRequestFailedBlock)failure;

@end
