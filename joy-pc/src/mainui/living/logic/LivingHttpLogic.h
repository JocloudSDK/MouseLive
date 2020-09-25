#pragma once

#include "../../../common/http/HttpClient.h"
#include <QObject>
#include <QMutex>

class LivingHttpLogicObserver;
class LivingHttpLogic : public QObject {
	friend class LivingHttpLogicObserver;
	Q_OBJECT
public:
	explicit LivingHttpLogic(QObject* parent = nullptr);
	~LivingHttpLogic();

	int getAnchorList(const QString& body);
	int setChatId(const QString& body);
	int createRoom(const QString& body);

protected:
	void onFinish(const QString& url, const QString& body, int error);

signals:
	void onGetAnchorListSuccess(const QString& body);
	void onGetAnchorListFailed();
	void onSetChatIdSuccess(const QString& body);
	void onSetChatIdFailed();
	void onCreateRoomSuccess(const QString& body);
	void onCreateRoomFailed();

private:
	std::shared_ptr<LivingHttpLogicObserver> _pLivingHttpLogicObserver;
};
