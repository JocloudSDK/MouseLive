//
//  SYStickerContentCell.m
//  MouseLive
//
//  Created by GasparChu on 2020/4/17.
//  Copyright © 2020 sy. All rights reserved.
//

#import "SYStickerContentCell.h"
#import "SYStickerCell.h"
#import "SYEffectsModel.h"
#import "SYEffectsDataManager.h"

static NSString * const SYStickerCellKey = @"SYStickerCell";

@interface SYStickerContentCell ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, SYEffectViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) SYEffectsModel *effectsModel;

@end

@implementation SYStickerContentCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    [self.collectionView registerNib:[UINib nibWithNibName:SYStickerCellKey bundle:nil] forCellWithReuseIdentifier:SYStickerCellKey];
}

- (void)setData:(SYEffectsModel *)data
{
    _effectsModel = data;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDelegateFlowLayout & UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.effectsModel.Icons.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SYStickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SYStickerCellKey forIndexPath:indexPath];
    if (0 == indexPath.item) {
        [cell setThumb:nil selected:!self.effectsModel.selectedMArr.count selectedMuti:NO downloaded:YES];
    } else {
        SYEffectItem *item = self.effectsModel.Icons[indexPath.item - 1];
        [cell setThumb:item.Thumb selected:item.isSelected selectedMuti:self.effectsModel.isGestureGroup downloaded:item.isDownloaded];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 点击禁用取消特效
    if (0 == indexPath.item) {
        [self.effectsModel.selectedMArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSInteger selectedIndex = [obj integerValue];
            SYEffectItem *selectedItem = self.effectsModel.Icons[selectedIndex];
            selectedItem.selected = NO;
        }];
        [self.effectsModel.selectedMArr removeAllObjects];
        if ([self.delegate respondsToSelector:@selector(cancelEffect:)]) {
            [self.delegate cancelEffect:self.effectsModel];
        }
    } else {
        NSInteger selectedIndex = indexPath.item - 1;
        SYEffectItem *selectedItem = self.effectsModel.Icons[selectedIndex];
        if (selectedItem.isDownloading) {
            return;
        }
        // 下载
        if (!selectedItem.isDownloaded) {
            SYStickerCell *cell = (SYStickerCell *)[collectionView cellForItemAtIndexPath:indexPath];
            [cell downloadEffectAndShowLoading];
            [[SYEffectsDataManager sharedManager] downloadWithEffectItem:selectedItem typeName:self.effectsModel.GroupType success:^{
                [cell downloadSuccessAndStopLoading];
                [self collectionView:collectionView didSelectItemAtIndexPath:indexPath];
            } faliure:^{
                [cell downloadFailureAndStopLoading];
            }];
            return;
        }
        
        // 贴纸单选
        if (self.effectsModel.isStickerGroup) {
            if ([self.effectsModel.selectedMArr containsObject:@(selectedIndex)]) {
                return;
            }
            if (self.effectsModel.selectedMArr.count) {
                NSInteger selectedIndex = [self.effectsModel.selectedMArr.firstObject integerValue];
                [self.effectsModel.selectedMArr removeObject:@(selectedIndex)];
                SYEffectItem *selectedItem = self.effectsModel.Icons[selectedIndex];
                selectedItem.selected = NO;
            }
            [self selectedEffectWithSelectedIndex:selectedIndex];
        }
        
        // 手势多选
        if (self.effectsModel.isGestureGroup) {
            if ([self.effectsModel.selectedMArr containsObject:@(selectedIndex)]) {
                [self.effectsModel.selectedMArr removeObject:@(selectedIndex)];
                SYEffectItem *selectedItem = self.effectsModel.Icons[selectedIndex];
                selectedItem.selected = NO;
                if ([self.delegate respondsToSelector:@selector(cancelEffect:effectItem:)]) {
                    [self.delegate cancelEffect:self.effectsModel effectItem:selectedItem];
                }
            } else {
                [self selectedEffectWithSelectedIndex:selectedIndex];
            }
        }
    }
    
    [self.collectionView reloadData];
}

- (void)selectedEffectWithSelectedIndex:(NSInteger)selectedIndex
{
    [self.effectsModel.selectedMArr addObject:@(selectedIndex)];
    SYEffectItem *item = self.effectsModel.Icons[selectedIndex];
    item.selected = YES;
    if ([self.delegate respondsToSelector:@selector(selectedItem:model:)]) {
        [self.delegate selectedItem:item model:self.effectsModel];
    }
}

#pragma mark - SYEffectViewDelegate
- (void)changeEffectIntensity:(int)value item:(SYEffectItem *)item model:(SYEffectsModel *)model
{
    if ([self.delegate respondsToSelector:@selector(changeEffectIntensity:item:model:)]) {
        [self.delegate changeEffectIntensity:value item:item model:self.effectsModel];
    }
}

@end
