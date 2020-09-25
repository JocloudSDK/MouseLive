package com.sclouds.datasource.business.pkg;

import com.google.gson.Gson;

public class BasePacket<T> {

    public static final int EV_CS_BASE = -1;

    public static final int EV_SC_ERRNO_BGN         = 10000;
    public static final int EV_SC_ERRNO_PARSER_JSON = 10101;

    // =====================用户A（进入房间，离开房间）的单播，组播{{=====================
    // 用户告知服务器，进入一个房间的通知, // 服务器应答用户，进入一个房间
    public static final int EV_CS_ENTER_ROOM_NTY = 201;

    // 服务器发出组播，用户进入一个房间的通知
    public static final int EV_SCC_ENTER_ROOM_NTY = 203;

    // 用户告知服务器，退出一个房间的通知, // 服务器应答用户，进入一个房间
    public static final int EV_CS_LEAVE_ROOM_NTY = 205;

    // 服务器发出组播，用户离开一个房间的通知
    public static final int EV_SCC_LEAVE_ROOM_NTY = 208;
    // =====================用户A进入房间的单播，组播}}=====================

    // =====================用户A请求和用户B连麦的单播，组播{{=====================
    // A/B用户发单播，告知服务器，向B/A用户连麦通知（A->B：请求、取消、B->A：接受、拒绝，A/B：挂断）
    public static final int EV_CC_CHAT_REQ    = 301; // A-->B发起连麦请求
    public static final int EV_CC_CHAT_CANCEL = 302; // A-->B取消连麦请求
    public static final int EV_CC_CHAT_ACCEPT = 303; // B-->A接受连麦请求
    public static final int EV_CC_CHAT_REJECT = 304; // B-->A拒绝连麦请求
    public static final int EV_CC_CHAT_HANGUP = 305; // A/B挂断连麦

    public static final int EV_SC_CHAT_LIMIT = 320; // A/B挂断连麦

    // 服务器发出组播，用户A和用户B连麦状态（聊天中、聊天结束）
    public static final int EV_SCC_CHATING     = 306;
    public static final int EV_SCC_CHAT_HANGUP = 308;

    // 语聊房：用户A-->服务器-->用户B，房主A闭麦用户B
    public static final int EV_CC_MIC_ENABLE = 401;

    // 服务器发出组播，用户A被闭麦了
    public static final int EV_SCC_MIC_ENABLE = 402;

    // =====================用户A请求和用户B连麦的单播，组播}}=====================
    // ## 0.5s心跳包，连续3次没有收到心跳认为断开了。{nobody:}
    public static final int EV_CS_HEARTBEAT = 500;
    public static final int EV_SC_HEARTBEAT = 501;
    //=====================event, msg}}========================================

    private static final String TAG = BasePacket.class.getSimpleName();
    public int MsgId = EV_CS_BASE;

    public T Body;
    protected static Gson gson = new Gson();

    public BasePacket(int MsgId) {
        this.MsgId = MsgId;
    }

    public String encode() {
        String rlt = gson.toJson(this);
        return rlt;
    }

    public void setMsgId(int msgId) {
        MsgId = msgId;
    }

    public boolean isError(){
        return MsgId >=10000;
    }

    public static <T extends BasePacket> T decode(String msg, Class<T> tClass) {
        return gson.fromJson(msg, tClass);
    }
}
