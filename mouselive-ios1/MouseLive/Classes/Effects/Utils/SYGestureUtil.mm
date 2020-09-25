//
//  SYGestureUtil.m
//  MouseLive
//
//  Created by GasparChu on 2020/4/22.
//  Copyright © 2020 sy. All rights reserved.
//
#if USE_BEATIFY

#import "SYGestureUtil.h"

@interface SYGestureUtil ()

@property (nonatomic, strong) NSMutableArray *effectsPath;

@end

@implementation SYGestureUtil
{
    OFHandle _ofContext;
    OF_EffectInfo _info;
    std::vector<OFHandle> _effects;
}
@synthesize enable = _enable;
@synthesize valid = _valid;

- (void)loadEffect:(OFHandle)ofContext effectPath:(NSString *)effectPath
{
    if ([self.effectsPath containsObject:effectPath]) {
        return;
    }
    _ofContext = ofContext;
    OFHandle effect = OF_INVALID_HANDLE;
    OF_Result result = OF_CreateEffectFromPackage(_ofContext, [effectPath UTF8String], (OFHandle *) &effect);
    if (OF_Result_Success != result) {
        return;
    }
    _effects.push_back(effect);
    [self.effectsPath addObject:effectPath];
}

- (std::vector<OFHandle>)getGestureEffects
{
    return _effects;
}

- (void)clearEffect
{
    for (int i = 0; i < _effects.size(); i++) {
        OFHandle effect = _effects[i];
        OF_DestroyEffect(_ofContext, effect);
        effect = OF_INVALID_HANDLE;
    }
    _effects.clear();
    [self.effectsPath removeAllObjects];
}

- (void)cancelOneGestureEffect:(NSString *)effectPath
{
    int index = (int)[self.effectsPath indexOfObject:effectPath];
    [self.effectsPath removeObject:effectPath];
    OFHandle effect = _effects[index];
    OF_DestroyEffect(_ofContext, effect);
    effect = OF_INVALID_HANDLE;
    _effects.erase(_effects.begin() + index);
}

- (BOOL)isValid
{
    return _effects.size() > 0;
}

- (NSMutableArray *)effectsPath
{
    if (!_effectsPath) {
        _effectsPath = [NSMutableArray array];
    }
    return _effectsPath;
}

@end

#endif
