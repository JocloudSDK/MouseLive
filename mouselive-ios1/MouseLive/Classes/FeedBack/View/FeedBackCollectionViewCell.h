//
//  FeedBackCollectionViewCell.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/6/12.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^DelectedBlock)(UIImage *image);
@interface FeedBackCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, copy) DelectedBlock delBlock;

@end

NS_ASSUME_NONNULL_END
