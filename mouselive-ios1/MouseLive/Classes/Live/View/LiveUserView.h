//
//  LiveUserView.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/5.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveUserModel.h"

typedef void (^ManagementUserBlock)(LiveUserModel * _Nullable userModel, ManagementUserType type);
NS_ASSUME_NONNULL_BEGIN

@interface LiveUserView : UIView

@property (nonatomic, strong)LiveUserModel *model;

@property(nonatomic, copy) ManagementUserBlock managementBlock;

@property (nonatomic, assign) LiveUserViewType  viewTyle;


+ (instancetype)userView;




@end

NS_ASSUME_NONNULL_END
