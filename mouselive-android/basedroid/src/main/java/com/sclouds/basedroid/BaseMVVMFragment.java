package com.sclouds.basedroid;

import android.os.Bundle;

import androidx.annotation.CallSuper;
import androidx.annotation.Nullable;
import androidx.databinding.ViewDataBinding;

/**
 * 基础类，封装了 MVVM 和 Lifecycle
 *
 * @author chenhengfei@yy.com
 * @since 2020年2月20日
 */
public abstract class BaseMVVMFragment<B extends ViewDataBinding, M extends BaseViewModel>
        extends BaseFragment<B> {
    public M mViewModel;

    public abstract M iniViewModel();

    @CallSuper
    @Override
    public void initData() {
        mViewModel.initData();
    }

    @CallSuper
    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mViewModel = iniViewModel();
        mViewModel.onCreate();
    }

    @CallSuper
    @Override
    public void onStart() {
        super.onStart();
        mViewModel.onStart();
    }

    @CallSuper
    @Override
    public void onResume() {
        super.onResume();
        mViewModel.onResume();
    }

    @CallSuper
    @Override
    public void onPause() {
        super.onPause();
        mViewModel.onPause();
    }

    @CallSuper
    @Override
    public void onStop() {
        super.onStop();
        mViewModel.onStop();
    }

    @CallSuper
    @Override
    public void onDestroy() {
        super.onDestroy();
        mViewModel.onDestroy();
    }
}
