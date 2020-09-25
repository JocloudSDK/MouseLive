//
//  SYEffectsDataManager.m
//  MouseLive
//
//  Created by GasparChu on 2020/4/13.
//  Copyright © 2020 sy. All rights reserved.
//

#import "SYEffectsDataManager.h"
#import "SYEffectsModel.h"
#import "SYEffectsFileHelper.h"
#import <AFNetworking.h>
#import "SYAppInfo.h"

static NSString * const BeautyResource = @"BeautyResource";
@interface SYEffectsDataManager ()

@property (nonatomic, strong) AFHTTPSessionManager *httpManager;
@property (nonatomic, strong) AFURLSessionManager *urlManager;
@property (nonatomic, copy) NSArray *dataArray;
@property (nonatomic, copy) NSString *defaultBeautyEffectPath;  // 默认美颜特效地址

@end

@implementation SYEffectsDataManager

+ (instancetype)sharedManager
{
    static SYEffectsDataManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _httpManager = [SYEffectsDataManager sy_createHTTPSessionManager];
        _urlManager = [SYEffectsDataManager sy_createURLSessionManager];
    }
    return self;
}

- (void)downloadEffectsData
{
    [self getEffectsListFromService];
}

- (NSArray *)getEffectsData
{
    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SYEffectsModel *model = obj;
        [model resetStatus];
        [model.Icons enumerateObjectsUsingBlock:^(SYEffectItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SYEffectItem *item = obj;
            [item resetStatus];
        }];
    }];
    return self.dataArray;
}

- (NSString *)getBeautyEffectPath
{
    if (self.defaultBeautyEffectPath.length) {
        return self.defaultBeautyEffectPath;
    }
    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SYEffectsModel *model = obj;
        if (model.isBeautyGroup && !self.defaultBeautyEffectPath) {
            SYEffectItem *item = model.Icons.firstObject;
            if ([SYEffectsFileHelper cacheIsExistWithUrlString:item.Url typeName:model.GroupType]) {
                self.defaultBeautyEffectPath = item.effectPath;
            }
        }
    }];
    return self.defaultBeautyEffectPath;
}

// 从服务端获取资源列表
- (void)getEffectsListFromService
{
    NSDictionary *params = @{@"AppId": @([SYAppInfo sharedInstance].appId.integerValue),
                             @"Version": @"v0.1.0"
    };
    NSString *url = @"http://fundbg.sunclouds.com/fun/api/v1/getBeauty";
    [self.httpManager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        responseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];;
        NSArray *dataArr = responseObject[@"Data"];
        NSArray *arr = [SYEffectsModel mj_objectArrayWithKeyValuesArray:dataArr];
        [self downloadDataWithArray:arr];
        self.dataArray = arr;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        YYLogDebug(@"-------%@", error);
    }];
}

// 遍历列表数据并下载资源
- (void)downloadDataWithArray:(NSArray *)array
{
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SYEffectsModel *model = obj;
        NSArray *itemArray = model.Icons;
        [itemArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SYEffectItem *item = obj;
            // 没有本地缓存并且是美颜或者滤镜的时候再下载
            if (![SYEffectsFileHelper cacheIsExistWithUrlString:item.Url typeName:model.GroupType]) {
                if (model.isBeautyGroup || model.isFilterGroup) {
                    [self downloadWithEffectItem:item typeName:model.GroupType success:nil faliure:nil];
                }
            } else {
                item.effectPath = [SYEffectsFileHelper effectResourcePathWithUrlString:item.Url typeName:model.GroupType];
                item.downloaded = YES;
            }
        }];
    }];
}

#pragma mark - download task
- (void)downloadWithEffectItem:(SYEffectItem *)effectItem typeName:(NSString *)typeName success:(dispatch_block_t _Nullable)success faliure:(dispatch_block_t _Nullable)failure
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:effectItem.Url]];
    NSURLSessionDownloadTask *downloadTask = [self.urlManager downloadTaskWithRequest:request progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *path = [[SYEffectsFileHelper effectsResourcePathWithTypeName:typeName] stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                effectItem.downloaded = YES;
                effectItem.effectPath = filePath.path;
                !success?:success();
            } else {
                !failure?:failure();
            }
        });
    }];
    [downloadTask resume];
}

#pragma mark - init AF
+ (AFHTTPSessionManager *)sy_createHTTPSessionManager
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30;
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"image/jpeg",@"text/plain", nil];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    return manager;
}

+ (AFURLSessionManager *)sy_createURLSessionManager
{
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:nil];
    manager.completionQueue = dispatch_queue_create("beauty", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    return manager;
}

@end
