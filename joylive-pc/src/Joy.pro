QT       += core gui
 
greaterThan(QT_MAJOR_VERSION, 4): QT += widgets websockets network


CONFIG += c++11

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    common/crash/CCrashStack.cpp \
    common/crash/Msjexhnd.cpp \
    common/download/Download.cpp \
    common/download/DownloadAvator.cpp \
    common/download/DownloadImpl.cpp \
    common/http/HttpClient.cpp \
    common/json2/RapidjsonHelper.cpp \
    common/log/log.cpp \
    common/log/logger.cpp \
    common/qss/QssLoad.cpp \
    common/setting/Setting.cpp \
    common/status/Status.cpp \
    common/taskQueue/TaskQueue.cpp \
    common/taskQueue/Work.cpp \
    common/thread/thread.cpp \
    common/thunder/ThunderManager.cpp \
    common/timer/Timer.cpp \
    common/translate/Translate.cpp \
    common/utils/String.cpp \
    common/websocket/CCService.cpp \
    common/websocket/CSWSService.cpp \
    common/websocket/Invite/LiveBeInvited.cpp \
    common/websocket/Invite/LiveInvite.cpp \
    common/websocket/LiveManager.cpp \
    common/websocket/WSService.cpp \
    common/websocket/WebSocketClient.cpp \
    main.cpp \
    mainui/baseui/MessageBoxNormalUI.cpp \
    mainui/baseui/MessageBoxPKUI.cpp \
    mainui/baseui/QPixmapUtil.cpp \
    mainui/living/logic/LivingHttpLogic.cpp \
    mainui/living/ui/AnchorCellUI.cpp \
    mainui/living/ui/BeautyUI.cpp \
    mainui/living/ui/ClientEquipmentUI.cpp \
    mainui/living/ui/LivingDialogUI.cpp \
    mainui/living/ui/ThunderMeetUI.cpp \
    mainui/living/ui/UserCellUI.cpp \
    mainui/living/ui/beauty/BeautyCellUI.cpp \
    mainui/living/ui/beauty/MeifuUI.cpp \
    mainui/living/ui/beauty/ShoushiUI.cpp \
    mainui/living/ui/beauty/TiezhiUI.cpp \
    mainui/living/ui/beauty/WuguanUI.cpp \
	mainui/living/ui/beauty/LvjingUI.cpp \
    mainui/main/logic/MainHttpLogic.cpp \
    mainui/main/ui/MainUI.cpp \
    mainui/main/ui/RoomInfoCellUI.cpp \
    mainui/sdk/beauty/BeautyManager.cpp \
    mainui/sdk/beauty/GLRuntimeEnvironment.cpp \
    mainui/sdk/beauty/OrangeFilterRender.cpp \
    mainui/sdk/beauty/OrangeHelper.cpp \
    mainui/sdk/beauty/UEvent.cpp \
    mainui/sdk/beauty/pathutils.cpp \
    mainui/sdk/chatroom/ChatRoomManager.cpp \
    mainui/sdk/thunderbolt/MediaManager.cpp

