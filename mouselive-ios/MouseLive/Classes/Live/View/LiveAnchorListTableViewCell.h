//
//  LiveAnchorListTableViewCell.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/20.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveUserListView.h"
#import "LiveUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveAnchorListTableViewCell : UITableViewCell

//刷新cell
- (void)configCellWithUserModel:(LiveUserModel *)model;
@end

NS_ASSUME_NONNULL_END
