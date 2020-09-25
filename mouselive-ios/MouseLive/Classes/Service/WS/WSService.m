//
//  WSService.m
//  MouseLive
//
//  Created by 张建平 on 2020/3/10.
//  Copyright © 2020 sy. All rights reserved.
//

#import "WSService.h"
#import "WebSocketManager.h"
#import <YYModel.h>
#import "SYAppInfo.h"

static NSString * const g_Cmd = @"MsgId";
static NSString * const g_Body = @"Body";
static NSString * const g_Code = @"Code";

@interface WSCmdRequest : NSObject

@property (nonatomic) int MsgId;
@property (nonatomic) id Body;

@end

@implementation WSCmdRequest

@end


// 什么情况下会重连，如下：
// 1. 有 6 次以上没有收到心跳 ack 返回，重新连接
// 2. WS 返回 webSocketError，webSocketDidClose

// 解决：
// 1. 记录当前的时间，并设置超时连接的时间，由于切后台/息屏，不会出现断网，所以只有正常断网/弱网，就设置 20s 超时，重连并发送连接中消息
// 2. 一直重新连接，并给 ui 返回重连中，如果连接成功，取消一切重连状态；如果连接超时，返回 webClose
// 3. 如果切换到前台，发送给服务器已经切到前台了
// 4. 不用启用定时器了，1 中记录的时间，与当前时间做对比

#define MAX_TIMEOUT_DEFAULT 20000
#define MAX_TIMEOUT_SPECIAL 50000

@interface WSService() <WebSocketManagerDelegate>

@property (nonatomic, strong) id<WSServiceDelegate> delegate;
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, strong) NSTimer *heartBeatTimer; //心跳定时器
@property (nonatomic, assign) int sendHeartCount;  // 发送的心跳包数量
@property (nonatomic, assign) int receiveHeartCount; // 接收的心跳包数量
@property (nonatomic, assign) int logCount; // 打印日志使用
@property (nonatomic, assign, readwrite) WSServiceState state;
@property (nonatomic, assign) long long updateReconnectTime; // 记录当前要重连时候的时间
@property (nonatomic, assign) long long timeout; // 超时的时间
@property (nonatomic, assign) BOOL isSendDidConnecting; // 如果断网是否发送了，正在连接中消息

@end

@implementation WSService

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self alloc];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.state = WS_DISCONNECT_SELF;
    }
    return self;
}

- (void)addObserver:(id<WSServiceDelegate>) delegate
{
    self.delegate = delegate;
}

- (void)removeObserver:(id<WSServiceDelegate>) delegate
{
    self.delegate = nil;
}

//初始化心跳
- (void)initHeartBeat
{
    //心跳没有被关闭
    if (self.heartBeatTimer) {
        return;
    }
    [self destoryHeartBeat];
    dispatch_main_async_safe(^{
        self.heartBeatTimer  = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(senderheartBeat) userInfo:nil repeats:true];
        [[NSRunLoop currentRunLoop]addTimer:self.heartBeatTimer forMode:NSRunLoopCommonModes];
    })
}

//取消心跳
- (void)destoryHeartBeat
{
    __weak typeof (self) weakSelf = self;
    dispatch_main_async_safe(^{
        if (weakSelf.heartBeatTimer) {
            [weakSelf.heartBeatTimer invalidate];
            weakSelf.heartBeatTimer = nil;
        }
    });
}

//发送心跳
- (void)senderheartBeat
{
    __weak typeof (self) weakSelf = self;
    dispatch_main_async_safe(^{
        if ([WebSocketManager shared].isConnect == YES) {
            self.logCount++;
            if (self.logCount >= 6) {
                // 每 6 次，打印日志
//                YYLogDebug(@"[MouseLive-WSService] 发送心跳 sendCount:%d, receiveHeartCount:%d", weakSelf.sendHeartCount, weakSelf.receiveHeartCount);
                self.logCount = 0;
            }
            
            // 发送心跳包
            weakSelf.sendHeartCount++;
            
            [weakSelf sendWithParam:WS_HEARTBEAT object:@"OK"];
        }
    });
    
    // 3s 没有收到心跳的 ack，认为已经要重连连接了
    if (weakSelf.sendHeartCount - weakSelf.receiveHeartCount >= 6) {
        YYLogDebug(@"[MouseLive-WSService] 3s timeout!!!!!!");
        [self reconnect:YES];
        
        // 记录当前时间
        self.timeout = MAX_TIMEOUT_DEFAULT;
        self.updateReconnectTime = [self getNowForMillisecond];
    }
}

