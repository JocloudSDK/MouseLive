package com.sclouds.mouselive.bean;

import com.sclouds.datasource.bean.User;

/**
 * @author xipeitao
 * @description:
 * @date : 2020-01-17 16:26
 */
public class FakeMessage {

    private User user;
    private String msg;
    private MessageType messageType;

    public enum MessageType {
        Join, Msg, Notice, Top
    }

    public FakeMessage(String msg, MessageType messageType) {
        this.msg = msg;
        this.messageType = messageType;
    }

    public FakeMessage(User user, String msg, MessageType messageType) {
        this.user = user;
        this.msg = msg;
        this.messageType = messageType;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    public MessageType getMessageType() {
        return messageType;
    }

    public void setMessageType(MessageType messageType) {
        this.messageType = messageType;
    }
}
