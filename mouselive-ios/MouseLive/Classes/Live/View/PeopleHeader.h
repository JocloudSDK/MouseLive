//
//  PeopleHeader.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/4/1.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PeopleHeader : UIView

@property (nonatomic, strong)LiveUserModel *model;
+ (instancetype)shareInstance;
@end

NS_ASSUME_NONNULL_END
