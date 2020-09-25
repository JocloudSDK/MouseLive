#ifndef HMR_CHAT_ROOM_H
#define HMR_CHAT_ROOM_H

#include <Hummer/Constants.h>
#include <Hummer/ChatRoomConstants.h>
#include <map>

struct HMRChatRoomListener {
	// 异步请求的上下文对象指针，一般为发起异步操作的对象指针
	void *context;

	/**
	* 聊天室基础属性变更的回调通知
	*
	* @param context		context为listener中携带的上下文对象指针透传
	* @param chatRoom		聊天室
	* @param operatorUser	操作人员
	* @param info			已变更属性的键值对
	*/
	HMR_DEPRECATED("Using onRoomInfoAddedOrUpdated instead")
	void(*onBasicInfoChanged)(void *context, uint32_t chatroom, uint64_t operatorUser, const HMRKvArray *info);

	/**
	* 聊天室属性变更的回调通知
	*
	* @param context		context为listener中携带的上下文对象指针透传
	* @param chatRoom		聊天室
	* @param operatorUser	操作人员
	* @param info			已变更属性的键值对
	*/
	void(*onRoomInfoAddedOrUpdated)(void *context, uint32_t chatroom, uint64_t operatorUser, const HMRKvArray *info);

	// Hummer 内部使用的保留字段，业务方应禁止访问、修改该数据
	void *reserved;
};

struct HMRChatRoomMemberListener {
	// 异步请求的上下文对象指针，一般为发起异步操作的对象指针
	void *context;

	/**
	* 用户被踢出聊天室的回调通知
	*
	* @param context context为listener中携带的上下文对象指针透传
	* @param chatRoom 聊天室
	* @param admin    管理员
	* @param member   被踢用户
	* @param membersize   被踢用户数
	* @param reason   原因
	*/
	void(*onMemberKicked)(void *context, uint32_t chatroom, uint64_t admin, const uint64_t *member, uint16_t membersize, const char *reason);

	/**
	* 用户加入聊天室的回调通知
	*
	* @param context context为listener中携带的上下文对象指针透传
	* @param chatRoom 聊天室
	* @param users    加入用户
	* @param usersize 加入用户数
	*/
	void(*onMemberJoined)(void *context, uint32_t chatroom, const uint64_t *users, uint16_t usersize);

	/**
	* 用户退出聊天室的回调通知
	*
	* @param context context为listener中携带的上下文对象指针透传
	* @param chatRoom 聊天室
	* @param users    退出用户
	* @param usersize 退出用户数
	*/
	void(*onMemberLeaved)(void *context, uint32_t chatroom, const uint64_t *users, uint16_t usersize);

	/**
	* 用户属性被设置的回调通知
	*
	* @param context context为listener中携带的上下文对象指针透传
	* @param chatRoom 聊天室
	* @param user 信息变更的成员
	* @param infos 设置后的用户属性
	*/
	void(*onUserInfoSet)(void *context, uint32_t chatroom, uint64_t user, const HMRKvArray *infos);

	/**
	* 用户数量变更的回调通知
	*
	* @param context context为listener中携带的上下文对象指针透传
	* @param chatRoom 聊天室
	* @param count    变更后的用户数量
	*/
	void(*onMemberCountChanged)(void *context, uint32_t chatroom, uint32_t count);

	/**
	* 用户断线超时退出聊天室的回调通知
	*
	* @param context context为listener中携带的上下文对象指针透传
	* @param chatRoom 聊天室
	* @param users    离线用户
	* @param usersize 离线用户数
	*/
	void(*onMemberOffline)(void *context, uint32_t chatroom, const uint64_t *users, uint16_t usersize);

	/**
	* 用户属性变更的回调通知
	*
	* @param context context为listener中携带的上下文对象指针透传
	* @param chatRoom	聊天室
	* @param user		变更的成员
	* @param infos		变更后的用户属性
	*/
	void(*onUserInfoAddedOrUpdated)(void *context, uint32_t chatroom, uint64_t user, const HMRKvArray *infos);

	/**
	* 用户属性删除的回调通知
	*
	* @param context context为listener中携带的上下文对象指针透传
	* @param chatRoom	聊天室
	* @param user		变更的成员
	* @param infos		被删除的用户属性
	*/
	void(*onUserInfoDeleted)(void *context, uint32_t chatroom, uint64_t user, const HMRKvArray *infos);

	// Hummer 内部使用的保留字段，业务方应禁止访问、修改该数据
	void *reserved;
};