- (long long)getNowForMillisecond
{
    // *1000 是精确到毫秒，不乘就是精确到秒
    return (long long)[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
}

- (void)reconnect:(BOOL)needClose
{
    YYLogDebug(@"[MouseLive-WSService] reconnect entry");
    self.state = WS_CONNECTING;
    
    // 1. 关闭
    if (needClose) {
        [self destoryHeartBeat];
        [[WebSocketManager shared] closeServer];
    }
    
    // 2. 连接
    [WebSocketManager shared].delegate = self;
    [[WebSocketManager shared] connectServer];
    self.sendHeartCount = 0;
    self.receiveHeartCount = 0;
    self.logCount = 0;
    
    if (self.isSendDidConnecting) {
        self.isSendDidConnecting = NO;
        YYLogDebug(@"[MouseLive-WSService] reconnect send webSocketDidConnecting");
        if ([self.delegate respondsToSelector:@selector(webSocketDidConnecting)]) {
            [self.delegate webSocketDidConnecting];
        }
    }
    
    YYLogDebug(@"[MouseLive-WSService] reconnect exit");
}

- (void)connect
{
    YYLogDebug(@"[MouseLive-WSService] connect entry");
    [WebSocketManager shared].delegate = self;
    [[WebSocketManager shared] connectServer];
    self.sendHeartCount = 0;
    self.receiveHeartCount = 0;
    self.logCount = 0;
    self.timeout = -1;
    self.updateReconnectTime = 0;
    self.state = WS_CONNECTING;
    YYLogDebug(@"[MouseLive-WSService] connect exit");
}

- (void)close
{
    YYLogDebug(@"[MouseLive-WSService] close entry");
    self.state = WS_DISCONNECT_SELF;
    [self destoryHeartBeat];
    [[WebSocketManager shared] closeServer];
    self.delegate = nil;
    YYLogDebug(@"[MouseLive-WSService] close exit");
}

- (void)sendWithParam:(WSRequestType)type object:(id)object
{
    // Convert model to json:
    NSDictionary *json;
    if ([object isKindOfClass: [NSDictionary class]]) {
        json = object;
    }
    else {
        WSCmdRequest *req = [WSCmdRequest alloc];
        req.MsgId = (int)type;
        req.Body = object;
        json = [req yy_modelToJSONObject];
    }

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&error];
    NSString *js = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    if (type != WS_HEARTBEAT) {
        YYLogDebugSync(@"[MouseLive-WSService] [cmd: %@], 发送请求, json = %@", [self enumToString:(int)type], js);
    }

    [[WebSocketManager shared] sendDataToServer:js];
}

/// 切后台+息屏
- (void)handleAppWillResignActive
{
    YYLogDebug(@"[MouseLive-WSService] handleAppWillResignActive entry");
    if (self.state == WS_CONNECTED) {
        YYLogDebug(@"[MouseLive-WSService] handleAppWillResignActive ws is connected");
        // 1. 超时时间设置 60s
        self.timeout = -1; // 还原时间
        self.timeout = MAX_TIMEOUT_SPECIAL;
        
        // 2. 记录当前时间
        self.updateReconnectTime = [self getNowForMillisecond];
    }
    else {
        // 如果现在网络是断开的，这个时候一定是重连的，不用管
        YYLogDebug(@"[MouseLive-WSService] handleAppWillResignActive ws is not connected");
    }
    YYLogDebug(@"[MouseLive-WSService] handleAppWillResignActive exit");
}

/// 切到前台+息屏
- (void)handleAppDidBecomeActive
{
    YYLogDebug(@"[MouseLive-WSService] handleAppDidBecomeActive entry");
    if (self.state == WS_CONNECTED) {
        YYLogDebug(@"[MouseLive-WSService] handleAppDidBecomeActive ws is connected");
        // 1. 还原时间
        self.timeout = -1;
    }
    else {
        YYLogDebug(@"[MouseLive-WSService] handleAppDidBecomeActive ws is not connected");
        // 一定是重连状态
        // 1. 超时时间设置 30s
        self.timeout = -1; // 还原时间
        self.timeout = MAX_TIMEOUT_DEFAULT;
        
        // 2. 记录当前时间
        self.updateReconnectTime = [self getNowForMillisecond];
    }
    YYLogDebug(@"[MouseLive-WSService] handleAppDidBecomeActive exit");
}

