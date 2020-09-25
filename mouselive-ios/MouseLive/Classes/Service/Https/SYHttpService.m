//
//  SYHttpService.m
//  MouseLive
//
//  Created by 宁丽环 on 2020/5/21.
//  Copyright © 2020 sy. All rights reserved.
//

#import "SYHttpService.h"
#import "AFNetworking.h"
#import "SYAppInfo.h"
#define SYConfigDictionary(method,url) [self requestInfoDictionaryWithMethod:method urlPath:url]
#define Method @"Method"
#define Url @"Url"
//测试网络是否正常
#define TestUrl  @"http://fundbg.sunclouds.com"
/**请求路径*************************/
/**
 登录
 "Uid":  // 必须：(int64)：首次为0，服务器反回，记录本地，后基于这个登陆，10001～(100*10000*10000)的随机数
 "DevName": // 必须：(string)：设备名称：android：例如：XiaoMi8
 "DevUUID": // 必须：(string)：设备UUID：android：例如：9774d56d682e549c
 */
#define Login @"api/v1/login"
/**
 首页列表
 "Uid":0     // 必须：(int) or 121297
 "RType":    // 必须：(int):房间类型, 1:语音房间, 2:直播房间
 "Offset":0  // 必须：(int) 0,21,
 "Limit":20  // 必须：(int) 20,20,
 */
#define GetRoomList @"api/v1/getRoomList"
/**
 获取主播列表（PK使用）
 "Uid":0, or 121297
 "RType": 1,
 */
#define GetAnchorList @"api/v1/getAnchorList"
/**
 获取直播房间观众列表
 "Uid": 121297,
 "RoomId": "15000",
 */
#define GetRoomInfo   @"api/v1/getRoomInfo"
/**
 创建聊天室
 "Uid":      // 必须：(int64)：用户Id
 "RoomId":      // (int64)：房间ID
 "RChatId":  // (int64)：聊天室ID
 "RType": 1, // 必须 (int)房间类型
 "RLevel": 1,
 "RName": "room-new-new",
 "RNotice": "房间公告"
 "RCover": "http://image.biaobaiju.com/uploads/20180802/03/1533152912-BmPIzdDxuT.jpg"
 */
#define CreateRoom    @"api/v1/createRoom"
#define SetChatId     @"api/v1/setChatId"
#define GetChatId     @"api/v1/getChatId"
#define GetUserInfo   @"api/v1/getUserInfo"

/*
 {
 "RoomId": 66205018,      // 必须：(int64)房间ID
 "RType": 2,           // 必须：(int)  房间类型（视频直播，语音房，KTV等）
 "RMicEnable": false   // 必须：(bool)全局开麦：true，全局禁麦：false
 }
 */
#define SetRoomMic   @"api/v1/setRoomMic"

/*
 {
 "SvrVer":"v0.1.0"
 "AppId": 18181818
 "ValidTime": 36000
 "Uid":20205018
 }
 */
#define GetToken     @"api/v1/getToken"

/*
 获取特效数据
 */
#define GetBeauty   @"api/v1/getBeauty"

/*
 
 /fun/api/v1/setStatus
 方法    post
 Head    token：Basic authorization，生成方法请参考 HTTP Basic身份认证
 请求
 type TSetStatus struct {
 SvrVer     string `bson:"SvrVer"`     // 必须：服务器版本号0.1.0
 AppId      int32  `bson:"AppId"`      // 必须：该项目的AppId
 Uid        int64  `bson:"Uid"`        // 必须：用户ID
 UStatus    int32  `bson:"UStatus"`    // 必须：用户当前状态，参考：用户状态UserStatus
 }
 {
 "SvrVer": "v0.1.0",
 "AppId": 18251900,
 "Uid": 27905814,
 "UStatus": 11
 }
 */
#define SetStatus   @"api/v1/setStatus"

static NSString * const kSYSvrVer = @"v0.1.0";//必须：服务器版本号0.1.0
static NSString * const kHttpSuccessBlock = @"kHttpSuccessBlock";
static NSString * const kHttpFailedBlock = @"kHttpFailedBlock";
static NSString * const kHttpIsSuccessFlag = @"kHttpIsSuccessFlag";
static NSString * const kHttpResponse = @"kHttpResponse";
static NSString * const kHttpErrorCode = @"kHttpErrorCode";
static NSString * const kHttpErrorMessage = @"kHttpErrorMessage";
static NSString * const kHttpTaskId = @"kHttpTaskId";

