//
//  BaseLiveCollectionViewCell.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/12.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveBGView.h"
#import "LiveDefaultConfig.h"
NS_ASSUME_NONNULL_BEGIN
@class AudioContentView;


@interface BaseLiveCollectionViewCell : UICollectionViewCell

/**是否是主播*/
@property (nonatomic, assign)BOOL isAnchor;
/**加入人数限制*/
@property (nonatomic, assign)int limit;
/**是否需要视频*/
@property (nonatomic, assign)BOOL haveVideo;

@property (nonatomic, weak) UIViewController <LiveBGDelegate> *parentVc;

@property (nonatomic, strong) LiveBGView *livebgView;

@property (nonatomic, strong)UIView *liveContentView;

/**音聊区*/
@property (nonatomic, weak)AudioContentView *audioContentView;

/**直播信息配置*/
@property(nonatomic, strong)LiveDefaultConfig *config;

- (void)setupLiveView;
//开始直播
- (void)startLive;



@end

NS_ASSUME_NONNULL_END
