//
//  LiveFlowLayout.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/3.
//  Copyright © 2020 sy. All rights reserved.
//

#import "LiveFlowLayout.h"

@implementation LiveFlowLayout

- (void)prepareLayout
{
    [super prepareLayout];
    self.scrollDirection  = UICollectionViewScrollDirectionVertical;
    self.itemSize =  self.collectionView.bounds.size;
    self.minimumLineSpacing = 0;
    self.minimumInteritemSpacing = 0;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
}

@end