typedef void(^NetResponseBlock) (NSString *taskId, id _Nullable respObjc, NSError *error);

@interface SYHttpService ()
/**
 响应处理器对象
 */
@property (nonatomic, weak) id <SYHttpResponseHandle> responseHandle;

@property (nonatomic, strong) NSMutableDictionary * _Nullable requestDict;

@property (nonatomic, strong) NSMutableDictionary * _Nullable reqeustAndRespondsDictionary;

@property (nonatomic, strong) AFHTTPSessionManager * _Nullable sessionManager;

@property (nonatomic, strong) NSMutableDictionary * _Nullable requestTaskIdDict;

@end

@implementation SYHttpService

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static SYHttpService *service = nil;
    dispatch_once(&onceToken, ^{
        service = [[[self class] alloc] init];
    });
    return service;
}


/// 添加观察者
/// @param delegate 观察者
- (void)addObserver:(id<SYHttpResponseHandle>) delegate
{
    self.responseHandle = delegate;
}

/// 移除观察者
/// @param delegate 观察者
- (void)removeObserver:(id<SYHttpResponseHandle>) delegate
{
    self.responseHandle = nil;
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _requestTaskIdDict = [[NSMutableDictionary alloc]init];
        _reqeustAndRespondsDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (NSMutableDictionary *)requestDict
{
    if (!_requestDict) {
        _requestDict = [[NSMutableDictionary alloc]init];
        [_requestDict setValue:SYConfigDictionary([self transformMethodEnumToString:SYHttpMethodTypePOST], Login) forKey:[self transformEnumToString: SYHttpRequestKeyType_Login]];
        [_requestDict setValue:SYConfigDictionary([self transformMethodEnumToString:SYHttpMethodTypePOST], GetRoomList) forKey:[self transformEnumToString:SYHttpRequestKeyType_RoomList]];
        [_requestDict setValue:SYConfigDictionary([self transformMethodEnumToString:SYHttpMethodTypePOST], GetAnchorList) forKey:[self transformEnumToString:SYHttpRequestKeyType_AnchorList]];
        [_requestDict setValue:SYConfigDictionary([self transformMethodEnumToString:SYHttpMethodTypePOST], GetRoomInfo) forKey:[self transformEnumToString:SYHttpRequestKeyType_RoomInfo]];
        [_requestDict setValue:SYConfigDictionary([self transformMethodEnumToString:SYHttpMethodTypePOST], CreateRoom) forKey:[self transformEnumToString:SYHttpRequestKeyType_CreateRoom]];
        [_requestDict setValue:SYConfigDictionary([self transformMethodEnumToString:SYHttpMethodTypePOST], SetChatId) forKey:[self transformEnumToString:SYHttpRequestKeyType_SetChatId]];
        [_requestDict setValue:SYConfigDictionary([self transformMethodEnumToString:SYHttpMethodTypePOST], GetUserInfo) forKey:[self transformEnumToString:SYHttpRequestKeyType_GetUserInfo]];
        [_requestDict setValue:SYConfigDictionary([self transformMethodEnumToString:SYHttpMethodTypePOST], GetChatId) forKey:[self transformEnumToString:SYHttpRequestKeyType_GetChatId]];
        [_requestDict setValue:SYConfigDictionary([self transformMethodEnumToString:SYHttpMethodTypePOST], SetRoomMic) forKey:[self transformEnumToString:SYHttpRequestKeyType_SetRoomMic]];
        [_requestDict setValue:SYConfigDictionary([self transformMethodEnumToString:SYHttpMethodTypePOST], GetToken) forKey:[self transformEnumToString:SYHttpRequestKeyType_GetToken]];
        [_requestDict setValue:SYConfigDictionary([self transformMethodEnumToString:SYHttpMethodTypePOST], TestUrl) forKey:[self transformEnumToString:SYHttpRequestKeyType_Test]];
        [_requestDict setValue:SYConfigDictionary([self transformMethodEnumToString:SYHttpMethodTypePOST], GetBeauty) forKey:[self transformEnumToString:SYHttpRequestKeyType_GetBeauty]];
        [_requestDict setValue:SYConfigDictionary([self transformMethodEnumToString:SYHttpMethodTypePOST], SetStatus) forKey:[self transformEnumToString:SYHttpRequestKeyType_SetStatus]];
    }
    return _requestDict;
}
- (SYHttpRequestKeyType)transformURLStringToEnum:(NSString *)URLString
{
    if ([URLString isEqualToString:Login]) {
        return SYHttpRequestKeyType_Login;
    } else if ([URLString isEqualToString:GetRoomList]) {
        return SYHttpRequestKeyType_RoomList;
    } else if ([URLString isEqualToString:GetAnchorList]) {
        return SYHttpRequestKeyType_AnchorList;
    } else if ([URLString isEqualToString:GetRoomInfo]) {
        return SYHttpRequestKeyType_RoomInfo;
    } else if ([URLString isEqualToString:CreateRoom]) {
        return SYHttpRequestKeyType_CreateRoom;
    } else if ([URLString isEqualToString:SetChatId]) {
        return SYHttpRequestKeyType_SetChatId;
    } else if ([URLString isEqualToString:GetUserInfo]) {
        return SYHttpRequestKeyType_GetUserInfo;
    } else if ([URLString isEqualToString:GetChatId]) {
        return SYHttpRequestKeyType_GetChatId;
    } else if ([URLString isEqualToString:SetRoomMic]) {
        return SYHttpRequestKeyType_SetRoomMic;
    } else if ([URLString isEqualToString:GetToken]) {
        return SYHttpRequestKeyType_GetToken;
    } else if ([URLString isEqualToString:TestUrl]) {
        return SYHttpRequestKeyType_Test;
    } else if ([URLString isEqualToString:GetBeauty]) {
        return SYHttpRequestKeyType_GetBeauty;
    } else if ([URLString isEqualToString:SetStatus]) {
        return SYHttpRequestKeyType_SetStatus;
    }
    return SYHttpRequestKeyType_NotFound;
}

- (NSString *)transformMethodEnumToString:(SYHttpMethodType)method
{
    switch (method) {
        case SYHttpMethodTypePOST:
            return @"POST";
            break;
        case SYHttpMethodTypeGET:
            return @"GET";
            break;
        default:
            break;
    }
    return nil;
}

- (NSString *)transformEnumToString:(SYHttpRequestKeyType) requestKeyType
{
    NSString *keyType = nil;
    switch (requestKeyType) {
        case SYHttpRequestKeyType_Test:
            keyType = @"SYHttpRequestKeyType_Test";
            break;
        case SYHttpRequestKeyType_Login:
            keyType = @"SYHttpRequestKeyType_Login";
            break;
        case SYHttpRequestKeyType_RoomList:
            keyType = @"SYHttpRequestKeyType_RoomList";
            break;
        case SYHttpRequestKeyType_AnchorList:
            keyType = @"SYHttpRequestKeyType_AnchorList";
            break;
        case SYHttpRequestKeyType_RoomInfo:
            keyType = @"SYHttpRequestKeyType_RoomInfo";
            break;
        case  SYHttpRequestKeyType_CreateRoom:
            keyType = @"SYHttpRequestKeyType_CreateRoom";
            break;
        case  SYHttpRequestKeyType_GetUserInfo:
            keyType= @"SYHttpRequestKeyType_GetUserInfo";
            break;
        case  SYHttpRequestKeyType_SetChatId:
            keyType= @"SYHttpRequestKeyType_SetChatId";
            break;
        case  SYHttpRequestKeyType_GetChatId:
            keyType = @"SYHttpRequestKeyType_GetChatId";
            break;
        case  SYHttpRequestKeyType_SetRoomMic:
            keyType = @"SYHttpRequestKeyType_SetRoomMic";
            break;
        case  SYHttpRequestKeyType_GetToken:
            keyType = @"SYHttpRequestKeyType_GetToken";
            break;
        case SYHttpRequestKeyType_GetBeauty:
            keyType = @"SYHttpRequestKeyType_GetBeauty";
            break;
        case  SYHttpRequestKeyType_SetStatus:
            keyType = @"SYHttpRequestKeyType_SetStatus";
            break;
        default:
            keyType = @"SYHttpRequestKeyType_NotFound";
            break;
    }
    return keyType;
}

- (NSDictionary *)requestInfoDictionaryWithMethod:(NSString *)method urlPath:(NSString *)urlPath
{
    return [NSDictionary dictionaryWithObjectsAndKeys:method,Method,urlPath,Url, nil];
}

#pragma mark -- http 请求
- (NSString *)sy_httpRequestWithType:(SYHttpRequestKeyType)type params:(NSDictionary *)params success:(NetServiceSuccessBlock)success failure:(NetServiceFailBlock)failure
{
    if (success == nil) {
        YYLogDebug(@"[MouseLive-Http] sy_httpRequestWithType, success is nil!");
    }
    NSDictionary *requestDict = [self.requestDict objectForKey:[self transformEnumToString:type]];
    
    NSString *requestMethod = [requestDict objectForKey:Method];
    NSString *requestUrl = [requestDict objectForKey:Url];
    
    // 1. 先获取 task id
    // 2. 发送 http 请求
    // 3. 保存格式如下 block suc + block failed + bool isSuc + response id + errorCode NSString* + errorMsg NSString*
    // 4. 在 http 请求的 block 中，保存传入的 success + failed，并加入到执行队列中
    
    NSMutableDictionary *tmpParam = [NSMutableDictionary dictionaryWithDictionary:params];
    [tmpParam setValue:kSYSvrVer forKey:kSvrVer];
    [tmpParam setObject:@([SYAppInfo sharedInstance].appId.longLongValue) forKey:kAppId];
    
    if ([requestMethod isEqualToString:[self transformMethodEnumToString:SYHttpMethodTypeGET]]) {
        NSString *requestId = [[SYHttpService shareInstance] sy_get:requestUrl parameters:[tmpParam copy] success:success failure:failure];
        return requestId;
        
    } else if ([requestMethod isEqualToString:[self transformMethodEnumToString:SYHttpMethodTypePOST]]) {
        NSString *requestId = [[SYHttpService shareInstance] sy_post:requestUrl parameters:[tmpParam copy] success:success failure:failure];
        return requestId;
    }
    return nil;
}

//代理返回
- (NSString *)sy_httpRequestWithType:(SYHttpRequestKeyType)type params:(NSDictionary *)params
{
    
    NSDictionary *requestDict = [self.requestDict objectForKey:[self transformEnumToString:type]];
    
    NSString *requestMethod = [requestDict objectForKey:Method];
    NSString *requestUrl = [requestDict objectForKey:Url];
    
    // 1. 先获取 task id
    // 2. 发送 http 请求
    // 3. 保存格式如下 block suc + block failed + bool isSuc + response id + errorCode NSString* + errorMsg NSString*
    // 4. 在 http 请求的 block 中，保存传入的 success + failed，并加入到执行队列中
    
    NSMutableDictionary *tmpParam = [NSMutableDictionary dictionaryWithDictionary:params];
    [tmpParam setValue:kSYSvrVer forKey:kSvrVer];
    [tmpParam setObject:@([SYAppInfo sharedInstance].appId.longLongValue) forKey:kAppId];
    
    if ([requestMethod isEqualToString:[self transformMethodEnumToString:SYHttpMethodTypeGET]]) {
        NSString *requestId = [self sy_get:requestUrl parameters:tmpParam];
        return requestId;
    } else if ([requestMethod isEqualToString:[self transformMethodEnumToString:SYHttpMethodTypePOST]]) {
        NSString *requestId = [self sy_post:requestUrl parameters:tmpParam];
        return requestId;
    }
    return nil;
}

- (NSString * _Nullable)sy_post:(NSString *)URLString parameters:(id)parameters
{
    NSString *urlString = URLString;
    if (![URLString isEqualToString:TestUrl]) {
        urlString = [kYYBaseUrl stringByAppendingString:URLString];
    }
    
    if (!([urlString hasPrefix:@"http://"] && ![urlString hasPrefix:@"https://"])) {
        YYLogDebug(@"[MouseLive-Http] sy_httpPostWithPath 请检查请求URL：%@",URLString);
        return nil;
    }
    NSString *realURL = urlString;
    
    //HTTPS SSL的验证，在此处调用上面的代码，给这个证书验证；
    [[SYHttpService shareInstance].sessionManager setSecurityPolicy:[[SYHttpService shareInstance] customSecurityPolicy]];
    WeakSelf
    __block NSURLSessionDataTask *task = nil;
    
    task =  [[SYHttpService shareInstance].sessionManager POST:realURL parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        responseObject = [weakSelf sy_customResponseSerializationData:responseObject];
        YYLogDebug(@"[MouseLive-Http] sy_httpPostWithPath \n\n***************  Start  ***************\nPOST:\nURL:%@\nParams:%@\nResponse:%@\n***************   End   ***************\n\n.",realURL, parameters, responseObject);
        NSString *requestId = [[NSString alloc] initWithFormat:@"%ld", (long)[task taskIdentifier]];
        
        [self.reqeustAndRespondsDictionary yy_setNotNullObject:responseObject ForKey:requestId];
        [self responseonSuccess:responseObject requestType:[self transformURLStringToEnum:[URLString copy]]];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        YYLogDebug(@"[MouseLive-Http] sy_httpPostWithPath \n\n***************  Start  ***************\nPOST:\nURL:%@\nParams:%@\nError:%@\n***************   End   ***************\n\n.",realURL, parameters, error);
        NSString *requestId = [[NSString alloc] initWithFormat:@"%ld", (long)[task taskIdentifier]];
        
        [self.reqeustAndRespondsDictionary yy_setNotNullObject:error ForKey:requestId];
        [self responseonFail:error requestType:[self transformURLStringToEnum:[URLString copy]]];
        
        
    }];
    NSString *requestId = [[NSString alloc] initWithFormat:@"%ld", (long)[task taskIdentifier]];
    
    [self.requestTaskIdDict yy_setNotNullObject:task ForKey:requestId];
    return requestId;
    
}

