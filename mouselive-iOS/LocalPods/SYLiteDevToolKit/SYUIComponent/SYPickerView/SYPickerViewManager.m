//
//  SYPickerViewManager.m
//  SYLiteDevToolKit
//
//  Created by iPhuan on 2019/9/28.
//


#import "SYPickerViewManager.h"
#import "UIColor+SYAdditions.h"


@interface SYPickerViewManager ()

@end

@implementation SYPickerViewManager

+ (instancetype)sharedManager {
    static SYPickerViewManager *instance = nil;
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
    _backgroundColor = [UIColor whiteColor];
    _textColor = SYColorHex(@"#3D3D3D");
    _rowHeight = 43;

}


@end
