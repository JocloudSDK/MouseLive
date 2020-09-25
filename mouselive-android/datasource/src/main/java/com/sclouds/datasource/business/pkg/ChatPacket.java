package com.sclouds.datasource.business.pkg;

/**
 * @author xipeitao
 * @description:
 * @date : 2020-03-17 13:53
 */
public class ChatPacket extends BasePacket<ChatPacket.ChatInfo> {

    public ChatPacket(long appId,String traceId,String msgName,int MsgId, long srcUid, long srcRid,
                      long dstUid, long dstRid, int chatType) {
        super(MsgId);
        Body = new ChatInfo(appId,traceId,srcUid, srcRid, dstUid, dstRid, chatType);
    }

    public class ChatInfo {
        public long AppId;
        public String TraceId;
        public String MsgName;
        public long SrcUid;
        public long SrcRoomId;
        public long DestUid;
        public long DestRoomId;
        public int ChatType;
        public String Code;

        public ChatInfo(long appId, String traceId, long srcUid, long srcRoomId, long destUid,
                        long destRoomId, int chatType) {
            AppId = appId;
            TraceId = traceId;
            SrcUid = srcUid;
            SrcRoomId = srcRoomId;
            DestUid = destUid;
            DestRoomId = destRoomId;
            ChatType = chatType;
        }

        @Override
        public String toString() {
            return "ChatInfo{" +
                    "AppId='" + AppId + '\'' +
                    ", TraceId='" + TraceId + '\'' +
                    ", MsgName='" + MsgName + '\'' +
                    ", SrcUid=" + SrcUid +
                    ", SrcRoomId=" + SrcRoomId +
                    ", DestUid=" + DestUid +
                    ", DestRoomId=" + DestRoomId +
                    ", ChatType=" + ChatType +
                    ", Code='" + Code + '\'' +
                    '}';
        }
    }

    public ChatPacket swapUser(){
        ChatInfo old = Body;
        Body = new ChatInfo(old.AppId,old.TraceId,old.DestUid, old.DestRoomId, old.SrcUid,
                old.SrcRoomId,
                old.ChatType);
        return this;
    }

    public boolean isAck(){
        return "ack".equalsIgnoreCase(Body.Code);
    }

    @Override
    public String toString() {
        return "ChatPacket{" +
                "MsgId=" + MsgId +
                ", Body=" + Body +
                '}';
    }
}