- (NSString * _Nullable)sy_get:(NSString *)URLString parameters:(id)parameters
{
     NSString *urlString = URLString;
       if (![URLString isEqualToString:TestUrl]) {
           urlString = [kYYBaseUrl stringByAppendingString:URLString];
       }
       if (![urlString hasPrefix:@"http://"] && ![urlString hasPrefix:@"https://"]) {
           YYLogDebug(@"[MouseLive-Http] sy_httpGetWithPath 请检查请求URL：%@",urlString);
           return nil;
       }
       NSString *realURL = urlString;
       __block NSURLSessionDataTask *task = nil;
       
       task =  [[SYHttpService shareInstance].sessionManager GET:realURL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
           responseObject = [[SYHttpService shareInstance] sy_customResponseSerializationData:responseObject];
           YYLogDebug(@"[MouseLive-Http] sy_httpGetWithPath \n\n***************  Start  ***************\nGET:\nURL:%@\nParams:%@\nResponse:%@\n***************   End   ***************\n\n.",realURL, parameters, responseObject);
           NSString *requestId = [[NSString alloc] initWithFormat:@"%ld", (long)[task taskIdentifier]];
           
           [self.reqeustAndRespondsDictionary yy_setNotNullObject:responseObject ForKey:requestId];
            //返回响应
           [self responseonSuccess:responseObject requestType:[self transformURLStringToEnum:[URLString copy]]];
         
           
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           YYLogDebug(@"[MouseLive-Http] sy_httpGetWithPath  \n\n***************  Start  ***************\nGET:\nURL:%@\nParams:%@\nError:%@\n***************   End   ***************\n\n.",realURL, parameters, error);
           NSString *requestId = [[NSString alloc] initWithFormat:@"%ld", (long)[task taskIdentifier]];
           [self.reqeustAndRespondsDictionary yy_setNotNullObject:error ForKey:requestId];
            //返回响应
           [self responseonFail:error requestType:[self transformURLStringToEnum:[URLString copy]]];

         
       }];
       NSString *requestId = [[NSString alloc] initWithFormat:@"%ld", (long)[task taskIdentifier]];
    [self.requestTaskIdDict yy_setNotNullObject:task ForKey:requestId];
    return requestId;
    
}

