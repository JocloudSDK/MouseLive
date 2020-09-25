#pragma once

#include <QObject>
#include "../3rd/Hummer/include/Hummer/Core.h"
#include "../3rd/Hummer/include/Hummer/Constants.h"
#include "../3rd/Hummer/include/Hummer/ChatRoomService.h"
#include "../../../common/utils/Singleton.h"

class ChatRoomManager : public QObject, public Singleton<ChatRoomManager> {
	Q_OBJECT

protected:
	friend class Singleton<ChatRoomManager>;

public:
	ChatRoomManager(QObject* parent = nullptr);
	~ChatRoomManager();

	void login(int64_t uid, const std::string& token);
	void logout();

	void joinRoom();
	void leaveRoom();

protected:
	static void OnCompleteLogin(ChatRoomManager *self, uint64_t reqId, HMRResult result, HMRVariant var);
	static void OnCompleteCreateChatroom(ChatRoomManager *self, uint64_t reqId, HMRResult result, HMRVariant var);
	static void OnCompleteJoinChatroom(ChatRoomManager *self, uint64_t reqId, HMRResult result, HMRVariant var);

signals:
	void onLoginChatRoomSuccess();
	void onLoginChatRoomFailed();
	void onJoinChatRoomSuccess(int64_t chatRoomId);
	void onJoinChatRoomFailed();

private:
	int64_t _iChatRoomId;
};
