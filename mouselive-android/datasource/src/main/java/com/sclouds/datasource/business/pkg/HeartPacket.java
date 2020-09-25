package com.sclouds.datasource.business.pkg;

/**
 * @author xipeitao
 * @description:
 * @date : 2020-03-16 16:01
 */
public class HeartPacket extends BasePacket<String> {

    public HeartPacket() {
        super(BasePacket.EV_CS_HEARTBEAT);
        Body = "ok";
    }
}