- (NSString *)sy_get:(NSString *)URLString parameters:(id)parameters success:(NetServiceSuccessBlock)success
             failure:(NetServiceFailBlock)failure
{
    NSString *urlString = URLString;
    if (![URLString isEqualToString:TestUrl]) {
        urlString = [kYYBaseUrl stringByAppendingString:URLString];
    }
    if (![urlString hasPrefix:@"http://"] && ![urlString hasPrefix:@"https://"]) {
        YYLogDebug(@"[MouseLive-Http] sy_httpGetWithPath 请检查请求URL：%@",urlString);
        return nil;
    }
    NSString *realURL = urlString;
    __block NSURLSessionDataTask *task = nil;
    
    task =  [[SYHttpService shareInstance].sessionManager GET:realURL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        responseObject = [[SYHttpService shareInstance] sy_customResponseSerializationData:responseObject];
        YYLogDebug(@"[MouseLive-Http] sy_httpGetWithPath \n\n***************  Start  ***************\nGET:\nURL:%@\nParams:%@\nResponse:%@\n***************   End   ***************\n\n.",realURL, parameters, responseObject);
        NSString *requestId = [[NSString alloc] initWithFormat:@"%ld", (long)[task taskIdentifier]];
        
        [self.reqeustAndRespondsDictionary yy_setNotNullObject:responseObject ForKey:requestId];
        [self requestSucessWithBlock:success];

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        YYLogDebug(@"[MouseLive-Http] sy_httpGetWithPath  \n\n***************  Start  ***************\nGET:\nURL:%@\nParams:%@\nError:%@\n***************   End   ***************\n\n.",realURL, parameters, error);
        NSString *requestId = [[NSString alloc] initWithFormat:@"%ld", (long)[task taskIdentifier]];
        [self.reqeustAndRespondsDictionary yy_setNotNullObject:error ForKey:requestId];
        [self requestFailWithBlock:failure];
    
    }];
    NSString *requestId = [[NSString alloc] initWithFormat:@"%ld", (long)[task taskIdentifier]];
    
    [self.requestTaskIdDict yy_setNotNullObject:task ForKey:requestId];
   return requestId;
}

