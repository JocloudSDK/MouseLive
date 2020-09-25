/*
 ***********************************************************************************
 *
 *  File     : SYInputAccessoryView.m
 *
 *  Author   : iPhuan
 *
 *  History	 : Created by iPhuan on 2017/6/27.
 ***********************************************************************************
 */

#import "SYInputAccessoryView.h"
#import "Masonry.h"
#import "SYCommonMacros.h"
#import "SYInputAccessoryViewManager.h"


@interface SYInputAccessoryView ()
@property (nonatomic, readwrite, strong) UILabel *titleLabel;
@property (nonatomic, readwrite, strong) UIButton *cancelButton;
@property (nonatomic, readwrite, strong) UIButton *confirmButton;

@end

@implementation SYInputAccessoryView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, SYScreenWidth, 44)];
    if (self) {
        [self p_setupSubViews];
    }
    return self;
}

- (instancetype)initWithComfirmBlock:(SYInputAccessoryViewBlock)comfirmBlock
                         cancelBlock:(SYInputAccessoryViewBlock)cancelBlock {
    self = [super initWithFrame:CGRectMake(0, 0, SYScreenWidth, 44)];
    if (self) {
        _comfirmBlock = [comfirmBlock copy];
        _cancelBlock = [cancelBlock copy];
    }
    return self;
}

- (void)p_setupSubViews {
    self.backgroundColor = [SYInputAccessoryViewManager sharedManager].backgroundColor;
    
    self.cancelButton = [[UIButton alloc] init];
    _cancelButton.titleLabel.font = [SYInputAccessoryViewManager sharedManager].cancelButtonFont;
    [_cancelButton setTitle:[SYInputAccessoryViewManager sharedManager].cancelButtonTitle forState:UIControlStateNormal];
    UIColor *cancelButtonTitleColor = [SYInputAccessoryViewManager sharedManager].cancelButtonTitleColor;
    [_cancelButton setTitleColor:cancelButtonTitleColor forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[cancelButtonTitleColor colorWithAlphaComponent:0.6] forState:UIControlStateHighlighted];

    [_cancelButton addTarget:self action:@selector(onCancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancelButton];
    
    [_cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.centerY.mas_equalTo(self);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(self);

    }];
    
    self.confirmButton = [[UIButton alloc] init];
    _confirmButton.titleLabel.font = [SYInputAccessoryViewManager sharedManager].confirmButtonFont;
    [_confirmButton setTitle:[SYInputAccessoryViewManager sharedManager].confirmButtonTitle forState:UIControlStateNormal];
    UIColor *confirmButtonTitleColor = [SYInputAccessoryViewManager sharedManager].confirmButtonTitleColor;
    [_confirmButton setTitleColor:confirmButtonTitleColor forState:UIControlStateNormal];
    [_confirmButton setTitleColor:[confirmButtonTitleColor colorWithAlphaComponent:0.6] forState:UIControlStateHighlighted];

    [_confirmButton addTarget:self action:@selector(onConfirmButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_confirmButton];
    
    [_confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(self);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(self);
    }];
    
    self.titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [SYInputAccessoryViewManager sharedManager].titleLabelFont;
    _titleLabel.textColor = [SYInputAccessoryViewManager sharedManager].titleLabelTextColor;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_cancelButton.mas_right);
        make.right.mas_equalTo(_confirmButton.mas_left);
        make.centerY.mas_equalTo(self);
    }];
    
    UIView *separatorLine = [[UIView alloc] init];
    separatorLine.backgroundColor = [SYInputAccessoryViewManager sharedManager].separatorLineBackgroundColor;
    [self addSubview:separatorLine];
    
    [separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
        make.height.mas_equalTo(1);
    }];

}

#pragma mark - Action

- (void)onCancelButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(inputAccessoryViewDidTapOnCancelButton:)]) {
        [_delegate inputAccessoryViewDidTapOnCancelButton:self];
    }
    
    if (_cancelBlock) {
        _cancelBlock(self);
    }
}

- (void)onConfirmButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(inputAccessoryViewDidTapOnConfirmButton:)]) {
        [_delegate inputAccessoryViewDidTapOnConfirmButton:self];
    }
    
    if (_comfirmBlock) {
        _comfirmBlock(self);
    }
}



@end
