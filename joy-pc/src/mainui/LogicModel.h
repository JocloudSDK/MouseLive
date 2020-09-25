#pragma once

#include "../common/json2/RapidjsonHelper.h"
#include "AppInfo.h"
#include "Constans.h"
#include <QUuid>

using namespace PBLIB::RapidJsonHelper;

class BaseRequest : public JsonBase {
protected:
	std::string SvrVer = STR_HTTP_VER.toStdString();
	int AppId = STR_APPID.toInt();
};

class BaseResponse : public JsonBase {
public:
	BaseResponse() {}
	~BaseResponse() {}

	int Code;
	std::string Msg;
};

class UserInfoResponseData : public JsonBase {
public:
	UserInfoResponseData() {}
	~UserInfoResponseData() {}

	int64_t Uid;
	int64_t LinkRoomId;
	int LinkUid;
	bool MicEnable;
	bool SelfMicEnable;
	std::string NickName;
	std::string Cover;

	UserInfoResponseData& operator=(const UserInfoResponseData& cls) {
		if (this != &cls) {
			this->Uid = cls.Uid;
			this->LinkRoomId = cls.LinkRoomId;
			this->LinkUid = cls.LinkUid;
			this->MicEnable = cls.MicEnable;
			this->SelfMicEnable = cls.SelfMicEnable;
			this->NickName = cls.NickName;
			this->Cover = cls.Cover;
		}
		return *this;
	}

	void ToWrite(Writer<StringBuffer> &writer) {}

	void ParseJson(const Value& val) {
		RapidjsonParseBegin(val);
		RapidjsonParseToInt64(Uid);
		RapidjsonParseToInt64(LinkRoomId);
		RapidjsonParseToInt(LinkUid);
		RapidjsonParseToBool(MicEnable);
		RapidjsonParseToBool(SelfMicEnable);
		RapidjsonParseToString(NickName);
		RapidjsonParseToString(Cover);
		RapidjsonParseEnd();
	}
};

class AnchorResponseData : public JsonBase {
public:
	AnchorResponseData() {}
	~AnchorResponseData() {}

	int64_t AId;
	int64_t ARoom;
	std::string AName;
	std::string ACover;

	AnchorResponseData& operator=(const AnchorResponseData& cls) {
		if (this != &cls) {
			this->AId = cls.AId;
			this->ARoom = cls.ARoom;
			this->AName = cls.AName;
			this->ACover = cls.ACover;
		}
		return *this;
	}

	void setData(const AnchorResponseData& cls) {
		this->AId = cls.AId;
		this->ARoom = cls.ARoom;
		this->AName = cls.AName;
		this->ACover = cls.ACover;
	}

	void ToWrite(Writer<StringBuffer> &writer) {}

	void ParseJson(const Value& val) {
		RapidjsonParseBegin(val);
		RapidjsonParseToInt64(AId);
		RapidjsonParseToInt64(ARoom);
		RapidjsonParseToString(AName);
		RapidjsonParseToString(ACover);
		RapidjsonParseEnd();
	}
};

// ====== Login =======
class LoginRequest :public BaseRequest {
public:
	LoginRequest() {}
	~LoginRequest() {}

	int64_t Uid;

	void ToWrite(Writer<StringBuffer> &writer) {
		RapidjsonWriteBegin(writer);
		RapidjsonWriteString(SvrVer);
		RapidjsonWriteInt(AppId);
		RapidjsonWriteString(AppSecret);
		RapidjsonWriteInt(ValidTime);
		RapidjsonWriteInt64(Uid);
		RapidjsonWriteString(DevName);
		RapidjsonWriteString(DevUUID);
		RapidjsonWriteEnd();
	}

	void ParseJson(const Value& val) {}

protected:
	std::string AppSecret = STR_SECRET.toStdString();
	std::string DevName = STR_PLOTFORM.toStdString();
	std::string DevUUID = QUuid::createUuid().toString().toStdString();
	int ValidTime = 3600;
};

class LoginResponse :public BaseResponse {
protected:
	class LoginResponseData: public JsonBase {
	public:
		LoginResponseData() {}
		~LoginResponseData() {}

		int64_t Uid;
		std::string Token;
		std::string NickName;
		std::string Cover;

		void ToWrite(Writer<StringBuffer> &writer) {}

		void ParseJson(const Value& val) {
			RapidjsonParseBegin(val);
			RapidjsonParseToInt64(Uid);
			RapidjsonParseToString(Token);
			RapidjsonParseToString(NickName);
			RapidjsonParseToString(Cover);
			RapidjsonParseEnd();
		}
	};

public:
	LoginResponse() {}
	~LoginResponse() {}

	LoginResponseData Data;

