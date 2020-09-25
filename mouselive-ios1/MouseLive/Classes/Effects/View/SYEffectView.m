//
//  SYEffectView.m
//  MouseLive
//
//  Created by GasparChu on 2020/4/15.
//  Copyright © 2020 sy. All rights reserved.
//

#import "SYEffectView.h"
#import "SYEffectsModel.h"
#import "SYEffectTabCell.h"
#import "SYStickerContentCell.h"
#import "SYBeautyContentCell.h"
#import "SYEffectsDataManager.h"

static NSString * const SYEffectTabCellKey = @"SYEffectTabCell";
static NSString * const SYStickerContentCellKey = @"SYStickerContentCell";
static NSString * const SYBeautyContentCellKey = @"SYBeautyContentCell";

@interface SYEffectView ()<UIGestureRecognizerDelegate,
UICollectionViewDelegateFlowLayout,
UICollectionViewDataSource,
SYEffectViewDelegate>

@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewBottomLayout;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewHeightLayout;
@property (nonatomic, weak) IBOutlet UICollectionView *tabCollectionView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tabHeightLayout;
@property (nonatomic, weak) IBOutlet UICollectionView *contentCollectionView;
@property (nonatomic, copy) NSArray *dataArray;
@property (nonatomic, assign) CGFloat tabWidth;
@property (nonatomic, assign) CGFloat tabHeight;
@property (nonatomic, assign) CGFloat contentWidth;
@property (nonatomic, assign) CGFloat contentHeight;
@property (nonatomic, assign) NSInteger selectTabIndex;
@property (nonatomic, assign) NSInteger tabNum;

@end

@implementation SYEffectView

+ (instancetype)loadNibView
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].firstObject;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentViewBottomLayout.constant = -self.contentViewHeightLayout.constant;
    [self.tabCollectionView registerNib:[UINib nibWithNibName:SYEffectTabCellKey bundle:nil] forCellWithReuseIdentifier:SYEffectTabCellKey];
    [self.contentCollectionView registerNib:[UINib nibWithNibName:SYStickerContentCellKey bundle:nil] forCellWithReuseIdentifier:SYStickerContentCellKey];
    [self.contentCollectionView registerNib:[UINib nibWithNibName:SYBeautyContentCellKey bundle:nil] forCellWithReuseIdentifier:SYBeautyContentCellKey];
    
    self.tabNum = 6;
    self.contentWidth = [UIScreen mainScreen].bounds.size.width;
    self.tabWidth = self.contentWidth / self.tabNum;
    self.tabHeight = self.tabHeightLayout.constant;
    self.contentHeight = self.contentViewHeightLayout.constant - self.tabHeight;
    
    self.contentCollectionView.scrollEnabled = NO;
}

- (void)showEffectView
{
    if (!_dataArray) {
        [self setData:[SYEffectsDataManager sharedManager].getEffectsData];
    }
    self.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.contentViewBottomLayout.constant = 0;
        [self layoutIfNeeded];
    }];
}

- (void)setData:(NSArray *)data
{
    self.dataArray = data;
    if (self.dataArray.count) {
        _selectTabIndex = 0;
        SYEffectsModel *model = self.dataArray[self.selectTabIndex];
        model.selected = YES;
        [self.tabCollectionView reloadData];
        [self.contentCollectionView reloadData];
        [self.contentCollectionView layoutIfNeeded];
        [self.contentCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
}

- (void)reloadView
{
    [self.contentCollectionView reloadData];
}

- (void)hiddenEffectView
{
    if (self.hidden) {
        return;
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.contentViewBottomLayout.constant = -self.contentViewHeightLayout.constant;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

- (IBAction)tapClickEffectView:(UITapGestureRecognizer *)sender
{
    [self hiddenEffectView];
}

#pragma mark - SYEffectViewDelegate
- (void)selectedItem:(SYEffectItem *)item model:(SYEffectsModel *)model
{
    if ([self.delegate respondsToSelector:@selector(selectedItem:model:)]) {
        [self.delegate selectedItem:item model:model];
    }
}

- (void)cancelEffect:(SYEffectsModel *)model
{
    if ([self.delegate respondsToSelector:@selector(cancelEffect:)]) {
        [self.delegate cancelEffect:model];
    }
}

- (void)cancelEffect:(SYEffectsModel *)model effectItem:(SYEffectItem *)item
{
    if ([self.delegate respondsToSelector:@selector(cancelEffect:effectItem:)]) {
        [self.delegate cancelEffect:model effectItem:item];
    }
}

- (void)changeEffectIntensity:(int)value item:(SYEffectItem *)item model:(SYEffectsModel *)model
{
    if ([self.delegate respondsToSelector:@selector(changeEffectIntensity:item:model:)]) {
        [self.delegate changeEffectIntensity:value item:item model:model];
    }
}

- (void)longGestureBegan
{
    if ([self.delegate respondsToSelector:@selector(longGestureBegan)]) {
        [self.delegate longGestureBegan];
    }
}

- (void)longGestureEnded
{
    if ([self.delegate respondsToSelector:@selector(longGestureEnded)]) {
        [self.delegate longGestureEnded];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout & UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    SYEffectsModel *model = self.dataArray[indexPath.item];
    if ([collectionView isEqual:self.tabCollectionView]) {
        cell = (SYEffectTabCell *)[collectionView dequeueReusableCellWithReuseIdentifier:SYEffectTabCellKey forIndexPath:indexPath];
        [(SYEffectTabCell *)cell setData:model];
    } else if ([collectionView isEqual:self.contentCollectionView]) {
        if (model.isBeautyGroup || model.isFilterGroup) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:SYBeautyContentCellKey forIndexPath:indexPath];
            [(SYBeautyContentCell *)cell setDelegate:self];
            [(SYBeautyContentCell *)cell setData:model];
        } else {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:SYStickerContentCellKey forIndexPath:indexPath];
            [(SYStickerContentCell *)cell setDelegate:self];
            [(SYStickerContentCell *)cell setData:model];
        }
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeZero;
    if ([collectionView isEqual:self.tabCollectionView]) {
        size = (CGSize) {self.tabWidth, self.tabHeight};
    } else if ([collectionView isEqual:self.contentCollectionView]) {
        size = (CGSize) {self.contentWidth, self.contentHeight};
    }
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:self.tabCollectionView]) {
        [self reloadData:self.selectTabIndex newSelectedIndex:indexPath.item];
        [self.contentCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger contentOffsetX = scrollView.contentOffset.x;
    NSInteger remainder = contentOffsetX % (NSInteger)self.contentWidth;
    if ([scrollView isEqual:self.contentCollectionView] && (0 == remainder)) {
        NSInteger index = contentOffsetX / self.contentWidth;
        [self reloadData:self.selectTabIndex newSelectedIndex:index];
        CGFloat offsetX = self.tabWidth * (index - self.tabNum - 1);
        [self.tabCollectionView setContentOffset:(CGPoint) {offsetX < 0 ? 0 : offsetX, 0} animated:YES];
    }
}

- (void)reloadData:(NSInteger)oldSelectedIndex newSelectedIndex:(NSInteger)newSelectedIndex
{
    _selectTabIndex = newSelectedIndex;
    SYEffectsModel *selectModel = self.dataArray[oldSelectedIndex];
    selectModel.selected = NO;
    SYEffectsModel *model = self.dataArray[newSelectedIndex];
    model.selected = YES;
    [self.tabCollectionView reloadData];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)gestureRecognizer;
    CGPoint point = [tap locationInView:self];
    return !CGRectContainsPoint(self.contentView.frame, point);
}

@end
