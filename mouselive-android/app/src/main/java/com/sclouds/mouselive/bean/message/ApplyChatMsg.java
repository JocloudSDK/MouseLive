package com.sclouds.mouselive.bean.message;

public class ApplyChatMsg {

    /**
     * roomId : 789
     * chatType : 1
     * operatorUserInfo : {"Uid":123,"NickName":"中文昵称","Cover":"https://static.moschat.com/useravatar/useravatar_3400001301_1533018457901.jpeg"}
     * operatedUserInfo : {"Uid":456,"NickName":"中文昵称","Cover":"https://static.moschat.com/useravatar/useravatar_3400001301_1533018457901.jpeg"}
     */

    private String roomId;
    private int chatType;
    private OperatorUserInfoBean operatorUserInfo;
    private OperatedUserInfoBean operatedUserInfo;

    public String getRoomId() {
        return roomId;
    }

    public void setRoomId(String roomId) {
        this.roomId = roomId;
    }

    public int getChatType() {
        return chatType;
    }

    public void setChatType(int chatType) {
        this.chatType = chatType;
    }

    public OperatorUserInfoBean getOperatorUserInfo() {
        return operatorUserInfo;
    }

    public void setOperatorUserInfo(OperatorUserInfoBean operatorUserInfo) {
        this.operatorUserInfo = operatorUserInfo;
    }

    public OperatedUserInfoBean getOperatedUserInfo() {
        return operatedUserInfo;
    }

    public void setOperatedUserInfo(OperatedUserInfoBean operatedUserInfo) {
        this.operatedUserInfo = operatedUserInfo;
    }

    public static class OperatorUserInfoBean {
        /**
         * Uid : 123
         * NickName : 中文昵称
         * Cover : https://static.moschat.com/useravatar/useravatar_3400001301_1533018457901.jpeg
         */

        private Long uid;
        private String nickName;
        private String photoUrl;

        public Long getUid() {
            return uid;
        }

        public void setUid(Long uid) {
            this.uid = uid;
        }

        public String getNickName() {
            return nickName;
        }

        public void setNickName(String nickName) {
            this.nickName = nickName;
        }

        public String getPhotoUrl() {
            return photoUrl;
        }

        public void setPhotoUrl(String photoUrl) {
            this.photoUrl = photoUrl;
        }
    }

    public static class OperatedUserInfoBean {
        /**
         * Uid : 456
         * NickName : 中文昵称
         * Cover : https://static.moschat.com/useravatar/useravatar_3400001301_1533018457901.jpeg
         */

        private Long uid;
        private String nickName;
        private String photoUrl;

        public Long getUid() {
            return uid;
        }

        public void setUid(Long uid) {
            this.uid = uid;
        }

        public String getNickName() {
            return nickName;
        }

        public void setNickName(String nickName) {
            this.nickName = nickName;
        }

        public String getPhotoUrl() {
            return photoUrl;
        }

        public void setPhotoUrl(String photoUrl) {
            this.photoUrl = photoUrl;
        }
    }
}
