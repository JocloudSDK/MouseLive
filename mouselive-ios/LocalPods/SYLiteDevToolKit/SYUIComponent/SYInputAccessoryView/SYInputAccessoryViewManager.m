/*
 ***********************************************************************************
 *
 *  File     : SYInputAccessoryViewManager.m
 *
 *  Author   : iPhuan
 *
 *  History	 : Created by iPhuan on 2017/11/15.
 ***********************************************************************************
 */

#import "SYInputAccessoryViewManager.h"
#import "UIColor+SYAdditions.h"


@interface SYInputAccessoryViewManager ()

@end

@implementation SYInputAccessoryViewManager

+ (instancetype)sharedManager {
    static SYInputAccessoryViewManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self p_setup];
    }
    return self;
}

- (void)p_setup {
    _backgroundColor = SYColorHex(@"#F2F2F2");
    _cancelButtonTitle = @"取消";
    _cancelButtonTitleColor = SYColorHex(@"#999999");
    _cancelButtonFont = [UIFont systemFontOfSize:14];
    
    _confirmButtonTitle = @"确定";
    _confirmButtonTitleColor = SYColorHex(@"#3D3D3D");
    _confirmButtonFont = [UIFont systemFontOfSize:14];
    
    _titleLabelTextColor = SYColorHex(@"#3D3D3D");
    _titleLabelFont = [UIFont systemFontOfSize:17];
    
    _separatorLineBackgroundColor = SYColorHex(@"#F9F9F9");
}

@end
