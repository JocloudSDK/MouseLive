//
//  LiveCollectionCell.h
//  MouseLive
//
//  Created by 张建平 on 2020/3/2.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveRoomInfoModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface LiveCollectionCell : UICollectionViewCell

@property (nonatomic, strong)LiveRoomInfoModel *roomModel;

@end

NS_ASSUME_NONNULL_END
