//
//  SYStickerUtil.m
//  MouseLive
//
//  Created by GasparChu on 2020/4/16.
//  Copyright © 2020 sy. All rights reserved.
//
#if USE_BEATIFY

#import "SYStickerUtil.h"

@implementation SYStickerUtil {
    OFHandle _ofContext;
    OFHandle _effect;
    OF_EffectInfo _info;
}
@synthesize enable = _enable;
@synthesize valid = _valid;

- (void)loadEffect:(OFHandle)ofContext effectPath:(NSString *)effectPath
{
    [self clearEffect];
    
    _ofContext = ofContext;
    OF_Result result = OF_CreateEffectFromPackage(_ofContext, [effectPath UTF8String], (OFHandle *) &_effect);
    if (OF_Result_Success != result) {
        return;
    }
}

- (OFHandle)getEffect
{
    return _effect;
}

- (void)clearEffect
{
    if (OF_INVALID_HANDLE != _effect) {
        OF_DestroyEffect(_ofContext, _effect);
        _effect = OF_INVALID_HANDLE;
    }
}

- (BOOL)isValid
{
    return _effect != OF_INVALID_HANDLE;
}

@end

#endif
