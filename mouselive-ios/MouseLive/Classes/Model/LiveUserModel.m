//
//  LiveUserModel.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/3.
//  Copyright © 2020 sy. All rights reserved.
//

#import "LiveUserModel.h"
#import <MJExtension/MJExtension.h>

@implementation LiveUserModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"newStar":@"new"};
}
@end