- (NSDictionary *)_yy_dictionaryWithJSON:(id)json
{
    if (!json || json == (id)kCFNull) {
        return nil;
    }
    
    NSDictionary *dic = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding : NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            dic = nil;
        }
    }
    return dic;
}

#pragma mark - WebsocketDelegate
- (NSString *)enumToString:(int)cmd
{
    switch (cmd) {
        case WS_JOIN_ROOM:
            return @"进入房间";
        case WS_JOIN_BROADCAST:
            return @"广播用户进入房间";
        case WS_LEAVE_BROADCAST:
            return @"广播用户退出房间";
        case WS_CHAT_APPLY:
            return @"连麦请求";
        case WS_CHAT_CANCEL:
            return @"取消连麦请求";
        case WS_CHAT_ACCEPT:
            return @"同意连麦请求";
        case WS_CHAT_REJECT:
            return @"拒绝请求";
        case WS_CHAT_HANGUP:
            return @"挂断请求";
        case WS_CHAT_CHATING_BROADCAST:
            return @"广播用户连麦中请求";
        case WS_CHAT_HANGUP_BROADCAST:
            return @"广播用户断开连麦请求";
        case WS_CHAT_CHATTING: // 用户正在连麦中，返回个数
            return @"用户在连麦中";
        case  WS_CHAT_MIC_ENABLE: // 闭麦某个用户
            return @"关闭某个用户";
        case WS_CHAT_MIC_ENABLE_BROADCAST: // 闭麦某个用户的广播
            return @"广播关闭某个用户";
        case WS_LEAVE_ROOM: // 主动退出房间
            return @"主动退出房间";
    }
    return @"错误";
}

- (void)webSocketDidReceiveMessageWithString:(NSString * _Nonnull)string
{
    NSDictionary *response = [self _yy_dictionaryWithJSON:string];
       if (!response) {
           YYLogDebug(@"[MouseLive-WSService] receive, _yy_dictionaryWithJSON failed");
           return;
       }
       
       NSNumber *cmd = [response objectForKey:g_Cmd];
       int iCmd = [cmd intValue];
       if (iCmd == WS_HEARTBEAT_ACK) {
           // 先不处理
           __weak typeof (self) weakSelf = self;
           dispatch_main_async_safe(^{
               weakSelf.receiveHeartCount++;
               if (weakSelf.receiveHeartCount != weakSelf.sendHeartCount) {
                   YYLogDebug(@"[MouseLive-WSService] 接收心跳, send:%d, receive:%d drop count:%d", weakSelf.sendHeartCount, weakSelf.receiveHeartCount, weakSelf.sendHeartCount - weakSelf.receiveHeartCount);
               }
               weakSelf.receiveHeartCount = 0;
               weakSelf.sendHeartCount = 0;
           });
           return;
       }

       if (iCmd >= 10000 || iCmd == 0) {
           // 错误了
           YYLogDebug(@"[MouseLive-WSService] [cmd: %@] 处理错误请求。 接受请求, json = %@", [self enumToString:iCmd], string);
           
           iCmd = WS_ERROR;
           if (self.state == WS_CONNECTED) {
               if ([self.delegate respondsToSelector:@selector(websocketRecvMsgWithCmd:body:)]) {
                   [self.delegate websocketRecvMsgWithCmd:@(iCmd) body:nil];
               }
           }
           return;
       }
       
       YYLogDebug(@"[MouseLive-WSService] [cmd: %@] 接受请求, json = %@", [self enumToString:iCmd], string);
       
       NSDictionary *body = [response objectForKey:g_Body];
       if (!body || [body isKindOfClass:[NSNull class]] || [body count] == 0) {
           return;
       }
       else {
           NSString *code = [body objectForKey:g_Code];
           if (code) {
               if (![code isEqualToString:@"Ack"]) {
                   return;
               }
               else {
                   // 只有 joinroom 的 ack 返回才有用
                   if (iCmd != WS_JOIN_ROOM) {
                       return;
                   }
               }
           }
       }

       if (self.state != WS_CONNECTED) {
           YYLogError(@"[MouseLive-WSService] webSocketDidReceiveMessageWithString, state is error. state:%lu", (unsigned long)self.state);
           return;
       }
       
       if ([response objectForKey:g_Body] && self.state == WS_CONNECTED) {
           if ([self.delegate respondsToSelector:@selector(websocketRecvMsgWithCmd:body:)]) {
               [self.delegate websocketRecvMsgWithCmd:cmd body:body];
           }
       }
}

