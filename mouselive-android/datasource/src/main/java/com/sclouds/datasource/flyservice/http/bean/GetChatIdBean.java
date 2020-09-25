package com.sclouds.datasource.flyservice.http.bean;

import java.io.Serializable;

/**
 * @author xipeitao
 * @description:
 * @date : 2020-03-09 15:19
 */
public class GetChatIdBean implements Serializable {
    private long RChatId;

    public long getRChatId() {
        return RChatId;
    }

    public void setRChatId(long RChatId) {
        this.RChatId = RChatId;
    }
}
