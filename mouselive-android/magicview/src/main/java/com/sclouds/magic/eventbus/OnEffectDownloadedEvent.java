package com.sclouds.magic.eventbus;

import androidx.annotation.NonNull;

import com.sclouds.magic.bean.MagicEffect;

/**
 * 美颜资源数据包下载完成通知消息
 *
 */
public class OnEffectDownloadedEvent {
    @NonNull
    private MagicEffect mMagicEffect;

    @NonNull
    private String mGroupType;

    public OnEffectDownloadedEvent(@NonNull MagicEffect magicEffect, @NonNull String groupType) {
        this.mMagicEffect = magicEffect;
        this.mGroupType = groupType;
    }

    @NonNull
    public MagicEffect getEffect() {
        return mMagicEffect;
    }

    public void setEffect(@NonNull MagicEffect magicEffect) {
        this.mMagicEffect = magicEffect;
    }

    @NonNull
    public String getGroupType() {
        return mGroupType;
    }

    public void setGroupType(@NonNull String groupType) {
        this.mGroupType = groupType;
    }

}
