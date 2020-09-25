//
//  UIViewController+SLExtension.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/3.
//  Copyright © 2020 sy. All rights reserved.
//



#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (SLExtension)
/** Gif加载状态 */
@property(nonatomic, weak) UIImageView *yy_gifView;

/**
 *  显示GIF加载动画
 *
 *  @param images gif图片数组, 不传的话默认是自带的
 *  @param view   显示在哪个view上, 如果不传默认就是self.view
 */
- (void)yy_showGifLoding:(nullable NSArray *)images inView:(UIView *)view;

/**
 *  取消GIF加载动画
 */
- (void)yy_hideGufLoding;

/**
 *  判断数组是否为空
 *
 *  @param array 数组
 *
 *  @return yes or no
 */
- (BOOL)yy_isNotEmpty:(NSArray *)array;
@end

NS_ASSUME_NONNULL_END
