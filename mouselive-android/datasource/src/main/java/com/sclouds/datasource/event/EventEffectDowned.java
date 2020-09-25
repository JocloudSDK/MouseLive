package com.sclouds.datasource.event;

import com.sclouds.datasource.bean.Effect;

import androidx.annotation.NonNull;

/**
 * Effect资源下载完成后触发通知
 *
 * @author Aslan chenhengfei@yy.com
 * @date 2020/04/26
 */
public class EventEffectDowned {
    @NonNull
    private Effect mEffect;

    public EventEffectDowned(@NonNull Effect mEffect) {
        this.mEffect = mEffect;
    }

    @NonNull
    public Effect getEffect() {
        return mEffect;
    }

    public void setEffect(@NonNull Effect effect) {
        mEffect = effect;
    }
}
