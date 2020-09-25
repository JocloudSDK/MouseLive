//
//  AppDelegate.m
//  MouseLive
//
//  Created by 张建平 on 2020/2/26.
//  Copyright © 2020 sy. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "AFNetworking.h"
#import "LiveUserModel.h"
#import "SYAppInfo.h"
#import "SYToken.h"
#import "SYEffectsDataManager.h"
#import "SYEffectRender.h"
#import "LiveManager.h"


@interface AppDelegate ()
@property (nonatomic, strong) UIAlertController *alertVC;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //开始监控网络状况
    //start network monitor
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    //第三方库初始化
    //third party SDK initialization
    [self initValueThirdParty:application didFinishLaunchingWithOptions:launchOptions];
    [self loginIn];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    MainViewController *mainViewController = [MainViewController instance];
    self.window.rootViewController = mainViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)initValueThirdParty:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    // 添加DDASLLogger，你的日志语句将被发送到Xcode控制台
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // 输出到一个指定的文件夹
    // path for the log file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *logPath = [paths.firstObject stringByAppendingPathComponent:@"SCLogs/MouseLive"];
    
    // 添加DDFileLogger，你的日志语句将写入到一个文件中，默认路径在沙盒的Library/Caches/Logs/目录下，文件名为bundleid+空格+日期.log。
    // 现在设置到 kLogFilePath 目录下
    DDLogFileManagerDefault *documentsFileManager = [[DDLogFileManagerDefault alloc]
                                                     initWithLogsDirectory:logPath];

    DDFileLogger *fileLogger = [[DDFileLogger alloc]
                                initWithLogFileManager:documentsFileManager];
    // Configure File Logger
    [fileLogger setMaximumFileSize:(1024 * 1024)];
    [fileLogger setRollingFrequency:(3600.0 * 24.0)];
    [[fileLogger logFileManager] setMaximumNumberOfLogFiles:5];
    [DDLog addLogger:fileLogger];
    

#if USE_BEATIFY
    // 校验美颜 SDK 序列号
    // check serail number for the beatify SDK
    [[SYEffectRender sharedRenderer] checkSDKSerailNumber:[SYAppInfo sharedInstance].ofSerialNumber];
    
    [[SYEffectsDataManager sharedManager] downloadEffectsData];
#endif
}

#pragma mark - Core Data stack
@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer  API_AVAILABLE(ios(10.0))
{
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"MouseLive"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    YYLogError(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
                
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext
{
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        YYLogError(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

//登录接口
//login
- (void)loginIn
{
    [[LiveManager shareManager] login:^(id  _Nullable obj) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kloginSucess];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } fail:^(NSError * _Nullable error) {
        DDLogDebug(@"登录失败%@",error);
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kloginSucess];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self showAlert];
        YYLogError(@"[MouseLive Appdelegate] login error show alert");
    }];
}
//登陆失败弹框提示
//alert view for login fail
- (void)showAlert
{
    self.alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Net Toast", nil) message:NSLocalizedString(@"Login failed, please try again", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self loginIn];
    }];
    [self.alertVC addAction:ok];
    [self.window.rootViewController presentViewController:self.alertVC animated:YES completion:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"杀死进程");
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kloginSucess];
}

@end
