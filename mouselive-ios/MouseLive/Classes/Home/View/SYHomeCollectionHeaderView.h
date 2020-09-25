//
//  SYHomeCollectionHeaderView.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/5/27.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SYHomeCollectionHeaderViewDelegate <NSObject>
/**
 @param type 当前选择下标类型
 */
- (void)syHomeCollectionHeaderViewDidSelecteType:(LiveType)type;

@end

NS_ASSUME_NONNULL_BEGIN

@interface SYHomeCollectionHeaderView : UICollectionReusableView
@property (nonatomic, weak) id <SYHomeCollectionHeaderViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
