//
//  LiveBaseViewController.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/4/27.
//  Copyright © 2020 sy. All rights reserved.
//

#import "LiveBaseViewController.h"
#import "BaseLiveContentView.h"
#import "LivePresenter.h"
#import "PublishViewController.h"
#import "IQKeyboardManager.h"
#import "SYThunderEvent.h"


@interface LiveBaseViewController ()<BaseLiveContentViewDelegate,UITextFieldDelegate,LivePresenterDelegate, LiveManagerSignalDelegate>

@property (nonatomic, strong) RLMNotificationToken *token;

@end

@implementation LiveBaseViewController

//初始化方法 如果不用Realm数据库 这里替换为自己维护的房间信息单例
- (instancetype)initWithRoomModel:(RLMLiveRoomModel *)roomModel
{
    if (self = [super init]) {
        self.roomModel = roomModel;
        if ([roomModel.ROwner.Uid isEqualToString:LoginUserUidString]) {
            self.isAnchor = YES;
        }
        if (roomModel.RPublishMode == 1) {
            self.publishMode = LivePublishMode_RTC;
        } else if (roomModel.RPublishMode == 2) {
            self.publishMode = LivePublishMode_CDN;
        }
        LiveDefaultConfig *config = [[LiveDefaultConfig alloc]init];
        config.ownerRoomId = roomModel.RoomId;
        config.localUid = LoginUserUidString;
        config.anchroMainUid = roomModel.ROwner.Uid;
        config.anchroMainRoomId = roomModel.RoomId;
        self.config = config;
        //数据返回 刷新视图
        [self refreshViewWithDataCallBack];
      
    }
    return self;
}

#pragma mark- 初始化方法
- (instancetype) initWithAnchor:(BOOL)isAnchor config:(LiveDefaultConfig *)config pushMode:(LivePublishMode)pushModel
{
    if (self = [super init]) {
        self.isAnchor = isAnchor;
        self.config = config;
        self.publishMode = pushModel;
    }
    return self;
}

#pragma mark - Life cycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //关闭自动键盘
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    self.navigationController.navigationBarHidden = YES;
    [LivePresenter shareInstance].delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.token invalidate];
    [LivePresenter shareInstance].delegate = nil;
    self.token = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.liveManager addDelegate:self];
    [self.liveManager addSignalDelegate:self];
    
//    [[SYHummerManager sharedManager] addHummerObserver:self];

    [self setup];
    if (self.isAnchor) {
        [self hummerCreateChatRoom];
    } else {
        //观众进入房间
        [self audiencejoinRoom];
    }
}

//子类做UI的初始化操作
- (void)setup
{
 
}

#pragma mark - 麦克风控制
- (AudioMicStateController *)audioMicStateController
{
    if (!_audioMicStateController) {
        _audioMicStateController = [[AudioMicStateController alloc] init];
    }
    return _audioMicStateController;
}

#pragma mark - LiveManager
- (LiveManager *)liveManager
{
    if (!_liveManager) {
        _liveManager = [LiveManager shareManager];
    }
    
    return _liveManager;
}

#pragma mark -主播创建聊天室
- (void)hummerCreateChatRoom
{
<<<<<<< HEAD
#if USE_REALM
       
       [[SYHummerManager sharedManager] createChatRoomWithCompletionHandler:^(NSString * _Nullable roomId, NSError * _Nullable error) {
           if (!error) {
               RLMRealm *realm = [RLMRealm defaultRealm];
               [realm beginWriteTransaction];
               self.roomModel.RChatId = roomId;
               [realm commitWriteTransaction];
               [self setChatId];
           } else {
               [self quit];
               YYLogError(@"Hummer启动失败 %@",error);
           }
       }];
      
    
        if (self.liveType == LiveTypeAudio) {
            [self cofigAudioRoom];
        } else if (self.liveType == LiveTypeVideo) {
            [self cofigVideoRoom];
        }
#else
    // by zhangjianping, 此错编译有错误
//    LiveBaseViewController.m:167:23: property 'presenter' not found on object of type 'LiveBaseViewController *'
//    self.config.ownerRoomId = self.liveRoomInfo.RoomId;
//    WeakSelf
//    [[SYHummerManager sharedManager] createChatRoomWithCompletionHandler:^(NSString * _Nullable roomId, NSError * _Nullable error) {
//        if (!error) {
//            //启动成功
//            NSDictionary *params = @{
//                kRoomId:@([weakSelf.config.ownerRoomId integerValue]),
//                kUid:@([weakSelf.config.localUid integerValue]),
//                kRChatId:@([roomId integerValue]),
//                kRType: @(weakSelf.liveType == LiveTypeVideo ? 1 : 2),
//            };
//            [weakSelf.presenter fetchSetchatIdWithParams:params];
//        } else {
//            YYLogError(@"Hummer启动失败 %@",error);
//        }
//    }];
#endif
=======
    [self.liveManager createChatRoomSuccess:^(NSString * _Nullable str) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        self.roomModel.RChatId = str;
        [realm commitWriteTransaction];
    } fail:^(NSError * _Nullable error) {
        [self quit];
        YYLogError(@"Hummer启动失败 %@",error);
    }];
}