extern "C" {

	/* ---- Identity管理 ---- */

	// 构造一个聊天室Identity对象
	// @param roomId 聊天室的id
	// @return id 为 roomId的聊天室Identity对象
	HMR_API HMRIdentity HMRMakeChatRoomIdentity(uint64_t roomId);

	// 从聊天室Identity对象中抽取聊天室Id值
	HMR_API HMRCode HMRExtractChatRoomId(HMRIdentity identity, uint64_t *roomId);

	// 判断一个identity对象是否表示一个聊天室
	HMR_API bool HMRIsChatRoom(HMRIdentity identity);

	/* ---- Identity管理 ---- */

	// 构造一个聊天室/用户Identity对象，该identity一般用于进行聊天室单播信令的发送
	// @param roomId 聊天室的id
	// @param userId 聊天室内的用户id
	// @return id 为 roomId的聊天室Identity对象
	HMR_API HMRIdentity HMRMakeChatRoomUser(uint64_t roomId, uint64_t userId);

	// 从聊天室Identity对象中抽取聊天室单播Id, 用户id值
	HMR_API HMRCode HMRExtractChatRoomUser(HMRIdentity identity, uint64_t *roomId, uint64_t *userId);

	// 判断一个identity对象是否表示一个聊天室单播Id
	HMR_API bool HMRIsChatRoomUser(HMRIdentity identity);


	/* ---- 房间管理 ---- */
	/**
	* 监听者模式，添加聊天室监听器
	* 根据谁申请谁释放的原则，业务添加监听器后，要管理好资源释放
	* 释放监听器的同时需调用 HMRRemoveChatRoomListener 移除sdk的监听器引用
	*/
	HMR_API void HMRAddChatRoomListener(HMRChatRoomListener *listener);

	/**
	* 监听者模式，移除聊天室监听器
	* 根据谁申请谁释放的原则，业务移除监听器后，应自行处理资源释放
	*/
	HMR_API void HMRRemoveChatRoomListener(HMRChatRoomListener *listener);

	/**
	* 监听者模式，添加聊天室成员监听器
	* 根据谁申请谁释放的原则，业务添加监听器后，要管理好资源释放
	* 释放监听器的同时需调用 HMRRemoveChatRoomListener 移除sdk的监听器引用
	*/
	HMR_API void HMRAddMemberListener(HMRChatRoomMemberListener *listener);

	/**
	* 监听者模式，移除聊天室成员监听器
	* 根据谁申请谁释放的原则，业务移除监听器后，应自行处理资源释放
	*/
	HMR_API void HMRRemoveMemberListener(HMRChatRoomMemberListener *listener);

	// 获取聊天室服务地区代号
	HMR_API const char* HMRGetChatRoomRegion();

	// 设置聊天室服务地区代号(支持的地区及代号请咨询开发人员)，默认为中国"cn"
	// @param region 聊天室区域
	// @discuss 请在登录前切换服务地区
	HMR_API void HMRSetChatRoomRegion(const char *region);

	// 创建一个聊天室
	// @param completion 操作请求的异步回调对象
	// @discuss 聊天室的roomId会通过completion回调方法的variant参数回传
	HMR_API void HMRCreateChatRoom(HMRCompletion completion);
	
	// 创建一个聊天室，并配置聊天室属性
	// @param info 聊天室属性键值对，可配置字段参见HMRChatRoomBasicInfoType相关描述
	// @param completion 操作请求的异步回调对象
	// @discuss 聊天室的roomId会通过completion回调方法的variant参数回传
	HMR_API void HMRCreateChatRoomWithInfo(HMRKvArray *info, HMRCompletion completion);

	// 加入聊天室
	// @param roomId 欲加入的聊天室房间号
	// @param completion 请求的异步回调
	// @discuss 加入房间后，除了成为该房间的成员外，还会持续收到来自该房间的消息
	HMR_API void HMRJoinChatRoom(uint64_t roomId, HMRCompletion completion);

	// 加入聊天室，并检测当前用户是否重复登陆
	// @param roomId 欲加入的聊天室房间号
	// @param isCheckMultiJoin 是否检测重复登陆
	// @param completion 请求的异步回调
	// @discuss 加入房间后，除了成为该房间的成员外，还会持续收到来自该房间的消息
	// 如果重复登陆，completion回调方法会返回相应错误信息
	HMR_API void HMRJoinChatRoomWithMultiCheck(uint64_t roomId, bool isCheckMultiJoin, HMRCompletion completion);

	// 加入聊天室，并指定扩展信息
	// @param roomId 欲加入的聊天室房间号
	// @param 扩展字段，用于业务扩展，SDK 只负责透传，并且在匿名登录时，该字段无效，并会到达服务器
	// @param completion 请求的异步回调
	// @discuss 加入房间后，除了成为该房间的成员外，还会持续收到来自该房间的消息
	// 如果重复登陆，completion回调方法会返回相应错误信息
	HMR_API void HMRJoinChatRoomWithConfigs(uint64_t roomId, const HMRKvItem *joinProps, int numerOfProperty, HMRCompletion completion);

	// 离开聊天室
	// @param roomId 聊天室房间号
	// @param completion 请求的异步回调
	// @discuss 离开房间后，不再属于该房间的成员，并且无法再收到该房间的消息
	HMR_API void HMRLeaveChatRoom(uint64_t roomId, HMRCompletion completion);

	// 获取聊天室基础属性
	// @param roomId 聊天室房间号
	// @param completion 请求的异步回调
	// @discuss 聊天室属性会通过completion回调方法的var参数回传:
	// HMRKvArray* info = (HMRKvArray*)(var.ptrValue)
	HMR_API_DEPRECATED("Using HMRChatRoomFetchRoomInfo instead")
	void HMRChatRoomFetchBasicInfo(uint64_t roomId, HMRCompletion completion);

	// 修改聊天室基础属性
	// @param roomId 聊天室房间号
	// @param info 聊天室属性键值对，可配置字段参见HMRChatRoomBasicInfoType相关描述
	// @param completion 请求的异步回调
	HMR_API_DEPRECATED("Using HMRChatRoomAddOrUpdateRoomInfo instead")
	HMR_API void HMRChatRoomChangeBasicInfo(uint64_t roomId, HMRKvArray *info, HMRCompletion completion);

	// 修改聊天室属性
	// @param roomId 聊天室房间号
	// @param info 聊天室属性键值对
	// @param completion 请求的异步回调
	HMR_API void HMRChatRoomAddOrUpdateRoomInfo(uint64_t roomId, HMRKvArray *info, HMRCompletion completion);

	// 获取聊天室属性
	// @param roomId 聊天室房间号
	// @param completion 请求的异步回调
	// @discuss 聊天室属性会通过completion回调方法的var参数回传:
	// HMRKvArray* info = (HMRKvArray*)(var.ptrValue)
	HMR_API void HMRChatRoomFetchRoomInfo(uint64_t roomId, HMRCompletion completion);

	// 获取聊天室成员列表
	// @param roomId 聊天室房间号
	// @param num 拉取的条数
	// @param offset 拉取的位置，第一页从0开始
	// @param completion 请求的异步回调
	// @discuss 聊天室成员列表会通过completion回调方法的var参数回传:
	// HMRIdArray* users = (HMRIdArray*)(var.ptrValue)
	HMR_API void HMRChatRoomFetchMembers(uint64_t roomId, int32_t num, int32_t offset, HMRCompletion completion);

	// 设置自己的用户属性
	// @param roomId 聊天室房间号
	// @param infos 待设置用户属性
	// @param completion 请求的异步回调
	HMR_API void HMRChatRoomSetUserInfo(uint64_t roomId, HMRKvArray *infos, HMRCompletion completion);

	// 删除自己的用户属性
	// @param roomId 聊天室房间号
	// @param keys 待删除用户属性key数组
	// @param completion 请求的异步回调
	HMR_API void HMRChatRoomDeleteUserInfo(uint64_t roomId, HMRStrArray *keys, HMRCompletion completion);

	// 修改自己的用户属性
	// @param roomId 聊天室房间号
	// @param infos 待修改用户属性
	// @param completion 请求的异步回调
	HMR_API void HMRChatRoomAddOrUpdateUserInfo(uint64_t roomId, HMRKvArray *infos, HMRCompletion completion);

	// 获取聊天室用户属性列表
	// @param roomId 聊天室房间号
	// @param completion 请求的异步回调
	// @discuss 聊天室用户属性列表会通过completion回调方法的var参数回传:
	// HMRChatRoomOnLineUserInfoList* infoList = (HMRChatRoomOnLineUserInfoList*)(var.ptrValue)
	HMR_API void HMRChatRoomFetchOnLineUserInfoList(uint64_t roomId, HMRCompletion completion);

	// 批量获取聊天室指定用户属性列表
	// @param roomId 聊天室房间号
	// @param uids 待获取信息用户列表
	// @param completion 请求的异步回调
	// @discuss 聊天室用户属性列表会通过completion回调方法的var参数回传:
	// HMRChatRoomOnLineUserInfoList* infoList = (HMRChatRoomOnLineUserInfoList*)(var.ptrValue)
	HMR_API void HMRChatRoomBatchFetchUserInfos(uint64_t roomId, HMRIdArray *uids, HMRCompletion completion);
}

#endif // !HMR_CHAT_ROOM_H
