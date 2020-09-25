//
//  FeedBackViewController.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/6/11.
//  Copyright © 2020 sy. All rights reserved.
//

#import "FeedBackViewController.h"
#import "SYCommonMacros.h"
#import "Masonry.h"
#import "SYUtils.h"
#import "UIImage+SYAdditions.h"
#import "UITextView+SYPlaceHolder.h"
#import "SYFeedbackRequestHelper.h"
#import "AFNetworkReachabilityManager.h"
#import "UIViewController+SYBaseViewController.h"
#import "FeedBackCollectionViewCell.h"
#import "MBProgressHUD+SYHUD.h"
#import "SYAppInfo.h"
#import "LogoUIView.h"
#import "TZImagePickerController.h"


static NSString * const kSYFeedbackAppId = @"MouseLive-ios"; // 对接反馈系统AppID

@interface FeedBackViewController ()<UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,TZImagePickerControllerDelegate> {
    UILabel *_placeHolderLabel;
}
@property (nonatomic, weak) IBOutlet UILabel *currentVersion;
@property (nonatomic, weak) IBOutlet UITextView *feedbackTextView;
@property (nonatomic, weak) IBOutlet UITextField *phoneTextField;
@property (nonatomic, weak) IBOutlet UIButton *submitBtn;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *submitBtnTopConstraint;
@property (nonatomic, weak) IBOutlet UIButton *upImageButton;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong)LogoUIView *logoView;
@property (nonatomic, strong)UIImagePickerController *imagePickerVC;
@property (nonatomic, strong)NSMutableArray *imagesArray;
@end

@implementation FeedBackViewController

- (void)setupFeedbackManagerOnce
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [SYFeedbackManager sharedManager].appId = kSYFeedbackAppId;
        [SYFeedbackManager sharedManager].appSceneName = @"MouseLive";
        [SYFeedbackManager sharedManager].functionDesc = @"1、实现同房间连麦互动\n2、具备麦克风静音，摄像头切换，mute音视频流等功能";
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) lastObject];
        NSString *logPath = [docPath stringByAppendingString:kLogFilePath];
        [SYFeedbackManager sharedManager].logFilePath = logPath;  // 日志目录和 thunder 是一样的
    });
}
#pragma mark - life cycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupFeedbackManagerOnce];
    [self setUI];
    self.topConstraint.constant = BannerCellHeight;
    self.logoView.hidden = NO;
    [self.submitBtn addTarget:self action:@selector(onSubmitButtonClick) forControlEvents:UIControlEventTouchUpInside];
    if (SCREEN_HEIGHT <= 568) {
        self.submitBtnTopConstraint.constant = 15;
    }
    
}


- (void)setUI
{
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    self.collectionView.collectionViewLayout = layout;
    layout.itemSize = CGSizeMake(40, 40);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([FeedBackCollectionViewCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:NSStringFromClass([FeedBackCollectionViewCell class])];
    [self settingLayer:self.feedbackTextView color:@"#F1F1F1" cornerRadius:2];
    [self settingLayer:self.phoneTextField color:@"#F1F1F1" cornerRadius:2];
    [self settingLayer:self.submitBtn color:@"#0DBE9E" cornerRadius:8];
    NSString *holderText = NSLocalizedString(@"Optional", nil);
    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:holderText];
    [placeholder addAttribute:NSForegroundColorAttributeName
                        value:[UIColor sl_red:37 green:44 blue:43 alpha:0.5]
                        range:NSMakeRange(0, holderText.length)];
    [placeholder addAttribute:NSFontAttributeName
                        value:[UIFont fontWithName:FONT_Regular size:12.0f]
                        range:NSMakeRange(0, holderText.length)];
    self.phoneTextField.attributedPlaceholder = placeholder;
    [self setFeedbackTextViewPlaceHolderLabel];
    
    self.currentVersion.text = [NSString stringWithFormat:@"%@：V%@-%@", NSLocalizedString(@"Current Version", nil), [SYUtils appVersion], [SYUtils appBuildVersion]];
}

- (void)setFeedbackTextViewPlaceHolderLabel
{
    self.feedbackTextView.delegate = self;
    _placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10,100, 20)];
    
    _placeHolderLabel.textColor = COLOR_TEXT_GRAY;
    
    _placeHolderLabel.textAlignment = NSTextAlignmentLeft;
    
    _placeHolderLabel.font = [UIFont fontWithName:FONT_Regular size:12.0f];
    
    _placeHolderLabel.text = NSLocalizedString(@"Do not leave it blank.", nil);
    [self.feedbackTextView addSubview:_placeHolderLabel];
    [_placeHolderLabel sizeToFit];
}

- (void)settingLayer:(UIView *)view color:(NSString *)colorString cornerRadius:(CGFloat)cornerRadius
{
    view.layer.cornerRadius = cornerRadius;
    view.layer.borderWidth = 1.0f;
    view.layer.borderColor = [UIColor sl_colorWithHexString:colorString].CGColor;
    [view.layer masksToBounds];
}

