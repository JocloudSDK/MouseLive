//
//  AudioContentView.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/6.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveUserModel.h"
#import "LiveRoomInfoModel.h"
#import "BaseLiveContentView.h"


typedef void(^AudioAllMicOffBlock)(BOOL);
typedef void(^CloseMicBlock)(LiveUserModel *model);
typedef void (^RunningMusicBlock)(BOOL isOn);
typedef void (^AudioIconClickBlock) (BOOL selected);

@protocol AudioContentViewDelegate <NSObject>
//关闭直播间
- (void)audioLiveCloseRoom;
//打开观众列表
- (void)audioLiveOpenUserList;
//连麦
- (void)audioConnectAnchor;
//下麦
- (void)audioDisconnectAnchor;
//播放或暂停音乐
- (void)audioManagerMusicPlay:(BOOL)play;

- (void)audioManagerMircStatus:(UIButton *)sender;
@end

@interface AudioContentView : UIView

@property (nonatomic, weak) IBOutlet UICollectionView *contentView;

@property (nonatomic, copy) void(^quitBlock)(void);

@property (nonatomic, copy) AudioIconClickBlock iconClickBlock;

/**主播数据模型*/
@property (nonatomic, strong) LiveRoomInfoModel *roomInfoModel;

@property (nonatomic, assign) NSInteger peopleCount;

@property (nonatomic, copy)CloseMicBlock closeOtherMicBlock; // 请其他人下麦

@property (nonatomic, copy)AudioAllMicOffBlock allMicOffBlock; // 全部禁麦

@property (nonatomic, copy)RunningMusicBlock musicBlock; // 全部禁麦

@property (nonatomic) BOOL volumShowState;
/**是否在播放音乐*/
@property (nonatomic, assign)BOOL isRunningMusic;



@property (nonatomic, weak) id <AudioContentViewDelegate> delegate;

@property (nonatomic, weak) id <BaseLiveContentViewDelegate> baseDelegate;

@property (nonatomic, strong) BaseLiveContentView *baseContentView;

- (instancetype)initWithRoomId:(NSString *)roomId;

+ (AudioContentView *)audioContentView;

//刷新上麦人员信息
- (void)refreshCollectionView;
//刷新麦克风状态图标
- (void)refreshOnlineUserMircStatusWithUid:(NSString *)uid;
- (LiveUserModel *)searchLiveUserWithUid:(NSString *)uid;
//点击空白处隐藏当前视图
- (void)hiddenCurrentView;
//根据连麦请求返回结果更新上麦按钮的状态
- (void)updateLinkMircButtonSelectedStatus:(BOOL)selected;
//更新变声视图显示状态
- (void)updateWhineViewHiddenStatus:(BOOL)hidden;
@end


