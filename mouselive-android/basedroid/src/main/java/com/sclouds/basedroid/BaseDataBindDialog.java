package com.sclouds.basedroid;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.databinding.DataBindingUtil;
import androidx.databinding.ViewDataBinding;

/**
 * 基础类
 *
 * @author chenhengfei@yy.com
 * @since 2020年2月20日
 */
public abstract class BaseDataBindDialog<B extends ViewDataBinding> extends BaseDialog {
    protected B mBinding;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        mBinding = DataBindingUtil.inflate(inflater, getLayoutResId(), container, true);
        return mBinding.getRoot();
    }
}
