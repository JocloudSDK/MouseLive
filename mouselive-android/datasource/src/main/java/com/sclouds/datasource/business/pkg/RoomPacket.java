package com.sclouds.datasource.business.pkg;

/**
 * @author xipeitao
 * @description:
 * @date : 2020-03-17 12:21
 */
public class RoomPacket extends BasePacket<RoomPacket.Body> {

    public RoomPacket(long appId,String traceId, int msgId, long uid, long rid, long chatid) {
        super(msgId);
        Body = new Body(appId,traceId, uid, rid, chatid);
    }

    public class Body {
        public long AppId;
        public String TraceId;
        public String MsgName;
        long Uid;
        long LiveRoomId;
        long ChatRoomId;
        public String Code;

        public Body(long appId, String traceId, long uid, long liveRoomId, long chatRoomId) {
            AppId = appId;
            TraceId = traceId;
            Uid = uid;
            LiveRoomId = liveRoomId;
            ChatRoomId = chatRoomId;
        }

        public long getUid() {
            return Uid;
        }

        public void setUid(long uid) {
            Uid = uid;
        }

        public void setLiveRoomId(long liveRoomId) {
            LiveRoomId = liveRoomId;
        }

        public void setChatRoomId(long chatRoomId) {
            ChatRoomId = chatRoomId;
        }

        public long getLiveRoomId() {
            return LiveRoomId;
        }

        public long getChatRoomId() {
            return ChatRoomId;
        }

        @Override
        public String toString() {
            return "Body{" +
                    "AppId='" + AppId + '\'' +
                    ", TraceId='" + TraceId + '\'' +
                    ", MsgName='" + MsgName + '\'' +
                    ", Uid=" + Uid +
                    ", LiveRoomId=" + LiveRoomId +
                    ", ChatRoomId=" + ChatRoomId +
                    ", Code='" + Code + '\'' +
                    '}';
        }
    }

    public boolean isAck() {
        return "ack".equalsIgnoreCase(Body.Code);
    }

    @Override
    public String toString() {
        return "RoomPacket{" +
                "MsgId=" + MsgId +
                ", Body=" + Body +
                '}';
    }
}