	void ToWrite(Writer<StringBuffer> &writer) {}

	void ParseJson(const Value& val) {
		RapidjsonParseBegin(val);
		RapidjsonParseToInt(Code);
		RapidjsonParseEnd();
		if (Code != (int)HttpErrorCode::SUCCESS) {
			return;
		}

		RapidjsonParseBegin(val);
		RapidjsonParseToInt(Code);
		RapidjsonParseToString(Msg);
		RapidjsonParseToClass(Data);
		RapidjsonParseEnd();
	}
};
// ====== Login =======

// ====== GetRoomList =======
class GetRoomListRequest :public BaseRequest {
public:
	GetRoomListRequest() {}
	~GetRoomListRequest() {}

	int64_t Uid;
	int  RType;

	void ToWrite(Writer<StringBuffer> &writer) {
		RapidjsonWriteBegin(writer);
		RapidjsonWriteString(SvrVer);
		RapidjsonWriteInt(AppId);
		RapidjsonWriteInt(RType);
		RapidjsonWriteInt64(Uid);
		RapidjsonWriteInt(Offset);
		RapidjsonWriteInt(Limit);
		RapidjsonWriteEnd();
	}

	void ParseJson(const Value& val) {}

protected:
	int Offset = 0;
	int Limit = 20;
};

class GetRoomListResponse :public BaseResponse {
public:
	class RoomInfoResponse : public JsonBase {
	public:
		RoomInfoResponse() {}
		~RoomInfoResponse() {}

		RoomInfoResponse& operator=(const RoomInfoResponse& cls) {
			if (this != &cls) {
				this->AppId = cls.AppId;
				this->RoomId = cls.RoomId;
				this->RName = cls.RName;
				this->RLiving = cls.RLiving;
				this->RMicEnable = cls.RMicEnable;
				this->RLevel = cls.RLevel;
				this->RCover = cls.RCover;
				this->RCount = cls.RCount;
				this->RChatId = cls.RChatId;
				this->RNotice = cls.RNotice;
				this->ROwner = cls.ROwner;
				this->RPublishMode = cls.RPublishMode;
				this->RUpStream = cls.RUpStream;
				this->RDownStream = cls.RDownStream;
				this->CreateTm = cls.CreateTm;
				this->UpdateTm = cls.UpdateTm;
			}
			return *this;
		}

		int AppId;
		int RoomId;
		std::string RName;
		bool RLiving;
		bool RMicEnable;
		int RType;
		int RLevel;
		std::string RCover;
		int RCount;
		int64_t RChatId;
		std::string RNotice;
		UserInfoResponseData ROwner;
		int RPublishMode;
		std::string RUpStream;
		std::string RDownStream;
		std::string CreateTm;
		std::string UpdateTm;

		void ToWrite(Writer<StringBuffer> &writer) {}

		void ParseJson(const Value& val) {
			RapidjsonParseBegin(val);
			RapidjsonParseToInt(AppId);
			RapidjsonParseToInt(RoomId);
			RapidjsonParseToString(RName);
			RapidjsonParseToBool(RLiving);
			RapidjsonParseToBool(RMicEnable);
			RapidjsonParseToInt(RType);
			RapidjsonParseToInt(RLevel);
			RapidjsonParseToString(RCover);
			RapidjsonParseToInt(RCount);
			RapidjsonParseToInt64(RChatId);
			RapidjsonParseToString(RNotice);
			RapidjsonParseToClass(ROwner);
			RapidjsonParseToInt(RPublishMode);
			RapidjsonParseToString(RUpStream);
			RapidjsonParseToString(RDownStream);
			RapidjsonParseToString(CreateTm);
			RapidjsonParseToString(UpdateTm);
			RapidjsonParseEnd();
		}
	};

	class GetRoomListResponseData : public JsonBase {
	public:
		GetRoomListResponseData() {}
		~GetRoomListResponseData() {}

		JsonArray<RoomInfoResponse> RoomList;

		void ToWrite(Writer<StringBuffer> &writer) {}

		void ParseJson(const Value& val) {
			RapidjsonParseBegin(val);
			RapidjsonParseToClass(RoomList);
			RapidjsonParseEnd();
		}
	};

public:
	GetRoomListResponse() {}
	~GetRoomListResponse() {}

	GetRoomListResponseData Data;

	void ToWrite(Writer<StringBuffer> &writer) {}

	void ParseJson(const Value& val) {
		RapidjsonParseBegin(val);
		RapidjsonParseToInt(Code);
		RapidjsonParseEnd();
		if (Code != (int)HttpErrorCode::SUCCESS) {
			return;
		}

		RapidjsonParseBegin(val);
		RapidjsonParseToInt(Code);
		RapidjsonParseToString(Msg);
		RapidjsonParseToClass(Data);
		RapidjsonParseEnd();
	}
};
// ====== GetRoomList =======

