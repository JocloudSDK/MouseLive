//
//  LiveUserView.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/3/5.
//  Copyright © 2020 sy. All rights reserved.
//

#import "LiveUserView.h"
#import "LiveUserListManager.h"

@interface LiveUserView()

@property (nonatomic, weak) IBOutlet UIView *bottomBgView;
@property (nonatomic, weak) IBOutlet UIView *leftLine;
@property (nonatomic, weak) IBOutlet UIView *rightLine;
/** 头像*/
@property (nonatomic, weak) IBOutlet UIImageView *coverView;
/** 昵称*/
@property (nonatomic, weak) IBOutlet UILabel *nickNameLabel;
/** 关闭*/
@property (nonatomic, weak) IBOutlet UIButton *closeBtn;
/** 升管*/
@property (nonatomic, weak) IBOutlet UIButton *riserBtn;
/** 禁言*/
@property (nonatomic, weak) IBOutlet UIButton *shutupBtn;

/**语音房上麦 下麦分割线*/
@property (nonatomic, weak) IBOutlet UIView *centerLine;
/**闭麦*/
@property (nonatomic, weak) IBOutlet UIButton *closeMircBtn;
/**下麦*/
@property (nonatomic, weak) IBOutlet UIButton *downMircBtn;
/** 剔出*/
@property (nonatomic, weak) IBOutlet UIButton *outBtn;


@end

@implementation LiveUserView

+ (instancetype)userView
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [UIView yy_maskViewToBounds:self radius:12.0];
    self.bottomBgView.layer.borderWidth = 1.0f;
    self.bottomBgView.layer.borderColor= [UIColor sl_colorWithHexString:@"#F3F3F3"].CGColor;
    //@"升管"
    [self.riserBtn setTitle:NSLocalizedString(@"Apply_Admin",nil) forState:UIControlStateNormal];
    //"降管"
    [self.riserBtn setTitle:NSLocalizedString(@"Viewer",nil) forState:UIControlStateSelected];
    //@"禁言"
    [self.shutupBtn setTitle:NSLocalizedString(@"Ban",nil) forState:UIControlStateNormal];
    //@"解言"
    [self.shutupBtn setTitle:NSLocalizedString(@"Unban","解禁") forState:UIControlStateSelected];
    self.riserBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.shutupBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.outBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.closeMircBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.downMircBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    
}

- (IBAction)closeBtnClicked:(UIButton *)sender
{
    self.hidden  = YES;
}

- (IBAction)managerBtnAction:(UIButton *)sender
{
    self.hidden = YES;
    LiveUserModel *localUser = [LiveUserListManager objectForPrimaryKey:LoginUserUidString];
    if (localUser.isAdmin || localUser.isAnchor) {
        if (self.managementBlock) {
            if (self.model.isAdmin) {
                //降管理员
                self.managementBlock(self.model, ManagementUserTypeRemoveAdmin);
            } else {
                self.managementBlock(self.model,ManagementUserTypeAddAdmin);
                //升管理员
            }
        }
    }
  
}
//解禁言 禁言
- (IBAction)shutupBtnClicked:(id)sender
{
    self.hidden = YES;
    [self muteOrUnmute];
    
    
}

//解禁言 禁言
- (void)muteOrUnmute
{
    LiveUserModel *localUser = [LiveUserListManager objectForPrimaryKey:LoginUserUidString];
    if (localUser.isAdmin || localUser.isAnchor) {
        if (self.managementBlock) {
            if (self.model.isMuted) {
                //解禁言
                self.managementBlock(self.model, ManagementUserTypeUnmute);
            } else {
                //禁言
                self.managementBlock(self.model, ManagementUserTypeMute);
            }
        }
    }
 
}

- (IBAction)kickBtnClicked:(id)sender
{
    self.hidden = YES;
    [self kickOutUser:sender];
    
}

//踢出
- (void)kickOutUser:(UIButton *)sender
{
    LiveUserModel *localUser = [LiveUserListManager objectForPrimaryKey:LoginUserUidString];
    if (localUser.isAdmin || localUser.isAnchor) {
        if (self.managementBlock) {
            self.managementBlock(self.model, ManagementUserTypeKick);
        }
    }

}

