//
//  SYBeautyContentCell.h
//  MouseLive
//
//  Created by GasparChu on 2020/4/23.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYEffectProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface SYBeautyContentCell : UICollectionViewCell

- (void)setData:(SYEffectsModel *)data;
@property (nonatomic, weak) id<SYEffectViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
