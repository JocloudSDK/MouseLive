//
//  Constant.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/3.
//  Copyright © 2020 sy. All rights reserved.
//
#import <UIKit/UIKit.h>

//数据库版本号 数据库升级
#define BGSchemaVersion 83

#pragma mark - Frame相关
// 屏幕宽/高
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

// 屏幕分辨率
#define SCREEN_RESOLUTION (SCREEN_WIDTH * SCREEN_HEIGHT * ([UIScreen mainScreen].scale))
// iPhone X系列判断
#define  IS_iPhoneX (CGSizeEqualToSize(CGSizeMake(375.f, 812.f), [UIScreen mainScreen].bounds.size) || CGSizeEqualToSize(CGSizeMake(812.f, 375.f), [UIScreen mainScreen].bounds.size)  || CGSizeEqualToSize(CGSizeMake(414.f, 896.f), [UIScreen mainScreen].bounds.size) || CGSizeEqualToSize(CGSizeMake(896.f, 414.f), [UIScreen mainScreen].bounds.size))
// 状态栏高度
#define StatusBarHeight (IS_iPhoneX ? 44.f : 20.f)
// 导航栏高度
#define NavBarHeight (44.f+StatusBarHeight)
// 底部标签栏高度
#define TabBarHeight (IS_iPhoneX ? (49.f+34.f) : 49.f)
// 安全区域高度
#define TabbarSafeBottomMargin     (IS_iPhoneX ? 34.f : 0.f)
//码率宽高
//#define CodeView_W 135
#define CodeView_H 162
// 首页的选择器的宽度
#define Live_Tool_H 50
#define Home_Seleted_Item_W 40
#define DefaultMargin       8
//公聊区高度
#define PubTalk_H (295 * SCREEN_HEIGHT / 896)
//主播头像信息展示高度
#define Anchor_H  75
//设置 宽高
#define Setting_W 256
#define Setting_H 73
//档位 高度
#define Gear_H 264
//首页-banner高度
#define BannerCellHeight 160
//在线观众列表 高度
#define USERLIST_H 374
//连麦弹框 高度
#define ApplyView_H 221
//用户弹框 宽高
#define USERVIEW_W 252
#define USERVIEW_H 180


#pragma mark - 颜色
// 颜色相关
#define Color(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define KeyColor Color(216, 41, 116)
//随机色
#define random(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]

#define Random_Color random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))
#define COLOR_Background @"#F7F7F7"
#define COLOR_NAV_TITLE @"#252C2B"
#define COLOR_TEXT_GRAY [UIColor colorWithRed:37/255.0 green:44/255.0 blue:43/255.0 alpha:0.5]
#define COLOR_TEXT_BLACK [UIColor colorWithRed:37/255.0 green:44/255.0 blue:43/255.0 alpha:1]





#pragma mark - 字体
#define FONT_Semibold @"PingFangSC-Semibold"
#define FONT_Regular @"PingFangSC-Regular"
#define FONT_Light @"PingFangSC-Light"


#pragma mark - 通知
//
#define kNotifySettingViewHidden @"kNotifySettingViewHidden"

// 当前没有关注的主播, 去看热门主播
#define kNotifyToseeBigWorld @"kNotifyToseeBigWorld"
// 当前的直播控制器即将消失
#define kNotifyLiveWillDisappear @"kNotifyLiveWillDisappear"
// 点击了用户
#define kNotifyClickUser @"kNotifyClickUser"
// 点击了用户列表
#define kNotifyClickUserList @"kNotifyClickUserList"

// 自动刷新最新主播界面
#define kNotifyRefreshNew @"kNotifyRefreshNew"

// 房主退出直播间，自动刷新最新主播界面，并删除当前直播间
#define kNotifyRefreshNewAndDelOld @"kNotifyRefreshNewAndDelOld"
// 点击了档位选择
#define kNotifySettingGear @"kNotifySettingGear"
// 对方同意了连麦请求 改变底部pk或者连麦工具按钮的状态
#define kNotifyChangeToolButtonState @"kNotifyChangeToolButtonState"
//音聊房上麦 下麦 改变显示及隐藏
#define kNotifyChangeAudioToolButtonState @"kNotifyChangeAudioToolButtonState"

//打开/关闭麦克风通知，根据 uid 和 MicEnable - yes 打开 / no - 关闭
#define kNotifyisMicEnable @"kNotifyisMicEnable"

//全员打开/关闭麦克风通知 - yes 打开 / no - 关闭
#define kNotifyAllMicEnable @"kNotifyAllMicEnable"

// 改变语音房 下边麦克风按钮的状态， YES - 开麦 / NO - 闭麦
#define kNotifyChangeAudioMicButtonState @"kNotifyChangeAudioMicButtonState"
//本地显示断开按钮
#define kNotifyshowHungUpButton @"kNotifyshowHungUpButton"
//变声view恢复初始状态
#define kNotifyChangeWhineView @"NotifyChangeWhineView"
#pragma mark - 其他
// 上一次刷新的时间
#define kLastRefreshDate @"kLastRefreshDate"

#define WeakSelf __typeof(self) weakSelf = self;


#define PLACEHOLDER_IMAGE [UIImage imageNamed:@"live_placeholder_head"]

#define LoginUserUidString [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:kUid]]
#define LOCAL_USER [LiveUserModel mj_objectWithKeyValues:[[NSUserDefaults standardUserDefaults] dictionaryForKey:kUserInfo]]

#define LIVE_BG_VIEW_SMALL_TOP 88
#define LIVE_BG_VIEW_SMALL_LEFT 0
#define LIVE_BG_VIEW_SMALL_RIGHT (self.bgView.frame.size.width) / 2
#define LIVE_BG_VIEW_SMALL_HEIGHT @(310 * [UIScreen mainScreen].bounds.size.height / 667)
#define LIVE_BG_VIEW_SMALL_WIDTH @((self.bgView.frame.size.width) / 2)