// ====== CreateRoom =======
class CreateRoomRequest :public BaseRequest {
public:
	CreateRoomRequest() {}
	~CreateRoomRequest() {}

	int64_t Uid;
	int  RType;
	int RLevel;
	int RPublishMode;

	void ToWrite(Writer<StringBuffer> &writer) {
		RapidjsonWriteBegin(writer);
		RapidjsonWriteString(SvrVer);
		RapidjsonWriteInt(AppId);
		RapidjsonWriteInt(RType);
		RapidjsonWriteInt64(Uid);
		RapidjsonWriteInt(RLevel);
		RapidjsonWriteInt(RPublishMode);
		RapidjsonWriteInt64(RoomId);
		RapidjsonWriteString(RName);
		RapidjsonWriteString(RCover);
		RapidjsonWriteString(RNotice);
		RapidjsonWriteInt64(RChatId);
		RapidjsonWriteEnd();
	}

	void ParseJson(const Value& val) {}

protected:
	int64_t RoomId = 0;
	std::string RName = "pc-room-123";
	std::string RCover = "http://sensedemo.oss-cn-qingdao.aliyuncs.com/fun/cover/room/008.jpg";
	std::string RNotice = "notice";
	int64_t RChatId = 0;
};

class CreateRoomResponse :public BaseResponse {
public:
	class CreateRoomResponseData : public JsonBase {
	public:
		CreateRoomResponseData() {}
		~CreateRoomResponseData() {}

		CreateRoomResponseData& operator=(const CreateRoomResponseData& cls) {
			if (this != &cls) {
				this->AppId = cls.AppId;
				this->RoomId = cls.RoomId;
				this->RName = cls.RName;
				this->RLiving = cls.RLiving;
				this->RMicEnable = cls.RMicEnable;
				this->RLevel = cls.RLevel;
				this->RCover = cls.RCover;
				this->RCount = cls.RCount;
				this->RChatId = cls.RChatId;
				this->RNotice = cls.RNotice;
				this->ROwner = cls.ROwner;
				this->RPublishMode = cls.RPublishMode;
				this->RUpStream = cls.RUpStream;
				this->RDownStream = cls.RDownStream;
				this->CreateTm = cls.CreateTm;
				this->UpdateTm = cls.UpdateTm;
			}
			return *this;
		}

		int AppId;
		int RoomId;
		std::string RName;
		bool RLiving;
		bool RMicEnable;
		int RType;
		int RLevel;
		std::string RCover;
		int RCount;
		int64_t RChatId;
		std::string RNotice;
		UserInfoResponseData ROwner;
		int RPublishMode;
		std::string RUpStream;
		std::string RDownStream;
		std::string CreateTm;
		std::string UpdateTm;

		void ToWrite(Writer<StringBuffer> &writer) {}

		void ParseJson(const Value& val) {
			RapidjsonParseBegin(val);
			RapidjsonParseToInt(AppId);
			RapidjsonParseToInt(RoomId);
			RapidjsonParseToString(RName);
			RapidjsonParseToBool(RLiving);
			RapidjsonParseToBool(RMicEnable);
			RapidjsonParseToInt(RType);
			RapidjsonParseToInt(RLevel);
			RapidjsonParseToString(RCover);
			RapidjsonParseToInt(RCount);
			RapidjsonParseToInt64(RChatId);
			RapidjsonParseToString(RNotice);
			RapidjsonParseToClass(ROwner);
			RapidjsonParseToInt(RPublishMode);
			RapidjsonParseToString(RUpStream);
			RapidjsonParseToString(RDownStream);
			RapidjsonParseToString(CreateTm);
			RapidjsonParseToString(UpdateTm);
			RapidjsonParseEnd();
		}
	};

public:
	CreateRoomResponse() {}
	~CreateRoomResponse() {}

	CreateRoomResponseData Data;

	void ToWrite(Writer<StringBuffer> &writer) {}

	void ParseJson(const Value& val) {
		RapidjsonParseBegin(val);
		RapidjsonParseToInt(Code);
		RapidjsonParseEnd();
		if (Code != (int)HttpErrorCode::SUCCESS) {
			return;
		}

		RapidjsonParseBegin(val);
		RapidjsonParseToString(Msg);
		RapidjsonParseToClass(Data);
		RapidjsonParseEnd();
	}
};

// ====== CreateRoom =======

// ====== GetRoomInfo =======
class GetRoomInfoRequest :public BaseRequest {
public:
	GetRoomInfoRequest() {}
	~GetRoomInfoRequest() {}

