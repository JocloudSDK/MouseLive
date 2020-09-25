#include "Translate.h"
#include "../../common/log/loggerExt.h"
#include <QCoreApplication>
#include "../setting/Setting.h"
#include "../../mainui/Constans.h"

using namespace base;

static const char* TAG = "Translator";

static const QString g_Language[Translator::LanguageType::MAX] = {
	"zh", "en"
};

Translator::Translator() {
	_pTranslator.reset(new QTranslator);
}

Translator::~Translator() {
}

bool Translator::reloadLanguage(LanguageType l) {
	Logd(TAG, Log(__FUNCTION__).addDetail("LanguageType", std::to_string(l)).setMessage("entry"));
	if (l > LanguageType::MAX) {
		Logw(TAG, Log(__FUNCTION__).setMessage("exit return false"));
		return false;
	}

	QString language = g_Language[l];
	QString s = QString(":/joy/language/%1.qm").arg(language);
	auto ret = _pTranslator->load(s);
	if (ret) {
		ret = QCoreApplication::installTranslator(_pTranslator.get());
		Setting::GetInstance()->write(STR_CONFIG_LANGUAGE, l);
	}
	Logd(TAG, Log(__FUNCTION__).addDetail("ret", std::to_string(ret)).setMessage("exit"));
	return ret;
}
