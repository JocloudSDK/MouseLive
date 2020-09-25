//
//  SYBeautyContentCell.m
//  MouseLive
//
//  Created by GasparChu on 2020/4/23.
//  Copyright © 2020 sy. All rights reserved.
//

#import "SYBeautyContentCell.h"
#import "SYBeautyCell.h"
#import "SYEffectsModel.h"

static NSString * const SYBeautyCellKey = @"SYBeautyCell";

@interface SYBeautyContentCell ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, SYEffectViewDelegate>

@property (nonatomic, weak) IBOutlet UISlider *slider;
@property (nonatomic, weak) IBOutlet UIImageView *defaultImgView;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) SYEffectsModel *effectsModel;
@property (nonatomic, weak) IBOutlet UILabel *resetLabel;
@property (nonatomic, weak) IBOutlet UILabel *originalLabel;

@end

@implementation SYBeautyContentCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    [self.collectionView registerNib:[UINib nibWithNibName:SYBeautyCellKey bundle:nil] forCellWithReuseIdentifier:SYBeautyCellKey];
    
    UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesture:)];
    [self.defaultImgView addGestureRecognizer:longGes];
    
    self.resetLabel.text = NSLocalizedString(@"Reset", nil);
    self.originalLabel.text = NSLocalizedString(@"Original", nil);
}

// 将 label 添加到 slider 滑块上方
- (void)addValueLabel
{
    [self.slider layoutIfNeeded];
    if (!_valueLabel) {
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:12.f];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @(self.slider.value).stringValue;
        _valueLabel = label;
        UIView *view = self.slider.subviews.lastObject;
        if (view) {
            [view addSubview:self.valueLabel];
            [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.offset(0.f);
                make.height.offset(13.f);
                make.top.offset(-20.f);
            }];
        }
    }
}

- (void)setData:(SYEffectsModel *)data
{
    [self addValueLabel];
    
    _effectsModel = data;
    [self.collectionView reloadData];
}

- (void)setSliderValueWithEffectItem:(SYEffectItem *)item
{
    self.slider.enabled = YES;
    self.slider.minimumValue = item.minValue;
    self.slider.maximumValue = item.maxValue;
    self.slider.value = item.value;
    self.valueLabel.text = @(item.value).stringValue;
}

- (IBAction)valueChanged:(UISlider *)sender
{
    if (!self.effectsModel.selectedMArr.count) {
        return;
    }
    NSInteger selectedIndex = [self.effectsModel.selectedMArr.firstObject integerValue];
    SYEffectItem *item = self.effectsModel.Icons[selectedIndex];
    int value = sender.value;
    item.value = value;
    self.valueLabel.text = @(value).stringValue;
    if ([self.delegate respondsToSelector:@selector(changeEffectIntensity:item:model:)]) {
        [self.delegate changeEffectIntensity:value item:item model:self.effectsModel];
    }
}

// 重置事件
- (IBAction)clickResetBtn:(UIButton *)sender
{
    if (!self.effectsModel.selectedMArr.count) {
        return;
    }
    NSInteger selectedIndex = [self.effectsModel.selectedMArr.firstObject integerValue];
    SYEffectItem *item = self.effectsModel.Icons[selectedIndex];
    int value = item.defaultValue;
    item.value = value;
    self.slider.value = value;
    self.valueLabel.text = @(value).stringValue;
    if ([self.delegate respondsToSelector:@selector(changeEffectIntensity:item:model:)]) {
        [self.delegate changeEffectIntensity:value item:item model:self.effectsModel];
    }
}

- (void)longGesture:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(longGestureBegan)]) {
            [self.delegate longGestureBegan];
        }
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(longGestureEnded)]) {
            [self.delegate longGestureEnded];
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout & UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.effectsModel.Icons.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SYBeautyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SYBeautyCellKey forIndexPath:indexPath];
    SYEffectItem *item = self.effectsModel.Icons[indexPath.item];
    [cell setName:item.ResourceTypeName thumb:item.Thumb selected:item.isSelected];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger selectedIndex = indexPath.item;
    if ([self.effectsModel.selectedMArr containsObject:@(selectedIndex)]) {
        return;
    }
    
    if (self.effectsModel.selectedMArr.count) {
        NSInteger selectedIndex = [self.effectsModel.selectedMArr.firstObject integerValue];
        SYEffectItem *selectedItem = self.effectsModel.Icons[selectedIndex];
        selectedItem.selected = NO;
        [self.effectsModel.selectedMArr removeObject:@(selectedIndex)];
    }
    
    SYEffectItem *item = self.effectsModel.Icons[selectedIndex];
    item.selected = YES;
    [self.effectsModel.selectedMArr addObject:@(selectedIndex)];
    if ([self.delegate respondsToSelector:@selector(selectedItem:model:)]) {
        [self.delegate selectedItem:item model:self.effectsModel];
    }
    
    [self.collectionView reloadData];
    // 特效的一些强度值都是在特效包中获取的，所以在代理方法之后重新设置 slider
    [self setSliderValueWithEffectItem:item];
}

@end
