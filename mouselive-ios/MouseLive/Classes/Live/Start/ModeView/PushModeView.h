//
//  PushModeView.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/4/23.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PushModeBlock)(NSInteger tag);

NS_ASSUME_NONNULL_BEGIN

@interface PushModeView : UIView

@property (nonatomic, copy) PushModeBlock modeBlock;

+ (instancetype)pushModeView;

@end

NS_ASSUME_NONNULL_END
