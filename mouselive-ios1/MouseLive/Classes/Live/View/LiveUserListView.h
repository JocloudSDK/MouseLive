//
//  LiveUserListView.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/5.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveUserListManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ClickCellBlock)(BOOL isAnchor, LiveUserModel*model);
typedef void (^AllMuteBlock)(UIButton *button);

@interface LiveUserListView : UIView
@property (nonatomic, copy)ClickCellBlock clickBlock;
@property (nonatomic, copy)AllMuteBlock allMuteBlock; // 是否全部禁言

@property (nonatomic, copy)NSString *roomId;

+ (instancetype)liveUserListView;

//刷新房间成员列表
- (void)refreshUserViewWithRoomId:(NSString *)roomId;
//刷新主播列表
- (void)refreshAnchorViewWithArray:(NSArray<LiveUserModel *> *)dataArray;

@end

NS_ASSUME_NONNULL_END
