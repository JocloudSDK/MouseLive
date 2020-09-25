package com.sclouds.datasource.flyservice.funws.listener;

import com.sclouds.datasource.business.pkg.ChatPacket;
import com.sclouds.datasource.business.pkg.MicPacket;
import com.sclouds.datasource.business.pkg.RoomPacket;

/**
 * @author xipeitao
 * @description:
 * @date : 2020-03-17 14:11
 */
public interface WSRoomListener {
    /**
     * 作为主播收到连麦申请的回调
     *
     * @param chatPkg
     */
    void onChatRev(ChatPacket chatPkg);

    /**
     * 作为主播收到连麦申请被取消的回调
     *
     * @param chatPkg
     */
    void onChatCanel(ChatPacket chatPkg);

    /**
     * 作为连麦方收到连麦断开的回调
     *
     * @param chatPkg
     */
    void onChatHangup(ChatPacket chatPkg);

    /**
     * 作为观众方收到连麦断开的回调
     *
     * @param chatPkg
     */
    void onMuiltCastChatHangup(ChatPacket chatPkg);

    /**
     * 作为观众方收到连麦开始的回调
     *
     * @param chatPkg
     */
    void onMuiltCastChating(ChatPacket chatPkg);

    /**
     * 有用户加入房间的回调
     *
     * @param chatPkg
     */
    void onUserEnterRoom(RoomPacket chatPkg);

    /**
     * 有用户离开房间的回调
     *
     * @param roomPkg
     */
    void onUserLeaveRoom(RoomPacket roomPkg);

    /**
     * 链接状态变化的回调
     *
     * @param state {@link com.sclouds.datasource.flyservice.funws.FunWSSvc.ConnectState}
     */
    void onConnectStateChanged(int state);

    /**
     * 用户被禁麦和取消禁麦的广播
     *
     * @param micPkg
     */
    void onUserMicEnable(MicPacket micPkg);

    /**
     * 服务器错误信息回调
     * @param msgId
     * @param code
     */
    void onSeverErr(int msgId, String code);
}
