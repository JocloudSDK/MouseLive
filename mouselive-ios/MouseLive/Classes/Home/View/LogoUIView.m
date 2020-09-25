//
//  LogoUIView.m
//  MouseLive
//
//  Created by 张建平 on 2020/3/3.
//  Copyright © 2020 sy. All rights reserved.
//

#import "LogoUIView.h"
#import "SYAppInfo.h"
#import "SYUtils.h"

@interface LogoUIView()

@property (nonatomic) NSString* bundleVersion;
@property (nonatomic) NSString *thunderBlotSDKVersion;
@property (nonatomic) NSString *hummerSDKVersion;

@property (nonatomic, weak) IBOutlet UILabel *bundleLabel;
@property (nonatomic, weak) IBOutlet UILabel *buildLabel;

@end

@implementation LogoUIView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    if (self = [super init]) {
        self = [[NSBundle mainBundle] loadNibNamed:@"LogoUIView" owner:nil options:nil].lastObject;
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"home_top_background"]];
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        NSString *dateString =   [dateFormatter stringFromDate:[NSDate date]];
        self.buildLabel.text = [NSString stringWithFormat:@"Build:%@ %@ TB 2.7.0 HMR 2.6.107",[SYUtils appBuildVersion],dateString];
        self.bundleLabel.text = [NSString stringWithFormat:@"V:%@-%@", [SYAppInfo sharedInstance].appVersion, [SYUtils appBuildVersion]];
    }
    return self;
}

@end
