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
import com.sclouds.magic.databinding.StickerDataBinding;
import com.sclouds.magic.helper.OrangeHelper;
import com.sclouds.magic.manager.MagicDataManager;

public class MagicStickerFragment extends MagicBaseFragment<StickerDataBinding> implements MagicRecycleViewAdapter.OnItemClickListener {

    private static final String TAG = "MagicStickerFragment";

    public MagicStickerFragment() {
        super();
        mMagicTypeEnum = MagicConfig.MagicTypeEnum.MAGIC_TYPE_STICKER;
    }

    @Override
    public int getLayoutResId() {
        return R.layout.layout_magic_sticker;
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
            // 0 为关闭 Item
            if (mAdapter.getSelectedPosition() > 0) {
                // 点击关闭 Item 时关闭当前选中效果
                mAdapter.updateSelectedStatusAtPosition(mAdapter.getSelectedPosition());
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
        boolean result = OrangeHelper.enableSticker(magicEffect.getPath(), enable);
        LogUtils.d(TAG, "enableEffect: result = " + result);
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