- (NSString * _Nullable)sy_post:(NSString *)URLString parameters:(id)parameters          success:(NetServiceSuccessBlock)success
                       failure:(NetServiceFailBlock)failure
{
    NSString *urlString = URLString;
    if (![URLString isEqualToString:TestUrl]) {
        urlString = [kYYBaseUrl stringByAppendingString:URLString];
    }
    
    if (!([urlString hasPrefix:@"http://"] && ![urlString hasPrefix:@"https://"])) {
        YYLogDebug(@"[MouseLive-Http] sy_httpPostWithPath 请检查请求URL：%@",URLString);
        return nil;
    }
    NSString *realURL = urlString;
    
    //HTTPS SSL的验证，在此处调用上面的代码，给这个证书验证；
    [[SYHttpService shareInstance].sessionManager setSecurityPolicy:[[SYHttpService shareInstance] customSecurityPolicy]];
    WeakSelf
    __block NSURLSessionDataTask *task = nil;
    
    task =  [[SYHttpService shareInstance].sessionManager POST:realURL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        responseObject = [weakSelf sy_customResponseSerializationData:responseObject];
        YYLogDebug(@"[MouseLive-Http] sy_httpPostWithPath \n\n***************  Start  ***************\nPOST:\nURL:%@\nParams:%@\nResponse:%@\n***************   End   ***************\n\n.",realURL, parameters, responseObject);
        NSString *requestId = [[NSString alloc] initWithFormat:@"%ld", (long)[task taskIdentifier]];
               
        [self.reqeustAndRespondsDictionary yy_setNotNullObject:responseObject ForKey:requestId];
        [self requestSucessWithBlock:success];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        YYLogDebug(@"[MouseLive-Http] sy_httpPostWithPath \n\n***************  Start  ***************\nPOST:\nURL:%@\nParams:%@\nError:%@\n***************   End   ***************\n\n.",realURL, parameters, error);
        NSString *requestId = [[NSString alloc] initWithFormat:@"%ld", (long)[task taskIdentifier]];
        
        [self.reqeustAndRespondsDictionary yy_setNotNullObject:error ForKey:requestId];
        [self requestFailWithBlock:failure];
        
    }];
    NSString *requestId = [[NSString alloc] initWithFormat:@"%ld", (long)[task taskIdentifier]];
    
    [self.requestTaskIdDict yy_setNotNullObject:task ForKey:requestId];
    return requestId;
    
}

