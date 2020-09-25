#include "mainui\main\ui\MainUI.h"
#include "common/crash/Msjexhnd.h"
#include <QtWidgets/QApplication>


int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

	a.setQuitOnLastWindowClosed(true);

	//QDir::setCurrent(QCoreApplication::applicationDirPath()); //设置工作路径到程序目录，这样就可以使用相对路径了

	MSJExceptionHandler dmpHandle("Joy-PC");

	MainUI w;
    w.show();
    return a.exec();
}
