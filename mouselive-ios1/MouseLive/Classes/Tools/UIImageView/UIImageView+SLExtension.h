//
//  UIImageView+SLExtension.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/3.
//  Copyright © 2020 sy. All rights reserved.
//



#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (SLExtension)
/** 播放GIF*/
- (void)yy_playGifAnim:(NSArray *)images;
/**停止动画*/
- (void)yy_stopGifAnim;

@end

NS_ASSUME_NONNULL_END
