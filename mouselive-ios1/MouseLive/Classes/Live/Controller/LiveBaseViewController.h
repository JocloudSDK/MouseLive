//
//  LiveBaseViewController.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/4/27.
//  Copyright © 2020 sy. All rights reserved.
//

#import "BaseViewController.h"
#import "LiveUserListManager.h"
#import "LiveManager.h"
#import "LiveDefaultConfig.h"
#import "BaseLiveContentView.h"
#import "VideoOrAudioPresenter.h"

typedef void (^BackBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface LiveBaseViewController : BaseViewController

@property (nonatomic, strong) VideoOrAudioPresenter *livePresenter;

@property (nonatomic, strong)LiveManager *liveManager;
//是否是主播
@property (nonatomic, assign)BOOL isAnchor;
//音频开播 或视频开播
@property (nonatomic, assign)LiveType liveType;

@property (nonatomic, assign) PublishMode publishMode;
//直播房间信息
@property (nonatomic, strong) LiveUserListManager *roomModel;

@property (nonatomic, strong) LiveDefaultConfig *config;

//返回主页面回调
@property (nonatomic, copy)BackBlock backBlock;

@property (nonatomic, assign) BOOL isResponsBackblock;

@property (nonatomic, strong) BaseLiveContentView *baseContentView;

- (instancetype)initWithRoomModel:(LiveUserListManager *)roomModel;
//网络连接成功
- (void)liveManagerDidNetConnected:(LiveManager * _Nonnull)manager;
//用户退出
- (void)liveManager:(LiveManager *)manager didUserLeave:(NSString *)uid;
//UI
- (void)setup;
//退出房间
- (void)quit;
//配置用户信息
- (void)fetchUsersConfigs;
@end

NS_ASSUME_NONNULL_END
