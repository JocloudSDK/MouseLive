package com.sclouds.datasource.hummer.listener;

import com.hummer.im.model.chat.Message;

/**
 * @author xipeitao
 * @description: 用于区分hummer的聊天消息和信令消息
 * @date : 2020-04-15 10:33
 */
public interface IMessageListener {

    /**
     * 聊天消息
     * @param message
     */
    void onMessageTxt(Message message);

    /**
     * 信令消息
     * @param singnal
     */
    void onSignle(Message singnal);
}