#pragma mark -观众进入直播房间
- (void)audiencejoinRoom
{
    [self.liveManager joinChatRoomSuccess:nil fail:^(NSError * _Nullable error) {
        [MBProgressHUD yy_showError:@"进入聊天室失败，请尝试重新进入直播间" toView:self.view];
    }];
}

//观众加入hummer
- (void)joinHummer
{
    [self.liveManager joinChatRoomSuccess:nil fail:^(NSError * _Nullable error) {
        [MBProgressHUD yy_showError:@"进入聊天室失败，请尝试重新进入直播间" toView:self.view];
    }];
>>>>>>> dev_v1.2.0_feature
}

#pragma mark - 退出直播
- (void)quit
{
    //注销http代理
    [[LivePresenter shareInstance] destory];
    //注销数据变更通知
    self.token = nil;
    //删除房间数据
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteAllObjects];
    [realm commitWriteTransaction];
    YYLogDebug(@"[MouseLive LiveBaseViewController] quit 删除数据成功");
    
}

//数据更新 刷新视图
- (void)refreshViewWithDataCallBack
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    // 获取 Realm 通知
    self.token = [realm addNotificationBlock:^(RLMNotification  _Nonnull notification, RLMRealm * _Nonnull realm) {
        [self refreshUserListView];
        [self refreshPeopleCount];
        [self refreshAudioCollectionView];
    }];
}

//刷新成员列表
- (void)refreshUserListView
{
    if (!self.baseContentView.userListViewIsHidden) {
        [self.baseContentView updateUserListViewStatus];
    }
}
//刷新房间人数
- (void)refreshPeopleCount
{
    
}
//刷新音聊房上麦者
- (void)refreshAudioCollectionView
{
    
}
#pragma mark - UITextFieldDelegate 聊天

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (self.baseContentView.chatTextField.text.length == 0) {
        [textField resignFirstResponder];
    } else {
        NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:kNickName];
        NSNumber *uid = [[NSUserDefaults standardUserDefaults] objectForKey:kUid];
        NSDictionary *messageDict = @{
            @"NickName":userName,
            @"Uid" :uid,
            @"message":textField.text,
            @"type":@"Msg"
        };
        WeakSelf
        self.baseContentView.chatTextField.text = nil;
        NSMutableString *sendString = [[NSMutableString alloc]initWithString:[NSString yy_stringFromJsonObject:messageDict]];
        [self.liveManager sendRoomMessage:sendString complete:^(NSError * _Nullable error) {
            if (!error) {
                [weakSelf.baseContentView.talkDataArray addObject:[self fectoryChatMessageWithMessageString:sendString isjoinOrLeave:NO]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.baseContentView refreshTalkPublicTabelView];
                });
                YYLogDebug(@"[MouseLive LiveBaseViewController] textFieldShouldReturn 发送消息成功 %@",sendString);
                [BaseConfigManager sy_logWithFormat:@"发送消息成功"];
            } else {
                YYLogError(@"[MouseLive LiveBaseViewController] textFieldShouldReturn 发送消息失败 %@",sendString);
                [BaseConfigManager sy_logWithFormat:@"发送消息失败"];
            }
        }];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

#pragma mark- 弹幕消息封装
/**
 1：msg 人黄，字白（自己+主播全黄色 ）
 2：主播通知 黄字
 3：进出房间 人白 字白
 4：顶部通知 白字
 */
