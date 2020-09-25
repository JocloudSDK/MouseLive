//
//  PublicEnum.h
//  MouseLive
//
//  Created by 宁丽环 on 2020/4/28.
//  Copyright © 2020 sy. All rights reserved.
//

//开播类型
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,LiveType) {
   LiveTypeVideo = 1,
   LiveTypeAudio,
   LiveTypeKTV,
   LiveTypeCommentary
};

//直播模式
typedef enum {
   PUBLISH_STREAM_RTC = 1,
   PUBLISH_STREAM_CDN = 2
}PublishMode;

typedef NS_ENUM(NSInteger,ManagementUserType){
    ManagementUserTypeAddAdmin,//升管
    ManagementUserTypeRemoveAdmin, // 降管
    ManagementUserTypeMute, // 禁言
    ManagementUserTypeUnmute, //解禁
    ManagementUserTypeKick,//剔出
    ManagementUserTypeOpenMirc, // 开麦
    ManagementUserTypeCloseMirc,//闭麦
    ManagementUserTypeDownMirc//下麦
};

typedef NS_ENUM(NSInteger,LiveUserViewType) {
    LiveUserViewTypeTwoMicStyle,//开麦 下麦
    LiveUserViewTypeTwoAdminStyle,//禁言，踢出 管理员的权限
    LiveUserViewTypeThreeStyle//禁言 升管 踢出
};
/**网络请求类型*/
typedef NS_ENUM(NSInteger,SYHttpMethodType){
    SYHttpMethodTypeGET,
    SYHttpMethodTypePOST
};

/**请求url 对应的key值*/
typedef NS_ENUM(NSInteger,SYHttpRequestKeyType){
    SYHttpRequestKeyType_NotFound,
    SYHttpRequestKeyType_Test,
    SYHttpRequestKeyType_Login,
    SYHttpRequestKeyType_RoomList,
    SYHttpRequestKeyType_AnchorList,
    SYHttpRequestKeyType_RoomInfo,
    SYHttpRequestKeyType_CreateRoom,
    SYHttpRequestKeyType_GetUserInfo,
    SYHttpRequestKeyType_SetChatId,
    SYHttpRequestKeyType_GetChatId,
    SYHttpRequestKeyType_SetRoomMic,
    SYHttpRequestKeyType_GetToken,
    SYHttpRequestKeyType_GetBeauty,
    SYHttpRequestKeyType_SetStatus
};

typedef enum : NSUInteger {
    QulityLevel_High,
    QulityLevel_normal,
    QulityLevel_fluency,
} QulityLevel;

typedef enum : NSUInteger {
    Http_GetToken,
    Http_Login,
    Http_GetUserInfo,
    Http_CreateRoom,
    Http_GetRoomList,
    Http_GetChatId,
    Http_SetChatId,
    Http_GetAnchorList,
    Http_GetRoomInfo,
    Http_SetRoomMic,
    Http_SetStatus
} RequestType;
