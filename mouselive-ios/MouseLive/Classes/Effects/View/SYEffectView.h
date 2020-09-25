//
//  SYEffectView.h
//  MouseLive
//
//  Created by GasparChu on 2020/4/15.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYEffectProtocol.h"

@class SYEffectsModel;
NS_ASSUME_NONNULL_BEGIN

@interface SYEffectView : UIView

+ (instancetype)loadNibView;
@property (nonatomic, weak) id<SYEffectViewDelegate> delegate;

/// 显示特效视图
- (void)showEffectView;

/// 隐藏视图
- (void)hiddenEffectView;

/// 设置特效数据
/// @param data data description
- (void)setData:(NSArray *)data;

/// 刷新视图
- (void)reloadView;

@end

NS_ASSUME_NONNULL_END