- (NSAttributedString *)fectoryChatMessageWithMessageString:(NSString *)message isjoinOrLeave:(BOOL)state
{
    NSDictionary *messageDict = [message yy_jsonObjectFromString];
    NSString *messageType = [messageDict objectForKey:@"type"];
    
    NSString *uid = [NSString stringWithFormat:@"%@",[messageDict objectForKey:kUid]];
    
    //黄色名字(人员进入退出白色) 自己发的显示 我：xx
    NSAttributedString *nameString = [[NSAttributedString alloc]initWithString:[uid isEqualToString:LoginUserUidString] ? NSLocalizedString(@"Talk_Me", nil):[NSString stringWithFormat:@"%@   ",[messageDict objectForKey:kNickName]] attributes:@{NSForegroundColorAttributeName:state ? [UIColor whiteColor] : [UIColor sl_colorWithHexString:@"#FFDA81"]}];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithAttributedString:nameString];
    UIColor *messageTextColor = [UIColor whiteColor];
    
    if ([messageType isEqualToString:@"Msg"]) {
        //自己发言或者是主播发言橙色突出字体
        if ([uid isEqualToString:LoginUserUidString] || [[messageDict objectForKey:kUid] isEqual:@(self.config.anchroMainUid.longLongValue)]) {
            messageTextColor = [UIColor sl_colorWithHexString:@"#FFDA81"];
            
        } else {
            //其他人 黄+白
            messageTextColor = [UIColor whiteColor];
        }
    } else if ([messageType isEqualToString:@"Notice"]) {
        //主播通知 黄色字体
        messageTextColor = [UIColor sl_colorWithHexString:@"#FFDA81"];
        
    }
    
    if (state) {
        messageTextColor = [UIColor whiteColor];
    }
    
    NSAttributedString *messageString = [[NSAttributedString alloc]initWithString:[messageDict objectForKey:kmessage] attributes:@{NSForegroundColorAttributeName:messageTextColor}];
    [attributedString appendAttributedString:messageString];
    [attributedString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]} range:NSMakeRange(0, attributedString.mutableString.length)];
    return [[NSAttributedString alloc]initWithAttributedString:attributedString];
}

#pragma mark - LiveManager Delegate
- (void)liveManagerDidNetConnected:(LiveManager *)manager
{
    
}

#pragma mark - LiveManager Signal Delegate
- (void)liveManager:(LiveManager *)manager didBeInvitedBy:(NSString *)uid roomId:(NSString *)roomId
{
    RLMLiveUserModel *user = [RLMLiveUserModel objectForPrimaryKey:uid];
    //同房间 观众连麦
    if ([roomId isEqualToString:self.config.ownerRoomId]) {
        if (user) {
            [self.baseContentView showMircApplayWithUid:user.Uid];
            YYLogDebug(@"[MouseLive LiveBaseViewController] didBeInvitedWithUid 收到用户:%@连麦请求",uid);
        } else {
            [MBProgressHUD yy_showSuccess:@"用户不存在"];
            YYLogError(@"[MouseLive LiveBaseViewController] didBeInvitedWithUid 用户:%@不存在",uid);
        }
    } else {
        // 如果不是自己的房间，就需要获取其他房间的用户信息
        [self.liveManager getUserInfoWith:uid success:^(id  _Nullable obj) {
            [self.baseContentView showMircApplay:obj];
        } fail:^(NSError * _Nullable error) {
            [MBProgressHUD yy_showSuccess:@"用户不存在"];
        }];
    }
}

- (void)liveManager:(LiveManager *)manager didInviteTimeoutBy:(NSString *)uid roomId:(NSString *)roomId
{
    [self.baseContentView updateLinkHudHiddenStatus:YES];
}

- (void)liveManager:(LiveManager *)manager didInviteCancelBy:(NSString *)uid roomId:(NSString *)roomId
{
    [self.baseContentView hiddenMircApplay];
}

- (void)liveManager:(LiveManager *)manager didInviteRefuseBy:(NSString *)uid roomId:(NSString *)roomId
{
    //隐藏15s倒计时
    [self.baseContentView updateLinkHudHiddenStatus:YES];
    //主播拒绝了你的连麦申请
    [MBProgressHUD yy_showSuccess:NSLocalizedString(@"You're rejected by the owner.", nil)  toView:self.view];
}

- (void)liveManager:(LiveManager *)manager didInviteRunningBy:(NSString *)uid roomId:(NSString *)roomId
{
    
}

