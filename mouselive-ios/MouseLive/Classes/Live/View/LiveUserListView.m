//
//  LiveUserListView.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/5.
//  Copyright © 2020 sy. All rights reserved.
//

#import "LiveUserListView.h"
#import "LiveAnchorListTableViewCell.h"
#import "LiveUserListManager.h"


@interface LiveUserListView()<UITableViewDelegate, UITableViewDataSource>
/** 全员禁言*/
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *shutupBtn;
/** 用户列表*/
@property (nonatomic, weak) IBOutlet UITableView *userTableView;
@property (nonatomic, strong) NSArray *anchorDataArray;
@property (nonatomic, strong) NSArray *userDataArray;
@property (nonatomic, assign)LiveType liveType;

// 需要的是主播列表，还是观众列表
@property (nonatomic, assign)BOOL needAnchor;

@end
static  NSString *reuseIdentifier = @"LiveAnchorListTableViewCell";
@implementation LiveUserListView

+ (instancetype)liveUserListView
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.userTableView.delegate = self;
    self.userTableView.dataSource = self;
    self.userTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.userTableView registerNib:[UINib nibWithNibName:NSStringFromClass([LiveAnchorListTableViewCell class]) bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    [self.shutupBtn setTitle:NSLocalizedString(@"Ban All",nil) forState:UIControlStateNormal];
    [self.shutupBtn setTitle:NSLocalizedString(@"Unban All",nil) forState:UIControlStateSelected];
    self.shutupBtn.hidden = YES;
    self.userTableView.rowHeight = 68.0f;
    if ([[LiveUserListManager defaultManager].ROwner.Uid isEqualToString:LoginUserUidString]) {
        self.shutupBtn.hidden = NO;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.anchorDataArray) {
        return self.anchorDataArray.count;
    } else if (self.userDataArray) {
        return self.userDataArray.count;
    } else {
        return 0;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LiveAnchorListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.anchorDataArray) {
        [cell configCellWithUserModel:self.anchorDataArray[indexPath.row]];
    } else if (self.userDataArray){
        [cell configCellWithUserModel:self.userDataArray[indexPath.row]];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id model = nil;
    if (self.anchorDataArray) {
        //主播pk
        model = self.anchorDataArray[indexPath.row];
        if (self.clickBlock) {
            
            self.clickBlock(YES, model);
        }
        
    } else if (self.userDataArray) {
        //观众列表管理
        model = self.userDataArray[indexPath.row];
        if (self.clickBlock) {
            
            self.clickBlock(NO, model);
        }
    }
}

- (void)refreshUserViewWithRoomId:(NSString *)roomId
{
    self.anchorDataArray = nil;
    self.userDataArray = [self sortUserList];
    //@"在线观众"
    self.titleLabel.text = NSLocalizedString(@"Audience",nil);
    [self.userTableView reloadData];
}

//排序
- (NSArray *)sortUserList
{
  LiveUserListManager *roomModel = [LiveUserListManager defaultManager];

    LiveUserModel *localUser = [LiveUserListManager objectForPrimaryKey:LoginUserUidString];
    LiveUserModel *owner = [LiveUserListManager objectForPrimaryKey:roomModel.ROwner.Uid];
    NSMutableArray *userArray = [[NSMutableArray alloc]init];
    [userArray addObjectsFromArray:roomModel.onlineUserList];
    if ([localUser.Uid isEqualToString:roomModel.ROwner.Uid]) {
        [userArray removeObject:owner];
    } else {
        [userArray removeObject:localUser];
        [userArray removeObject:owner];
    }
    
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:kisAdmin ascending:NO];
    NSArray *results1 = [userArray sortedArrayUsingDescriptors:@[sortDescriptor1]];
    [userArray removeAllObjects];
    if ([localUser.Uid isEqualToString:roomModel.ROwner.Uid]) {
        [userArray addObject:owner];
    } else {
        [userArray addObject:owner];
        [userArray addObject:localUser];
    }
    [userArray addObjectsFromArray:results1];
    return userArray;
}
- (void)refreshAnchorViewWithArray:(NSArray<LiveUserModel *> *)dataArray
{
    self.userDataArray = nil;
    //@"在线主播"
    self.titleLabel.text = NSLocalizedString(@"Broadcasters",nil);
    self.shutupBtn.hidden  = YES;
    self.needAnchor = YES;
    self.anchorDataArray = dataArray;
    [self.userTableView reloadData];
}


- (IBAction)allMuteBtnClick:(UIButton *)sender
{
    if (self.allMuteBlock) {
        self.allMuteBlock(sender);
    }
}


@end
