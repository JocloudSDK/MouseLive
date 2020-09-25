//
//  VideoContentView.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/4/26.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseLiveContentView.h"
#import "LiveRoomInfoModel.h"
#import "SYEffectView.h"
#import "LiveAnchorView.h"

@protocol VideoContentViewDelegate <NSObject>

//切换摄像头
- (void)videoLiveChangeCamera:(UIButton * _Nonnull) button;
//改变镜像
- (void)videoLiveChangeMirroring:(UIButton * _Nonnull)button;
//添加美颜
- (void)videoLiveAddEffectView:(SYEffectView * _Nonnull)effectView;
//挂断连麦
- (void)videoLiveHungupMirc;
//关闭直播间
- (void)videoLiveCloseRoom;
//打开观众列表
- (void)videoLiveOpenUserList;

@end

NS_ASSUME_NONNULL_BEGIN

@interface VideoContentView : UIView

@property (nonatomic, weak) id <VideoContentViewDelegate> delegate;

@property (nonatomic, weak) id <SYEffectViewDelegate> effectDelegate;

@property (nonatomic, weak) id <BaseLiveContentViewDelegate> baseDelegate;

@property (nonatomic, strong) BaseLiveContentView *baseContentView;

@property (nonatomic, strong) LiveAnchorView *anchorView;

@property (nonatomic, assign) NSInteger peopleCount;

@property (nonatomic, assign) PublishMode publishMode;

//非主播和非连麦的人不可以点击档位按钮
@property (nonatomic, assign) BOOL isCanSettingGear;

//是否要隐藏连麦者的头像
@property (nonatomic, assign) BOOL shouldHiddenMircedHeader;

//连麦者的数据
@property (nonatomic, strong) LiveUserModel *mircedPeopleModel;

//隐藏挂掉按钮
@property (nonatomic, assign) BOOL isHiddenHungupButton;

@property (nonatomic, assign) BOOL isAnchor;

@property (nonatomic, assign) BOOL settingViewHidden;

- (instancetype)initWithRoomId:(NSString *)roomId;

- (instancetype)initWithIsAnchor:(BOOL)isAnchor;

//更新设置视图状态
- (void)updateSettingViewStatus:(BOOL)hidden;
//点击空白处隐藏当前显示的view
- (void)hiddenCurrentView;
@end

NS_ASSUME_NONNULL_END