#pragma mark - 拦截器
- (void)responseonSuccess:(id)responseObject requestType:(SYHttpRequestKeyType)type
{
    for (NSString *requestId in [self.reqeustAndRespondsDictionary allKeys]) {
        if (![[self.requestTaskIdDict allKeys] containsObject:requestId]) {
            //丢掉返回的数据
           [self.reqeustAndRespondsDictionary removeObjectForKey:requestId];
            break;
        } else {
             //返回响应
            if (_responseHandle && [_responseHandle respondsToSelector:@selector(onSuccess:requestType:)]) {
                [_responseHandle onSuccess:responseObject requestType:type];
               [self.reqeustAndRespondsDictionary removeObjectForKey:requestId];
               [self.requestTaskIdDict removeObjectForKey:requestId];
            }
        }
    }
}

- (void)responseonFail:(NSError *)error requestType:(SYHttpRequestKeyType)type
{
    for (NSString *requestId in [self.reqeustAndRespondsDictionary allKeys]) {
           if (![[self.requestTaskIdDict allKeys] containsObject:requestId]) {
               //丢掉返回的数据
              [self.reqeustAndRespondsDictionary removeObjectForKey:requestId];
               break;
           } else {
               //
               if (_responseHandle && [_responseHandle respondsToSelector:@selector(onFail:requestType:error:)]) {
                   [_responseHandle onFail:nil requestType:type error:error];
                  [self.reqeustAndRespondsDictionary removeObjectForKey:requestId];
                   [self.requestTaskIdDict removeObjectForKey:requestId];

               }
           }
       }
}

