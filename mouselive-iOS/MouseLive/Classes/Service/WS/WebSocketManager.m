//
//  WebSocketManager.m
//  MouseLive
//
//  Created by 张建平 on 2020/3/15.
//  Copyright © 2020 sy. All rights reserved.
//

#import "WebSocketManager.h"
#import <AFNetworking.h>

//static NSString* const kYYWSUrl = @"ws://192.168.1.200:9006/fun/ws/v1";

@interface WebSocketManager ()<SRWebSocketDelegate>

@property (nonatomic, strong) NSTimer *heartBeatTimer; //心跳定时器
@property (nonatomic, strong) NSTimer *netWorkTestingTimer; //没有网络的时候检测网络定时器
@property (nonatomic, assign) NSTimeInterval reConnectTime; //重连时间
@property (nonatomic, strong) NSMutableArray *sendDataArray; //存储要发送给服务端的数据，现在还没有用
@property (nonatomic, assign) BOOL isActivelyClose;    //用于判断是否主动关闭长连接，如果是主动断开连接，连接失败的代理中，就不用执行 重新连接方法

@end

@implementation WebSocketManager

+ (instancetype)shared
{
    static WebSocketManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.reConnectTime = 0;
        self.isActivelyClose = NO;
        self.sendDataArray = [[NSMutableArray alloc] init];
    }
    return self;
}

//建立长连接
- (void)connectServer
{
    YYLogDebug(@"[MouseLive-WSService] connectServer, entry");
    
    self.isActivelyClose = NO;
    _webSocket = nil;
    
    self.webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:kYYWSUrl]];
    self.webSocket.delegate = self;
    [self.webSocket open];
    
    YYLogDebug(@"[MouseLive-WSService] connectServer, exit");
}

- (void)sendPing:(id)sender
{
    [self.webSocket sendPing:nil];
}

#pragma mark - NSTimer

//初始化心跳
- (void)initHeartBeat
{
    //心跳没有被关闭
    if (self.heartBeatTimer) {
        return;
    }
    [self destoryHeartBeat];
    dispatch_main_async_safe(^{
        self.heartBeatTimer  = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(senderheartBeat) userInfo:nil repeats:true];
        [[NSRunLoop currentRunLoop]addTimer:self.heartBeatTimer forMode:NSRunLoopCommonModes];
    })
}

//发送心跳
- (void)senderheartBeat
{
    //和服务端约定好发送什么作为心跳标识，尽可能的减小心跳包大小
    __weak typeof (self) weakSelf = self;
    dispatch_main_async_safe(^{
        if (weakSelf.webSocket.readyState == SR_OPEN) {
            // 发送心跳包
//            YYLogDebug(@"[MouseLive-WSService] 发送ping数据");
            [weakSelf sendPing:nil];
        }
    });
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


//关闭长连接
- (void)closeServer
{
    YYLogDebug(@"[MouseLive-WSService] closeServer entry");
    self.isActivelyClose = YES;
    self.isConnect = NO;
    self.connectType = WebSocketConnectTypeDefault;
    if (self.webSocket) {
        [self.webSocket close];
        _webSocket = nil;
    }
    
    //关闭心跳定时器
    [self destoryHeartBeat];
    YYLogDebug(@"[MouseLive-WSService] closeServer exit");
}


//发送数据给服务器
- (void)sendDataToServer:(NSString *)data
{
    // 只有长连接OPEN开启状态才能调 send 方法，不然会Crash
    if (self.webSocket.readyState == SR_OPEN && self.connectType != WebSocketConnectTypeDisconnect) {
        [_webSocket send:data]; //发送数据
    }
    else {
        YYLogDebug(@"[MouseLive-WSService] sendDataToServer disconnect");
    }
}

#pragma mark --------------------------------------------------
#pragma mark - socket delegate

///开始连接
- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    YYLogDebug(@"[MouseLive-WSService] webSocketDidOpen entry");
    YYLogDebugSync(@"[MouseLive-WSService] webSocketDidOpen 连接成功, url:%@", kYYWSUrl);
    self.isConnect = YES;
    self.connectType = WebSocketConnectTypeConnect;

    [self initHeartBeat];///开始心跳
    
    if ([self.delegate respondsToSelector:@selector(webSocketDidOpen)]) {
        YYLogDebug(@"[MouseLive-WSService] webSocketDidOpen webSocketDidOpen");
        [self.delegate webSocketDidOpen];
    }
    YYLogDebug(@"[MouseLive-WSService] webSocketDidOpen exit");
}

///连接失败
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    YYLogDebug(@"[MouseLive-WSService] didFailWithError entry, 连接失败, error:%@", error);
    self.isConnect = NO;
    self.connectType = WebSocketConnectTypeDisconnect;

    if ([self.delegate respondsToSelector:@selector(webSocketError:)]) {
        [self.delegate webSocketError:1];
    }
}

///关闭连接
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    YYLogDebug(@"[MouseLive-WSService] didCloseWithCode entry, 被关闭连接 code:%ld, reason:%@, wasClean:%d", (long)code, reason, wasClean);
    self.isConnect = NO;

    if (self.connectType == WebSocketConnectTypeDisconnect || self.connectType == WebSocketConnectTypeDefault) {
        YYLogDebug(@"[MouseLive-WSService] didCloseWithCode exit already send webSocketError");
        return;
    }
    
    if (self.isActivelyClose) {
        self.connectType = WebSocketConnectTypeDefault;
    }
    else {
        self.connectType = WebSocketConnectTypeDisconnect;
    }
    
    [self destoryHeartBeat]; //断开连接时销毁心跳
    
    if ([self.delegate respondsToSelector:@selector(webSocketDidClose)]) {
        YYLogDebug(@"[MouseLive-WSService] didCloseWithCode webSocketDidClos");
        [self.delegate webSocketDidClose];
    }
    YYLogDebug(@"[MouseLive-WSService] didCloseWithCode exit");
}

///ping
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongData
{
//    YYLogDebug(@"[MouseLive-WSService] 接受pong数据--> %@",pongData);
}

///接收消息
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    // NSLog(@"接收消息----  %@",message);
    if ([self.delegate respondsToSelector:@selector(webSocketDidReceiveMessageWithString:)]) {
        [self.delegate webSocketDidReceiveMessageWithString:message];
    }
}


@end

