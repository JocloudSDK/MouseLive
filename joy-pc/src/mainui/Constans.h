#pragma once

#include <QString>
#include <QApplication>

const QString USER_DATA_PATH = "/UserData";
const QString USER_DATA_CACHE_PATH = USER_DATA_PATH + "/Default/Cache";
const QString USER_DATA_SYSLOG_PATH = USER_DATA_PATH + "/Syslog";
const QString USER_DATA_UILOG_PATH = USER_DATA_SYSLOG_PATH + "/UI";
const QString USER_DATA_SDKLOG_PATH = USER_DATA_SYSLOG_PATH + "/SDK";

// ========== config ===========
const QString STR_CONFIG_PATH = USER_DATA_PATH + "/config.ini";
const QString STR_CONFIG_UID = "UI/UID";
const QString STR_CONFIG_LANGUAGE = "UI/Language";

const QString STR_PLOTFORM = "PC";

// =========== http ==========
const QString STR_HTTP_VER = "v0.1.0";
const QString STR_HTTP_BASE = "http://fun.jocloud.com";
const QString STR_WEBSOCKET_BASE = "ws://fun.jocloud.com/fun/ws/v1";
const QString STR_HTTP_GET_TOKEN = STR_HTTP_BASE + "/fun/api/v1/getToken"; // -- 没有实现
const QString STR_HTTP_GET_USER_INFO = STR_HTTP_BASE + "/fun/api/v1/getUserInfo"; // -- 没有实现
const QString STR_HTTP_GET_CHARID = STR_HTTP_BASE + "/fun/api/v1/getChatId"; // -- 没有实现
const QString STR_HTTP_SET_ROOM_MIC = STR_HTTP_BASE + "/fun/api/v1/setRoomMic"; // -- 没有实现
const QString STR_HTTP_SET_STATUS = STR_HTTP_BASE + "/fun/api/v1/setStatus"; // -- 没有实现

const QString STR_HTTP_SET_CHARID = STR_HTTP_BASE + "/fun/api/v1/setChatId";
const QString STR_HTTP_GET_ANCHOR_LIST = STR_HTTP_BASE + "/fun/api/v1/getAnchorList";
const QString STR_HTTP_GET_ROOM_INFO = STR_HTTP_BASE + "/fun/api/v1/getRoomInfo";
const QString STR_HTTP_CREATE_ROOM = STR_HTTP_BASE + "/fun/api/v1/createRoom";
const QString STR_HTTP_LOGIN = STR_HTTP_BASE + "/fun/api/v1/login";
const QString STR_HTTP_GET_ROOM_LIST = STR_HTTP_BASE + "/fun/api/v1/getRoomList";

// =========== enum ==========
enum class RoomType {
	LIVE = 1,
	CHAT,
	KTV
};

enum class HttpErrorCode {
	SUCCESS = 5000,
};

enum class PushMode {
	RTC = 1,
	CDN
};
