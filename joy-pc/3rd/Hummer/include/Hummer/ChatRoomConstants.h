#pragma once
#include <Hummer/Constants.h>

/**
聊天室基础信息的枚举字段
主要用来修改聊天室信息和监听聊天室信息时候，可以标识那个字段发生变化/需要修改

- HMRChatRoomBasicInfoTypeName			: 聊天室名字对应的枚举字段
- HMRChatRoomBasicInfoTypeDescription	: 聊天室描述对应的枚举字段
- HMRChatRoomBasicInfoTypeBulletin		: 聊天室公告对应的枚举字段
- HMRChatRoomBasicInfoTypeAppExtra		: 扩展字段对应的枚举字段
*/
static const char *HMRChatRoomBasicInfoTypeName			= "Name";
static const char *HMRChatRoomBasicInfoTypeDescription	= "Description";
static const char *HMRChatRoomBasicInfoTypeBulletin		= "Bulletin";
static const char *HMRChatRoomBasicInfoTypeAppExtra		= "AppExtra";

struct HMRChatRoomOnLineUserInfo {
	uint64_t uid;
	HMRKvArray *info;
};

struct HMRChatRoomOnLineUserInfoList {
	uint32_t len;
	HMRChatRoomOnLineUserInfo *users;
};
