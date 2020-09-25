package com.sclouds.datasource.business.pkg;

/**
 * @author xipeitao
 * @description:
 * @date : 2020-03-17 13:53
 */
public class ChatLimitPacket extends BasePacket<ChatLimitPacket.ChatLimitInfo> {

    public ChatLimitPacket(long appId,int MsgId, String traceId, int maxLinkNum) {
        super(MsgId);
        Body = new ChatLimitInfo(appId,traceId,maxLinkNum);
    }

    public class ChatLimitInfo {
        public long AppId;
        public String TraceId;
        public String MsgName;
        public int MaxLinkNum;

        public ChatLimitInfo(long appId, String traceId, int maxLinkNum) {
            AppId = appId;
            TraceId = traceId;
            MaxLinkNum = maxLinkNum;
        }

        @Override
        public String toString() {
            return "ChatLimitInfo{" +
                    "AppId='" + AppId + '\'' +
                    ", TraceId='" + TraceId + '\'' +
                    ", MsgName='" + MsgName + '\'' +
                    ", MaxLinkNum=" + MaxLinkNum +
                    '}';
        }
    }

    @Override
    public String toString() {
        return "ChatPacket{" +
                "MsgId=" + MsgId +
                ", Body=" + Body +
                '}';
    }
}
