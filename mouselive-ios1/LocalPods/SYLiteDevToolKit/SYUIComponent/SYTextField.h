//
//  SYTextField.h
//  SYLiteDevToolKit
//
//  Created by iPhuan on 2019/8/13.
//  Copyright © 2019 SY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYTextField : UITextField
@property (nonatomic, assign) BOOL canPerformAction;        // 默认YES
@property (nonatomic, assign) BOOL canPaste;                // 默认YES
@property (nonatomic, assign) NSUInteger maxInputLength;    // 传0不受限制


@end
