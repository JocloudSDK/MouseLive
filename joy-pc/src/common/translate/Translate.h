#pragma once

#include <QTranslator>
#include <memory>
#include "../utils/Singleton.h"

class Translator : public Singleton<Translator> {
protected:
	friend class Singleton<Translator>;
	Translator();
	~Translator();

public:
	enum LanguageType {
		ZH = 0,
		EN,
		MAX,
	};

public:
	bool reloadLanguage(LanguageType l);

private:
	std::shared_ptr<QTranslator> _pTranslator;
};

