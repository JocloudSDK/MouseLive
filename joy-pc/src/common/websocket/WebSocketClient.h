#ifndef WEBSOCKETCLIENTMANAGER_H
#define WEBSOCKETCLIENTMANAGER_H

/************************************************************\
* �ؼ����ƣ� WebSocket�ͻ��˹�����
* �ؼ�������
*          1.������QTcpServer����
* ���ߣ���ģ��    ��ϵ��ʽ��QQ21497936
* ���͵�ַ��https://blog.csdn.net/qq21497936
*       ����             �汾         ����
*   2019��09��04��      v1.0.0      ��������
\************************************************************/

#include <QObject>
#include <QWebSocket>

class WebSocketClientManager : public QObject
{
	Q_OBJECT
public:
	explicit WebSocketClientManager(QObject *parent = nullptr);
	~WebSocketClientManager();

public:
	bool running() const;
	bool connected() const { return _connected; }

signals:
	void signal_connected();
	void signal_disconnected();
	void signal_sendTextMessageResult(bool result);
	void signal_sendBinaryMessageResult(bool result);
	void signal_error(QString errorString);
	void signal_textFrameReceived(QString frame, bool isLastFrame);
	void signal_textMessageReceived(QString message);

public slots:
	void slot_start();
	void slot_stop();
	void slot_connectedTo(const QString& url);
	void slot_sendTextMessage(const QString &message);
	void slot_sendBinaryMessage(const QByteArray &data);

protected slots:
	void slot_connected();
	void slot_disconnected();
	void slot_error(QAbstractSocket::SocketError error);
	void slot_textFrameReceived(const QString &frame, bool isLastFrame);
	void slot_textMessageReceived(const QString &message);
	void slot_pong(quint64 elapsedTime, const QByteArray &payload);

private:
	bool _running;
	QString _url;
	bool _connected;
	QWebSocket *_pWebSocket;
};

#endif // WEBSOCKETCLIENTMANAGER_H