	int64_t Uid;
	int64_t RoomId;
	int  RType;

	void ToWrite(Writer<StringBuffer> &writer) {
		RapidjsonWriteBegin(writer);
		RapidjsonWriteString(SvrVer);
		RapidjsonWriteInt(AppId);
		RapidjsonWriteInt64(Uid);
		RapidjsonWriteInt64(RoomId);
		RapidjsonWriteInt(RType);
		RapidjsonWriteEnd();
	}

	void ParseJson(const Value& val) {}
};

class GetRoomInfoResponse :public BaseResponse {

public:
	class GetRoomInfoResponseData : public JsonBase {
	public:
		GetRoomInfoResponseData() {}
		~GetRoomInfoResponseData() {}

		GetRoomListResponse::RoomInfoResponse RoomInfo;
		JsonArray<UserInfoResponseData> UserList;

		void ToWrite(Writer<StringBuffer> &writer) {}

		void ParseJson(const Value& val) {
			RapidjsonParseBegin(val);
			RapidjsonParseToClass(RoomInfo);
			RapidjsonParseToClass(UserList);
			RapidjsonParseEnd();
		}
	};

public:
	GetRoomInfoResponse() {}
	~GetRoomInfoResponse() {}

	GetRoomInfoResponseData Data;

	void ToWrite(Writer<StringBuffer> &writer) {}

	void ParseJson(const Value& val) {
		RapidjsonParseBegin(val);
		RapidjsonParseToInt(Code);
		RapidjsonParseEnd();
		if (Code != (int)HttpErrorCode::SUCCESS) {
			return;
		}

		RapidjsonParseBegin(val);
		RapidjsonParseToString(Msg);
		RapidjsonParseToClass(Data);
		RapidjsonParseEnd();
	}
};
// ====== GetRoomInfo =======

// ====== GetAnchorList =======
class GetAnchorListRequest :public BaseRequest {
public:
	GetAnchorListRequest() {}
	~GetAnchorListRequest() {}

	int64_t Uid;
	int  RType;

	void ToWrite(Writer<StringBuffer> &writer) {
		RapidjsonWriteBegin(writer);
		RapidjsonWriteString(SvrVer);
		RapidjsonWriteInt(AppId);
		RapidjsonWriteInt64(Uid);
		RapidjsonWriteInt(RType);
		RapidjsonWriteEnd();
	}

	void ParseJson(const Value& val) {}
};

class GetAnchorListResponse :public BaseResponse {
public:
	class GetAnchorListResponseData : public JsonBase {
	public:
		GetAnchorListResponseData() {}
		~GetAnchorListResponseData() {}

		JsonArray<AnchorResponseData> Anchors;

		void ToWrite(Writer<StringBuffer> &writer) {}

		void ParseJson(const Value& val) {
			RapidjsonParseBegin(val);
			RapidjsonParseToClass(Anchors);
			RapidjsonParseEnd();
		}
	};

public:
	GetAnchorListResponse() {}
	~GetAnchorListResponse() {}

	JsonArray<AnchorResponseData> Data;

	void ToWrite(Writer<StringBuffer> &writer) {}

	void ParseJson(const Value& val) {
		RapidjsonParseBegin(val);
		RapidjsonParseToInt(Code);
		RapidjsonParseEnd();
		if (Code != (int)HttpErrorCode::SUCCESS) {
			return;
		}

		RapidjsonParseBegin(val);
		RapidjsonParseToString(Msg);
		RapidjsonParseToClass(Data);
		RapidjsonParseEnd();
	}
};
// ====== GetAnchorList =======

// ====== SetChatId =======
class SetChatIdRequest :public BaseRequest {
public:
	SetChatIdRequest() {}
	~SetChatIdRequest() {}

	int64_t Uid;
	int64_t RoomId;
	int  RType;
	int64_t RChatId;

	void ToWrite(Writer<StringBuffer> &writer) {
		RapidjsonWriteBegin(writer);
		RapidjsonWriteString(SvrVer);
		RapidjsonWriteInt(AppId);
		RapidjsonWriteInt64(Uid);
		RapidjsonWriteInt64(RoomId);
		RapidjsonWriteInt(RType);
		RapidjsonWriteInt64(RChatId);
		RapidjsonWriteEnd();
	}

	void ParseJson(const Value& val) {}
};

class SetChatIdResponse :public BaseResponse {
public:
	SetChatIdResponse() {}
	~SetChatIdResponse() {}

	void ToWrite(Writer<StringBuffer> &writer) {}

	void ParseJson(const Value& val) {
		RapidjsonParseBegin(val);
		RapidjsonParseToInt(Code);
		RapidjsonParseEnd();
	}
};
// ====== SetChatId =======
