//
//  BaseLiveContentView.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/4/26.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoLiveBottonToolView.h"
#import "AudioLiveBottonToolView.h"
#import "LiveUserView.h"
#import "LiveUserListManager.h"
#import "LivePublicTalkView.h"
#import "NetworkQualityStauts.h"

@protocol BaseLiveContentViewDelegate <NSObject>
/**
 @param needAnchor  YES 主播列表
                   NO  观众列表
 */
- (void)refreshUserListViewNeedAnchor:(BOOL)needAnchor;
//改变麦克风状态
- (void)refreshMicButtonStatus:(UIButton * _Nonnull) mircButton;
//开始连麦
- (void)startConnectOtherUser:(UIButton * _Nonnull) linkButton;
//视频房设置按钮响应事件
- (void)settingButtonAction:(UIButton * _Nonnull) settingButton;
//反馈事件
- (void)feedbackButtonAction:(UIButton * _Nonnull) feedbackButton;
//变声事件
- (void)audioWhineButtonAction;
//pk事件
- (void)pkConnectWithUid:(NSString *)uid roomId:(NSString *)roomid;
//开麦 闭麦 下麦
- (void)mircManagerActionWithModel:(LiveUserModel *)userMode mircType:(ManagementUserType) type;
//同意连麦
- (void)acceptLinkMircWithUid:(NSString * _Nonnull)uid roomId:(NSString * _Nonnull)roomId;
//拒绝连麦
- (void)refuseLinkMircWithUid:(NSString *)uid;
//码率显示或隐藏
- (void)refreshCodeViewHiddenStatus:(BOOL)selecte;
//设置房间的全员禁言状态
- (void)setRoomAllmuteStatus:(BOOL)isMuted button:(UIButton *)button;
//禁言
- (void)mutedRemoteUser:(LiveUserModel *)user;
//解禁言
- (void)unmuteRemoteUser:(LiveUserModel *)user;
//提升管理员
- (void)addAdminRemoteUser:(LiveUserModel *)user;
//降管理员
- (void)removeAdminRemoteUser:(LiveUserModel *)user;
//踢出某人
- (void)kickOutRemoteUser:(LiveUserModel *)user;
@end


NS_ASSUME_NONNULL_BEGIN

@interface BaseLiveContentView : NSObject

@property (nonatomic, copy) NSString *roomId;

@property (nonatomic, weak) id <BaseLiveContentViewDelegate,AudioLiveBottonToolViewDelegate,VideoLiveBottonToolViewDelegate> delegate;
//聊天输入框
@property (nonatomic, strong) UITextField *chatTextField;
//视频房底部工具栏
@property (nonatomic, strong) VideoLiveBottonToolView *videoToolView;
//音聊房底部工具栏
@property (nonatomic, strong) AudioLiveBottonToolView *audioToolView;
//主播的uid
@property (nonatomic, copy) NSString *anchorMainUid;
//音频开播 或视频开播
@property (nonatomic, assign) LiveType liveType;

@property (nonatomic, assign) PublishMode  publishMode;

//是否是主播
@property (nonatomic, assign) BOOL isAnchor;
//是否在禁言中
@property (nonatomic, assign) BOOL ismute;
//音聊房自己是否正在连麦中
@property (nonatomic, assign) BOOL localRuningMirc;
//自己是否可以连麦 主播在连麦中不可以显示连麦按钮
@property (nonatomic, assign) BOOL mircEnable;
//用户列表隐藏状态
@property (nonatomic, assign) BOOL userListViewIsHidden;
//留言区弹幕消息
@property (nonatomic, strong) NSMutableArray *talkDataArray;
//码率
@property (nonatomic, strong) NetworkQualityStauts *qualityModel;
//显示样式
@property (nonatomic, assign)LiveUserViewType userViewType;

- (instancetype)initWithRoomid:(NSString *)roomId view:(UIView *)view;
//控制码率的显示
- (void)showCodeView;
- (void)hiddenCodeView;
//刷新弹幕
- (void)refreshTalkPublicTabelView;
//刷新工具栏
- (void)refreshBottomToolView;
//更新用户列表
- (void)updateUserListViewStatus;
//更新主播列表
- (void)updateAnchorListViewWithArray:(NSArray<LiveUserModel *> *)dataArray;
//更新连接中视图
- (void)updateLinkHudHiddenStatus:(BOOL)hidden;
//隐藏连麦弹框
- (void)hiddenMircApplayWithUid:(NSString *)uid;
//点击空白处隐藏当前显示的view
- (void)hiddenCurrentView;
//显示连麦申请弹框
- (void)showMircApplay:(id)model;
//显示连麦申请弹框
- (void)showMircApplayWithUid:(NSString *)uid;
//显示用户管理弹框
- (void)showUserViewWithUid:(NSString *)uid;
//显示网络状态框
- (void)showNetAlertView;
//隐藏网络状态框
- (void)hiddenNetAlertView;
//刷新码率视图
- (void)refreshCodeView;
//关闭定时器
- (void)stopTimer;
@end

NS_ASSUME_NONNULL_END
