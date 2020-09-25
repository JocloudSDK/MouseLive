package com.sclouds.basedroid;

import android.os.Bundle;
import android.text.TextUtils;

import androidx.annotation.CallSuper;
import androidx.annotation.Nullable;
import androidx.databinding.ViewDataBinding;
import androidx.lifecycle.Observer;

/**
 * 基础类，封装了 MVVM 和 Lifecycle
 *
 * @author chenhengfei@yy.com
 * @since 2020年2月20日
 */
public abstract class BaseMVVMActivity<B extends ViewDataBinding, M extends BaseViewModel>
        extends BaseActivity<B> {
    protected M mViewModel;

    @CallSuper
    @Override
    protected void iniBeforeView() {
        mViewModel = iniViewModel();
        observeLoading();
    }

    @CallSuper
    @Override
    protected void initData() {
        mViewModel.initData();
    }

    protected abstract M iniViewModel();

    @CallSuper
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mViewModel.onCreate();
    }

    @CallSuper
    @Override
    protected void onStart() {
        super.onStart();
        mViewModel.onStart();
    }

    @CallSuper
    @Override
    protected void onResume() {
        super.onResume();
        mViewModel.onResume();
    }

    @CallSuper
    @Override
    protected void onPause() {
        super.onPause();
        mViewModel.onPause();
    }

    @CallSuper
    @Override
    protected void onStop() {
        super.onStop();
        mViewModel.onStop();
    }

    @CallSuper
    @Override
    protected void onDestroy() {
        super.onDestroy();
        mViewModel.onDestroy();
    }

    /**
     * 处理等待
     */
    private void observeLoading() {
        mViewModel.mLiveDataLoading.observe(this, new Observer<String>() {
            @Override
            public void onChanged(@Nullable String msg) {
                if (msg == null) {
                    hideLoading();
                    return;
                }

                if (TextUtils.isEmpty(msg)) {
                    showLoading();
                } else {
                    showLoading(msg);
                }
            }
        });
    }
}