- (void)setBackButton
{
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, StatusBarHeight, 60, 44)];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    self.title = NSLocalizedString(@"Feedback", nil);
    [self.view addSubview:backButton];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 100, StatusBarHeight, 200, 44)];
    titleLabel.attributedText = [[NSAttributedString alloc]initWithString:NSLocalizedString(@"Feedback", nil) attributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Semibold" size:18.0], NSForegroundColorAttributeName:[UIColor sl_colorWithHexString:COLOR_NAV_TITLE]}];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    self.topConstraint.constant = 26 + StatusBarHeight;
    self.logoView.hidden = YES;
}

- (void)initNavigation
{
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Semibold" size:18.0], NSForegroundColorAttributeName:[UIColor sl_colorWithHexString:COLOR_NAV_TITLE]}];
    self.title = NSLocalizedString(@"Feedback", nil);
    if (!self.navigationController.navigationBarHidden) {
        self.topConstraint.constant = 26;
    }
    
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    
    if (textView.text.length == 0) {
        _placeHolderLabel.text = NSLocalizedString(@"Do not leave it blank.", nil);
    }
    
    else {
        _placeHolderLabel.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.text.length == 0) {
        _placeHolderLabel.text = NSLocalizedString(@"Do not leave it blank.", nil);
    }
    
    else {
        _placeHolderLabel.text = @"";
    }
}
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resetView
{
    self.feedbackTextView.text = nil;
    self.phoneTextField.text = nil;
}

- (void)onSubmitButtonClick
{

    if (_feedbackTextView.text.length == 0 || [[_feedbackTextView.text  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length] == 0) {
        [MBProgressHUD showToast:NSLocalizedString(@"Please kindly let us know your concerns.", @"请输入反馈内容")];
        return;
    }
    [MBProgressHUD showActivityIndicator];
    
    NSString *appVersion = @"";
#if 0
    if ([[SYAppInfo sharedInstance].gitBranch isEqualToString:@"master"]) {
        appVersion = [SYAppInfo sharedInstance].appVersion;
    }
    else {
        appVersion = [NSString stringWithFormat:@"%@-%@", [SYAppInfo sharedInstance].appVersion, [SYAppInfo sharedInstance].appBuild];
    }
#else
    appVersion = [SYAppInfo sharedInstance].appVersion;
#endif
    SYFeedbackManager *feedbackManager = [SYFeedbackManager sharedManager];
    NSString *logFile = feedbackManager.logFilePath;
    for (int i = 0; i < self.imagesArray.count; i ++) {
        NSString *imagePath = [logFile stringByAppendingFormat:@"pic%d.jpg",i];
        //文件写入
        [UIImageJPEGRepresentation(self.imagesArray[i], 0.3) writeToFile:imagePath atomically:YES];
    }
    WeakSelf
    [SYFeedbackRequestHelper requestWithFeedbackContent:_feedbackTextView.text uid:LoginUserUidString contact:self.phoneTextField.text appVersion:appVersion success:^{
        [MBProgressHUD showToast:NSLocalizedString(@"Feedback success.", @"反馈成功")];
        [weakSelf resetView];
        weakSelf.feedbackTextView.text = @"";
        [weakSelf.imagesArray removeAllObjects];
        [weakSelf.collectionView reloadData];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(SYRequestFailedReason failedReason) {
        [MBProgressHUD showToast:NSLocalizedString(@"Feedback failed.", @"反馈失败")];
        NSString *para = nil;
        if (failedReason == SYRequestFailedReasonZipArchiveFailed) {
            para = @"压缩日志文件失败";
        } else if (failedReason == SYRequestFailedReasonMissingParameter) {
             para = @"请求参数缺失";
        } else {
             para = @"反馈失败，请稍后重试";
        }
        YYLogFuncEntry([self class], _cmd, para);

    }];
}

- (LogoUIView *)logoView
{
    if (!_logoView) {
        _logoView = [[LogoUIView alloc]init];
        [self.view addSubview:_logoView];
        [_logoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.mas_equalTo(0);
            make.height.mas_equalTo(BannerCellHeight);
        }];
    }
    return _logoView;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.feedbackTextView resignFirstResponder];
    [self.phoneTextField resignFirstResponder];
}

- (IBAction)uploadImageButtonAction:(UIButton *)sender
{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:MAXFLOAT delegate:self];
    WeakSelf
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photo, NSArray * assets, BOOL isSelectOriginalPhoto) {
        [weakSelf.imagesArray addObjectsFromArray:photo];
        [weakSelf.collectionView reloadData];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
    
}

- (UIImagePickerController *)imagePickerVC
{
    if (!_imagePickerVC) {
        _imagePickerVC = [[UIImagePickerController alloc]init];
        _imagePickerVC.delegate = self;
        _imagePickerVC.allowsEditing = YES;
    }
    return _imagePickerVC;
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.upImageButton setImage:image forState:UIControlStateNormal];
 
}

- (NSMutableArray *)imagesArray
{
    if (!_imagesArray) {
        _imagesArray = [[NSMutableArray alloc]init];
    }
    return _imagesArray;
}

#pragma mark - UICollectionViewDelegate UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imagesArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FeedBackCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FeedBackCollectionViewCell class]) forIndexPath:indexPath];
    UIImage *image = self.imagesArray[indexPath.row];
    cell.imageView.image = image;
    WeakSelf
    cell.delBlock = ^(UIImage * _Nonnull image) {
        [weakSelf.imagesArray removeObject:image];
        [weakSelf.collectionView reloadData];
    };
    return cell;
}

@end
