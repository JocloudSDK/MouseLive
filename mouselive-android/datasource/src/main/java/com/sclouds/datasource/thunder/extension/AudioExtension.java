package com.sclouds.datasource.thunder.extension;

import com.thunder.livesdk.ThunderEngine;

/**
 * @author xipeitao
 * @description:
 * @date : 2020/4/26 4:08 PM
 */
public class AudioExtension implements IExtension{
    @Override
    public void onCreate(ThunderEngine thunderEngine) {

    }

    @Override
    public int getThunderRtcProfile() {
        return 0;
    }

    @Override
    public void onDestory() {

    }
}
