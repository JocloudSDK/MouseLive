#include "ChatRoomManager.h"
#include "../../../common/log/loggerExt.h"
#include "../../AppInfo.h"

using namespace base;

static const char* TAG = "ChatRoomManager";

ChatRoomManager::ChatRoomManager(QObject* parent) : QObject(parent) {
	_iChatRoomId = 0;

	Logd(TAG, Log(__FUNCTION__).addDetail("version", HMRGetVersion()));
	HMRInit(STR_APPID.toInt());
}

ChatRoomManager::~ChatRoomManager() {
}

void ChatRoomManager::login(int64_t uid, const std::string& token) {
	Logd(TAG, Log(__FUNCTION__).addDetail("uid", std::to_string(uid)));
	HMROpenWithStringToken(uid, "cn", token.c_str(), HMRMakeCompletion(this, 0, (HMROnComplete)OnCompleteLogin));
	HMRSetChatRoomRegion("cn");
}

void ChatRoomManager::logout() {
	Logd(TAG, Log(__FUNCTION__).setMessage("===="));
	HMRClose();
}

void ChatRoomManager::joinRoom() {
	Logd(TAG, Log(__FUNCTION__).setMessage("===="));
	HMRCreateChatRoom(HMRMakeCompletion(this, 0, (HMROnComplete)OnCompleteCreateChatroom));
}

void ChatRoomManager::leaveRoom() {
	if (_iChatRoomId != 0) {
		Logd(TAG, Log(__FUNCTION__).addDetail("_iChatRoomId", std::to_string(_iChatRoomId)));
		HMRLeaveChatRoom(_iChatRoomId, HMRCompletion());
		_iChatRoomId = 0;
	}
}

void ChatRoomManager::OnCompleteLogin(ChatRoomManager *self, uint64_t reqId, HMRResult result, HMRVariant var) {
	if (result.code == HMRCodeSuccess) {
		Logd(TAG, Log(__FUNCTION__).setMessage("onLoginChatRoomSuccess"));
		emit self->onLoginChatRoomSuccess();
	}
	else {
		Logd(TAG, Log(__FUNCTION__).setMessage("onLoginChatRoomFailed"));
		emit self->onLoginChatRoomFailed();
	}
}

void ChatRoomManager::OnCompleteJoinChatroom(ChatRoomManager *self, uint64_t reqId, HMRResult result, HMRVariant var) {
	if (result.code == HMRCodeSuccess) {
		Logd(TAG, Log(__FUNCTION__).setMessage("onJoinChatRoomSuccess").addDetail("_iChatRoomId", std::to_string(self->_iChatRoomId)));
		emit self->onJoinChatRoomSuccess(self->_iChatRoomId);
	}
	else {
		Logd(TAG, Log(__FUNCTION__).setMessage("onJoinChatRoomFailed"));
		emit self->onJoinChatRoomFailed();
	}
}

void ChatRoomManager::OnCompleteCreateChatroom(ChatRoomManager *self, uint64_t reqId, HMRResult result, HMRVariant var) {
	if (result.code == HMRCodeSuccess) {
		Logd(TAG, Log(__FUNCTION__).setMessage("onJoinChatRoomSuccess").addDetail("_iChatRoomId", std::to_string(self->_iChatRoomId)));
		self->_iChatRoomId = (int64_t)var.intValue;
		emit self->onJoinChatRoomSuccess(self->_iChatRoomId);
		// 进入房间, HMRJoinChatRoom 出现兼容错误
		//HMRJoinChatRoom(self->_iChatRoomId, HMRMakeCompletion(self, 0, (HMROnComplete)OnCompleteJoinChatroom));
	}
	else {
		Logd(TAG, Log(__FUNCTION__).setMessage("onLoginChatRoomFailed"));
		emit self->onLoginChatRoomFailed();
	}
}
