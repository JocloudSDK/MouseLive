package com.sclouds.magic.fragment;

import android.annotation.SuppressLint;
import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.sclouds.basedroid.LogUtils;
import com.sclouds.magic.R;
import com.sclouds.magic.adapter.MagicRecycleViewAdapter;
import com.sclouds.magic.bean.MagicEffect;
import com.sclouds.magic.config.MagicConfig;
import com.sclouds.magic.databinding.GestureDataBinding;
import com.sclouds.magic.helper.OrangeHelper;
import com.sclouds.magic.manager.MagicDataManager;

import java.util.List;

public class MagicGestureFragment extends MagicBaseFragment<GestureDataBinding> implements MagicRecycleViewAdapter.OnItemClickListener {

    private static final String TAG = "MagicGestureFragment";

    public MagicGestureFragment() {
        super();
        mMagicTypeEnum = MagicConfig.MagicTypeEnum.MAGIC_TYPE_GESTURE;
    }

    @Override
    public int getLayoutResId() {
        return R.layout.layout_magic_gesture;
    }

    @SuppressLint("ClickableViewAccessibility")
    @Override
    public void initView(View view) {
        GridLayoutManager layoutManager = new GridLayoutManager(getContext(), MagicConfig.MAGIC_GRID_LAYOUT_SPAN_COUNT, RecyclerView.VERTICAL, false);
        mDataBinding.recyclerView.setLayoutManager(layoutManager);
        mAdapter = new MagicRecycleViewAdapter(getContext(), mMagicTypeEnum.getValue());
        mAdapter.setOnItemClickListener(this);
        mAdapter.setEffectEnableListener(this);
        mDataBinding.recyclerView.setAdapter(mAdapter);
    }

    @Override
    public void initData() {
        Log.d(TAG, "initData");
        mAdapter.setData(MagicDataManager.getInstance().getMagicEffectListByGroupType(mMagicTypeEnum.getType()));
    }

    @Override
    public void onDestroyView() {
        LogUtils.d(TAG, "onDestroyView");
        super.onDestroyView();
    }

    @Override
    public void onItemClick(@NonNull View view, int position) {
        int id = view.getId();
        Log.d(TAG, "onItemClick: id = " + id + ", position = " + position);
        if (null == mAdapter) {
            return;
        }
        if (0 == position) {
            // 点击关闭 Item 时关闭所有当前选中效果
            List<MagicEffect> magicEffectList = mAdapter.getData();
            for (int i = 1; i < magicEffectList.size(); i++) {
                // 0 为关闭 Item
                MagicEffect effect = magicEffectList.get(i);
                if (effect.isSelected()) {
                    boolean result = OrangeHelper.enableGesture(effect.getPath(), false);
                    LogUtils.d(TAG, "onEffectEnable: " + effect.getName() + " result = " + result);
                    mAdapter.updateSelectedStatusAtPosition(i);
                }
            }
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
        boolean selected = magicEffect.isSelected();
        LogUtils.d(TAG, "onItemClick: selected = " + selected);
        mAdapter.updateSelectedStatusAtPosition(position);
    }

    @Override
    public void onEffectEnable(int position, boolean enable) {
        if ((null == mAdapter) || (null == mAdapter.getData()) || (position < 0)) {
            return;
        }
        LogUtils.d(TAG, "onEffectEnable: position = " + position + ", enable = " + enable);
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
        boolean result = OrangeHelper.enableGesture(magicEffect.getPath(), enable);
        LogUtils.d(TAG, "onEffectEnable: result = " + result);
    }

    @Override
    public void onEffectDownloaded(MagicEffect magicEffect) {
        if ((null == mAdapter) || (null == mAdapter.getData())) {
            return;
        }
        LogUtils.d(TAG, "onEffectDownloaded: name = " + magicEffect.getName());
        List<MagicEffect> magicEffectList = mAdapter.getData();
        for (MagicEffect effect : magicEffectList) {
            if (effect.isSelected() && effect.getName().equals(magicEffect.getName())) {
                boolean result = OrangeHelper.enableGesture(effect.getPath(), true);
                LogUtils.d(TAG, "onEffectDownloaded: result = " + result);
            }
        }
    }

}
