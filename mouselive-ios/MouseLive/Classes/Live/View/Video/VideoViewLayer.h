//
//  VideoViewLayer.h
//  MouseLive
//
//  Created by 张骥 on 2020/5/27.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoViewLayer : NSObject

+ (void)layoutFullSession:(VideoSession *)fullsession inContainerView:(UIView *)container;

+ (void)layoutLeftSession:(VideoSession *)leftSession rightSession:(VideoSession * _Nullable)rightession inContainerView:(UIView *)container withTopView:(UIView *)topView;

@end

NS_ASSUME_NONNULL_END
