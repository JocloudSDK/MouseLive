//
//  AudioContentView.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/6.
//  Copyright © 2020 sy. All rights reserved.
//

#import "AudioContentView.h"
#import "AudioCollectionViewCell.h"
#import "AudioFlowLayout.h"
#import "LiveUserListManager.h"
#import "AudioWhineView.h"
#import "LiveManager.h"

#define CollectionView_H ((SCREEN_WIDTH - 4)  / 4.0 * 2 + 20)
@interface AudioContentView()<UICollectionViewDataSource,UICollectionViewDelegate,UIGestureRecognizerDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong)LiveUserListManager *roomModel;
/**上麦人员数据源*/
@property (nonatomic, strong)NSMutableDictionary *dataDict;
@property (nonatomic, weak) IBOutlet UIImageView *headerImageview;
@property (nonatomic, weak) IBOutlet UIImageView *microImageView;
@property (nonatomic, weak) IBOutlet UILabel *nickNameLB;
@property (nonatomic, weak) IBOutlet UIButton *musicButton;
/**全员闭麦*/
@property (nonatomic, weak) IBOutlet UIButton *closeMircButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *mircButtonBottomConstraint;
@property (nonatomic, weak) IBOutlet UIButton *linkMricButton;
//@property (nonatomic, strong) LivePresenter *presenter;
@property (nonatomic, weak) IBOutlet UIView *volumeBgView;
@property (nonatomic, weak) IBOutlet UISlider *volumeSlider;
/**主播房间名*/
@property (nonatomic, weak) IBOutlet UILabel *anchorRoomName;
/**在线人数*/
@property (nonatomic, weak) IBOutlet UILabel *onlinePeopleCount;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topLayouConstraint;
@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic, strong)CAShapeLayer *shapeLayer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *collectionViewHeightConstraint;
//变声view
@property (nonatomic, strong)AudioWhineView *whineView;
//控制页面显示
@property (nonatomic) BOOL isAnchor;


@end

static NSString *reuseIdentifier = @"AudioCollectionViewCell";
@implementation AudioContentView
#pragma mark 抖动

- (NSTimer *)timer
{
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:5.0
                                         target:self
                                       selector:@selector(timerAction)
                                       userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
    return _timer;
}

- (NSMutableDictionary *)dataDict
{
    if (!_dataDict) {
        _dataDict = [[NSMutableDictionary alloc]init];
    }
    return _dataDict;
}

- (instancetype)initWithRoomId:(NSString *)roomId
{
   self = [super init];
    if (self) {
        self =  [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([AudioContentView class]) owner:nil options:nil].lastObject;
        LiveUserListManager *roomModel = [LiveUserListManager defaultManager];
        self.roomModel = roomModel;
        if ([roomModel.ROwner.Uid isEqualToString:LoginUserUidString]) {
            self.isAnchor = YES;
            [LiveUserListManager beginWriteTransaction];
            self.roomModel.ROwner.MicEnable = YES;
            self.roomModel.ROwner.SelfMicEnable = YES;
            [LiveUserListManager commitWriteTransaction];
        } else {
            self.isAnchor = NO;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserMicEnable:) name:kNotifyisMicEnable object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAllUserMicEnable:) name:kNotifyAllMicEnable object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
        [self setup];
        [self refreshView];
    }
    return self;
}

- (void)keyboardWillShow {
    self.contentView.userInteractionEnabled = NO;
}

- (void)keyboardWillHide {
    self.contentView.userInteractionEnabled = YES;
}

+ (AudioContentView *)audioContentView
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (BaseLiveContentView *)baseContentView
{
    if (!_baseContentView) {
        _baseContentView = [[BaseLiveContentView alloc]initWithRoomid:self.roomModel.RoomId view:self];
    
    }
    return _baseContentView;
}

