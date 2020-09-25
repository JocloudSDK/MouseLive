//
//  SYEffectsModel.m
//  MouseLive
//
//  Created by GasparChu on 2020/4/13.
//  Copyright © 2020 sy. All rights reserved.
//

#import "SYEffectsModel.h"
#import <YYModel.h>

@implementation SYEffectsModel

+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"Icons": [SYEffectItem class]};
}

- (BOOL)isBeautyGroup
{
    return [self.GroupType isEqualToString:@"Beauty"];
}

- (BOOL)isFilterGroup
{
    return [self.GroupType isEqualToString:@"Filter"];
}

- (BOOL)isStickerGroup
{
    return [self.GroupType isEqualToString:@"Sticker"];
}

- (BOOL)isGestureGroup
{
    return [self.GroupType isEqualToString:@"Gesture"];
}

- (NSMutableArray *)selectedMArr
{
    if (!_selectedMArr) {
        _selectedMArr = [NSMutableArray array];
    }
    return _selectedMArr;
}

- (void)resetStatus
{
    self.selected = NO;
    [self.selectedMArr removeAllObjects];
}

@end

@implementation SYEffectItem

- (void)resetStatus
{
    self.minValue = 0;
    self.maxValue = 0;
    self.value = 0;
    self.defaultValue = 0;
    self.hasSelected = NO;
    self.selected = NO;
}

@end
