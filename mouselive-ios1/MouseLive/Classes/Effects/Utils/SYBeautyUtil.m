//
//  SYBeautyUtil.m
//  MouseLive
//
//  Created by GasparChu on 2020/4/15.
//  Copyright © 2020 sy. All rights reserved.
//
#if USE_BEATIFY

#import "SYBeautyUtil.h"

@implementation SYBeautyUtil {
    OFHandle _ofContext;
    OFHandle _effect;
    OF_EffectInfo _info;
}
@synthesize enable = _enable;
@synthesize valid = _valid;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _enable = YES;
    }
    return self;
}

- (void)loadEffect:(OFHandle)ofContext effectPath:(NSString *)effectPath
{
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

- (int)getBeautyOptionMinValue:(int)filterIndex filterName:(NSString *)filterName
{
    OF_Paramf *param = [self getFilterParam:filterIndex filterName:filterName]->data.paramf;
    return (int) (param->minVal / (param->maxVal - param->minVal) * 100);
}

- (int)getBeautyOptionMaxValue:(int)filterIndex filterName:(NSString *)filterName
{
    OF_Paramf *param = [self getFilterParam:filterIndex filterName:filterName]->data.paramf;
    return (int) (param->maxVal / (param->maxVal - param->minVal) * 100);
}

- (int)getBeautyOptionValue:(int)filterIndex filterName:(NSString *)filterName
{
    OF_Paramf *param = [self getFilterParam:filterIndex filterName:filterName]->data.paramf;
    return (int) (param->val / (param->maxVal - param->minVal) * 100);
}

- (void)setBeautyOptionValue:(int)filterIndex filterName:(NSString *)filterName value:(int)value
{
    OF_Param *param = [self getFilterParam:filterIndex filterName:filterName];
    OF_Paramf *paramf = param->data.paramf;
    paramf->val = value / 100.0f * (paramf->maxVal - paramf->minVal);
    
    int filter = _info.filterList[filterIndex];
    OF_SetFilterParamData(_ofContext, filter, param->name, param);
}

- (OF_Param *)getFilterParam:(int)filterIndex filterName:(NSString *)filterName
{
    int filter = _info.filterList[filterIndex];
    const char *name = [filterName UTF8String];
    OF_Param *param = OF_NULL;
    OF_GetFilterParamData(_ofContext, filter, name, &param);
    return param;
}

@end

#endif
