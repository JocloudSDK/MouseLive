package com.sclouds.datasource.thunder.mode;

import com.thunder.livesdk.ThunderEngine;
import com.thunder.livesdk.ThunderRtcConstant;

/**
 * @author xipeitao
 * @description: 本意是接管thunder的所有配置操作，可以由业务保存。改变不同的参数会直接作用到thunder
 * @date : 2020/4/26 4:15 PM
 */
public abstract class ThunderConfig {

    private ThunderEngine mThunderEngine;

    protected boolean enableLoudspeaker = true;



    /**
     * @return 媒体模式：纯音频或音视频 {@link ThunderRtcConstant.ThunderRtcProfile
     *      *                                         THUNDER_PROFILE_DEFAULT = 0; =1 音视频模式
     *      *                                         THUNDER_PROFILE_NORMAL = 1; 音视频模式
     *      *                                         THUNDER_PROFILE_ONLY_AUDIO = 2; 纯音频模式}
     */
    public abstract int getMediaMode();

    public boolean isAudio(){
        return getMediaMode() == ThunderRtcConstant.ThunderRtcProfile.THUNDER_PROFILE_ONLY_AUDIO;
    }

    /**
     *
     * @return 房间模式 {@link ThunderRtcConstant.RoomConfig
     *      *                          THUNDER_ROOMCONFIG_LIVE = 直播模式（流畅）
     *      *                          THUNDER_ROOMCONFIG_COMMUNICATION = 通话模式（延时低）
     *      *                          THUNDER_ROOMCONFIG_GAME = 游戏（省流量、延时低）}
     *
     */
    public abstract int getRoomMode();

    public abstract int getAudioConfig();

    public abstract int getScenarioMode();

    public abstract int getCommutMode();



    public void setEngine(ThunderEngine thunderEngine) {
        mThunderEngine = thunderEngine;
        // mThunderEngine.enableLoudspeaker(enableLoudspeaker);
    }
}
