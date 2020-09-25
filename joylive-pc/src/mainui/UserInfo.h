#pragma once

#include <stdlib.h>
#include <stdint.h>
#include <QString>
#include "../common/utils/Singleton.h"
#include "LogicModel.h"
#include "../common/utils/String.h"

class UserInfo {
public:
	enum UserState {
		IDLE,
		LIVING,
		LINKING,
		WATCHING,
	};

public:
	UserInfo() {}
	~UserInfo() {}

	UserInfo& operator=(const UserInfo& cls) {
		if (this != &cls) {
			this->_iUid = cls._iUid;
			this->_bMicEnable = cls._bMicEnable;
			this->_bSelfMicEnable = cls._bSelfMicEnable;
			this->_iLinkRoomId = cls._iLinkRoomId;
			this->_iLinkUid = cls._iLinkUid;
			this->_strNickName = cls._strNickName;
			this->_strCover = cls._strCover;
		}
		return *this;
	}

	bool operator==(const int& uid) const {
		return this->_iUid == uid;
	}

	void setUserInfo(const UserInfoResponseData& cls) {
		this->_iUid = cls.Uid;
		this->_bMicEnable = cls.MicEnable;
		this->_bSelfMicEnable = cls.SelfMicEnable;
		this->_iLinkRoomId = cls.LinkRoomId;
		this->_iLinkUid = cls.LinkUid;
		this->_strNickName = stdString2QString(cls.NickName);
		this->_strCover = stdString2QString(cls.Cover);
	}

	int64_t _iUid = 0;
	bool _bMicEnable = false;
	bool _bSelfMicEnable = true;
	bool _bAdministrator = false;
	QString _strNickName;
	QString _strCover;
	UserState _eState = IDLE;
	int64_t _iLinkRoomId;
	int _iLinkUid;
};

class LocalUserInfo : public UserInfo, public  Singleton<LocalUserInfo> {
	friend class Singleton<LocalUserInfo>;
public:
	LocalUserInfo() {}
	~LocalUserInfo() {}

	std::string _strToken;
	bool _bOwner = false;
};