- (AudioWhineView *)whineView
{
    if (!_whineView) {
        _whineView = [AudioWhineView shareAudioWhineView];
        [self addSubview:_whineView];
        [_whineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.mas_equalTo(SCREEN_HEIGHT);
            make.height.mas_equalTo(SCREEN_HEIGHT);
            make.width.mas_equalTo(SCREEN_WIDTH);
        }];
        _whineView.hidden = YES;
    }
    return _whineView;
}

- (void)setBaseDelegate:(id<BaseLiveContentViewDelegate>)baseDelegate
{
    _baseDelegate = baseDelegate;
    self.baseContentView.delegate = baseDelegate;
}

- (void)setDelegate:(id<AudioContentViewDelegate>)delegate
{
    _delegate = delegate;
}

- (void)refreshAllUserMicEnable:(NSNotification *)notification
{
    // TODO: 其他用户自己进来，就让他自己刷上来好了 走流程 handleDidMicOnWithUid 和 handleDidMicOffWithUid 刷新 refreshUserMicEnable
    
    NSString *state = notification.object;
    BOOL enable = [state isEqualToString:@"YES"] ? YES : NO;
    
    // 把所有的黄色 禁麦图片全部刷下去/刷上去
    // yes -- 刷下黄色图片； no -- 刷上黄色图片
    for (LiveUserModel *userModel in [self.dataDict allValues]) {
        userModel.MicEnable = enable;
        userModel.AnchorLocalLock = NO;
    }
    
    [self.contentView reloadData];
}

- (void)refreshUserMicEnable:(NSNotification *)notification
{
    NSString *uid = [notification.object objectForKey:@"uid"];
    BOOL ignoreSelfMicEnable = [[notification.object objectForKey:@"SelfMicEnable"] isEqualToString:@"2"] ? YES : NO;  // 是否忽略设置 SelfMicEnable
    BOOL selfMicEnable = [[notification.object objectForKey:@"SelfMicEnable"] isEqualToString:@"1"] ? YES : NO;
    BOOL micEnableByAnchor = [[notification.object objectForKey:@"MicEnableByAnchor"] isEqualToString:@"1"] ? YES : NO;
    
    BOOL found = NO;
    BOOL anchorLocalLock = NO;
    NSString *strAnchorLocalLock = [notification.object objectForKey:@"AnchorLocalLock"];
    if (strAnchorLocalLock) {
        found = YES;
        anchorLocalLock = [[notification.object objectForKey:@"AnchorLocalLock"] isEqualToString:@"1"] ? YES : NO;
    }
    
    // 这里需要修改
    LiveUserModel *userModel = [self.dataDict objectForKey:uid];
    if (userModel != nil) {
        if (found) {
            userModel.MicEnable = micEnableByAnchor;
            userModel.AnchorLocalLock = anchorLocalLock;
            if (!ignoreSelfMicEnable) {
                // 主播设置的
                userModel.SelfMicEnable = selfMicEnable;
            }
        }
        else {
            if (!userModel.AnchorLocalLock) {
                // 没有锁住，才可修改
                userModel.MicEnable = micEnableByAnchor;
                if (!ignoreSelfMicEnable) {
                    // 主播设置的
                    userModel.SelfMicEnable = selfMicEnable;
                }
            }
        }

        [self.contentView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:[[self.dataDict allValues] indexOfObject:userModel] inSection:0]]];
    }
    
    //刷新主播麦克风状态
    if ([self.roomInfoModel.ROwner.Uid isEqualToString:uid]) {
        self.roomInfoModel.ROwner.SelfMicEnable = selfMicEnable;
        if (self.roomInfoModel.ROwner.SelfMicEnable) {
            [self.microImageView setImage:[UIImage imageNamed:@"audio_micr_open"]];
        } else {
            [self.microImageView setImage:[UIImage imageNamed:@"audio_mirc_close_onme"]];
        }
    }
}


