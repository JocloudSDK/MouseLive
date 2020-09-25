//
//  LivePublicTalkView.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/4.
//  Copyright © 2020 sy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface LivePublicTalkView : UITableView

@property (nonatomic, strong)NSMutableArray *dataArray;

- (void)refreshTalkView;
@end

NS_ASSUME_NONNULL_END
