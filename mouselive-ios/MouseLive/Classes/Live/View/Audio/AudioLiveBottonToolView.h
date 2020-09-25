//
//  LiveBottonToolView.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/3.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AudioLiveBottonToolViewDelegate <NSObject>
//关闭本地麦克风
- (void)closeLocalMirc;
//打开本地麦克风
- (void)openLocalMirc;
@end

typedef NS_ENUM(NSUInteger, AudioLiveToolType) {
    AudioLiveToolTypeMicr     = 1,      //麦克风  0
    AudioLiveToolTypeWhine = 2,  //主播pk 观众连麦
    AudioLiveToolTypeFeedback = 3,  //反馈   3
    AudioLiveToolTypeCodeRate  = 4,  //码率
};

NS_ASSUME_NONNULL_BEGIN

@interface AudioLiveBottonToolView : UIView
/** 点击工具栏  */
@property (nonatomic, copy)void (^clickToolBlock)(AudioLiveToolType type,BOOL selected, UIButton *button);

@property (nonatomic, copy) NSString *talkButtonTitle;

/**音聊房自己是否正在连麦中*/
@property (nonatomic, assign) BOOL localRuningMirc;

/**自己在连麦中 主播关闭麦克风 麦克风不可被点击*/
@property (nonatomic, assign) BOOL mircEnable;

@property (nonatomic, weak)id <AudioLiveBottonToolViewDelegate> delegate;

- (instancetype)initWithAnchor:(BOOL)isAnchor;
@end

NS_ASSUME_NONNULL_END
