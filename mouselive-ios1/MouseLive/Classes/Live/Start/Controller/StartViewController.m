//
//  StartViewController.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/11.
//  Copyright © 2020 sy. All rights reserved.
//

#import "StartViewController.h"
#import "SYAppId.h"
#import "PushModeView.h"
#import "VideoViewController.h"
#import "AudioViewController.h"

@interface StartViewController ()<SYHttpResponseHandle, LiveManagerDelegate>

@property (nonatomic, weak) IBOutlet UIView *videoView;
@property (nonatomic, weak) IBOutlet UIView *voiceView;

//在线KTV
@property (nonatomic, weak) IBOutlet UIView *onlineView;
@property (nonatomic, weak) IBOutlet UIView *sportsView;

//赛事解说
@property (nonatomic, weak) IBOutlet UIButton *startBtn;
@property (nonatomic, weak) IBOutlet UILabel *videoLB;
@property (nonatomic, weak) IBOutlet UILabel *videoSubLB;
@property (nonatomic, weak) IBOutlet UILabel *voiceLB;
@property (nonatomic, weak) IBOutlet UILabel *voiceSubLB;
@property (nonatomic, weak) IBOutlet UILabel *onlineLB;
@property (nonatomic, weak) IBOutlet UILabel *onlineSubLB;
@property (nonatomic, weak) IBOutlet UILabel *sportLB;
@property (nonatomic, weak) IBOutlet UILabel *sportSubLB;
@property (nonatomic, weak) IBOutlet UIImageView *videoImageView;
@property (nonatomic, weak) IBOutlet UIImageView *audioImageView;

@property (nonatomic, strong) PushModeView *modeView;
@property (nonatomic, assign)NSInteger selectIndex;

@property (nonatomic, assign) LiveType roomType;
@property (nonatomic, assign) PublishMode publishMode;

@property (nonatomic, strong)LiveDefaultConfig *config;

@end

@implementation StartViewController

- (PushModeView *)modeView
{
    if (!_modeView) {
        _modeView = [PushModeView pushModeView];
        [self.view addSubview:_modeView];
        WeakSelf
        [_modeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(weakSelf.view);
            make.size.mas_equalTo(CGSizeMake(weakSelf.view.frame.size.width, weakSelf.view.frame.size.height));
        }];
        _modeView.modeBlock = ^(NSInteger tag) {
            if (tag == 1) {
                weakSelf.publishMode = PUBLISH_STREAM_RTC;
            } else if (tag == 2) {
                weakSelf.publishMode = PUBLISH_STREAM_CDN;
            }
            weakSelf.modeView.hidden = YES;
            [weakSelf openVideoController];
        };
        _modeView.hidden = YES;
    }
    return _modeView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[LiveManager shareManager] addDelegate:self];
    [super viewWillAppear:animated];
    [self updateUIState];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[LiveManager shareManager] removeDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUp];
}

- (void)setUp
{
    self.selectIndex = 0;
    self.roomType = LiveTypeVideo;
    self.publishMode = PUBLISH_STREAM_RTC;
    self.view.backgroundColor = [UIColor sl_colorWithHexString:COLOR_Background];
    [self updateUIState];
    self.onlineView.layer.contents = (id)[UIImage imageNamed:@"publish_ placeholder"].CGImage;
    self.sportsView.layer.contents = (id)[UIImage imageNamed:@"publish_ placeholder"].CGImage;
    [UIView yy_maskViewToBounds:self.videoView radius:8.0f];
    [UIView yy_maskViewToBounds:self.voiceView radius:8.0f];
    [UIView yy_maskViewToBounds:self.onlineView radius:8.0f];
    [UIView yy_maskViewToBounds:self.sportsView radius:8.0f];
    [UIView yy_maskViewToBounds:self.startBtn radius:8.0f];
}

