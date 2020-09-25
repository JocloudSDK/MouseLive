package com.sclouds.magic.fragment;

import android.util.Log;
import android.view.View;

import com.sclouds.magic.R;
import com.sclouds.magic.bean.MagicEffect;
import com.sclouds.magic.databinding.EmptyDataBinding;

public class MagicEmptyFragment extends MagicBaseFragment<EmptyDataBinding> {

    @Override
    public int getLayoutResId() {
        return R.layout.layout_magic_empty;
    }

    @Override
    public void initView(View view) {

    }

    @Override
    public void initData() {

    }

    @Override
    public void onEffectEnable(int position, boolean enable) {

    }

    @Override
    public void onEffectDownloaded(MagicEffect magicEffect) {

    }

}