- (void)setup
{
    self.mircButtonBottomConstraint.constant = TabbarSafeBottomMargin + Live_Tool_H + 10;
    self.linkMricButton.hidden = self.isAnchor;
    
    [self.volumeSlider setThumbImage:[UIImage imageNamed:@"slider_thurk"] forState:UIControlStateNormal];
    [self.volumeSlider setThumbImage:[UIImage imageNamed:@"slider_thurk"] forState:UIControlStateSelected];
    [self.volumeSlider setThumbImage:[UIImage imageNamed:@"slider_thurk"] forState:UIControlStateHighlighted];
    self.topLayouConstraint.constant = StatusBarHeight + 4.0f;
    self.isRunningMusic = NO;
    self.collectionViewHeightConstraint.constant = CollectionView_H;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.musicButton.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(100,100)];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = self.musicButton.bounds;
    layer.path = path.CGPath;
    self.musicButton.layer.mask = layer;
    self.musicButton.backgroundColor = [UIColor sl_colorWithHexString:@"#33C397"];
    
    
    self.volumeBgView.layer.cornerRadius = 17.0f;
    self.volumeBgView.layer.masksToBounds = YES;
    self.volumeBgView.backgroundColor = [UIColor sl_colorWithHexString:@"#33C397"];
    self.volumeBgView.hidden = YES;
    self.volumShowState =  self.volumeBgView.hidden;
    
    self.closeMircButton.backgroundColor = [UIColor sl_colorWithHexString:@"#33C397"];
    self.closeMircButton.layer.cornerRadius = 15.0f;
    self.closeMircButton.layer.masksToBounds = YES;
    
    
    self.contentView.collectionViewLayout = [[AudioFlowLayout alloc]init];
    [self.contentView registerNib:[UINib nibWithNibName:NSStringFromClass([AudioCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    self.contentView.dataSource = self;
    self.contentView.delegate = self;
    [self.contentView reloadData];
    [UIView yy_maskViewToBounds:self.headerImageview];
    [UIView yy_maskViewToBounds:self.microImageView];
    [self baseContentView];
    [self bringSubviewToFront:self.linkMricButton];
}

//根据数据刷新视图
- (void)refreshView
{
    [self refreshAnchorView];
    [self refreshCollectionView];
}
//刷新主播头像
- (void)refreshAnchorView
{
    [self.headerImageview yy_setImageWithURL:[NSURL URLWithString:self.roomModel.ROwner.Cover] placeholder:PLACEHOLDER_IMAGE];
    if (self.roomModel.ROwner.SelfMicEnable) {
        [self.microImageView setImage:[UIImage imageNamed:@"audio_micr_open"]];
    } else {
        [self.microImageView setImage:[UIImage imageNamed:@"audio_mirc_close_onme"]];
    }
    self.anchorRoomName.text = self.roomModel.RName;
    self.nickNameLB.text = self.roomModel.ROwner.NickName;
    self.headerImageview.backgroundColor = [UIColor redColor];
    //房间人数
    self.peopleCount = self.roomModel.onlineUserList.count;
   
}

#pragma mark - 刷新语音房
- (void)refreshCollectionView
{
    LiveUserListManager *roomModel = [LiveUserListManager defaultManager];
    [self.dataDict removeAllObjects];
       // 找已经上麦的人
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Uid != %@ AND LinkUid != %@ AND LinkRoomId != %@", self.roomModel.ROwner.Uid,@"0",@"0"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kUid ascending:YES];

    NSArray *filteredArray = [[roomModel.onlineUserList filteredArrayUsingPredicate:predicate] sortedArrayUsingDescriptors:@[sortDescriptor]];
    if (filteredArray.count) {
        for (LiveUserModel *userModel in filteredArray) {
            [self.dataDict setObject:userModel forKey:userModel.Uid];
        }
    }
    [self.contentView reloadData];
}

- (void)refreshOnlineUserMircStatusWithUid:(NSString *)uid
{
    LiveUserModel *userModel =  [self.dataDict objectForKey:uid];
    if (userModel) {
        NSInteger index = [self.dataDict.allValues indexOfObject:userModel];
         //只刷新一个cell
         [self.contentView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
    } else {
        //刷新主播头像
        if ([LiveUserListManager defaultManager].ROwner.SelfMicEnable) {
            [self.microImageView setImage:[UIImage imageNamed:@"audio_micr_open"]];
        } else {
            [self.microImageView setImage:[UIImage imageNamed:@"audio_mirc_close_onme"]];
        }
    }
}

- (void)setIsAnchor:(BOOL)isAnchor
{
    _isAnchor = isAnchor;
    //全部闭麦
    [self.closeMircButton setTitle:NSLocalizedString(@"Mute All", nil) forState:UIControlStateNormal];
    //全部开麦"
    [self.closeMircButton setTitle:NSLocalizedString(@"Unmute All", nil) forState:UIControlStateSelected];
    if (!_isAnchor) {
        _closeMircButton.hidden = YES;
        _musicButton.hidden = YES;
        _volumeBgView.hidden = YES;
        self.volumShowState =  self.volumeBgView.hidden;
    }
}


#pragma mark - CollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 8;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AudioCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.indexPath = indexPath;

    if (indexPath.row <= self.dataDict.count - 1 && self.dataDict.count > 0) {
        LiveUserModel *model = [self.dataDict allValues][indexPath.row];
        cell.userModel = model;
    } else {
        cell.userModel = nil;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AudioCollectionViewCell *cell = (AudioCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    LiveUserModel *localUser = [LiveUserListManager objectForPrimaryKey:LoginUserUidString];
    if (localUser.isAnchor || localUser.isAdmin) {
        //不对自己操作
        if ((![cell.userModel.Uid isEqualToString:localUser.Uid]) && cell.userModel) {
            //显示用户管理弹框
            self.baseContentView.userViewType = LiveUserViewTypeTwoMicStyle;
            [self.baseContentView showUserViewWithUid:cell.userModel.Uid];
        }
    }
}

- (void)setPeopleCount:(NSInteger)peopleCount
{
    
    _peopleCount = peopleCount;
    self.onlinePeopleCount.text = [NSString stringWithFormat:@"%@：%ld",NSLocalizedString(@"Online", nil),(long)peopleCount];
}

#pragma mark -播放音乐 展开收起播放条
- (IBAction)musicClicked:(UIButton *)sender
{
    if (!self.isRunningMusic) {
        [[LiveManager shareManager] openAuidoFileWithPath:[[NSBundle mainBundle]pathForResource:@"music1931" ofType:@"mp3"]];
        [[LiveManager shareManager] setAudioFilePlayVolume:50];
        //第一次进来先不要播放
        [[LiveManager shareManager] pauseAudioFile];
    }
    if (!self.volumeBgView.hidden) {
        sender.selected = !sender.selected;
        //相应了block开始播放音乐了
        if (self.delegate && [self.delegate respondsToSelector:@selector(audioManagerMusicPlay:)]) {
            self.isRunningMusic = YES;
            [self.delegate audioManagerMusicPlay:sender.selected];
        }
    }
    //首次点击展开音量条
    self.volumeBgView.hidden = NO;
    self.volumShowState =  self.volumeBgView.hidden;
    [sender setImage:[UIImage imageNamed:@"music_play"] forState:UIControlStateNormal];
    [sender setImage:[UIImage imageNamed:@"music_pause"] forState:UIControlStateSelected];
    [self.musicButton.imageView.layer addSublayer:self.shapeLayer];
 
    self.shapeLayer.strokeEnd = [[LiveManager shareManager] currentPlayprogress];
    if (self.shapeLayer.strokeEnd == 1.0) {
        self.shapeLayer.strokeEnd = 0.1;
    }
    if (_timer.isValid) {
        [_timer invalidate];
    }
    _timer = nil;
    _timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerAction) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
}

- (void)timerAction
{
    [self.musicButton setImage:[UIImage imageNamed:@"audio_music"] forState:UIControlStateNormal];
    [self.musicButton setImage:[UIImage imageNamed:@"audio_music"] forState:UIControlStateSelected];
    [self.shapeLayer removeFromSuperlayer];
    self.volumeBgView.hidden = YES;
    self.volumShowState =  self.volumeBgView.hidden;
}

//绘制播放进度
- (CAShapeLayer *)shapeLayer
{
    if (!_shapeLayer) {
        _shapeLayer =[[CAShapeLayer alloc]init];
        
        _shapeLayer.frame = CGRectMake(0, 0, self.musicButton.imageView.bounds.size.width - 2, self.musicButton.imageView.bounds.size.width - 2);
        _shapeLayer.lineWidth = 1;
        
        _shapeLayer.fillColor =[UIColor clearColor].CGColor;
        _shapeLayer.strokeColor =[UIColor whiteColor].CGColor;
        _shapeLayer.strokeStart = 0;
        _shapeLayer.strokeEnd = 0.1;
        
        CGPoint center =  CGPointMake((self.musicButton.imageView.bounds.size.width)/2, (self.musicButton.imageView.bounds.size.width)/2);
        
        UIBezierPath *bezierPath =[UIBezierPath bezierPathWithArcCenter:center radius:(self.musicButton.imageView.bounds.size.width)/2 startAngle: -0.5 * M_PI endAngle: 1.5 * M_PI clockwise:YES];
        _shapeLayer.path = bezierPath.CGPath;
    }
    return _shapeLayer;
}

#pragma mark - Button Action
//调节音量
- (IBAction)volumeSliderAction:(UISlider *)sender
{
    [[LiveManager shareManager] setAudioFilePlayVolume:sender.value];
}


//关闭麦克风
- (IBAction)closeBtnClicked:(UIButton *)sender
{
    self.closeMircButton.selected = !self.closeMircButton.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioManagerMircStatus:)]) {
        [self.delegate audioManagerMircStatus:sender];
    }
}

//打开观众列表
- (IBAction)peopleListBtnAction:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioLiveOpenUserList)]) {
        [self.delegate audioLiveOpenUserList];
    }
}

