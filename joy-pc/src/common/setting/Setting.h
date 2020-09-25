#pragma once
#include <QString>
#include <QSettings>
#include <memory>

#include "../utils/Singleton.h"

class Setting : public Singleton<Setting> {
protected:
	friend class Singleton<Setting>;
	Setting();
	~Setting();

public:
	void setConfigPath(const QString& configPath);
	void write(const QString &key, const QVariant &value);
	QString readString(const QString &key);
	int readInt(const QString &key);

private:
	std::shared_ptr<QSettings> _pSettings;
};