- (void)liveManager:(LiveManager *)manager didUserJoin:(NSString *)uid
{
    RLMLiveUserModel *user = [RLMLiveUserModel objectForPrimaryKey:uid];
    if (!user) {
        user = [[RLMLiveUserModel alloc]init];
        user.Uid = uid;
    }
      
    [self sendMessageWithUserModel:user isleft:NO];
    //更新用户列表 pk主播不保存
    if (![self.roomModel.userList objectsWhere:@"Uid == %@",uid].count) {
         RLMRealm *realm = [RLMRealm defaultRealm];
         [realm beginWriteTransaction];
         user.LinkUid = @"0";
         user.LinkRoomId = @"0";
         [self.roomModel.userList addObject:user];
         [realm commitWriteTransaction];
        
    }
}

- (void)liveManager:(LiveManager *)manager didUserLeave:(NSString *)uid
{
    if ([self.roomModel.userList objectsWhere:@"Uid == %@",uid].count) {
        RLMLiveUserModel *user = [RLMLiveUserModel objectForPrimaryKey:uid];
        //发弹幕消息
        [self sendMessageWithUserModel:user isleft:YES];
        //用户表删除
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        NSInteger index =  [self.roomModel.userList indexOfObjectWhere:@"Uid == %@",uid];
        [self.roomModel.userList removeObjectAtIndex:index];
        [realm commitWriteTransaction];
    }
}


#pragma mark - LiveBGDelegate
- (void)didChatJoinWithUid:(NSString *)uid roomid:(NSString *)roomid
{
    //音聊房发弹幕
    if (self.liveType == RoomType_Audio) {
        [[LivePresenter shareInstance]fetchUserDataWithUid:uid success:^(int taskId, id  _Nullable respObjc) {
            if (respObjc) {
                RLMRealm *realm = [RLMRealm defaultRealm];
                [realm beginWriteTransaction];
                RLMLiveUserModel *user = respObjc;
                user.LinkUid = self.roomModel.ROwner.Uid;
                user.LinkRoomId = roomid;
                user.MicEnable = YES;
                user.SelfMicEnable = YES;
                if (!self.roomModel.RMicEnable) {
                    user.MicEnable = NO;
                }
                if (![self.roomModel.userList objectsWhere:@"Uid == %@",uid].count) {
                    [self.roomModel.userList addObject:user];
                }
                [realm commitWriteTransaction];
                [self audioJoinSendMessageWithUserModel:user];
                YYLogDebug(@"[MouseLive LiveBaseViewController] didChatJoinWithUid fetchUserDataWithUid success");
            } else {
                YYLogError(@"[MouseLive LiveBaseViewController] didChatJoinWithUid fetchUserDataWithUid error");
            }
        } failure:^(int taskId, id  _Nullable respObjc, NSString * _Nullable errorCode, NSString * _Nullable errorMsg) {
            YYLogError(@"[MouseLive LiveBaseViewController] didChatJoinWithUid fetchUserDataWithUid error: %@",errorMsg);
        }];
        
    }
}

//连麦者离开 还在房间
- (void)didChatLeaveWithUid:(NSString *)uid
{
   //音聊房发弹幕消息 不存在跨房间
    if (self.liveType == RoomType_Audio) {
        RLMLiveUserModel *userModel = [RLMLiveUserModel objectForPrimaryKey:uid];
        NSDictionary *messageDict = @{
            @"NickName":userModel.NickName,
            @"Uid" :userModel.Uid,
            @"message":NSLocalizedString(@"left the seat.", nil),
            @"type":@"Notice"
        };
        NSAttributedString *messageString = [self fectoryChatMessageWithMessageString:[NSString yy_stringFromJsonObject:messageDict] isjoinOrLeave:NO];
        [self.baseContentView.talkDataArray addObject: messageString];
        [self.baseContentView refreshTalkPublicTabelView];
    }
}

//音聊房人员连麦成功弹幕消息
- (void)audioJoinSendMessageWithUserModel:(RLMLiveUserModel *)userModel
{
    NSDictionary *messageDict = @{
        @"NickName":userModel.NickName,
        @"Uid" :userModel.Uid,
        @"message":NSLocalizedString(@"have a seat.", nil),
        @"type": @"Notice"
    };
    NSAttributedString *messageString = [self fectoryChatMessageWithMessageString:[NSString yy_stringFromJsonObject:messageDict] isjoinOrLeave:NO];
    [self.baseContentView.talkDataArray addObject: messageString];
    [self.baseContentView refreshTalkPublicTabelView];
}

