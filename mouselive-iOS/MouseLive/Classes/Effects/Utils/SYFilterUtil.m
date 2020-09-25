//
//  SYFilterUtil.m
//  MouseLive
//
//  Created by GasparChu on 2020/4/16.
//  Copyright © 2020 sy. All rights reserved.
//
#if USE_BEATIFY

#import "SYFilterUtil.h"

@implementation SYFilterUtil {
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
    OF_GetEffectInfo(_ofContext, _effect, &_info);
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

- (void)setFilterIntensity:(int)value
{
    OF_Param *param = [self getFilterParam];
    OF_Paramf *paramf = param->data.paramf;
    paramf->val = value / 100.0f;
    int filter = _info.filterList[0];
    OF_SetFilterParamData(_ofContext, filter, param->name, param);
}

- (int)getFilterIntensity
{
    OF_Param *param = [self getFilterParam];
    OF_Paramf *paramf = param->data.paramf;
    return (int) (paramf->val * 100);
}

- (OF_Param *)getFilterParam
{
    int filter = _info.filterList[0];
    OF_Param *param = OF_NULL;
    OF_GetFilterParamData(_ofContext, filter, "Intensity", &param);
    return param;
}

@end

#endif
