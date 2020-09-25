/*
 ***********************************************************************************
 *
 *  File     : SYPickerView.h
 *
 *  Author   : iPhuan
 *
 *  History	 : Created by iPhuan on 2019/4/25.
 ***********************************************************************************
 */

#import <UIKit/UIKit.h>
#import "SYPickerDataProtocal.h"

@class SYPickerBaseData;

@interface SYPickerView : UIPickerView <UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic, readonly, copy) NSArray <id <SYPickerDataProtocal>> *dataSources;
@property (nonatomic, strong) id selectedResultValue;
@property (nonatomic, readonly, copy) NSString *selectedResultText;

+ (instancetype)pickerViewWithDataSource:(NSArray <id <SYPickerDataProtocal>> *)dataSource;

- (instancetype)initWithDataSource:(NSArray <id <SYPickerDataProtocal>> *)dataSource;

- (void)updateDataSource:(NSArray <id <SYPickerDataProtocal>> *)dataSource;

- (void)setSelectedRowWithValue:(id)value;

@end
