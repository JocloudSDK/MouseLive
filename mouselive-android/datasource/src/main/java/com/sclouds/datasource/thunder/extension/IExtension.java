package com.sclouds.datasource.thunder.extension;

import com.thunder.livesdk.ThunderEngine;

/**
 * @author xipeitao
 * @description:   thunder各个能力封装
 * @date : 2020/4/26 3:24 PM
 */
public interface IExtension {

    void onCreate(ThunderEngine thunderEngine);

    int getThunderRtcProfile();

    void onDestory();
}