- (IBAction)itemClicked:(UITapGestureRecognizer *)sender
{
    UIView *tapView = sender.view;
    self.selectIndex = tapView.tag - 10;
    self.roomType = (LiveType)(tapView.tag - 9);
    
    [self updateUIState];
}

- (void)updateUIState
{
    self.videoLB.alpha = (_selectIndex == self.videoView.tag - 10)? 1 : 0.5;
    self.videoSubLB.alpha = (_selectIndex == self.videoView.tag - 10)? 1 : 0.5;
    
    self.voiceLB.alpha = (_selectIndex == self.voiceView.tag - 10)? 1 : 0.5;
    self.voiceSubLB.alpha = (_selectIndex == self.voiceView.tag - 10)? 1 : 0.5;
    //    self.onlineLB.alpha = (_selectIndex == self.onlineView.tag - 10)? 1 : 0.5;
    //    self.onlineSubLB.alpha = (_selectIndex == self.onlineView.tag - 10)? 1 : 0.5;
    //
    //    self.onlineSubLB.alpha = (_selectIndex == self.onlineView.tag - 10)? 1 : 0.5;
    //    self.onlineSubLB.alpha = (_selectIndex == self.onlineView.tag - 10)? 1 : 0.5;
    
    self.videoImageView.alpha = (_selectIndex == self.voiceView.tag - 10)? 0.5 : 1;
    self.audioImageView.alpha = (_selectIndex == self.voiceView.tag - 10)? 1 : 0.5;
    
    self.videoView.layer.contents = (_selectIndex == self.videoView.tag - 10)?(id)[UIImage imageNamed:@"publish_ placeholder_selected"].CGImage :(id)[UIImage imageNamed:@"publish_ placeholder_normal"].CGImage;
    self.voiceView.layer.contents = (_selectIndex == self.voiceView.tag - 10)?(id)[UIImage imageNamed:@"publish_ placeholder_selected"].CGImage :(id)[UIImage imageNamed:@"publish_ placeholder_normal"].CGImage;
    self.onlineView.layer.contents = (_selectIndex == self.onlineView.tag - 10)?(id)[UIImage imageNamed:@"publish_ placeholder_selected"].CGImage :(id)[UIImage imageNamed:@"publish_ placeholder_normal"].CGImage;
    self.sportsView.layer.contents = (_selectIndex == self.sportsView.tag - 10)?(id)[UIImage imageNamed:@"publish_ placeholder_selected"].CGImage :(id)[UIImage imageNamed:@"publish_ placeholder_normal"].CGImage;
    
    self.videoView.layer.cornerRadius = (_selectIndex == self.videoView.tag - 10) ? 8 : 0;
    self.videoView.layer.borderWidth = (_selectIndex == self.videoView.tag - 10) ? 2 : 0;
    self.videoView.layer.borderColor = (_selectIndex == self.videoView.tag - 10) ? [UIColor sl_colorWithHexString:@"#0DBE9E"].CGColor : [UIColor whiteColor].CGColor;
    self.videoView.layer.masksToBounds = (_selectIndex == self.videoView.tag - 10) ? YES :NO;
    
    self.voiceView.layer.cornerRadius = (_selectIndex == self.voiceView.tag - 10) ? 8 : 0;
    self.voiceView.layer.borderWidth = (_selectIndex == self.voiceView.tag - 10) ? 2 : 0;
    self.voiceView.layer.borderColor = (_selectIndex == self.voiceView.tag - 10) ? [UIColor sl_colorWithHexString:@"#0DBE9E"].CGColor : [UIColor whiteColor].CGColor;
    self.voiceView.layer.masksToBounds = (_selectIndex == self.voiceView.tag - 10) ? YES :NO;

    //    self.onlineView.layer.cornerRadius = (_selectIndex == self.onlineView.tag - 10) ? 8 : 0;
    //    self.onlineView.layer.borderWidth = (_selectIndex == self.onlineView.tag - 10) ? 2 : 0;
    //    self.onlineView.layer.borderColor = (_selectIndex == self.onlineView.tag - 10) ? [UIColor sl_colorWithHexString:@"#0DBE9E"].CGColor : [UIColor whiteColor].CGColor;
    //    self.onlineView.layer.masksToBounds = (_selectIndex == self.onlineView.tag - 10) ? YES :NO;
    //
    //    self.sportsView.layer.cornerRadius = (_selectIndex == self.sportsView.tag - 10) ? 8 : 0;
    //    self.sportsView.layer.borderWidth = (_selectIndex == self.sportsView.tag - 10) ? 2 : 0;
    //    self.sportsView.layer.borderColor = (_selectIndex == self.sportsView.tag - 10) ? [UIColor sl_colorWithHexString:@"#0DBE9E"].CGColor : [UIColor whiteColor].CGColor;
    //    self.sportsView.layer.masksToBounds = (_selectIndex == self.sportsView.tag - 10) ? YES :NO;
}