//发弹幕消息
- (void)sendMessageWithUserModel:(RLMLiveUserModel *)userModel isleft:(BOOL)left
{
    [self.liveManager getUserInfoWith:userModel.Uid success:^(id  _Nullable obj) {
        RLMLiveUserModel *userModel = obj;
        if (obj) {
            NSDictionary *messageDict = @{
                @"NickName":userModel.NickName,
                @"Uid" :userModel.Uid,
                @"message":left ? NSLocalizedString(@"left", nil) : NSLocalizedString(@"joined", nil)// @"离开"
            };
            NSAttributedString *messageString = [self fectoryChatMessageWithMessageString:[NSString yy_stringFromJsonObject:messageDict] isjoinOrLeave:YES];
            [self.baseContentView.talkDataArray addObject: messageString];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.baseContentView refreshTalkPublicTabelView];
                YYLogDebug(@"[MouseLive LiveBaseViewController] sendMessageWithUserModel 用户%@：success %@",[messageDict objectForKey:kUid],left ? @"离开房间":@"加入房间");
            });
        }
    } fail:^(NSError * _Nullable error) {
        [MBProgressHUD yy_showSuccess:@"获取用户信息失败"];
        YYLogError(@"[MouseLive LiveBaseViewController] sendMessageWithUserModel 用户：%@ error: %@",left ? @"离开房间":@"加入房间",error.domain);
    }];
}

// 接受到被连麦的请求 主播弹框提示
- (void)didBeInvitedWithUid:(NSString *)uid roomid:(NSString *)roomid
{
    RLMLiveUserModel *user = [RLMLiveUserModel objectForPrimaryKey:uid];
    //同房间 观众连麦
    if ([roomid isEqualToString:self.config.ownerRoomId]) {
        if (user) {
            [self.baseContentView showMircApplayWithUid:user.Uid];
            YYLogDebug(@"[MouseLive LiveBaseViewController] didBeInvitedWithUid 收到用户:%@连麦请求",uid);
        } else {
            [MBProgressHUD yy_showSuccess:@"用户不存在"];
            YYLogError(@"[MouseLive LiveBaseViewController] didBeInvitedWithUid 用户:%@不存在",uid);
        }
    } else {
        // 如果不是自己的房间，就需要获取其他房间的用户信息
        [self.liveManager getUserInfoWith:uid success:^(id  _Nullable obj) {
            [self.baseContentView showMircApplay:obj];
        } fail:^(NSError * _Nullable error) {
            [MBProgressHUD yy_showSuccess:@"用户不存在"];
        }];
//        [[LivePresenter shareInstance]fetchUserDataWithUid:uid success:^(int taskId, id  _Nullable respObjc) {
//            if (respObjc) {
//                [self.baseContentView showMircApplay:respObjc];
//                YYLogDebug(@"[MouseLive LiveBaseViewController] didBeInvitedWithUid 收到用户:%@pk请求",uid);
//            } else {
//                [MBProgressHUD yy_showSuccess:@"用户不存在"];
//                YYLogError(@"[MouseLive LiveBaseViewController] didBeInvitedWithUid 用户:%@详情不存在",uid);
//            }
//        } failure:^(int taskId, id  _Nullable respObjc, NSString * _Nullable errorCode, NSString * _Nullable errorMsg) {
//            [MBProgressHUD yy_showSuccess:@"用户不存在"];
//            YYLogError(@"[MouseLive LiveBaseViewController] didBeInvitedWithUid 用户:%@详情不存在",uid);
//        }];
    }
}

//显示码率  如果视频有人进入，会返回左边和右边的 uid，只有在 chatJoin 后才会返回，didChatLeaveWithUid 是不会返回
- (void)didShowCanvasWith:(NSString *)leftUid rightUid:(NSString *)rightUid
{
    __block  LiveUserModel *firstUser = [[LiveUserModel alloc]init];
    __block  LiveUserModel *secondUser = [[LiveUserModel alloc]init];
    [self.userInfoList getUserInfoWithUid:leftUid complete:^(LiveUserModel * _Nonnull userModel) {
        firstUser = userModel;
    }];
    
    [self.userInfoList getUserInfoWithUid:rightUid complete:^(LiveUserModel * _Nonnull userModel) {
        secondUser = userModel;
    }];
    [self.baseContentView didShowCodeViewWith:firstUser rightUser:secondUser];
    YYLogDebug(@"[MouseLive LiveBaseViewController] didShowCanvasWith firstUser: %@ secondUser: %@",firstUser,secondUser);

}

