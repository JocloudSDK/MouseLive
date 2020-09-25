/*
 ***********************************************************************************
 *
 *  File     : SYPickerView.m
 *
 *  Author   : iPhuan
 *
 *  History	 : Created by iPhuan on 2019/4/25.
 ***********************************************************************************
 */

#import "SYPickerView.h"
#import "SYCommonMacros.h"
#import "SYPickerViewManager.h"


@interface SYPickerView ()
@property (nonatomic, readwrite, copy) NSArray *dataSources;
@property (nonatomic, readwrite, copy) NSString *selectedResultText;

@end

@implementation SYPickerView

#pragma mark - Public

+ (instancetype)pickerViewWithDataSource:(NSArray <id <SYPickerDataProtocal>> *)dataSource {
    
    return [[self alloc] initWithDataSource:dataSource];;
}


- (instancetype)initWithDataSource:(NSArray <id <SYPickerDataProtocal>> *)dataSource {
    self = [super init];
    if (self) {
        _dataSources = [dataSource copy];
        
        self.backgroundColor = [SYPickerViewManager sharedManager].backgroundColor;
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

- (void)setSelectedRowWithValue:(id)value {
    [self.dataSources enumerateObjectsUsingBlock:^(id <SYPickerDataProtocal> obj, NSUInteger idx, BOOL *stop) {
        if (obj.value == value) {
            [self selectRow:idx inComponent:0 animated:NO];
            *stop = YES;
        }
    }];
}

- (void)updateDataSource:(NSArray <id <SYPickerDataProtocal>> *)dataSource {
    _dataSources = [dataSource copy];
    [self reloadAllComponents];
}


#pragma mark - Private

- (NSAttributedString *)p_attributedStringWithTitle:(NSString *)title {
    if (title) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
        NSDictionary *attrs = @{NSForegroundColorAttributeName:[SYPickerViewManager sharedManager].textColor};
        [attributedString addAttributes:attrs range:NSMakeRange(0, title.length)];
        return attributedString;
    }
    
    return nil;
}


#pragma mark -

- (void)layoutSubviews {
    [super layoutSubviews];
}


#pragma mark - Set or Get

- (void)setSelectedResultValue:(NSString *)selectedResultValue {
    [self setSelectedRowWithValue:selectedResultValue];
}

- (NSString *)selectedResultText {
    NSInteger row = [self selectedRowInComponent:0];
    if (row < 0) {
        return nil;
    }
    if (self.dataSources.count == 0) {
        return nil;
    }
    
    id <SYPickerDataProtocal> data = self.dataSources[row];
    return data.title;
}

- (id)selectedResultValue {
    NSInteger row = [self selectedRowInComponent:0];
    if (row < 0) {
        return nil;
    }
    
    if (self.dataSources.count == 0) {
        return nil;
    }
    
    id <SYPickerDataProtocal> data = self.dataSources[row];
    return data.value;
}



#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.dataSources.count;
}

#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return [SYPickerViewManager sharedManager].rowHeight;
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return nil;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    id <SYPickerDataProtocal> data = self.dataSources[row];
    return [self p_attributedStringWithTitle:data.title];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
}

@end
