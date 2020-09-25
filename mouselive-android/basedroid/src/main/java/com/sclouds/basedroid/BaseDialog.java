package com.sclouds.basedroid;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.trello.rxlifecycle3.components.support.RxAppCompatDialogFragment;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import pub.devrel.easypermissions.EasyPermissions;

/**
 * 基础类
 *
 * @author chenhengfei@yy.com
 * @since 2020年2月20日
 */
public abstract class BaseDialog extends RxAppCompatDialogFragment {
    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(getLayoutResId(), container);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initBundle(getArguments());
        initView(view);
        initData();
    }

    public void initBundle(@Nullable Bundle bundle) {

    }

    public abstract void initView(@NonNull View view);

    public abstract void initData();

    public abstract int getLayoutResId();

    private ProgressDialog mProgressDialog;

    protected ProgressDialog createProgressDialog() {
        if (mProgressDialog == null) {
            mProgressDialog = new ProgressDialog();
        }
        return mProgressDialog;
    }

    protected void hideLoading() {
        if (mProgressDialog == null) {
            return;
        }

        try {
            mProgressDialog.dismiss();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    protected void showLoading() {
        ProgressDialog mProgressDialog = createProgressDialog();
        try {
            mProgressDialog.show(getChildFragmentManager());
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    protected void showLoading(@NonNull String message) {
        ProgressDialog mProgressDialog = createProgressDialog();
        try {
            mProgressDialog.showWithMessage(getChildFragmentManager(), message);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    protected void showLoading(@StringRes int rid) {
        showLoading(getString(rid));
    }

    @CallSuper
    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        EasyPermissions.onRequestPermissionsResult(requestCode, permissions, grantResults, this);
    }

    /**
     * 是否显示
     *
     * @return
     */
    public boolean isShowing() {
        return (null != getDialog()) && getDialog().isShowing();
    }

    @CallSuper
    @Override
    public void onDestroy() {
        hideLoading();
        super.onDestroy();
    }
}
