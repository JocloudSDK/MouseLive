#include "WebSocketClient.h"
#include <QDebug>
#include "../log/loggerExt.h"

using namespace base;

static const char* TAG = "WebSocketClientManager";

WebSocketClientManager::WebSocketClientManager(QObject *parent)
	: QObject(parent),
	_running(false),
	_pWebSocket(0),
	_connected(false) {
}

WebSocketClientManager::~WebSocketClientManager() {
	if (_pWebSocket != 0) {
		_pWebSocket->deleteLater();
		_pWebSocket = 0;
	}
}

bool WebSocketClientManager::running() const {
	return _running;
}

void WebSocketClientManager::slot_start() {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));
	if (_running) {
		Logw(TAG, Log(__FUNCTION__).setMessage("Failed, it's already running... exit"));
		return;
	}

	if (!_pWebSocket) {
		_pWebSocket = new QWebSocket();
		connect(_pWebSocket, SIGNAL(connected()), this, SLOT(slot_connected()));
		connect(_pWebSocket, SIGNAL(disconnected()), this, SLOT(slot_disconnected()));
		connect(_pWebSocket, SIGNAL(error(QAbstractSocket::SocketError)),
			this, SLOT(slot_error(QAbstractSocket::SocketError)));
		connect(_pWebSocket, SIGNAL(textFrameReceived(QString, bool)),
			this, SLOT(slot_textFrameReceived(QString, bool)));
		connect(_pWebSocket, SIGNAL(textMessageReceived(QString)),
			this, SLOT(slot_textMessageReceived(QString)));
		connect(_pWebSocket, SIGNAL(pong(quint64, const QByteArray)),
			this, SLOT(slot_pong(quint64, const QByteArray)));
	}
	_running = true;
	Logd(TAG, Log(__FUNCTION__).setMessage("exit"));
}

void WebSocketClientManager::slot_stop() {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry"));
	if (!_running) {
		Logw(TAG, Log(__FUNCTION__).setMessage("Failed, it's not running... exit"));
		return;
	}
	_running = false;
	_pWebSocket->close();
	Logd(TAG, Log(__FUNCTION__).setMessage("exit"));
}

void WebSocketClientManager::slot_connectedTo(const QString& url) {
	Logd(TAG, Log(__FUNCTION__).setMessage("entry").addDetail("url", url.toStdString()));
	if (!_running) {
		Logw(TAG, Log(__FUNCTION__).setMessage("Failed, it's not running... exit"));
		return;
	}
	_pWebSocket->open(QUrl(url));
	Logd(TAG, Log(__FUNCTION__).setMessage("exit"));
}

void WebSocketClientManager::slot_sendTextMessage(const QString &message) {
	if (!_running) {
		Logw(TAG, Log(__FUNCTION__).setMessage("Failed, it's not running... exit"));
		return;
	}
	bool result = true;
	_pWebSocket->sendTextMessage(message);
	emit signal_sendTextMessageResult(result);
}

void WebSocketClientManager::slot_sendBinaryMessage(const QByteArray &data) {
	if (!_running) {
		Logw(TAG, Log(__FUNCTION__).setMessage("Failed, it's not running... exit"));
		return;
	}
	bool result = true;
	_pWebSocket->sendBinaryMessage(data);
	emit signal_sendBinaryMessageResult(result);
}

void WebSocketClientManager::slot_connected() {
	_connected = true;
	Logd(TAG, Log(__FUNCTION__).setMessage("connected"));
	emit signal_connected();
}

void WebSocketClientManager::slot_disconnected() {
	_connected = false;
	Logd(TAG, Log(__FUNCTION__).setMessage("disconnected"));
	emit signal_disconnected();
}

void WebSocketClientManager::slot_error(QAbstractSocket::SocketError error) {
	Logd(TAG, Log(__FUNCTION__).setMessage("error:%s", _pWebSocket->errorString()));
	emit signal_error(_pWebSocket->errorString());
}

void WebSocketClientManager::slot_textFrameReceived(const QString &frame, bool isLastFrame) {
	emit signal_textFrameReceived(frame, isLastFrame);
}

void WebSocketClientManager::slot_textMessageReceived(const QString &message) {
	emit signal_textMessageReceived(message);
}

void WebSocketClientManager::slot_pong(quint64 elapsedTime, const QByteArray &payload) {
	if (_pWebSocket) {
		_pWebSocket->ping();
	}
}