- (void)setModel:(LiveUserModel *)model
{
    _model = model;
    [self.coverView yy_setImageWithURL:[NSURL URLWithString:model.Cover] placeholder:PLACEHOLDER_IMAGE];
    self.nickNameLabel.text = model.NickName;
    [self updateButtonStatus];
    if (self.viewTyle == LiveUserViewTypeThreeStyle) {
           //升管 禁言 踢出
        self.shutupBtn.selected = model.isMuted;
        self.riserBtn.selected = self.model.isAdmin;
    } else if (self.viewTyle == LiveUserViewTypeTwoMicStyle){
        [self.closeMircBtn setTitle:NSLocalizedString(@"Mic On",nil)  forState:UIControlStateNormal];
        [self.closeMircBtn setTitle:NSLocalizedString(@"Mic Off",nil)  forState:UIControlStateSelected];
        [self.downMircBtn setTitle:NSLocalizedString(@"Off Seat",nil)  forState:UIControlStateNormal];
        // 闭麦 开麦
        self.closeMircBtn.selected = model.MicEnable;
    } else if (self.viewTyle == LiveUserViewTypeTwoAdminStyle) {
        [self.closeMircBtn setTitle:NSLocalizedString(@"Ban",nil)  forState:UIControlStateNormal];
        //@"解言"
        [self.closeMircBtn setTitle:NSLocalizedString(@"Unban",nil) forState:UIControlStateSelected];
        //右按钮 "踢出"
        [self.downMircBtn setTitle:NSLocalizedString(@"Kick",nil) forState:UIControlStateNormal];
        self.closeMircBtn.selected = self.model.isMuted;
    }
}

- (IBAction)closeMirClicked:(UIButton *)sender
{
    self.hidden = YES;
    if (self.viewTyle == LiveUserViewTypeTwoMicStyle) {
        LiveUserModel *localUser = [LiveUserListManager objectForPrimaryKey:LoginUserUidString];
        if (localUser.isAdmin || localUser.isAnchor) {
            if (self.managementBlock) {
                int micType = ManagementUserTypeCloseMirc;
                if (!self.model.MicEnable) {
                    // 开麦
                    micType = ManagementUserTypeOpenMirc;
                }
                self.managementBlock(self.model, micType);
            }
        }
    } else if (self.viewTyle == LiveUserViewTypeTwoAdminStyle) {
        //管理员禁言 解禁
        [self muteOrUnmute];
        
    }
}


- (IBAction)downMircClicked:(UIButton *)sender
{
    self.hidden = YES;
    if (self.viewTyle == LiveUserViewTypeTwoMicStyle) {
        LiveUserModel *localUser = [LiveUserListManager objectForPrimaryKey:LoginUserUidString];
        if (localUser.isAdmin || localUser.isAnchor) {
            if (self.managementBlock) {
                self.managementBlock(self.model, ManagementUserTypeDownMirc);
            }
        }
    } else if(self.viewTyle == LiveUserViewTypeTwoAdminStyle || self.viewTyle == LiveUserViewTypeThreeStyle) {
        //踢出成员
        [self kickOutUser:sender];
        
    }
}

- (void)updateButtonStatus
{
    LiveUserModel *localUser = [LiveUserListManager objectForPrimaryKey:LoginUserUidString];
    if (self.viewTyle == LiveUserViewTypeTwoMicStyle || self.viewTyle == LiveUserViewTypeTwoAdminStyle) {
        self.centerLine.hidden = NO;
        self.closeMircBtn.hidden = NO;
        self.downMircBtn.hidden = NO;
        
        self.leftLine.hidden  = YES;
        self.rightLine.hidden = YES;
        self.outBtn.hidden = YES;
        self.riserBtn.hidden = YES;
        self.shutupBtn.hidden = YES;
    } else if (self.viewTyle == LiveUserViewTypeThreeStyle) {
        self.centerLine.hidden = YES;
        self.closeMircBtn.hidden = YES;
        self.downMircBtn.hidden = YES;
        
        self.leftLine.hidden  = NO;
        self.rightLine.hidden = NO;
        self.outBtn.hidden = NO;
        self.riserBtn.hidden = NO;
        self.shutupBtn.hidden = NO;
    }
}
@end
