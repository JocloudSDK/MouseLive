package com.sclouds.datasource.thunder.mode;

import com.thunder.livesdk.ThunderRtcConstant;

/**
 * @author xipeitao
 * @description:
 * @date : 2020/4/26 4:27 PM
 */
public class KTVConfig extends ThunderConfig {
    @Override
    public int getMediaMode() {
        return ThunderRtcConstant.ThunderRtcProfile.THUNDER_PROFILE_DEFAULT;
    }

    @Override
    public int getRoomMode() {
        return ThunderRtcConstant.RoomConfig.THUNDER_ROOMCONFIG_LIVE;
    }

    @Override
    public int getAudioConfig() {
        return ThunderRtcConstant.AudioConfig.THUNDER_AUDIO_CONFIG_DEFAULT;
    }

    @Override
    public int getScenarioMode() {
        return ThunderRtcConstant.ScenarioMode.THUNDER_SCENARIO_MODE_DEFAULT;
    }

    @Override
    public int getCommutMode() {
        return ThunderRtcConstant.CommutMode.THUNDER_COMMUT_MODE_DEFAULT;
    }
}
