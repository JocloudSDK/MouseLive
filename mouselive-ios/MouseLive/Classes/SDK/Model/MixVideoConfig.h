//
//  MixVideoConfig.h
//  MouseLive
//
//  Created by 张建平 on 2020/4/22.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MixVideoConfig : NSObject

@property (nonatomic, assign) CGRect rect;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, assign) BOOL bStandard; // 是否基准流用户，默认为false，赛事解说场景中一般将赛事流作为基准流。如果是连麦，大家都是基准流，都是 YES
@property(nonatomic, assign) BOOL bCrop; // 源流适应混画窗口的方式，
// true：缩放后裁剪多于部分，false：缩放后补黑边；如有设置裁剪区域，此操作则是作用在裁剪区域上。如果是连麦，需要去黑边，都是 YES

@end

NS_ASSUME_NONNULL_END
