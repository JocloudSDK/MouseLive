//
//  SYAppId.h
//  MouseLive
//
//  Created by 张建平 on 2020/4/20.
//  Copyright © 2020 sy. All rights reserved.
//

#ifndef SYAppId_h
#define SYAppId_h

/**
 * 聚联云官网申请的appid，请关注https://www.sunclouds.com/#/
 */
/**
 * 聚联云官网申请的appid所对应的apseret，token的使用和生成请关注https://www.sunclouds.com/#/
 *
 * 三种模式：
 * appid模式：hummer和thunder会跳过token验证？？？
 * token验证模式：适用于安全性要求较高的场景，hummer和thunder会验证token，验证过期或者不ton过测无法使用服务
 * token和业务服务器模式：适用于安全性要求很高的场景，hummer和thunder会验证token，验证通过后还会请求业务服务器进行token效验，验证过期或者不ton过测无法使用服务
 */

extern NSString * const kSYAppId;
extern NSString * const kCDNRtmpPullUrl;
extern NSString * const kCDNRtmpPushUrl;
extern NSString * const kOFSDKSerialNumber;

#endif /* SYAppId_h */
