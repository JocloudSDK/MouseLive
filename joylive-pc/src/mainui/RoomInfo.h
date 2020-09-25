#pragma once

#include <stdlib.h>
#include <stdint.h>
#include <QString>
#include "UserInfo.h"
#include "Constans.h"
#include "../common/utils/Singleton.h"
#include <memory>
#include <QMutex>

struct UserLinkInfo {
	int64_t _iRoomId;  // �����˵ķ���
	int64_t _iUid;  // �����˵� uid
	QString _strNickName; // �������ǳ�
	QString _strCover; // ������ͷ��
};

class RoomInfo : public  Singleton<RoomInfo> {
public:
	enum class UserRole {
		Anchor,
		Viewer
	};

protected:
	friend class Singleton<RoomInfo>;
	RoomInfo() {
		_pRoomAnchor.reset(new UserInfo);
	}
	~RoomInfo() {}

public:
	void clearAll() {
		{
			QMutexLocker loc(&_oMutex);
			_oAllNormalUserList.clear();
		}
		
		_oAllAdministratorUserList.clear();
		_oLinkUserList.clear();
		_pRoomAnchor.reset(new UserInfo);
		_iRoomId = 0;
		_iChatId = 0;
		_eRoomType = RoomType::LIVE;
		_eUserRole = UserRole::Viewer;
	}
	
	void pushUserList(std::shared_ptr<UserInfo>&& user) {
		QMutexLocker loc(&_oMutex);
		_oAllNormalUserList.emplace_back(user);
	}

	void updateUserList(const UserInfo& user) {
		QMutexLocker loc(&_oMutex);
		for (auto u = _oAllNormalUserList.begin();
			u != RoomInfo::GetInstance()->_oAllNormalUserList.end();
			u++) {
			if ((*u)->_iUid == user._iUid) {
				(*u)->_bMicEnable = user._bMicEnable;
				(*u)->_bSelfMicEnable = user._bSelfMicEnable;
				(*u)->_iLinkRoomId = user._iLinkRoomId;
				(*u)->_iLinkUid = user._iLinkUid;
				(*u)->_strNickName = user._strNickName;
				(*u)->_strCover = user._strCover;
				break;
			}
		}
	}

	void popUserList(int64_t uid) {
		QMutexLocker loc(&_oMutex);
		for (auto user = RoomInfo::GetInstance()->_oAllNormalUserList.begin();
			user != RoomInfo::GetInstance()->_oAllNormalUserList.end();
			user++) {
			if ((*user)->_iUid == uid) {
				RoomInfo::GetInstance()->_oAllNormalUserList.erase(user);
				break;
			}
		}
	}

	int64_t _iRoomId = 0;
	int64_t _iChatId = 0;
	RoomType _eRoomType = RoomType::LIVE;
	UserRole _eUserRole = UserRole::Viewer;
	QString _strRoomName = "";

	QMutex _oMutex;

	std::shared_ptr<UserInfo> _pRoomAnchor;
	std::list<std::shared_ptr<UserLinkInfo>> _oLinkUserList;  // ��������Ϣ��������������Ҳ�����ǹ���
	std::list<std::shared_ptr<UserInfo>> _oAllNormalUserList;  // ���������������ǰ�˲��Ƿ���������list ��
	std::list<std::shared_ptr<UserInfo>> _oAllAdministratorUserList;  // ���������������ǰ�˲��Ƿ���������list ��
};
