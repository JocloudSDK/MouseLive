//
//  WebSocketManager.h
//  MouseLive
//
//  Created by 张建平 on 2020/3/15.
//  Copyright © 2020 sy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SRWebSocket.h>

typedef NS_ENUM(NSUInteger,WebSocketConnectType){
    WebSocketConnectTypeDefault = 0, //初始状态,未连接
    WebSocketConnectTypeConnect,      //已连接
    WebSocketConnectTypeDisconnect    //连接后断开
};

@class WebSocketManager;
@protocol WebSocketManagerDelegate <NSObject>

- (void)webSocketDidReceiveMessageWithString:(NSString * _Nonnull)string;

- (void)webSocketDidOpen;

- (void)webSocketDidClose;

- (void)webSocketError:(int)error;

@end

NS_ASSUME_NONNULL_BEGIN

@interface WebSocketManager : NSObject

@property (nonatomic, strong) SRWebSocket *webSocket;
@property (nonatomic, weak) id<WebSocketManagerDelegate > delegate;
@property (nonatomic, assign) BOOL isConnect;  //是否连接
@property (nonatomic, assign) WebSocketConnectType connectType;

+ (instancetype)shared;
- (void)connectServer;//建立长连接
- (void)closeServer;//关闭长连接
- (void)sendDataToServer:(NSString *)data;//发送数据给服务器

@end

NS_ASSUME_NONNULL_END
