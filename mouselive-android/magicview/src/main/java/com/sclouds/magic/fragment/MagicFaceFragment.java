package com.sclouds.magic.fragment;

import android.annotation.SuppressLint;
import android.view.MotionEvent;
import android.view.View;
import android.widget.SeekBar;

import androidx.annotation.NonNull;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.sclouds.basedroid.LogUtils;
import com.sclouds.magic.R;
import com.sclouds.magic.adapter.MagicRecycleViewAdapter;
import com.sclouds.magic.bean.MagicEffect;
import com.sclouds.magic.config.MagicConfig;
import com.sclouds.magic.databinding.FaceDataBinding;
import com.sclouds.magic.helper.OrangeHelper;
import com.sclouds.magic.manager.MagicDataManager;

import java.util.ArrayList;
import java.util.List;

public class MagicFaceFragment extends MagicBaseFragment<FaceDataBinding>
        implements View.OnFocusChangeListener, View.OnClickListener, View.OnTouchListener, SeekBar.OnSeekBarChangeListener, MagicRecycleViewAdapter.OnItemClickListener {

    private static final String TAG = "MagicFaceFragment";

    // true - 基础整形, false - 高级整形, 默认为基础整形
    private boolean isBasicOrAdvanced = true;

    private List<MagicEffect> mMagicEffectList = null;

    private ProgressBarStatus mProgressBarStatus = new ProgressBarStatus();

    public MagicFaceFragment() {
        super();
        mMagicTypeEnum = MagicConfig.MagicTypeEnum.MAGIC_TYPE_FACE;
    }

    @Override
    public int getLayoutResId() {
        return R.layout.layout_magic_face;
    }

    @SuppressLint("ClickableViewAccessibility")
    @Override
    public void initView(View view) {
        mDataBinding.basicButton.setOnFocusChangeListener(this);
        mDataBinding.advancedButton.setOnFocusChangeListener(this);
        mDataBinding.basicButton.setOnClickListener(this);
        mDataBinding.advancedButton.setOnClickListener(this);
        mDataBinding.faceResetImageView.setOnClickListener(this);
        mDataBinding.originalImageView.setOnTouchListener(this);
        mDataBinding.overallTextView.setOnClickListener(this);
        mDataBinding.faceSeekBar.setOnSeekBarChangeListener(this);

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
        mMagicEffectList = MagicDataManager.getInstance().getMagicEffectListByGroupType(mMagicTypeEnum.getType());
        if (mMagicEffectList.size() > 1) {
            // index 0 is basic face
            List<MagicEffect> advancedMagicEffectList = new ArrayList<>();
            for (int i = 1; i < mMagicEffectList.size(); i++) {
                advancedMagicEffectList.add(mMagicEffectList.get(i));
            }
            mAdapter.setData(advancedMagicEffectList);
        }
        if (0 == mMagicEffectList.size()) {
            return;
        }
        mDataBinding.faceSeekBar.setEnabled(false);
        if (mMagicEffectList.get(0).isSelected()) {
            OrangeHelper.EffectParam effectPram = new OrangeHelper.EffectParam();
            if (OrangeHelper.getEffectParamDetail(OrangeHelper.EffectParamType.EP_BasicTypeIntensity, effectPram)) {
                LogUtils.d(TAG, "initData: cur = "+ effectPram.curVal + ", min = " + effectPram.minVal + ", max = " + effectPram.maxVal);
                int progress = 100 * (effectPram.curVal - effectPram.minVal) / (effectPram.maxVal - effectPram.minVal);
                LogUtils.d(TAG, "initData: progress = " + progress);
                mProgressBarStatus.setBasicProgress(progress);
                mProgressBarStatus.setBasicValue(effectPram.curVal);
                mDataBinding.faceSeekBar.setProgress(mProgressBarStatus.getBasicProgress());
                mDataBinding.valueTextView.setText(String.valueOf(effectPram.curVal));
            }
            mDataBinding.basicButton.requestFocus();
        } else {
            MagicEffect magicEffect = mAdapter.getSelectedData();
            if (null != magicEffect) {
                mDataBinding.faceSeekBar.setEnabled(true);
            }
            if ((null != magicEffect) && (magicEffect.isSelected())) {
                OrangeHelper.EffectParam effectPram = new OrangeHelper.EffectParam();
                if (OrangeHelper.getEffectParamDetail(getEffectParamType(mAdapter.getSelectedPosition()), effectPram)) {
                    LogUtils.d(TAG, "initData: cur = "+ effectPram.curVal + ", min = " + effectPram.minVal + ", max = " + effectPram.maxVal);
                    int progress = 100 * (effectPram.curVal - effectPram.minVal) / (effectPram.maxVal - effectPram.minVal);
                    LogUtils.d(TAG, "initData: progress = " + progress);
                    mProgressBarStatus.setAdvancedProgress(progress);
                    mProgressBarStatus.setAdvancedValue(effectPram.curVal);
                    mDataBinding.faceSeekBar.setProgress(mProgressBarStatus.getBasicProgress());
                    mDataBinding.valueTextView.setText(String.valueOf(effectPram.curVal));
                }
            }
            mDataBinding.advancedButton.requestFocus();
        }
        initShowName();
    }

    private void initShowName() {
        String[] showNameArray = getResources().getStringArray(R.array.magic_view_advanced_show_name_array);
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
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);
        LogUtils.d(TAG, "setUserVisibleHint: isVisibleToUser = " + isVisibleToUser);
        if (!isVisibleToUser) {
            return;
        }
        if (null == mDataBinding) {
            LogUtils.d(TAG, "setUserVisibleHint: mDataBinding is null");
            return;
        }
        if (isBasicOrAdvanced) {
            mDataBinding.basicButton.requestFocus();
        } else {
            mDataBinding.advancedButton.requestFocus();
        }
    }

    @Override
    public void onFocusChange(View v, boolean hasFocus) {
        int id = v.getId();
        LogUtils.d(TAG, "onFocusChange: id = " + id + ", hasFocus = " + hasFocus);
        if (!hasFocus) {
            return;
        }
        if (id == R.id.basicButton) {
            doBasicSwitch();
        } else if (id == R.id.advancedButton) {
            doAdvancedSwitch();
        } else if (id == R.id.faceResetImageView) {
            doResetFace();
        } else {
            LogUtils.d(TAG, "onFocusChange: nothing to do");
        }
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        LogUtils.d(TAG, "onClick: id = " + id);
        if (id == R.id.basicButton) {
            doBasicSwitch();
        } else if (id == R.id.advancedButton) {
            doAdvancedSwitch();
        } else if (id == R.id.faceResetImageView) {
            doResetFace();
        } else {
            LogUtils.d(TAG, "onClick: nothing to do");
        }
    }

    private void doBasicSwitch() {
        isBasicOrAdvanced = true;
        mDataBinding.overallTextView.setVisibility(View.VISIBLE);
        mDataBinding.originalImageView.setVisibility(View.INVISIBLE);
        mDataBinding.originalTextView.setVisibility(View.INVISIBLE);
        mDataBinding.recyclerView.setVisibility(View.INVISIBLE);
        ConstraintLayout.LayoutParams lp = (ConstraintLayout.LayoutParams) mDataBinding.faceSeekBar.getLayoutParams();
        lp.leftMargin = 0;
        mDataBinding.faceSeekBar.setLayoutParams(lp);
        mDataBinding.faceSeekBar.setProgress(mProgressBarStatus.getBasicProgress());
        mDataBinding.valueTextView.setText(String.valueOf(mProgressBarStatus.getBasicValue()));
        boolean result = OrangeHelper.enableEffect(OrangeHelper.EffectType.ET_SeniorBeautyType, false);
        LogUtils.d(TAG, "doBasicSwitch: advanced disable result = " + result);
        result = OrangeHelper.enableEffect(OrangeHelper.EffectType.ET_BasicBeautyType, true);
        LogUtils.d(TAG, "doBasicSwitch: basic enable result = " + result);
        setBasicSelectedStatus(true);
        doBasicSeek(mProgressBarStatus.getBasicProgress());
    }

    private void doAdvancedSwitch() {
        isBasicOrAdvanced = false;
        mDataBinding.overallTextView.setVisibility(View.GONE);
        mDataBinding.originalImageView.setVisibility(View.VISIBLE);
        mDataBinding.originalTextView.setVisibility(View.VISIBLE);
        mDataBinding.recyclerView.setVisibility(View.VISIBLE);
        ConstraintLayout.LayoutParams lp = (ConstraintLayout.LayoutParams) mDataBinding.faceSeekBar.getLayoutParams();
        lp.leftMargin = (int) getResources().getDimension(R.dimen.magic_seekbar_magrin_left);
        mDataBinding.faceSeekBar.setLayoutParams(lp);
        mDataBinding.faceSeekBar.setProgress(mProgressBarStatus.getAdvancedProgress());
        mDataBinding.valueTextView.setText(String.valueOf(mProgressBarStatus.getAdvancedValue()));
        boolean result = OrangeHelper.enableEffect(OrangeHelper.EffectType.ET_BasicBeautyType, false);
        LogUtils.d(TAG, "doAdvancedSwitch: basic disable result = " + result);
        result = OrangeHelper.enableEffect(OrangeHelper.EffectType.ET_SeniorBeautyType, true);
        LogUtils.d(TAG, "doAdvancedSwitch: advanced enable result = " + result);
        setBasicSelectedStatus(false);
    }

    private void setBasicSelectedStatus(boolean selected) {
        LogUtils.d(TAG, "setBasicSelectedStatus: selected = " + selected);
        if ((null == mMagicEffectList) || (0 == mMagicEffectList.size())) {
            return;
        }
        mMagicEffectList.get(0).setSelected(selected);
    }

    private void doResetFace() {
        if (isBasicOrAdvanced) {
            doBasicReset();
        } else {
            doAdvancedReset();
        }
    }

    private void doBasicReset() {
        LogUtils.d(TAG, "doBasicReset");
        OrangeHelper.EffectParam effectPram = new OrangeHelper.EffectParam();
        if (OrangeHelper.getEffectParamDetail(OrangeHelper.EffectParamType.EP_BasicTypeIntensity, effectPram)) {
            LogUtils.d(TAG, "doBasicReset: def = "+ effectPram.defVal + ", min = " + effectPram.minVal + ", max = " + effectPram.maxVal);
            boolean result = OrangeHelper.setEffectParam(OrangeHelper.EffectParamType.EP_BasicTypeIntensity, MagicConfig.DEFAULT_BASIC_FACE_VALUE);
            LogUtils.d(TAG, "doWhitenReset: result = " + result);
            int progress = 100 * (MagicConfig.DEFAULT_BASIC_FACE_VALUE - effectPram.minVal) / (effectPram.maxVal - effectPram.minVal);
            LogUtils.d(TAG, "doBasicReset: progress = " + progress);
            mDataBinding.faceSeekBar.setProgress(progress);
            mProgressBarStatus.setBasicProgress(progress);
            mProgressBarStatus.setBasicValue(MagicConfig.DEFAULT_BASIC_FACE_VALUE);
            mDataBinding.valueTextView.setText(String.valueOf(MagicConfig.DEFAULT_BASIC_FACE_VALUE));
        }
    }

    private void doAdvancedReset() {
        if ((null == mAdapter) || (mAdapter.getSelectedPosition() < 0)) {
            return;
        }
        OrangeHelper.EffectParam effectPram = new OrangeHelper.EffectParam();
        OrangeHelper.EffectParamType effectParamType = getEffectParamType(mAdapter.getSelectedPosition());
        LogUtils.d(TAG, "doAdvancedReset: effectParamType = " + effectParamType.toString());
        if (OrangeHelper.getEffectParamDetail(effectParamType, effectPram)) {
            LogUtils.d(TAG, "doAdvancedReset: def = "+ effectPram.defVal + ", min = " + effectPram.minVal + ", max = " + effectPram.maxVal);
            int defVal = effectPram.defVal;
            if (OrangeHelper.EffectParamType.EP_SeniorTypeSmallFaceIntensity.equals(effectParamType)) {
                defVal = MagicConfig.DEFAULT_SMALL_FACE_VALUE;
            }
            if (OrangeHelper.EffectParamType.EP_SeniorTypeBigSmallEyeIntensity.equals(effectParamType)) {
                defVal = MagicConfig.DEFAULT_BIG_EYE_VALUE;
            }
            if (OrangeHelper.EffectParamType.EP_SeniorTypeThinNoseIntensity.equals(effectParamType)) {
                defVal = MagicConfig.DEFAULT_THIN_NOSE_VALUE;
            }
            LogUtils.d(TAG, "doAdvancedReset: defVal = " + defVal);
            boolean result = OrangeHelper.setEffectParam(effectParamType, defVal);
            LogUtils.d(TAG, "doAdvancedReset: result = " + result);
            int progress = 100 * (defVal - effectPram.minVal) / (effectPram.maxVal - effectPram.minVal);
            LogUtils.d(TAG, "doAdvancedReset: progress = " + progress);
            mDataBinding.faceSeekBar.setProgress(progress);
            mProgressBarStatus.setAdvancedProgress(progress);
            mProgressBarStatus.setAdvancedValue(defVal);
            mDataBinding.valueTextView.setText(String.valueOf(defVal));
        }
    }

    public OrangeHelper.EffectParamType getEffectParamType(int position) {
        OrangeHelper.EffectParamType effectParamType;
        switch (position) {
            case 0:
                effectParamType = OrangeHelper.EffectParamType.EP_SeniorTypeThinFaceIntensity;
                break;
            case 1:
                effectParamType = OrangeHelper.EffectParamType.EP_SeniorTypeSmallFaceIntensity;
                break;
            case 2:
                effectParamType = OrangeHelper.EffectParamType.EP_SeniorTypeSquashedFaceIntensity;
                break;
            case 3:
                effectParamType = OrangeHelper.EffectParamType.EP_SeniorTypeForeheadLiftingIntensity;
                break;
            case 4:
                effectParamType = OrangeHelper.EffectParamType.EP_SeniorTypeWideForeheadIntensity;
                break;
            case 5:
                effectParamType = OrangeHelper.EffectParamType.EP_SeniorTypeBigSmallEyeIntensity;
                break;
            case 6:
                effectParamType = OrangeHelper.EffectParamType.EP_SeniorTypeEyesOffsetIntensity;
                break;
            case 7:
                effectParamType = OrangeHelper.EffectParamType.EP_SeniorTypeEyesRotationIntensity;
                break;
            case 8:
                effectParamType = OrangeHelper.EffectParamType.EP_SeniorTypeThinNoseIntensity;
                break;
            case 9:
                effectParamType = OrangeHelper.EffectParamType.EP_SeniorTypeLongNoseIntensity;
                break;
            case 10:
                effectParamType = OrangeHelper.EffectParamType.EP_SeniorTypeThinNoseBridgeIntensity;
                break;
            case 11:
                effectParamType = OrangeHelper.EffectParamType.EP_SeniorTypeThinmouthIntensity;
                break;
            case 12:
                effectParamType = OrangeHelper.EffectParamType.EP_SeniorTypeMovemouthIntensity;
                break;
            case 13:
                effectParamType = OrangeHelper.EffectParamType.EP_SeniorTypeChinLiftingIntensity;
                break;
            default:
                effectParamType = OrangeHelper.EffectParamType.EP_SeniorTypeThinFaceIntensity;
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
        if (isBasicOrAdvanced) {
            doBasicSeek(seekBar.getProgress());
        } else {
            doAdvancedSeek(seekBar.getProgress());
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

    private void doBasicSeek(int progress) {
        LogUtils.d(TAG, "doBasicSeek: progress = " + progress);
        if (null == mAdapter) {
            return;
        }
        OrangeHelper.EffectParam effectPram = new OrangeHelper.EffectParam();
        if (OrangeHelper.getEffectParamDetail(OrangeHelper.EffectParamType.EP_BasicTypeIntensity, effectPram)) {
            LogUtils.d(TAG, "doBasicSeek: min = " + effectPram.minVal + ", max = " + effectPram.maxVal);
            int curVal = progress * (effectPram.maxVal - effectPram.minVal) / 100 + effectPram.minVal;
            LogUtils.d(TAG, "doBasicSeek: curVal = " + curVal);
            boolean result = OrangeHelper.setEffectParam(OrangeHelper.EffectParamType.EP_BasicTypeIntensity, curVal);
            LogUtils.d(TAG, "doBasicSeek: result = " + result);
            mProgressBarStatus.setBasicProgress(progress);
            mProgressBarStatus.setBasicValue(curVal);
            mDataBinding.valueTextView.setText(String.valueOf(curVal));
        }
    }

    private void doAdvancedSeek(int progress) {
        LogUtils.d(TAG, "doAdvancedSeek: progress = " + progress);
        if ((null == mAdapter) || (mAdapter.getSelectedPosition() < 0)) {
            return;
        }
        OrangeHelper.EffectParam effectPram = new OrangeHelper.EffectParam();
        if (OrangeHelper.getEffectParamDetail(getEffectParamType(mAdapter.getSelectedPosition()), effectPram)) {
            LogUtils.d(TAG, "doAdvancedSeek: min = " + effectPram.minVal + ", max = " + effectPram.maxVal);
            int curVal = progress * (effectPram.maxVal - effectPram.minVal) / 100 + effectPram.minVal;
            LogUtils.d(TAG, "doAdvancedSeek: curVal = " + curVal);
            boolean result = OrangeHelper.setEffectParam(getEffectParamType(mAdapter.getSelectedPosition()), curVal);
            LogUtils.d(TAG, "doAdvancedSeek: result = " + result);
            mProgressBarStatus.setAdvancedProgress(progress);
            mProgressBarStatus.setAdvancedValue(curVal);
            mDataBinding.valueTextView.setText(String.valueOf(curVal));
        }
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
        if (!mDataBinding.faceSeekBar.isEnabled()) {
            mDataBinding.faceSeekBar.setEnabled(true);
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
        boolean result = OrangeHelper.enableEffect(OrangeHelper.EffectType.ET_SeniorBeautyType, enable);
        LogUtils.d(TAG, "enableEffect: result = " + result);
        if (!enable || !result) {
            return;
        }
        OrangeHelper.EffectParam effectPram = new OrangeHelper.EffectParam();
        if (OrangeHelper.getEffectParamDetail(getEffectParamType(position), effectPram)) {
            LogUtils.d(TAG, "enableEffect: cur = "+ effectPram.curVal + ", min = " + effectPram.minVal + ", max = " + effectPram.maxVal);
            int progress = 100 * (effectPram.curVal - effectPram.minVal) / (effectPram.maxVal - effectPram.minVal);
            LogUtils.d(TAG, "enableEffect: progress = " + progress);
            mProgressBarStatus.setAdvancedProgress(progress);
            mDataBinding.faceSeekBar.setProgress(progress);
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

    private static class ProgressBarStatus {

        private int mBasicProgress = MagicConfig.DEFAULT_BASIC_FACE_VALUE;
        private int mBasicValue = 0;
        private int mAdvancedProgress = 0;
        private int mAdvancedValue = 0;

        public ProgressBarStatus() {

        }

        public int getBasicProgress() {
            return mBasicProgress;
        }

        public void setBasicProgress(int basicProgress) {
            this.mBasicProgress = basicProgress;
        }

        public int getBasicValue() {
            return mBasicValue;
        }

        public void setBasicValue(int basicValue) {
            this.mBasicValue = basicValue;
        }

        public int getAdvancedProgress() {
            return mAdvancedProgress;
        }

        public void setAdvancedProgress(int advancedProgress) {
            this.mAdvancedProgress = advancedProgress;
        }

        public int getAdvancedValue() {
            return mAdvancedValue;
        }

        public void setAdvancedValue(int advancedValue) {
            this.mAdvancedValue = advancedValue;
        }

    }

}
