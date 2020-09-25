//
//  SYPlayerProtocol.h
//  MouseLive
//
//  Created by 张骥 on 2020/4/27.
//  Copyright © 2020 sy. All rights reserved.
//

#ifndef SYPlayerProtocol_h
#define SYPlayerProtocol_h

@protocol SYPlayerProtocol <NSObject>

@property(nonatomic, readonly) UIView* playView;

- (void)upadteUrl: (NSString*)url;

- (void)start;

- (void)pause;

- (void)stop;

- (void)destory;


@end


#endif /* SYPlayerProtocol_h */
