//
//  LiveUserView.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/5.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveUserModel.h"

typedef NS_ENUM(NSInteger, ApplyActionType) {
    ApplyActionTypeAgree,
    ApplyActionTypeReject
};

typedef void (^ApplyAlertBlock)(ApplyActionType type, NSString * _Nonnull uid,  NSString * _Nonnull roomId);
NS_ASSUME_NONNULL_BEGIN

@interface ApplyAlertView : UIView

@property(nonatomic, strong)LiveUserModel *model;

@property(nonatomic, copy) ApplyAlertBlock applyBlock;


- (instancetype)initWithLiveType:(LiveType)livetype;

@end

NS_ASSUME_NONNULL_END
