//
//  SYPickerDataProtocal.h
//  SYLiteDevToolKit
//
//  Created by iPhuan on 2019/9/28.
//


#import <Foundation/Foundation.h>


@protocol SYPickerDataProtocal <NSObject>

@required
@property (nonatomic, readonly, copy) id value;
@property (nonatomic, readonly, copy) NSString *title;


- (instancetype)initWithValue:(id)value;

@optional

- (instancetype)initWithValue:(id)value title:(NSString *)title;


@end