// 关闭直播间
- (IBAction)quitBtnAction:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioLiveCloseRoom)]) {
        self.isRunningMusic = NO;
        [self.delegate audioLiveCloseRoom];
    }
}
- (IBAction)linkMircBtnAction:(UIButton *)sender
{
    if (sender.selected) {
        //下麦
        if (self.delegate && [self.delegate respondsToSelector:@selector(audioDisconnectAnchor)]) {
            [self.delegate audioDisconnectAnchor];
        }
    } else {
        //上麦
        if (self.delegate && [self.delegate respondsToSelector:@selector(audioConnectAnchor)]) {
            [self.delegate audioConnectAnchor];
        }
    }
}

#pragma mark privite method
/**显示变声视图*/
- (void)showAudioWhine
{
    [self bringSubviewToFront:self.whineView];
    self.whineView.hidden = NO;
    self.whineView.transform = CGAffineTransformMakeTranslation(0, - SCREEN_HEIGHT);
    
}
/**隐藏变声视图*/
- (void)hidenWhineView
{
    [self sendSubviewToBack:self.whineView];
    self.whineView.hidden = YES;
    self.whineView.transform = CGAffineTransformIdentity;
    
}
- (void)hiddenCurrentView
{
    if (!self.whineView.hidden) {
        [self hidenWhineView];
    }
}

- (void)updateLinkMircButtonSelectedStatus:(BOOL)selected
{
    self.linkMricButton.userInteractionEnabled = YES;
    self.linkMricButton.selected = selected;
}

- (void)updateWhineViewHiddenStatus:(BOOL)hidden
{
    if (hidden) {
        [self hidenWhineView];
    } else {
        [self showAudioWhine];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.baseContentView hiddenCurrentView];
    [self hiddenCurrentView];
}
@end