- (void)requestFailWithBlock:(NetServiceFailBlock)blk
{
    for (NSString *requestId in [self.reqeustAndRespondsDictionary allKeys]) {
        if (![[self.requestTaskIdDict allKeys] containsObject:requestId]) {
            //丢掉返回的数据
           [self.reqeustAndRespondsDictionary removeObjectForKey:requestId];
            break;
        } else {
           if (blk) {
                blk(requestId,[[self.reqeustAndRespondsDictionary objectForKey:requestId] copy]);
               [self.reqeustAndRespondsDictionary removeObjectForKey:requestId];
               [self.requestTaskIdDict removeObjectForKey:requestId];

            }
        }
    }
}

- (void)requestSucessWithBlock:(NetServiceSuccessBlock)blk
{
    
    for (NSString *requestId in [self.reqeustAndRespondsDictionary allKeys]) {
        if (![[self.requestTaskIdDict allKeys] containsObject:requestId]) {
            //丢掉返回的数据
            [self.reqeustAndRespondsDictionary removeObjectForKey:requestId];
            break;
        } else {
            if (blk) {
                blk(requestId,[[self.reqeustAndRespondsDictionary objectForKey:requestId] copy]);
               [self.reqeustAndRespondsDictionary removeObjectForKey:requestId];
               [self.requestTaskIdDict removeObjectForKey:requestId];
            }
        }
    }
}

#pragma mark - 初始化 AFHTTPSessionManager
- (AFHTTPSessionManager *)sessionManager
{
    if (!_sessionManager) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _sessionManager.requestSerializer.timeoutInterval = HttpTimeoutInterval;
        _sessionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringCacheData;
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"image/jpeg",@"text/plain", nil];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    
    return _sessionManager;
}

#pragma mark - 初始化一个AFSecurityPolicy

- (AFSecurityPolicy *)customSecurityPolicy
{
    //先导入证书，找到证书的路径
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"cer"];
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    
    //AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    
    //allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    //如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = NO;
    NSSet *set = [[NSSet alloc] initWithObjects:certData, nil];
    securityPolicy.pinnedCertificates = set;
    
    return securityPolicy;
}

- (id)sy_customResponseSerializationData:(id)responseObject
{
    if (responseObject && [responseObject isKindOfClass:[NSData class]]) {
        responseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];;
    }
    return responseObject;
}

/**
 取消一个网络请求
 
 @param requestID 请求id
 */
- (void)cancelRequestWithRequestID:(nonnull NSString *)requestID
{
    NSURLSessionDataTask *requestOperation = self.requestTaskIdDict[requestID];
    [requestOperation cancel];
    [self.requestTaskIdDict removeObjectForKey:requestID];
}

/**
 取消很多网络请求
 
 @param requestIDList @[请求id,请求id]
 */
- (void)cancelRequestWithRequestIDList:(nonnull NSArray<NSString *> *)requestIDList
{
    for (NSString *requestId in requestIDList) {
        [self cancelRequestWithRequestID:requestId];
    }
}

- (void)cancelAllRequest
{
    for (NSString *requestId in [self.requestTaskIdDict allKeys]) {
        [self cancelRequestWithRequestID:requestId];
    }
}
@end
