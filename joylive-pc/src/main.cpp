#include "mainui\main\ui\MainUI.h"
#include "common/crash/Msjexhnd.h"
#include <QtWidgets/QApplication>


int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

	a.setQuitOnLastWindowClosed(true);

	//QDir::setCurrent(QCoreApplication::applicationDirPath()); //���ù���·��������Ŀ¼�������Ϳ���ʹ�����·����

	MSJExceptionHandler dmpHandle("Joy-PC");

	MainUI w;
    w.show();
    return a.exec();
}
