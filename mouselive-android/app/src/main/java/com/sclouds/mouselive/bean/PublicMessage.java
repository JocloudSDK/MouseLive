package com.sclouds.mouselive.bean;

/**
 * 聊天室消息体
 *
 * @author Aslan chenhengfei@yy.com
 * @date 2020/3/24
 */
public class PublicMessage {

    private String NickName;
    private String Uid;
    private String message;
    private FakeMessage.MessageType type;

    public PublicMessage(String nickName, String uid, String message,
                         FakeMessage.MessageType type) {
        NickName = nickName;
        Uid = uid;
        this.message = message;
        this.type = type;
    }

    public String getNickName() {
        return NickName;
    }

    public void setNickName(String nickName) {
        NickName = nickName;
    }

    public String getUid() {
        return Uid;
    }

    public void setUid(String uid) {
        Uid = uid;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public FakeMessage.MessageType getType() {
        return type;
    }

    public void setType(FakeMessage.MessageType type) {
        this.type = type;
    }

    @Override
    public String toString() {
        return "PublicMessage{" +
                "NickName='" + NickName + '\'' +
                ", Uid=" + Uid +
                ", message='" + message + '\'' +
                ", type=" + type +
                '}';
    }
}
