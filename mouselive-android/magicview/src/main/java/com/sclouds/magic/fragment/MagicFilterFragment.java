package com.sclouds.magic.fragment;

import android.annotation.SuppressLint;
import android.view.MotionEvent;
import android.view.View;
import android.widget.SeekBar;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.sclouds.basedroid.LogUtils;
import com.sclouds.magic.R;
import com.sclouds.magic.adapter.MagicRecycleViewAdapter;
import com.sclouds.magic.bean.MagicEffect;
import com.sclouds.magic.config.MagicConfig;
import com.sclouds.magic.databinding.FilterDataBinding;
import com.sclouds.magic.helper.OrangeHelper;
import com.sclouds.magic.manager.MagicDataManager;

public class MagicFilterFragment extends MagicBaseFragment<FilterDataBinding>
        implements View.OnClickListener, View.OnTouchListener, SeekBar.OnSeekBarChangeListener, MagicRecycleViewAdapter.OnItemClickListener {

    private static final String TAG = "MagicFilterFragment";

    public MagicFilterFragment() {
        super();
        mMagicTypeEnum = MagicConfig.MagicTypeEnum.MAGIC_TYPE_FILTER;
    }

    @Override
    public int getLayoutResId() {
        return R.layout.layout_magic_filter;
    }

    @SuppressLint("ClickableViewAccessibility")
    @Override
    public void initView(View view) {
        mDataBinding.resetImageView.setOnClickListener(this);
        mDataBinding.originalImageView.setOnTouchListener(this);
        mDataBinding.progressSeekBar.setOnSeekBarChangeListener(this);

        LinearLayoutManager layoutManager = new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false);
        mDataBinding.recyclerView.setLayoutManager(layoutManager);
        mAdapter = new MagicRecycleViewAdapter(getContext(), mMagicTypeEnum.getValue());
        mAdapter.setOnItemClickListener(this);
        mAdapter.setEffectEnableListener(this);
        mDataBinding.recyclerView.setAdapter(mAdapter);
    }

    @Override
    public void initData() {
        LogUtils.d(TAG, "initData");
        mAdapter.setData(MagicDataManager.getInstance().getMagicEffectListByGroupType(MagicConfig.MagicTypeEnum.MAGIC_TYPE_FILTER.getType()));
        MagicEffect magicEffect = mAdapter.getSelectedData();
        if (null == magicEffect) {
            mDataBinding.progressSeekBar.setEnabled(false);
        } else {
            mDataBinding.progressSeekBar.setEnabled(true);
        }
        if ((null != magicEffect) && (magicEffect.isSelected())) {
            OrangeHelper.EffectParam effectPram = new OrangeHelper.EffectParam();
            if (OrangeHelper.getEffectParamDetail(getEffectParamType(mAdapter.getSelectedPosition()), effectPram)) {
                LogUtils.d(TAG, "initData: cur = "+ effectPram.curVal + ", min = " + effectPram.minVal + ", max = " + effectPram.maxVal);
                int progress = 100 * (effectPram.curVal - effectPram.minVal) / (effectPram.maxVal - effectPram.minVal);
                LogUtils.d(TAG, "initData: progress = " + progress);
                mDataBinding.progressSeekBar.setProgress(progress);
                mDataBinding.valueTextView.setText(String.valueOf(effectPram.curVal));
            }
        }
        initShowName();
    }

    private void initShowName() {
        String[] showNameArray = getResources().getStringArray(R.array.magic_view_filter_show_name_array);
        if (mAdapter.getItemCount() != showNameArray.length) {
            LogUtils.e(TAG, "initShowName: count = " + mAdapter.getItemCount() + ", length = " + showNameArray.length);
            return;
        }
        for (int i = 0; i < mAdapter.getItemCount(); i++) {
            MagicEffect magicEffect = mAdapter.getDataAtPosition(i);
            if (null != magicEffect) {
                magicEffect.setShowName(showNameArray[i]);
            }
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
        if (id == R.id.resetImageView) {
            doResetFilter(null != mAdapter ? mAdapter.getSelectedPosition() : -1);
        } else {
            LogUtils.d(TAG, "onClick: nothing to do");
        }
    }

    private void doResetFilter(int position) {
        LogUtils.d(TAG, "doResetFilter: position = " + position);
        if (position < 0) {
            return;
        }
        OrangeHelper.EffectParam effectPram = new OrangeHelper.EffectParam();
        if (OrangeHelper.getEffectParamDetail(getEffectParamType(position), effectPram)) {
            LogUtils.d(TAG, "doResetFilter: def = "+ effectPram.defVal + ", min = " + effectPram.minVal + ", max = " + effectPram.maxVal);
            boolean result = OrangeHelper.setEffectParam(getEffectParamType(position), effectPram.defVal);
            LogUtils.d(TAG, "doWhitenReset: result = " + result);
            int progress = 100 * (effectPram.defVal - effectPram.minVal) / (effectPram.maxVal - effectPram.minVal);
            LogUtils.d(TAG, "doResetFilter: progress = " + progress);
            mDataBinding.progressSeekBar.setProgress(progress);
            mDataBinding.valueTextView.setText(String.valueOf(effectPram.defVal));
        }
    }

    public OrangeHelper.EffectType getEffectType(int position) {
        OrangeHelper.EffectType effectType;
        switch (position) {
            case 0:
                effectType = OrangeHelper.EffectType.ET_FilterHoliday;
                break;
            case 1:
                effectType = OrangeHelper.EffectType.ET_FilterClear;
                break;
            case 2:
                effectType = OrangeHelper.EffectType.ET_FilterWarm;
                break;
            case 3:
                effectType = OrangeHelper.EffectType.ET_FilterFresh;
                break;
            case 4:
                effectType = OrangeHelper.EffectType.ET_FilterTender;
                break;
            default:
                effectType = OrangeHelper.EffectType.ET_FilterHoliday;
                break;
        }
        LogUtils.d(TAG, "getEffectType: effectType = " + effectType.toString());
        return  effectType;
    }

    public OrangeHelper.EffectParamType getEffectParamType(int position) {
        OrangeHelper.EffectParamType effectParamType;
        switch (position) {
            case 0:
                effectParamType = OrangeHelper.EffectParamType.EP_FilterHolidayIntensity;
                break;
            case 1:
                effectParamType = OrangeHelper.EffectParamType.EP_FilterClearIntensity;
                break;
            case 2:
                effectParamType = OrangeHelper.EffectParamType.EP_FilterWarmIntensity;
                break;
            case 3:
                effectParamType = OrangeHelper.EffectParamType.EP_FilterFreshIntensity;
                break;
            case 4:
                effectParamType = OrangeHelper.EffectParamType.EP_FilterTenderIntensity;
                break;
            default:
                effectParamType = OrangeHelper.EffectParamType.EP_FilterHolidayIntensity;
                break;
        }
        LogUtils.d(TAG, "getEffectParamType: effectParamType = " + effectParamType.toString());
        return  effectParamType;
    }

    @SuppressLint("ClickableViewAccessibility")
    @Override
    public boolean onTouch(View v, MotionEvent event) {
        if ((null == mAdapter) || (mAdapter.getSelectedPosition() < 0)) {
            return false;
        }
        final int action = event.getAction() & MotionEvent.ACTION_MASK;
        switch (action) {
            case MotionEvent.ACTION_DOWN:
                enableEffect(mAdapter.getSelectedPosition(), false);
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                enableEffect(mAdapter.getSelectedPosition(), true);
                break;
            default:
                break;
        }
        return true;
    }

    @Override
    public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
        LogUtils.d(TAG, "onProgressChanged: id = " + seekBar.getId() + ", progress = " + progress + ", fromUser = " + fromUser);
        if ((null == mAdapter) || (mAdapter.getSelectedPosition() < 0)) {
            return;
        }
        OrangeHelper.EffectParam effectPram = new OrangeHelper.EffectParam();
        if (OrangeHelper.getEffectParamDetail(getEffectParamType(mAdapter.getSelectedPosition()), effectPram)) {
            LogUtils.d(TAG, "onStartTrackingTouch: min = " + effectPram.minVal + ", max = " + effectPram.maxVal);
            int curVal = progress * (effectPram.maxVal - effectPram.minVal) / 100 + effectPram.minVal;
            LogUtils.d(TAG, "onStartTrackingTouch: curVal = " + curVal);
            boolean result = OrangeHelper.setEffectParam(getEffectParamType(mAdapter.getSelectedPosition()), curVal);
            LogUtils.d(TAG, "onStartTrackingTouch: result = " + result);
            mDataBinding.valueTextView.setText(String.valueOf(curVal));
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

    @Override
    public void onItemClick(@NonNull View view, int position) {
        int id = view.getId();
        LogUtils.d(TAG, "onItemClick: id = " + id + ", position = " + position);
        if (null == mAdapter) {
            return;
        }
        MagicEffect magicEffect = mAdapter.getDataAtPosition(position);
        if (null == magicEffect) {
            return;
        }
        if (R.id.downloadImageView == id) {
            MagicDataManager.getInstance().loadEffectData(getContext(), mMagicTypeEnum.getType(), magicEffect);
            return;
        }
        if (!mDataBinding.progressSeekBar.isEnabled()) {
            mDataBinding.progressSeekBar.setEnabled(true);
        }
        boolean selected = magicEffect.isSelected();
        LogUtils.d(TAG, "onItemClick: selected = " + selected);
        if (!selected) {
            mAdapter.updateSelectedStatusAtPosition(position);
        }
    }

    private void enableEffect(int position, boolean enable) {
        LogUtils.d(TAG, "enableEffect: position = " + position + ", enable = " + enable);
        MagicEffect magicEffect = mAdapter.getDataAtPosition(position);
        if (null == magicEffect) {
            LogUtils.d(TAG, "enableEffect: magic effect is null");
            return;
        }
        if (!MagicEffect.DownloadStatus.DOWNLOADED.equals(magicEffect.getDownloadStatus())) {
            LogUtils.d(TAG, "enableEffect: effect data has not been downloaded");
            MagicDataManager.getInstance().loadEffectData(getContext(), mMagicTypeEnum.getType(), magicEffect);
            return;
        }
        boolean result = OrangeHelper.enableEffect(getEffectType(position), enable);
        LogUtils.d(TAG, "enableEffect: result = " + result);
        if (!enable || !result) {
            return;
        }
        OrangeHelper.EffectParam effectPram = new OrangeHelper.EffectParam();
        if (OrangeHelper.getEffectParamDetail(getEffectParamType(position), effectPram)) {
            LogUtils.d(TAG, "enableEffect: cur = "+ effectPram.curVal + ", min = " + effectPram.minVal + ", max = " + effectPram.maxVal);
            int progress = 100 * (effectPram.curVal - effectPram.minVal) / (effectPram.maxVal - effectPram.minVal);
            LogUtils.d(TAG, "enableEffect: progress = " + progress);
            mDataBinding.progressSeekBar.setProgress(progress);
            mDataBinding.valueTextView.setText(String.valueOf(effectPram.curVal));
        }
    }

    @Override
    public void onEffectEnable(int position, boolean enable) {
        if ((null == mAdapter) || (null == mAdapter.getData()) || (position < 0)) {
            return;
        }
        LogUtils.d(TAG, "onEffectEnable: position = " + position + ", enable = " + enable);
        enableEffect(position, enable);
    }

    @Override
    public void onEffectDownloaded(MagicEffect magicEffect) {
        if ((null == mAdapter) || (mAdapter.getSelectedPosition() < 0)) {
            return;
        }
        LogUtils.d(TAG, "onEffectDownloaded: name = " + magicEffect.getName());
        enableEffect(mAdapter.getSelectedPosition(), true);
    }

}
