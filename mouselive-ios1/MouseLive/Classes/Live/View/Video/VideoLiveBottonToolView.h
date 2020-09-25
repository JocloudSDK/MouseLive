//
//  LiveBottonToolView.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/3.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveDefaultConfig.h"
@protocol VideoLiveBottonToolViewDelegate <NSObject>
//关闭本地麦克风
- (void)closeLocalMirc;
//打开本地麦克风
- (void)openLocalMirc;
@end

typedef NS_ENUM(NSUInteger, VideoLiveToolType) {
    VideoLiveToolTypeMicr     = 1,      //麦克风  0
    VideoLiveToolTypeLinkmicr = 2,  //主播pk 观众连麦
    VideoLiveToolTypeSetting  = 3,   //设置   2
    VideoLiveToolTypeFeedback = 4,  //反馈   3
    VideoLiveToolTypeCodeRate = 5,  //码率
};

NS_ASSUME_NONNULL_BEGIN

@interface VideoLiveBottonToolView : UIView

@property (nonatomic, weak)id <VideoLiveBottonToolViewDelegate> delegate;
/** 点击工具栏  */
@property(nonatomic, copy)void (^clickToolBlock)(VideoLiveToolType type,BOOL selected, UIButton *button);

@property(nonatomic, copy) NSString *talkButtonTitle;
/**音聊房自己是否正在连麦中*/
@property(nonatomic, assign) BOOL localRuningMirc;

/**自己是否可以连麦 主播在连麦中不可以显示连麦按钮*/
@property(nonatomic, assign) BOOL mircEnable;
/**是否是cdn模式 是 可以连麦和PK 否 不可以连麦和PK*/
@property(nonatomic, assign) BOOL isCdnModel;

//初始化方法
- (instancetype)initWithAnchor:(BOOL)isAnchor;
//刷新视频工具栏
- (void)refreshVideoToolView;

@end

NS_ASSUME_NONNULL_END
