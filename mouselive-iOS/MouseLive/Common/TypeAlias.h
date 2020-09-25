//
//  TypeAlias.h
//  MouseLive
//
//  Created by 张骥 on 2020/5/14.
//  Copyright © 2020 sy. All rights reserved.
//

#ifndef TypeAlias_h
#define TypeAlias_h

typedef void(^CompleteHandler)(NSError* _Nullable error);

typedef void(^ErrorComplete)(NSError* _Nullable error);

typedef void(^ErrorStrComplete)(NSError* _Nullable error, NSString* _Nullable msg);

typedef void(^ErrorDicComplete)(NSError* _Nullable error, NSDictionary* _Nullable dic, NSString* _Nullable msg);

typedef void(^DicCompletion)(NSDictionary* _Nullable dic);

typedef void(^RoomInfoCompletion)(LiveRoomInfoModel* _Nullable roomInfo, NSArray<LiveUserModel*>* _Nullable userList);

typedef void(^UserInfoCompletion)(LiveUserModel* _Nullable userInfo);

typedef void(^ObjCompletion)(id _Nullable obj);

typedef void(^StrCompletion)(NSString* _Nullable str);

typedef void(^ArrayCompletion)(NSArray* _Nullable array);

#endif /* TypeAlias_h */
