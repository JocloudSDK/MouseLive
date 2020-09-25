#pragma once

#include <QSettings>
#include <QString>
#include <QApplication>

inline QVariant GetConfig(const QString &path, const QString &key, const QVariant &defaultValue = QVariant())
{
	auto realPath = qApp->applicationDirPath() + path;
	QSettings settings(realPath, QSettings::IniFormat);
	auto value = settings.value(key, defaultValue);

	return value;
}

inline QVariant GetConfig(const QString &path, const QString &group, const QString &key, const QVariant &defaultValue = QVariant())
{
	auto realPath = qApp->applicationDirPath() + path;
	QSettings settings(realPath, QSettings::IniFormat);
	settings.beginGroup(group);
	auto value = settings.value(key, defaultValue);
	settings.endGroup();

	return value;
}

inline void SetConfig(const QString &path, const QString &group, const QString &key, const QVariant &defaultValue = QVariant())
{
	auto realPath = qApp->applicationDirPath() + path;
	QSettings settings(realPath, QSettings::IniFormat);
	settings.beginGroup(group);
	settings.setValue(key, defaultValue);
	settings.endGroup();
}

const QString SETTINGS_DIR = "/Settings/";

/*platform*/
const QString PF_SETTINGS_PATH = SETTINGS_DIR + "platform.ini";

const QString PF_GROUP_SYS = "sys";
const QString PF_SYS_SINGLE = "single";
const QString PF_GROUP_UPDATE = "update";

const QString PF_UPDATE_CHECK = "check";
const QString PF_UPDATE_FORCE = "force";

const QString PF_GROUP_WEB = "web";
const QString PF_WEB_URL = "url";
const QString PF_WEB_VER_LOG_URL = "version_log_url";
const QString PF_WEB_LOGIN_URL = "login_url";

const QString PF_WEB_LOGIN_PATH = "login_path";
const QString PF_WEB_VERSION_PATH = "version_path";
const QString PF_WEB_USER_PROFILES_PATH = "user_profiles_path";
const QString PF_WEB_CODE_PATH = "code_path";

/*VERSION*/
const QString VERSION_PATH = SETTINGS_DIR + "version.ini";
const QString VERSION = "version";

/*UI*/
const QString UI_SETTINGS_PATH = SETTINGS_DIR + "/interface.ini";

const QString UI_GROUP_SYS_TRAYMENU = "SystemTrayMenu";
const QString UI_TRAYMENU_KEY_TOP = "top";
const QString UI_TRAYMENU_KEY_LOCK = "lock";