- (BOOL)isReconect
{
    YYLogDebug(@"[MouseLive-WSService] isReconect entry");
    BOOL reconect = NO;
    long long now = [self getNowForMillisecond];
    if (self.updateReconnectTime == 0) {
        YYLogDebug(@"[MouseLive-WSService] isReconect updateReconnectTime = 0, need to reconnect");
        // 1. 记录当前时间
        self.timeout = MAX_TIMEOUT_DEFAULT;
        self.updateReconnectTime = [self getNowForMillisecond];
        
        // 2. 重连
        [self reconnect:YES];
        reconect = YES;
    }
    else {
        if (now - self.updateReconnectTime < self.timeout) {
            [self reconnect:YES];
            reconect = YES;
        }
    }
    
    return reconect;
}

- (void)webSocketDidOpen
{
    YYLogDebug(@"[MouseLive-WSService] webSocketDidOpen");
    if (self.state != WS_CONNECTING) {
        // 如果状态不对就返回
        YYLogError(@"[MouseLive-WSService] webSocketDidOpen, state is error. state:%lu", (unsigned long)self.state);
        return;
    }
    
    self.state = WS_CONNECTED;
    self.timeout = -1;
    self.updateReconnectTime = 0;
    self.isSendDidConnecting = YES;
    [self initHeartBeat];

    YYLogDebug(@"[MouseLive-WSService] webSocketDidOpen will send webSocketDidOpen");
    if ([self.delegate respondsToSelector:@selector(webSocketDidOpen)]) {
        YYLogDebug(@"[MouseLive-WSService] webSocketDidOpen send webSocketDidOpen");
        [self.delegate webSocketDidOpen];
    }
}

- (void)webSocketDidClose
{
    YYLogDebug(@"[MouseLive-WSService] webSocketDidClose");
#if 1
    if (self.state != WS_DISCONNECT_SELF) {
        // 1. 如果没有超时，就继续重连
        if ([self isReconect]) {
            sleep(1);
            return;
        }

        // 2. 如果超过，就发送 ws close
        YYLogDebug(@"[MouseLive-WSService] webSocketDidClose will send webSocketDidClose");
        if ([self.delegate respondsToSelector:@selector(webSocketDidClose)]) {
            YYLogDebug(@"[MouseLive-WSService] webSocketDidClose send webSocketDidClose");
            [self.delegate webSocketDidClose];
        }
    }
#else
    // 如果接受到这个消息，就是服务器已经断开连接了，就发送 ws close
    YYLogDebug(@"[MouseLive-WSService] webSocketDidClose will send webSocketDidClose");
    if ([self.delegate respondsToSelector:@selector(webSocketDidClose)]) {
        YYLogDebug(@"[MouseLive-WSService] webSocketDidClose send webSocketDidClose");
        [self.delegate webSocketDidClose];
    }
#endif
}


- (void)webSocketError:(int)error
{
    // 1. 如果没有超时，就继续重连
    if ([self isReconect]) {
        sleep(1);
        return;
    }
    
    // 2. 如果超过，就发送 ws error
    YYLogDebug(@"[MouseLive-WSService] webSocketError will send websocketDidNetError, error:%d", error);
    if ([self.delegate respondsToSelector:@selector(websocketDidNetError:)]) {
        YYLogDebug(@"[MouseLive-WSService] webSocketError send websocketDidNetError");
        [self.delegate websocketDidNetError:error];
    }
}

#pragma mark -- get / set
- (void)setTimeout:(long long)timeout
{
    if (timeout != -1) {
        if (_timeout == -1) {
            _timeout = timeout;
        }
    }
    else {
        _timeout = -1;
    }
}

@end