///// 处理用户进入
///// @param uid 进入用户 uid
///// @param roomid 进入用户 roomid
//- (void)handleUserJoinWithUid:(NSString *)uid roomid:(NSString *)roomid
//{
//    if (![self.userInfoList userAlreadyExistWithUid:uid]) {
//        // 用户数目 ++
////        if (self.liveType == LiveTypeVideo) {
////            self.anchorView.peopleCount++;
////            YYLogDebug(@"[MouseLive BaseLiveViewController] handleUserJoinWithUid peopleCount = %ld",self.anchorView.peopleCount);
////        } else if (self.liveType == LiveTypeAudio) {
////             self.audioContentView.peopleCount++;
////            YYLogDebug(@"[MouseLive BaseLiveViewController] handleUserJoinWithUid peopleCount = %ld",self.audioContentView.peopleCount);
////        }
////    }
//    WeakSelf
//    [self.userInfoList getUserInfoWithUid:uid complete:^(LiveUserModel * _Nonnull userModel) {
//        NSDictionary *messageDict = @{
//            @"NickName":userModel.NickName,
//            @"Uid" :userModel.Uid,
//            @"message": NSLocalizedString(@"joined", nil) // @"来了"
//        };
//        NSAttributedString *messageString = [weakSelf fectoryChatMessageWithMessageString:[NSString yy_stringFromJsonObject:messageDict] isjoinOrLeave:YES];
////        [weakSelf.talkTableView.dataArray addObject: messageString];
//        dispatch_async(dispatch_get_main_queue(), ^{
//
////            [weakSelf.talkTableView refreshTalkView];
//        });
//
////        [weakSelf.userListView refreshViewWithType:weakSelf.liveType needAnchor:NO isAnchor:weakSelf.isAnchor config:weakSelf.config userInfoList:weakSelf.userInfoList];
//
//    }];
//}
//
///// 处理用户离开
///// @param uid 离开用户 uid
///// @param roomid 离开用户 roomid
//- (void)handleUserLeaveWithUid:(NSString *)uid roomid:(NSString *)roomid
//{
//    if ([self.userInfoList userAlreadyExistWithUid:uid]) {
//
//        if (self.liveType == LiveTypeVideo) {
//
//            self.anchorView.peopleCount--;
//
//            YYLogDebug(@"[MouseLive BaseLiveViewController] handleUserJoinWithUid peopleCount = %ld",self.anchorView.peopleCount);
//        } else if (self.liveType == LiveTypeAudio) {
//            self.audioContentView.peopleCount--;
//            YYLogDebug(@"[MouseLive BaseLiveViewController] handleUserJoinWithUid peopleCount = %ld",self.audioContentView.peopleCount);
//        }
//
//    } else {
//        //用户查询不到不做处理
//        return;
//    }
//    if ([roomid isEqualToString:self.config.ownerRoomId]) {
//        WeakSelf
//        [self.userInfoList getUserInfoWithUid:uid complete:^(LiveUserModel * _Nonnull userModel) {
//            NSDictionary *messageDict = @{
//                @"NickName":userModel.NickName,
//                @"Uid" :userModel.Uid,
//                @"message": NSLocalizedString(@"left", nil) // @"离开"
//            };
//            NSAttributedString *messageString = [weakSelf fectoryChatMessageWithMessageString:[NSString yy_stringFromJsonObject:messageDict] isjoinOrLeave:YES];
//            [weakSelf.talkTableView.dataArray addObject: messageString];
//            dispatch_async(dispatch_get_main_queue(), ^{
//
//                [weakSelf.talkTableView refreshTalkView];
//            });
//            if (userModel) {
//                //更新本地存储列表
//                [weakSelf.userInfoList userLeave:userModel.Uid];
//            }
//            //刷新列表
//            [weakSelf.userListView refreshViewWithType:weakSelf.liveType needAnchor:NO isAnchor:weakSelf.isAnchor config:weakSelf.config userInfoList:weakSelf.userInfoList];
//
//        }];
//        //改变底部状态栏  自己可以连麦了
//        if (self.liveType == LiveTypeAudio) {
//             [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyChangeToolButtonState object:@{@"uid":uid ,@"state":@"OFF"}];
//        }
//    }
//}
// 反馈网络状态
- (void)didUpdateNetworkQualityStatus:(NetworkQualityStauts *)status
{

    [self.baseContentView didUpdateNetworkQualityStatus:status];
}

