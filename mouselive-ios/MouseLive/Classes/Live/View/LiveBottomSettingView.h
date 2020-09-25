//
//  LiveBottomSettingView.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/9.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
  BottomSettingTypeChangeCamera,//切换摄像头
  BottomSettingTypeMirroring,   //镜像
  BottomSettingTypeGear,        //档位
  BottomSettingTypeSkinCare     //美颜
} BottomSettingType;

typedef void (^SettingBlock)(BottomSettingType type, UIButton *button);


NS_ASSUME_NONNULL_BEGIN

@interface LiveBottomSettingView : UIView

@property (nonatomic, copy) SettingBlock settingBlock;
/**非主播和非连麦的人不可以点击档位按钮*/
@property (nonatomic, assign) BOOL isCanSettingGear;

+ (instancetype)bottomSettingView;

@end

NS_ASSUME_NONNULL_END
