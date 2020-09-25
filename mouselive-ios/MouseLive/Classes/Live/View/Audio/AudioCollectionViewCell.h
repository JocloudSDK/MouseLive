//
//  AudioCollectionViewCell.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/6.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AudioCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong)LiveUserModel *userModel;
@property (nonatomic, strong)NSIndexPath *indexPath;
- (void)shakeView;
@end

NS_ASSUME_NONNULL_END
