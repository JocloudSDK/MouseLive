//
//  SYStickerCell.h
//  MouseLive
//
//  Created by GasparChu on 2020/4/23.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYStickerCell : UICollectionViewCell

/// 设置缩略图
/// @param thumb 缩略图
/// @param selected 是否选中
/// @param selectedMuti 是否是多选
/// @param downloaded 是否已下载
- (void)setThumb:(NSString * _Nullable)thumb
        selected:(BOOL)selected
    selectedMuti:(BOOL)selectedMuti
      downloaded:(BOOL)downloaded;

- (void)downloadEffectAndShowLoading;
- (void)downloadSuccessAndStopLoading;
- (void)downloadFailureAndStopLoading;

@end

NS_ASSUME_NONNULL_END
