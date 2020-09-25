#pragma once

#include "../json2/RapidjsonHelper.h"
#include "../../mainui/AppInfo.h"
#include "WSService.h"

using namespace PBLIB::RapidJsonHelper;

class WSBaseRequest : public JsonBase {
public:
	int AppId = STR_APPID.toInt();
	int MsgId;
};

class WSBaseResponseBody : public JsonBase {
public:
	WSBaseResponseBody() {}
	~WSBaseResponseBody() {}

	std::string Code;
	std::string MsgName;
	std::string TraceId;

	void ParseJson(const Value& val) {
		RapidjsonParseBegin(val);
		RapidjsonParseToString(Code);
		RapidjsonParseEnd();
	}
};

class WSBaseResponse : public JsonBase {
public:
	int MsgId;
};

class WSBaseParseResponse : public JsonBase {
public:
	int MsgId;
	WSBaseResponseBody Body;

	void ParseJson(const Value& val) {
		RapidjsonParseBegin(val);
		RapidjsonParseToInt(MsgId);
		RapidjsonParseEnd();

		if (MsgId == (int)WSRequestCmd::WS_HEARTBEAT_ACK) {
			return;
		}

		RapidjsonParseBegin(val);
		RapidjsonParseToInt(MsgId);
		RapidjsonParseToClass(Body);
		RapidjsonParseEnd();
	}
};

class WSRoomMessage : public WSBaseRequest {
public:
	WSRoomMessage() {}
	~WSRoomMessage() {}

public:
	class WSRoomBody : public WSBaseResponseBody
	{
	public:
		WSRoomBody() {}
		~WSRoomBody() {}

		int AppId = STR_APPID.toInt();
		int64_t Uid;
		int64_t LiveRoomId;
		int64_t ChatRoomId;

		void ToWrite(Writer<StringBuffer> &writer) {
			RapidjsonWriteBegin(writer);
			RapidjsonWriteInt(AppId);
			RapidjsonWriteInt64(Uid);
			RapidjsonWriteInt64(LiveRoomId);
			RapidjsonWriteInt64(ChatRoomId);
			RapidjsonWriteEnd();
		}

		void ParseJson(const Value& val) {
			RapidjsonParseBegin(val);
			RapidjsonParseToString(Code);
			RapidjsonParseToString(MsgName);
			RapidjsonParseToString(TraceId);
			RapidjsonParseToInt64(Uid);
			RapidjsonParseToInt64(LiveRoomId);
			RapidjsonParseToInt64(ChatRoomId);
			RapidjsonParseEnd();
		}
	};

	WSRoomBody Body;

	void ToWrite(Writer<StringBuffer> &writer) {
		RapidjsonWriteBegin(writer);
		RapidjsonWriteInt(MsgId);
		RapidjsonWriteClass(Body);
		RapidjsonWriteEnd();
	}

	void ParseJson(const Value& val) {
		RapidjsonParseBegin(val);
		RapidjsonParseToInt(MsgId);
		RapidjsonParseToClass(Body);
		RapidjsonParseEnd();
	}
};

class WSInviteMessage : public WSBaseRequest {
public:
	WSInviteMessage() {}
	~WSInviteMessage() {}

public:
	class WSInviteBody : public WSBaseResponseBody
	{
	public:
		WSInviteBody() {}
		~WSInviteBody() {}

		int AppId = STR_APPID.toInt();
		int64_t SrcUid;
		int64_t SrcRoomId;
		int64_t DestUid;
		int64_t DestRoomId;
		int ChatType;
		std::string TraceId;

		void ToWrite(Writer<StringBuffer> &writer) {
			RapidjsonWriteBegin(writer);
			RapidjsonWriteInt(AppId);
			RapidjsonWriteInt64(SrcUid);
			RapidjsonWriteInt64(SrcRoomId);
			RapidjsonWriteInt64(DestUid);
			RapidjsonWriteInt64(DestRoomId);
			RapidjsonWriteInt(ChatType);
			RapidjsonWriteString(TraceId);
			RapidjsonWriteEnd();
		}

		void ParseJson(const Value& val) {
			RapidjsonParseBegin(val);
			RapidjsonParseToString(Code);
			RapidjsonParseToString(MsgName);
			RapidjsonParseToString(TraceId);
			RapidjsonParseToInt64(SrcUid);
			RapidjsonParseToInt64(SrcRoomId);
			RapidjsonParseToInt64(DestUid);
			RapidjsonParseToInt64(DestRoomId);
			RapidjsonParseToInt(ChatType);
			RapidjsonParseEnd();
		}
	};

	WSInviteBody Body;

	void ToWrite(Writer<StringBuffer> &writer) {
		RapidjsonWriteBegin(writer);
		RapidjsonWriteInt(MsgId);
		RapidjsonWriteClass(Body);
		RapidjsonWriteEnd();
	}

	void ParseJson(const Value& val) {
		RapidjsonParseBegin(val);
		RapidjsonParseToInt(MsgId);
		RapidjsonParseToClass(Body);
		RapidjsonParseEnd();
	}
};

class WSChatingMessage : public WSBaseRequest {
public:
	WSChatingMessage() {}
	~WSChatingMessage() {}

public:
	class WSChatingBody : public WSBaseResponseBody
	{
	public:
		WSChatingBody() {}
		~WSChatingBody() {}

		int AppId = STR_APPID.toInt();
		int MaxLinkNum;

		void ParseJson(const Value& val) {
			RapidjsonParseBegin(val);
			RapidjsonParseToString(Code);
			RapidjsonParseToString(MsgName);
			RapidjsonParseToString(TraceId);
			RapidjsonParseToInt(MaxLinkNum);
			RapidjsonParseEnd();
		}
	};

	WSChatingBody Body;

	void ParseJson(const Value& val) {
		RapidjsonParseBegin(val);
		RapidjsonParseToInt(MsgId);
		RapidjsonParseToClass(Body);
		RapidjsonParseEnd();
	}
};

//class WSRoomResponse : public WSBaseResponse {
//protected:
//	class WSRoomResponseBody : public WSBaseResponseBody
//	{
//	public:
//		WSRoomResponseBody() {}
//		~WSRoomResponseBody() {}
//
//		int64_t Uid;
//		int64_t LiveRoomId;
//		int64_t ChatRoomId;
//
//		void ParseJson(const Value& val) {
//			RapidjsonParseBegin(val);
//			RapidjsonParseToString(Code);
//			RapidjsonParseToString(MsgName);
//			RapidjsonParseToString(TraceId);
//			RapidjsonParseToInt64(Uid);
//			RapidjsonParseToInt64(LiveRoomId);
//			RapidjsonParseToInt64(ChatRoomId);
//			RapidjsonParseEnd();
//		}
//	};
//
//public:
//	int MsgId;
//	WSRoomResponseBody Body;
//
//	void ParseJson(const Value& val) {
//		RapidjsonParseBegin(val);
//		RapidjsonParseToInt(MsgId);
//		RapidjsonParseToClass(Body);
//		RapidjsonParseEnd();
//	}
//};