- (void)openVideoController
{
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kUserInfo];
    LiveDefaultConfig *config = [[LiveDefaultConfig alloc]init];
    config.ownerRoomId = [NSString stringWithFormat:@"%@",[userDict objectForKey:kUid]];
    config.localUid = [NSString stringWithFormat:@"%@",[userDict objectForKey:kUid]];
    config.anchroMainUid = [NSString stringWithFormat:@"%@",[userDict objectForKey:kUid]];
    self.config = config;
    [self createChatRoom];
    
}

- (void)openAudioController
{
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kUserInfo];
    LiveDefaultConfig *config = [[LiveDefaultConfig alloc]init];
    config.ownerRoomId = [NSString stringWithFormat:@"%@",[userDict objectForKey:kUid]];
    config.localUid = [NSString stringWithFormat:@"%@",[userDict objectForKey:kUid]];
    
    config.anchroMainUid = [NSString stringWithFormat:@"%@",[userDict objectForKey:kUid]];
    self.config = config;
    [self createChatRoom];
    
}

//在线KTV
- (void)openOnlineController
{
    //    KTVLiveViewController *vc = [[KTVLiveViewController alloc]init];
    //    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)backAction:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//开播
- (IBAction)startLive:(UIButton *)sender
{
    switch (self.selectIndex) {
        case 0: //视频直播
            self.modeView.hidden = NO;
            break;
        case 1: //音频直播
            [self openAudioController];
            break;
        case 2: //唱歌娱乐
            //            [self openOnlineController];
            break;
        case 3://球赛解说
            break;
        default:
            break;
    }
}
#pragma mark -主播创建聊天室
- (void)createChatRoom
{
    [[LiveManager shareManager] createRoomForType:self.roomType publishMode:self.publishMode];
}

#pragma mark- 成功获取roomid
- (void)liveManager:(LiveManager *)manager createRoomSuccess:(LiveRoomInfoModel *)roomInfo
{
    [LiveUserListManager sy_ModelWithLiveRoomInfoModel:roomInfo];
    WeakSelf
    switch (self.roomType) {
        case LiveTypeVideo: {
            VideoViewController *vc = [[VideoViewController alloc]initWithRoomModel:[LiveUserListManager defaultManager]];
            vc.isResponsBackblock = YES;
            vc.backBlock = ^{
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            };
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case LiveTypeAudio: {
            AudioViewController *vc = [[AudioViewController alloc]initWithRoomModel:[LiveUserListManager defaultManager]];
            vc.isResponsBackblock = YES;
            vc.backBlock = ^{
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            };
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)liveManager:(LiveManager *)manager createRoomFailed:(NSError *)error
{
    [MBProgressHUD yy_showError:error.domain];
    if ([error.domain isEqual:NSURLErrorDomain]) {
        [MBProgressHUD yy_showError:NSLocalizedString(@"Reconnecting to internet, please wait.", @"网络异常，请检查网络连接")];
    }
}



@end
