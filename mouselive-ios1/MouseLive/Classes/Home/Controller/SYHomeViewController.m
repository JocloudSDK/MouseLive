//
//  SYHomeViewController.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/5/26.
//  Copyright © 2020 sy. All rights reserved.
//

#import "SYHomeViewController.h"
#import "LiveCollectionCell.h"
#import "SYHomeCollectionHeaderView.h"
#import "LiveManager.h"
#import <MJRefresh.h>
#import "VideoViewController.h"
#import "AudioViewController.h"

@interface SYHomeViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,LiveManagerDelegate,SYHomeCollectionHeaderViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong)NSMutableArray *dataSource;
@property (nonatomic) LiveType type;

@end

@implementation SYHomeViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[LiveManager shareManager] addDelegate:self];
    //刷新列表
    [self.collectionView.mj_header beginRefreshing];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
     [[LiveManager shareManager] removeDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    [self setup];
    [self addRefresh];

}
- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc]init];
    }
    return _dataSource;
}

- (void)setup
{
    SYHomeCollectionHeaderView *headerView = [[SYHomeCollectionHeaderView alloc]init];
    [self.view addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.collectionView.mas_top);
    }];
    headerView.delegate = self;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemW = (SCREEN_WIDTH - 24) / 2;
    CGFloat itemH = (SCREEN_WIDTH - 24) / 2 + 23;
    layout.itemSize =  CGSizeMake(itemW , itemH);
    layout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 8;
    layout.minimumInteritemSpacing = 8;
    [_collectionView setCollectionViewLayout:layout];
    _collectionView.showsVerticalScrollIndicator = NO;
    [_collectionView registerClass:[LiveCollectionCell class] forCellWithReuseIdentifier:@"LiveCollectionCell"];

   
}

- (void)addRefresh
{
    __weak __typeof(self) weakSelf = self;
    self.type = LiveTypeVideo;
    // 下拉刷新
    _collectionView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [[LiveManager shareManager]getRoomListOfType:weakSelf.type];
    }];
    [_collectionView.mj_header beginRefreshing];
    // 上拉刷新
    _collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [[LiveManager shareManager]getRoomListOfType:weakSelf.type];
    }];
//    _collectionView.mj_footer.ignoredScrollViewContentInsetBottom = TabbarSafeBottomMargin;
}

- (void)refreshViewAndDelOld:(NSString *)roomid
{
    // 删除房间号
    if (roomid) {
        for (LiveRoomInfoModel* model in self.dataSource) {
            if ([model.RoomId isEqualToString:roomid]) {
                [self.dataSource removeObject:model];
                break;
            }
        }
        [self.collectionView reloadData];
    }
}
// MARK: - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LiveCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LiveCollectionCell" forIndexPath:indexPath];
    LiveRoomInfoModel *roomModel = self.dataSource[indexPath.item];
    cell.roomModel = roomModel;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LiveRoomInfoModel *roomModel = self.dataSource[indexPath.item];
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
     [[LiveManager shareManager] getRoomInfo:roomModel.RoomId Type:self.type];
}

#pragma mark- SYHomeCollectionHeaderViewDelegate
//选择某个item
- (void)syHomeCollectionHeaderViewDidSelecteType:(LiveType)type
{
    if (self.type != type) {
          //清空数据
        [self.dataSource removeAllObjects];
      }
    self.type = type;
    [_collectionView.mj_header beginRefreshing];
}

#pragma  mark - LiveManagerDelegate
- (void)liveManager:(LiveManager *)manager getRoomList:(NSArray<LiveRoomInfoModel *> *)roomList type:(LiveType)type
{
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
    if (type != self.type) { return; }
    //解决主播杀进程在回到列表页面因30s的延时问题出现已经销毁的房间
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    for (LiveRoomInfoModel *roomInfoModel in roomList) {
        if (![roomInfoModel.ROwner.Uid isEqualToString:LoginUserUidString]) {
            [tempArray addObject:roomInfoModel];
        }
    }
    self.dataSource = tempArray;
    [self.collectionView reloadData];
}

- (void)liveManager:(LiveManager *)manager getRoomListFailed:(NSError *)error
{
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
    [MBProgressHUD yy_showError:NSLocalizedString(@"Reconnecting to internet, please wait.", @"网络异常，请检查网络连接")];
}

- (void)liveManager:(LiveManager *)manager getRoomInfoSuccess:(LiveRoomInfoModel *)roomInfo userList:(NSArray<LiveUserModel *> *)userList
{
    if (roomInfo.RType == self.type) {
        
        LiveUserListManager *roomModel = [LiveUserListManager sy_ModelWithLiveRoomInfoModel:roomInfo];
        [LiveUserListManager createOrUpdateOnLineUserWithArray:userList];
        
        //视频聊天室
        if (roomInfo.RType == LiveTypeVideo) {
            VideoViewController *vc = [[VideoViewController alloc]initWithRoomModel:roomModel];
            
            [self.navigationController pushViewController:vc animated:YES];
            
        } else if (roomInfo.RType == LiveTypeAudio) {
            AudioViewController *vc = [[AudioViewController alloc]initWithRoomModel:roomModel];
            
            [self.navigationController pushViewController:vc animated:YES];
            
        }
    } else {
        [MBProgressHUD yy_showError:@"无效的房间信息"];
        [self refreshViewAndDelOld:roomInfo.RoomId];
    }
}

- (void)liveManager:(LiveManager *)manager getRoomInfoFailed:(NSError *)error
{
  
    [MBProgressHUD yy_showError:@"无效的房间信息"];
    //刷新房间列表
    [self.collectionView.mj_header beginRefreshing];
    NSString *para = @"无效的房间信息";
    YYLogFuncEntry([self class], _cmd, para);
}

@end
