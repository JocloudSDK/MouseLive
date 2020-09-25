package com.sclouds.datasource.business.pkg;

/**
 * @author xipeitao
 * @description:
 * @date : 2020-03-17 13:53
 */
public class MicPacket extends BasePacket<MicPacket.MicInfo> {

    public MicPacket(long appId,String traceId, int MsgId, long srcUid, long srcRid, long dstUid,
                     long dstRid,
                     int chatType,boolean enable) {
        super(MsgId);
        Body = new MicInfo(appId,traceId,srcUid, srcRid,dstUid,dstRid, chatType,enable);
    }

    public class MicInfo {
        public long AppId;
        public String TraceId;
        public String MsgName;
        public long SrcUid;
        public long SrcRoomId;
        public long DestUid;
        public long DestRoomId;
        public int ChatType;
        public boolean MicEnable;
        public String Code;

        public MicInfo(long appId, String traceId, long srcUid, long srcRoomId, long destUid,
                       long destRoomId, int chatType, boolean micEnable) {
            AppId = appId;
            TraceId = traceId;
            SrcUid = srcUid;
            SrcRoomId = srcRoomId;
            DestUid = destUid;
            DestRoomId = destRoomId;
            ChatType = chatType;
            MicEnable = micEnable;
        }

        @Override
        public String toString() {
            return "MicInfo{" +
                    "AppId='" + AppId + '\'' +
                    ", TraceId='" + TraceId + '\'' +
                    ", MsgName='" + MsgName + '\'' +
                    ", SrcUid=" + SrcUid +
                    ", SrcRoomId=" + SrcRoomId +
                    ", DestUid=" + DestUid +
                    ", DestRoomId=" + DestRoomId +
                    ", ChatType=" + ChatType +
                    ", MicEnable=" + MicEnable +
                    ", Code='" + Code + '\'' +
                    '}';
        }
    }



    public boolean isAck(){
        return "ack".equalsIgnoreCase(Body.Code);
    }

    @Override
    public String toString() {
        return "MicPacket{" +
                "MsgId=" + MsgId +
                ", Body=" + Body +
                '}';
    }
}
