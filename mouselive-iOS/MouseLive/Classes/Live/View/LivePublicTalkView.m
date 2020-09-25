//
//  LivePublicTalkView.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/4.
//  Copyright © 2020 sy. All rights reserved.
//

#import "LivePublicTalkView.h"
#import "LivePublicTalkCell.h"

@interface LivePublicTalkView()<UITableViewDataSource,UITableViewDelegate>

@end
static NSString *reuseIdentifier = @"LivePublicTalkCell";
@implementation LivePublicTalkView

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        [_dataArray addObject:[self fectoryTalkStringWithString:NSLocalizedString(@"Jocloud provides low latency, high quality video and audio streaming SDK and chatroom SDK. Try the features in the live room and know more about us via www.jocloud.com.", nil) color:[UIColor sl_colorWithHexString:@"#FFFFFF"]]];
      
    }
    return _dataArray;
}

- (NSAttributedString *)fectoryTalkStringWithString:(NSString *)str color:(UIColor *)color
{
    return [[NSAttributedString alloc]initWithString:str attributes:@{NSForegroundColorAttributeName: color,NSFontAttributeName:[UIFont systemFontOfSize:14.0]}];
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self == [super initWithFrame:frame style:style]) {
        self.dataSource = self;
        self.delegate = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.showsVerticalScrollIndicator = NO;
        self.estimatedRowHeight = 44.0f;
        self.rowHeight = UITableViewAutomaticDimension;
        [self registerNib:[UINib nibWithNibName:NSStringFromClass([LivePublicTalkCell class]) bundle:nil] forCellReuseIdentifier:reuseIdentifier];
        
    }
    return self;
}

#pragma mark- TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
      LivePublicTalkCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    NSAttributedString *talkString = self.dataArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.talkLable.attributedText = talkString;
    return cell;
}


- (void)refreshTalkView
{
    [self reloadData];
    [self scrollToBottom];
}
//无动画
- (void)scrollToBottom
{
    if (self.dataArray.count >= 2) {
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count - 1  inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [[self nextResponder] touchesBegan:touches withEvent:event];
}

@end
