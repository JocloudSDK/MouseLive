#include "Setting.h"
#include <QFile>
#include <QCoreApplication>

Setting::Setting() {
}

Setting::~Setting() {
}

void Setting::setConfigPath(const QString& configPath) {
	_pSettings.reset(new QSettings(configPath, QSettings::IniFormat));
	_pSettings->sync();
}

void Setting::write(const QString &key, const QVariant &value) {
	_pSettings->setValue(key, value);
	_pSettings->sync();
}

QString Setting::readString(const QString &key) {
	return _pSettings->value(key).toString();
}

int Setting::readInt(const QString &key) {
	return _pSettings->value(key).toInt();
}
