//
//  SYEnums.h
//  MouseLive
//
//  Created by 张骥 on 2020/5/15.
//  Copyright © 2020 sy. All rights reserved.
//

#ifndef SYEnums_h
#define SYEnums_h

typedef enum : NSUInteger {
    RoomType_Live = 1,
    RoomType_Audio,
    RoomType_KTV,
    RoomType_Sport,
} RoomType;

typedef enum : NSUInteger {
    LivePublishMode_RTC = 1,
    LivePublishMode_CDN
} LivePublishMode;


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

#endif /* SYEnums_h */
