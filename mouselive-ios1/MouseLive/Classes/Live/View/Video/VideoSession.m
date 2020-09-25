//
//  VideoSession.m
//  MouseLive
//
//  Created by 张骥 on 2020/5/27.
//  Copyright © 2020 sy. All rights reserved.
//

#import "VideoSession.h"
#import "PeopleHeader.h"

@interface VideoSession()

@property (nonatomic, weak) IBOutlet UIButton *hungupButton;
@property (nonatomic, weak) PeopleHeader *headerView;

@property (nonatomic, copy) ClickBlocK clickBlock;

@end

@implementation VideoSession

+ (instancetype)newInstanceWithHungupButton:(BOOL)hasButton withClickBlock:(ClickBlocK _Nullable)clickBlock
{
    VideoSession *instance = [[NSBundle mainBundle]loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
    instance.hungupButton.hidden = !hasButton;
    instance.clickBlock =  clickBlock;
    instance.codeRateView.hidden = YES;
    instance.codeRateView.userDetailString = [NSString stringWithFormat:@"RoomId:%@\nUID:%@\n%@",[LiveUserListManager defaultManager].RoomId,[LiveUserListManager defaultManager].ROwner.Uid,[LiveUserListManager defaultManager].ROwner.NickName];
    [instance.codeRateView refreshCodeView];

    return instance;
}

- (void)hiddenQuqlityView:(BOOL)hidden
{
    self.codeRateView.hidden = hidden;
}

//连麦者详细信息
- (void)setUserInfo:(LiveUserModel *)userInfo
{
    _userInfo = userInfo;
    LiveUserModel *localUser = [LiveUserListManager objectForPrimaryKey:LoginUserUidString];
    if (localUser.isAnchor) {
        //主播端
        if (![userInfo.Uid isEqualToString:localUser.Uid]) {
            //连麦者显示头像信息
            self.hungupButton.hidden = NO;
            self.headerView.hidden = NO;
            self.codeRateView.qualityModel.isShowCodeDetail = NO;
            NSString *para = @"连麦者视图显示挂断按钮";
            YYLogFuncEntry([self class], _cmd, para);
        } else {
            //房主端隐藏
            self.hungupButton.hidden = YES;
            self.headerView.hidden = YES;
            NSString *para = @"房主视图不显示挂断按钮";
            YYLogFuncEntry([self class], _cmd, para);
        }
    } else {
        //观众端
        self.hungupButton.hidden = YES;
        self.headerView.hidden = NO;
        NSString *para = @"观众端不显示挂断按钮 显示连麦者头像";
        YYLogFuncEntry([self class], _cmd, para);
    }
    self.headerView.model = userInfo;
    if (userInfo.isAnchor) {
        self.codeRateView.userDetailString = [NSString stringWithFormat:@"RoomId:%@\nUID:%@\n%@",userInfo.RoomId,userInfo.Uid,userInfo.NickName];
    } else{
        self.codeRateView.userDetailString = [NSString stringWithFormat:@"UID:%@\n %@",userInfo.Uid,userInfo.NickName];
    }

}

- (NetworkQualityStauts *)qualityModel
{
    if (!_qualityModel) {
        _qualityModel = [[NetworkQualityStauts alloc]init];
    }
    return _qualityModel;
}

- (void)refreshCodeView
{
    self.codeRateView.qualityModel = self.qualityModel;
    [self.codeRateView refreshCodeView];
}
- (PeopleHeader *)headerView
{
    if (!_headerView) {
        _headerView = [PeopleHeader shareInstance];
        _headerView.hidden = YES;
        [self addSubview:_headerView];
        [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(8);
            make.left.mas_equalTo(8);
            make.size.mas_equalTo(CGSizeMake(60, 40));
        }];
    }
    
    return _headerView;
}

- (LiveCodeRateView *)codeRateView
{
    if (!_codeRateView) {
        _codeRateView = [LiveCodeRateView liveCodeRateView];
        [self addSubview:_codeRateView];
        [_codeRateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(48);
            make.left.mas_equalTo(6);
            make.height.mas_equalTo(CodeView_H);
        }];
    }
    
    return _codeRateView;
}

- (IBAction)doHungupPressed:(UIButton *)sender
{
    WeakSelf
    if (_clickBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.clickBlock(self->_userInfo);
        });
    }
}

@end