HEADERS += \
	../3rd/Hummer/include/Hummer/ChatRoomConstants.h \
	../3rd/Hummer/include/Hummer/ChatRoomService.h \
	../3rd/Hummer/include/Hummer/Constants.h \
	../3rd/Hummer/include/Hummer/ContentSignal.h \
	../3rd/Hummer/include/Hummer/ContentText.h \
	../3rd/Hummer/include/Hummer/Core.h \
	../3rd/Hummer/include/Hummer/Hummer.h \
	../3rd/Hummer/include/Hummer/MessageService.h \
	../3rd/Thunderbolt/include/IThunderEngine.h \
	../3rd/Thunderbolt/include/ThunderEngineDefine.h \
	../depends/dwinternal/orangefilterpub2013/include/GL/eglew.h \
	../depends/dwinternal/orangefilterpub2013/include/GL/glew.h \
	../depends/dwinternal/orangefilterpub2013/include/GL/glxew.h \
	../depends/dwinternal/orangefilterpub2013/include/GL/wglew.h \
	../depends/dwinternal/orangefilterpub2013/include/orangefilter.h \
	../depends/dwinternal/orangefilterpub2013/include/orangefilter_win.h \
	common/download/Download.h \
	common/download/DownloadAvator.h \
	common/download/DownloadImpl.h \
	common/http/HttpClient.h \
	common/json2/RapidjsonHelper.h \
	common/json2/rapidjson/allocators.h \
	common/json2/rapidjson/cursorstreamwrapper.h \
	common/json2/rapidjson/document.h \
	common/json2/rapidjson/encodedstream.h \
	common/json2/rapidjson/encodings.h \
	common/json2/rapidjson/error/en.h \
	common/json2/rapidjson/error/error.h \
	common/json2/rapidjson/filereadstream.h \
	common/json2/rapidjson/filewritestream.h \
	common/json2/rapidjson/fwd.h \
	common/json2/rapidjson/internal/biginteger.h \
	common/json2/rapidjson/internal/clzll.h \
	common/json2/rapidjson/internal/diyfp.h \
	common/json2/rapidjson/internal/dtoa.h \
	common/json2/rapidjson/internal/ieee754.h \
	common/json2/rapidjson/internal/itoa.h \
	common/json2/rapidjson/internal/meta.h \
	common/json2/rapidjson/internal/pow10.h \
	common/json2/rapidjson/internal/regex.h \
	common/json2/rapidjson/internal/stack.h \
	common/json2/rapidjson/internal/strfunc.h \
	common/json2/rapidjson/internal/strtod.h \
	common/json2/rapidjson/internal/swap.h \
	common/json2/rapidjson/istreamwrapper.h \
	common/json2/rapidjson/memorybuffer.h \
	common/json2/rapidjson/memorystream.h \
	common/json2/rapidjson/msinttypes/inttypes.h \
	common/json2/rapidjson/msinttypes/stdint.h \
	common/json2/rapidjson/ostreamwrapper.h \
	common/json2/rapidjson/pointer.h \
	common/json2/rapidjson/prettywriter.h \
	common/json2/rapidjson/rapidjson.h \
	common/json2/rapidjson/reader.h \
	common/json2/rapidjson/schema.h \
	common/json2/rapidjson/stream.h \
	common/json2/rapidjson/stringbuffer.h \
	common/json2/rapidjson/writer.h \
	common/log/log.h \
	common/log/loggerExt.h \
	common/qss/QssLoad.h \
	common/setting/Setting.h \
	common/status/Status.h \
	common/taskQueue/Task.h \
	common/taskQueue/TaskQueue.h \
	common/taskQueue/Thread.h \
	common/taskQueue/Work.h \
	common/thread/thread.h \
	common/thunder/ThunderManager.h \
	common/timer/Timer.h \
	common/translate/Translate.h \
	common/utils/Settings.h \
	common/utils/Singleton.h \
	common/utils/String.h \
	common/websocket/CCService.h \
	common/websocket/CSWSService.h \
	common/websocket/Invite/LiveBeInvited.h \
	common/websocket/Invite/LiveInvite.h \
	common/websocket/Invite/LiveInviteItem.h \
	common/websocket/LiveManager.h \
	common/websocket/LiveManagerObserver.h \
	common/websocket/WSModel.h \
	common/websocket/WSService.h \
	common/websocket/WebSocketClient.h \
	common\crash\CCrashStack.h \
	common\crash\Msjexhnd.h \
	mainui/AppInfo.h \
	mainui/Constans.h \
	mainui/LogicModel.h \
	mainui/RoomInfo.h \
	mainui/UserInfo.h \
	mainui/baseui/MessageBoxNormalUI.h \
	mainui/baseui/MessageBoxPKUI.h \
	mainui/baseui/QPixmapUtil.h \
	mainui/living/logic/LivingHttpLogic.h \
	mainui/living/ui/AnchorCellUI.h \
	mainui/living/ui/BeautyUI.h \
	mainui/living/ui/ClientEquipmentUI.h \
	mainui/living/ui/LivingDialogUI.h \
	mainui/living/ui/ThunderMeetUI.h \
	mainui/living/ui/UserCellUI.h \
	mainui/living/ui/beauty/BeautyCellUI.h \
	mainui/living/ui/beauty/MeifuUI.h \
	mainui/living/ui/beauty/ShoushiUI.h \
	mainui/living/ui/beauty/TiezhiUI.h \
	mainui/living/ui/beauty/WuguanUI.h \
	mainui/living/ui/beauty/LvjingUI.h \
	mainui/main/logic/MainHttpLogic.h \
	mainui/main/ui/MainUI.h \
	mainui/main/ui/RoomInfoCellUI.h \
	mainui/sdk/beauty/BeautyManager.h \
	mainui/sdk/beauty/CSLock.h \
	mainui/sdk/beauty/GLRuntimeEnvironment.h \
	mainui/sdk/beauty/OrangeFilterRender.h \
	mainui/sdk/beauty/OrangeHelper.h \
	mainui/sdk/beauty/UEvent.h \
	mainui/sdk/beauty/pathutils.h \
	mainui/sdk/chatroom/ChatRoomManager.h \
	mainui/sdk/thunderbolt/MediaManager.h

FORMS += \
    ui/BeautyCellUI.ui \
    ui/BeautyUI.ui \
    ui/MeifuUI.ui \
    ui/ShoushiUI.ui \
    ui/TiezhiUI.ui \
    ui/WuguanUI.ui \
    ui/AnchorCellUI.ui \
	ui/ClientEquipmentUI.ui \
	ui/LivingUI.ui \
	ui/MainUI.ui \
	ui/MessageBoxNormalUI.ui \
	ui/MessageBoxPKUI.ui \
	ui/NoEquipmentUI.ui \
	ui/RoomInfoCellUI.ui \
	ui/lvjingUI.ui \
	ui/UserCellUI.ui

TRANSLATIONS += \
    language\zh.ts \
	language\en.ts

RESOURCES += \
	joy.qrc
	
RC_FILE += \
	joy.rc

INCLUDEPATH += \
	../3rd/Hummer/include \
	../3rd/Thunderbolt/include \
	../depends/dwinternal/orangefilterpub2013/include
	

LIBS += -lGdi32 -lopengl32 -L../3rd/Hummer/lib/Release_x86/ -lHummer -L../3rd/Thunderbolt/lib/x86/ -lthunderbolt -L../depends/dwinternal/orangefilterpub2013/lib/Release/x86/ -lglew32 -lof_effect
	
QMAKE_CXXFLAGS_RELEASE -= -Zc:strictStrings
QMAKE_CFLAGS_RELEASE -= -Zc:strictStrings
QMAKE_CFLAGS -= -Zc:strictStrings
QMAKE_CXXFLAGS -= -Zc:strictStrings
	
# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    common/.gitkeep \
    common/hummer/.gitkeep \
    common/thunder/.gitkeep \
    mainui/baseui/.gitkeep \
    mainui/living/.gitkeep \
    mainui/living/logic/.gitkeep \
    mainui/living/ui/.gitkeep \
    mainui/main/logic/.gitkeep
