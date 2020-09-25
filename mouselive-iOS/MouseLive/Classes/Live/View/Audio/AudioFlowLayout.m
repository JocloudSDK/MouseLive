//
//  AudioFlowLayout.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/6.
//  Copyright © 2020 sy. All rights reserved.
//

#import "AudioFlowLayout.h"

@implementation AudioFlowLayout


- (void)prepareLayout
{
    [super prepareLayout];
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    CGFloat wh = (SCREEN_WIDTH - 4)  / 4.0;
    
    self.itemSize = CGSizeMake(wh , wh);
    self.minimumLineSpacing = 20;
    self.minimumInteritemSpacing = 1;
    
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.alwaysBounceVertical = YES;
}
@end
