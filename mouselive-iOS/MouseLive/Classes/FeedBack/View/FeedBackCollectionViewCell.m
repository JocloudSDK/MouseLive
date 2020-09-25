//
//  FeedBackCollectionViewCell.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/6/12.
//  Copyright © 2020 sy. All rights reserved.
//

#import "FeedBackCollectionViewCell.h"

@implementation FeedBackCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)delectButtonAction:(UIButton *)sender
{
    if (self.delBlock) {
        self.delBlock(self.imageView.image);
    }
}

@end
