//
//  LiveAnchorView.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/2.
//  Copyright © 2020 sy. All rights reserved.
//

#import "LiveAnchorView.h"
#import "LiveUserModel.h"
#import <YYWebImage.h>


#define  DefaultRadius 1
@interface LiveAnchorView()
@property (nonatomic, weak) IBOutlet UIView *anchorView;
@property (nonatomic, weak) IBOutlet UIImageView *headImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *peopleLabel;
@property (nonatomic, weak) IBOutlet UIButton *closeBtn;
@property (nonatomic, weak) IBOutlet UIScrollView *peoplesScrollView;
@property (nonatomic, weak) IBOutlet UIView *startLevelView;

@property (nonatomic, weak) IBOutlet UILabel *contributeLB;
@property (nonatomic, weak) IBOutlet UILabel *nobilityLB;
@property (nonatomic, weak) IBOutlet UIButton *listBtn;
//cdn模式 或者 rtc 模式
@property (nonatomic, weak) IBOutlet UIButton *modeButton;

@property (nonatomic, strong) NSTimer *timer;
/** 其它直播*/
@property (nonatomic, strong) NSArray *otherAnchors;
@property (nonatomic, copy) NSAttributedString *peopleLabelBaseAttributedString;

@end

@implementation LiveAnchorView
- (NSArray *)otherAnchors
{
    if (!_otherAnchors) {
        NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"user.plist" ofType:nil]];
        _otherAnchors = [LiveUserModel mj_objectArrayWithKeyValuesArray:array];
    }
    return _otherAnchors;
}

+ (instancetype)liveAnchorView
{
    return [[NSBundle mainBundle]loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
    
}

//更新观众数
- (void)updateNum
{
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self maskViewToBounds:self.anchorView radius:DefaultRadius];
    [self maskViewToBounds:self.headImageView radius:DefaultRadius];
    [self maskViewToBounds:self.closeBtn radius:DefaultRadius];
    [self maskViewToBounds:self.contributeLB radius:9.0];
    [self maskViewToBounds:self.nobilityLB radius:4.0];
    [self maskViewToBounds:self.listBtn radius:DefaultRadius];

    self.headImageView.layer.borderWidth = 1;
    self.headImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:@""];
    NSTextAttachment *attchment = [[NSTextAttachment alloc]init];
    attchment.bounds = CGRectMake(0, 0, 8, 8);
    attchment.image = [UIImage imageNamed:@"live-people_count"];
    NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(attchment)];
    [attributedString insertAttributedString:string atIndex:0];

    self.peopleLabel.attributedText = attributedString;
    self.peopleLabelBaseAttributedString = attributedString;
    
    NSMutableAttributedString *contributeString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"  %@",NSLocalizedString(@"Contributions", nil)]];
    [contributeString addAttribute:NSForegroundColorAttributeName value:[UIColor sl_colorWithHexString:@"30DDBD"] range:NSMakeRange(0, contributeString.string.length)];
    NSMutableAttributedString *count = [[NSMutableAttributedString alloc]initWithString:@"  9,302,000"];
    [count addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:255 green:255 blue:255 alpha:0.8] range:NSMakeRange(0, count.string.length)];
    [contributeString appendAttributedString:count];
    self.contributeLB.attributedText = contributeString;
}


- (IBAction)listButtonClicked:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (self.iconClickBlock) {
        self.iconClickBlock(IconClikTypeListBtn,sender.selected);
    }
}

- (void)maskViewToBounds:(UIView *)view radius:(CGFloat)cornerRadius
{
    if (cornerRadius == 1) {
        cornerRadius = view.yy_height * 0.5;
    }
    view.layer.cornerRadius = cornerRadius;
    view.layer.masksToBounds = YES;
}

- (IBAction)quit:(UIButton *)sender
{
    if (self.quitBlock) {
        self.quitBlock();
    }
}

- (void)setRoomModel:(LiveUserListManager *)roomModel
{
    [self.headImageView yy_setImageWithURL:[NSURL URLWithString:roomModel.ROwner.Cover] placeholder:[UIImage imageNamed:@"placeholder_head"]];
    self.nameLabel.text = roomModel.RName;
}


- (void)setRoomInfoModel:(LiveRoomInfoModel *)roomInfoModel
{
    _roomInfoModel = roomInfoModel;
    [self.headImageView yy_setImageWithURL:[NSURL URLWithString:roomInfoModel.ROwner.Cover] placeholder:[UIImage imageNamed:@"placeholder_head"]];
    self.nameLabel.text = _roomInfoModel.RName;
}

- (void)setPeopleCount:(NSInteger)peopleCount
{
    _peopleCount = peopleCount;
    NSMutableAttributedString *countString =  [[NSMutableAttributedString alloc] initWithAttributedString:self.peopleLabelBaseAttributedString];
    [countString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld",(long)peopleCount]]];
    self.peopleLabel.attributedText = countString;
}

- (void)setPublishMode:(PublishMode)publishMode
{
    _publishMode = publishMode;
    switch (publishMode) {
        case PUBLISH_STREAM_RTC:
            [self.modeButton setImage:[UIImage imageNamed:@"icon-RTC"] forState:UIControlStateNormal];
            break;
        case PUBLISH_STREAM_CDN:
            [self.modeButton setImage:[UIImage imageNamed:@"icon-CDN"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}
- (IBAction)modeBtnClicked:(UIButton *)sender
{
 switch (_publishMode) {
     case PUBLISH_STREAM_RTC:
         [MBProgressHUD yy_showSuccess:@"当前是实时RTC模式"];
         break;
     case PUBLISH_STREAM_CDN:
        [MBProgressHUD yy_showSuccess:@"当前是CDN模式"];
         break;
     default:
         break;
 }
}
@end
