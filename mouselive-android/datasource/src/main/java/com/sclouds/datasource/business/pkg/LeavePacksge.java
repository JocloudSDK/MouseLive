package com.sclouds.datasource.business.pkg;

/**
 * @author xipeitao
 * @description:
 * @date : 2020/5/12 11:29 AM
 */
public class LeavePacksge extends BasePacket<LeavePacksge.LeaveInfo> {

    public LeavePacksge(LeaveInfo info) {
        super(BasePacket.EV_CS_LEAVE_ROOM_NTY);
        Body = info;
    }

    public static class LeaveInfo {
        public long AppId;
        public String TraceId;
        public long Uid;
        public long LiveRoomId;
        public long ChatRoomId;

        public LeaveInfo(long appId, String traceId, long uid, long liveRoomId, long chatRoomId) {
            AppId = appId;
            TraceId = traceId;
            Uid = uid;
            LiveRoomId = liveRoomId;
            ChatRoomId = chatRoomId;
        }

        @Override
        public String toString() {
            return "LeaveInfo{" +
                    "AppId=" + AppId +
                    ", TraceId='" + TraceId + '\'' +
                    ", Uid=" + Uid +
                    ", LiveRoomId=" + LiveRoomId +
                    ", ChatRoomId=" + ChatRoomId +
                    '}';
        }
    }

    @Override
    public String toString() {
        return "LeavePacksge{" +
                "MsgId=" + MsgId +
                ", Body=" + Body +
                '}';
    }
}
