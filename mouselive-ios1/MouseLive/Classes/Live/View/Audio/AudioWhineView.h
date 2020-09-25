//
//  AudioWhineView.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/20.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>
// 变声场景模式
typedef NS_ENUM(NSInteger, VoiceChangerMode)
{
    VoiceChangerMode_LUBAN = 0, // 鲁班
    VoiceChangerMode_UNCLE = 1, // 大叔
    VoiceChangerMode_LORIE = 2, // 萝莉
    VoiceChangerMode_COLD = 3, // 感冒
    VoiceChangerMode_BADBOY = 4, // 熊孩子
    VoiceChangerMode_HEAVYMECHINERY = 5, // 重机械
    VoiceChangerMode_WRACRAFT = 6, // 魔兽农民
    
};
NS_ASSUME_NONNULL_BEGIN

@interface AudioWhineView : UIView

+ (AudioWhineView *)shareAudioWhineView;

@end

NS_ASSUME_NONNULL_END
