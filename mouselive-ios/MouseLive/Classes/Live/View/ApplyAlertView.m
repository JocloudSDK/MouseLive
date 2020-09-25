//
//  LiveUserView.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/5.
//  Copyright © 2020 sy. All rights reserved.
//

#import "ApplyAlertView.h"
#import "LiveUserModel.h"

@interface ApplyAlertView()
/** 头像*/
@property (nonatomic, weak) IBOutlet UIImageView *coverView;
/** 昵称*/
@property (nonatomic, weak) IBOutlet UILabel *nickNameLabel;
/** 申请类型*/
@property (nonatomic, weak) IBOutlet UILabel *applyNameLabel;
/** 关闭*/
@property (nonatomic, weak) IBOutlet UIButton *closeBtn;
/** 同意*/
@property (nonatomic, weak) IBOutlet UIButton *agreeBtn;
/** 拒绝*/
@property (nonatomic, weak) IBOutlet UIButton *rejectBtn;

@property (nonatomic, weak) IBOutlet UIView *bottomBgView;

@property (nonatomic, weak) IBOutlet UIView *bgContentView;



@property(nonatomic, assign)LiveType livetype;

@end

@implementation ApplyAlertView
- (instancetype)initWithLiveType:(LiveType)livetype
{
    self = [super init];
    if (self) {
        self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ApplyAlertView class]) owner:nil options:nil].lastObject;
        self.livetype = livetype;
    }
    return  self;
}

+ (instancetype)applyAlertView
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [UIView yy_maskViewToBounds:self.bgContentView radius:12.0];
    self.bottomBgView.layer.borderWidth = 1.0f;
    self.bottomBgView.layer.borderColor= [UIColor sl_colorWithHexString:@"#F3F3F3"].CGColor;
}

- (IBAction)closeBtnClicked:(UIButton *)sender
{
    if (self.applyBlock) {
        self.applyBlock(ApplyActionTypeReject,_model.Uid,_model.RoomId);
    }
}

- (IBAction)applayAction:(UIButton *)sender
{
    ApplyActionType type = sender.tag;
    if (self.applyBlock) {
        self.applyBlock(type,_model.Uid,_model.RoomId);
    }
}

- (void)setModel:(LiveUserModel *)model
{
    _model = model;
 
    [self.coverView yy_setImageWithURL:[NSURL URLWithString:model.Cover] placeholder:PLACEHOLDER_IMAGE];
    self.nickNameLabel.text = model.NickName;
    if (!model.isAnchor) {
        // @"申请连麦"
        self.applyNameLabel.text = self.livetype == LiveTypeVideo ? NSLocalizedString(@"wants to interact with you.",nil):NSLocalizedString(@"wants to have a seat.",nil);
    } else {
        //@"想与您PK"
        self.applyNameLabel.text =NSLocalizedString(@"wants to battle with you.",nil);
    }
    
}


@end
