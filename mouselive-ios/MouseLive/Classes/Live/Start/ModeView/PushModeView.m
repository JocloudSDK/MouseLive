//
//  PushModeView.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/4/23.
//  Copyright © 2020 sy. All rights reserved.
//

#import "PushModeView.h"

@implementation PushModeView

+ (instancetype)pushModeView
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation p affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
//    self.layer.cornerRadius
//    self.layer.masksToBounds
}

- (IBAction)buttonClicked:(UIButton *)sender
{
    if (self.modeBlock) {
        self.modeBlock(sender.tag);
    }
}

- (IBAction)closeAction:(UIButton *)sender
{
    
    self.hidden = YES;
}

@end