#pragma mark - BaseLiveContentViewDelegate
//解禁 禁言
- (void)muteManagerActionWithModel:(LiveUserModel *)userModel
{
    WeakSelf
    [self.liveManager muteRemoteUser:userModel.Uid mute:!userModel.isMuted complete:^(NSError * _Nullable error) {
        if (!error) {
            YYLogDebug(@"[MouseLive LiveBaseViewController] muteManagerActionWithModel %@ success userModel: %@", userModel.isMuted ? @"解禁" : @"禁言" ,userModel);
            userModel.isMuted = !userModel.isMuted;
            [weakSelf.userInfoList setUserInfo:userModel];
        } else {
            [MBProgressHUD yy_showError:error.domain];
            YYLogError(@"[MouseLive LiveBaseViewController] muteManagerActionWithModel %@ error: %@", userModel.isMuted ? @"解禁" : @"禁言", error);

        }
    }];
}
//反馈页面
- (void)feedbackButtonAction:(UIButton * _Nonnull)feedbackButton
{
     PublishViewController *vc = [[PublishViewController alloc]init];
     [vc setBackButton];
     [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - LivePresenter 网络请求
//主播 setchatID
//- (void)setChatId
//{
//    NSDictionary *params = @{
//        kRoomId:@([self.config.ownerRoomId integerValue]),
//        kUid:@([self.config.localUid integerValue]),
//        kRChatId:@([self.roomModel.RChatId integerValue]),
//        kRType: @(self.liveType == RoomType_Live ? 1 : 2),
//    };
//    YYLogDebug(@"[MouseLive LiveBaseViewController] setChatId params: %@",params);
//    [[LivePresenter shareInstance] fetchSetchatIdWithParams:params];
//}
//- (void)getChatId
//{
    //没有chatid 进行网络获取
//    [self.liveManager ]
//        NSDictionary *params = @{
//            kRoomId:@(self.config.anchroMainRoomId.longLongValue),
//            kUid:@([self.config.localUid integerValue]),
//            kRType: @(self.liveType == RoomType_Live ? 1 : 2),
//        };
//
//        YYLogDebug(@"[MouseLive LiveBaseViewController] getChatId params: %@",params);
//        [[LivePresenter shareInstance] fetchGetchatIdWithParams:params];

//}

#pragma mark- LivePresenterDelegate

- (void)createRoomError:(NSString *)errorMessage
{
    YYLogDebug(@"主播创建聊天室失败%@",errorMessage);
    [MBProgressHUD yy_showError:errorMessage];
    [self quit];
}

<<<<<<< HEAD

#if !USE_REALM
//主播成功创建聊天室
- (void)createRoomSucess:(id)data
{
    //初始化本地存储对象
    self.userInfoList = [[LiveUserInfoList alloc]initWithLiveType:self.liveType roomid:self.config.ownerRoomId uid:self.config.localUid anchorId:self.liveRoomInfo.ROwner.Uid];
    WeakSelf
    // 获取roominfo
    [self.userInfoList getRoomInfo:^(LiveRoomInfoModel * _Nonnull roomInfo, NSDictionary<NSString *,LiveUserModel *> * _Nonnull userList) {
        weakSelf.liveRoomInfo = roomInfo;
        if (weakSelf.liveType == LiveTypeAudio) {
            [weakSelf cofigAudioRoom];
        } else if (weakSelf.liveType == LiveTypeVideo) {
            [weakSelf cofigVideoRoom];
        }
    }];
}
#endif

=======
>>>>>>> dev_v1.2.0_feature
// 观众成功进入房间
/**
 1初始化本地存储对象
 2获取房间信息
 3存储房间用户本地列表
 */
- (void)successGetChatId:(id)data
{
    
    id roomId = [data objectForKey:@"RChatId"];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    self.roomModel.RChatId = [NSString stringWithFormat:@"%@",roomId];
    [realm commitWriteTransaction];
    [self joinHummer];
}


@end
