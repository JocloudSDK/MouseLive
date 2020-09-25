//
//  UIViewController+SYAlertController.h
//  SYLiteDevToolKit
//
//  Created by iPhuan on 2019/8/21.
//

#import <UIKit/UIKit.h>

typedef void(^SYAlertActionHandler)(UIAlertAction *action, NSUInteger index);

@interface UIViewController (SYAlert)


// 默认title为“提示”，confirmActionTitle为“确定”，其他参数为nil
- (UIAlertController *)popupAlertViewWithMessage:(NSString *)message;

// block中index的下标对应的action按钮顺序为`confirmActionTitle`，`cancelActionTitle`
- (UIAlertController *)popupAlertViewWithTitle:(NSString *)title
                        message:(NSString *)message
                        handler:(SYAlertActionHandler)handler
              cancelActionTitle:(NSString *)cancelActionTitle
             confirmActionTitle:(NSString *)confirmActionTitle;

- (UIAlertController *)showActionSheetWithTitle:(NSString *)title
                         message:(NSString *)message
                         handler:(SYAlertActionHandler)handler
               otherActionTitles:(NSString *)otherActionTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (UIAlertController *)actionSheetWithTitle:(NSString *)title
                                    message:(NSString *)message
                                    handler:(SYAlertActionHandler)handler
                          otherActionTitles:(NSString *)otherActionTitles, ... NS_REQUIRES_NIL_TERMINATION;



- (UIAlertController *)showActionSheetWithTitle:(NSString *)title
                         message:(NSString *)message
                         handler:(SYAlertActionHandler)handler
            otherActionTitleList:(NSArray *)otherActionTitleList;

// block中index的下标对应的action按钮顺序为`otherActionTitleList`，`cancelActionTitle`
- (UIAlertController *)actionSheetWithTitle:(NSString *)title
                                    message:(NSString *)message
                                    handler:(SYAlertActionHandler)handler
                          cancelActionTitle:(NSString *)cancelActionTitle
                       otherActionTitleList:(NSArray *)otherActionTitleList;



@end
