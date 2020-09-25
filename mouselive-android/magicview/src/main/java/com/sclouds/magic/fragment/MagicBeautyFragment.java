package com.sclouds.magic.fragment;

import android.annotation.SuppressLint;
import android.view.View;
import android.widget.SeekBar;

import com.sclouds.basedroid.LogUtils;
import com.sclouds.magic.R;
import com.sclouds.magic.bean.MagicEffect;
import com.sclouds.magic.config.MagicConfig;
import com.sclouds.magic.databinding.BeautyDataBinding;
import com.sclouds.magic.helper.OrangeHelper;

public class MagicBeautyFragment extends MagicBaseFragment<BeautyDataBinding>
        implements View.OnClickListener, SeekBar.OnSeekBarChangeListener {

    private static final String TAG = "MagicBeautyFragment";

    public MagicBeautyFragment() {
        super();
        mMagicTypeEnum = MagicConfig.MagicTypeEnum.MAGIC_TYPE_SKIN;
    }

    @Override
    public int getLayoutResId() {
        return R.layout.layout_magic_beauty;
    }

    @SuppressLint("ClickableViewAccessibility")
    @Override
    public void initView(View view) {
        mDataBinding.smoothenResetImageView.setOnClickListener(this);
        mDataBinding.whitenResetImageView.setOnClickListener(this);
        mDataBinding.smoothenSeekBar.setOnSeekBarChangeListener(this);
        mDataBinding.whitenSeekBar.setOnSeekBarChangeListener(this);
    }

    @Override
    public void initData() {
        LogUtils.d(TAG, "initData");
        initSmoothenData();
        initWhitenData();
    }

    private void initSmoothenData() {
        OrangeHelper.EffectParam effectPram = new OrangeHelper.EffectParam();
        if (OrangeHelper.getEffectParamDetail(OrangeHelper.EffectParamType.EP_BasicBeautyOpacity, effectPram)) {
            LogUtils.d(TAG, "initSmoothenData: cur = " + effectPram.curVal + ", min = " + effectPram.minVal + ", max = " + effectPram.maxVal);
            int progress = 100 * (effectPram.curVal - effectPram.minVal) / (effectPram.maxVal - effectPram.minVal);
            LogUtils.d(TAG, "initSmoothenData: progress = " + progress);
            mDataBinding.smoothenSeekBar.setProgress(progress);
            mDataBinding.smoothenValueTextView.setText(String.valueOf(effectPram.curVal));
        }
    }

    private void initWhitenData() {
        OrangeHelper.EffectParam effectPram = new OrangeHelper.EffectParam();
        if (OrangeHelper.getEffectParamDetail(OrangeHelper.EffectParamType.EP_BasicBeautyIntensity, effectPram)) {
            LogUtils.d(TAG, "initWhitenData: cur = " + effectPram.curVal + ", min = " + effectPram.minVal + ", max = " + effectPram.maxVal);
            int progress = 100 * (effectPram.curVal - effectPram.minVal) / (effectPram.maxVal - effectPram.minVal);
            LogUtils.d(TAG, "initWhitenData: progress = " + progress);
            mDataBinding.whitenSeekBar.setProgress(progress);
            mDataBinding.whitenValueTextView.setText(String.valueOf(effectPram.curVal));
        }
    }

    @Override
    public void onDestroyView() {
        LogUtils.d(TAG, "onDestroyView");
        super.onDestroyView();
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        LogUtils.d(TAG, "onClick: id = " + id);
        if (id == R.id.smoothenResetImageView) {
            doSmoothReset();
        } else if (id == R.id.whitenResetImageView) {
            doWhitenReset();
        } else {
            LogUtils.d(TAG, "onClick: nothing to do");
        }
    }

    private void doSmoothReset() {
        LogUtils.d(TAG, "odoSmoothReset");
        OrangeHelper.EffectParam effectPram = new OrangeHelper.EffectParam();
        if (OrangeHelper.getEffectParamDetail(OrangeHelper.EffectParamType.EP_BasicBeautyOpacity, effectPram)) {
            LogUtils.d(TAG, "doSmoothReset: min = " + effectPram.minVal + ", max = " + effectPram.maxVal);
            boolean result = OrangeHelper.setEffectParam(OrangeHelper.EffectParamType.EP_BasicBeautyOpacity, MagicConfig.DEFAULT_SMOOTHEN_VALUE);
            LogUtils.d(TAG, "doSmoothReset: result = " + result);
            int progress = 100 * (MagicConfig.DEFAULT_SMOOTHEN_VALUE - effectPram.minVal) / (effectPram.maxVal - effectPram.minVal);
            LogUtils.d(TAG, "doSmoothReset: progress = " + progress);
            mDataBinding.smoothenSeekBar.setProgress(progress);
            mDataBinding.smoothenValueTextView.setText(String.valueOf(MagicConfig.DEFAULT_WHITEN_VALUE));
        }
    }

    private void doWhitenReset() {
        LogUtils.d(TAG, "doWhitenReset");
        OrangeHelper.EffectParam effectPram = new OrangeHelper.EffectParam();
        if (OrangeHelper.getEffectParamDetail(OrangeHelper.EffectParamType.EP_BasicBeautyIntensity, effectPram)) {
            LogUtils.d(TAG, "doWhitenReset: min = " + effectPram.minVal + ", max = " + effectPram.maxVal);
            boolean result = OrangeHelper.setEffectParam(OrangeHelper.EffectParamType.EP_BasicBeautyIntensity, MagicConfig.DEFAULT_WHITEN_VALUE);
            LogUtils.d(TAG, "doWhitenReset: result = " + result);
            int progress = 100 * (MagicConfig.DEFAULT_WHITEN_VALUE - effectPram.minVal) / (effectPram.maxVal - effectPram.minVal);
            LogUtils.d(TAG, "doWhitenReset: progress = " + progress);
            mDataBinding.whitenSeekBar.setProgress(progress);
            mDataBinding.whitenValueTextView.setText(String.valueOf(MagicConfig.DEFAULT_WHITEN_VALUE));
        }
    }

    @Override
    public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
        LogUtils.d(TAG, "onProgressChanged: id = " + seekBar.getId() + ", progress = " + progress + ", fromUser = " + fromUser);
        int id = seekBar.getId();
        if (R.id.smoothenSeekBar == id) {
            doSmoothSeek(seekBar.getProgress());
        } else if (R.id.whitenSeekBar == id) {
            doWhitenSeek(seekBar.getProgress());
        } else {
            LogUtils.d(TAG, "onStopTrackingTouch: nothing to do");
        }
    }

    @Override
    public void onStartTrackingTouch(SeekBar seekBar) {
        LogUtils.d(TAG, "onStartTrackingTouch: progress = " + seekBar.getProgress());
    }

    @Override
    public void onStopTrackingTouch(SeekBar seekBar) {
        LogUtils.d(TAG, "onStopTrackingTouch: progress = " + seekBar.getProgress());
    }

    private void doSmoothSeek(int progress) {
        LogUtils.d(TAG, "doSmoothSeek: progress = " + progress);
        OrangeHelper.EffectParam effectPram = new OrangeHelper.EffectParam();
        if (OrangeHelper.getEffectParamDetail(OrangeHelper.EffectParamType.EP_BasicBeautyOpacity, effectPram)) {
            LogUtils.d(TAG, "doSmoothSeek: min = " + effectPram.minVal + ", max = " + effectPram.maxVal);
            int curVal = progress * (effectPram.maxVal - effectPram.minVal) / 100 + effectPram.minVal;
            LogUtils.d(TAG, "doSmoothSeek: curVal = " + curVal);
            boolean result = OrangeHelper.setEffectParam(OrangeHelper.EffectParamType.EP_BasicBeautyOpacity, curVal);
            LogUtils.d(TAG, "doSmoothSeek: result = " + result);
            mDataBinding.smoothenValueTextView.setText(String.valueOf(curVal));
        }
    }

    private void doWhitenSeek(int progress) {
        LogUtils.d(TAG, "doWhitenSeek: progress = " + progress);
        OrangeHelper.EffectParam effectPram = new OrangeHelper.EffectParam();
        if (OrangeHelper.getEffectParamDetail(OrangeHelper.EffectParamType.EP_BasicBeautyIntensity, effectPram)) {
            LogUtils.d(TAG, "doWhitenSeek: min = " + effectPram.minVal + ", max = " + effectPram.maxVal);
            int curVal = progress * (effectPram.maxVal - effectPram.minVal) / 100 + effectPram.minVal;
            LogUtils.d(TAG, "doWhitenSeek: curVal = " + curVal);
            boolean result = OrangeHelper.setEffectParam(OrangeHelper.EffectParamType.EP_BasicBeautyIntensity, curVal);
            LogUtils.d(TAG, "doWhitenSeek: result = " + result);
            mDataBinding.whitenValueTextView.setText(String.valueOf(curVal));
        }
    }

    @Override
    public void onEffectEnable(int position, boolean enable) {
        LogUtils.d(TAG, "onEffectEnable: position = " + position + ", enable = " + enable);
    }

    @Override
    public void onEffectDownloaded(MagicEffect magicEffect) {
        LogUtils.d(TAG, "onEffectDownloaded: name = " + magicEffect.getName());
    }

}
