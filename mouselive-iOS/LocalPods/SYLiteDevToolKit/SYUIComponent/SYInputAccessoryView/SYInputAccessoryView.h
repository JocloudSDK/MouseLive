/*
 ***********************************************************************************
 *
 *  File     : SYInputAccessoryView.h
 *
 *  Author   : iPhuan
 *
 *  History	 : Created by iPhuan on 2017/6/27.
 ***********************************************************************************
 */

#import <UIKit/UIKit.h>

@class SYInputAccessoryView;

@protocol SYInputAccessoryViewDelegate <NSObject>

@optional

- (void)inputAccessoryViewDidTapOnCancelButton:(SYInputAccessoryView *)inputAccessoryView;
- (void)inputAccessoryViewDidTapOnConfirmButton:(SYInputAccessoryView *)inputAccessoryView;

@end

typedef void(^SYInputAccessoryViewBlock)(SYInputAccessoryView *inputAccessoryView);

@interface SYInputAccessoryView : UIView
@property (nonatomic, readonly, strong) UILabel *titleLabel;
@property (nonatomic, readonly, strong) UIButton *cancelButton;
@property (nonatomic, readonly, strong) UIButton *confirmButton;

@property (nonatomic, weak) id <SYInputAccessoryViewDelegate> delegate;
@property (nonatomic, copy) SYInputAccessoryViewBlock comfirmBlock;
@property (nonatomic, copy) SYInputAccessoryViewBlock cancelBlock;


- (instancetype)initWithComfirmBlock:(SYInputAccessoryViewBlock)comfirmBlock
                         cancelBlock:(SYInputAccessoryViewBlock)cancelBlock;


@end
