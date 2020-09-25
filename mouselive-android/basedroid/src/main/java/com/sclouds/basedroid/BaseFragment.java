package com.sclouds.basedroid;

import android.app.Activity;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.trello.rxlifecycle3.components.support.RxFragment;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.databinding.DataBindingUtil;
import androidx.databinding.ViewDataBinding;
import pub.devrel.easypermissions.EasyPermissions;

/**
 * 基础类
 *
 * @author Aslan
 * @since 2018/4/11
 */
public abstract class BaseFragment<B extends ViewDataBinding> extends RxFragment
        implements IBaseView {

    public B mBinding;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initBundle(getArguments());
    }

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        mBinding = DataBindingUtil.inflate(inflater, getLayoutResId(), container, false);
        return mBinding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initToolbar(view);
        initView(view);
        initData();
    }

    private void initToolbar(View view) {
        Toolbar toolbar = view.findViewById(R.id.toolbar);
        if (null == toolbar) {
            return;
        }
        Activity activity = getActivity();
        if (activity instanceof AppCompatActivity) {
            AppCompatActivity appCompatActivity = (AppCompatActivity) getActivity();
            //一定要优先设置
            appCompatActivity.setSupportActionBar(toolbar);
            toolbar.setNavigationOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    appCompatActivity.finish();
                }
            });
            ActionBar actionBar = appCompatActivity.getSupportActionBar();
            if (null != actionBar) {
                actionBar.setDisplayHomeAsUpEnabled(true);
                actionBar.setHomeButtonEnabled(true);
            }
        }
    }

    public void initBundle(@Nullable Bundle bundle) {

    }

    public abstract void initView(View view);

    public abstract void initData();

    public abstract int getLayoutResId();

    private ProgressDialog mProgressDialog;

    private ProgressDialog createProgressDialog() {
        if (mProgressDialog == null) {
            mProgressDialog = new ProgressDialog();
        }
        return mProgressDialog;
    }

    public void hideLoading() {
        if (mProgressDialog == null) {
            return;
        }

        try {
            mProgressDialog.dismiss();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public void showLoading() {
        ProgressDialog mProgressDialog = createProgressDialog();
        try {
            mProgressDialog.show(getChildFragmentManager());
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public void showLoading(@NonNull String message) {
        ProgressDialog mProgressDialog = createProgressDialog();
        try {
            mProgressDialog.showWithMessage(getChildFragmentManager(), message);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public void showLoading(@StringRes int rid) {
        showLoading(getString(rid));
    }

    @CallSuper
    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        EasyPermissions.onRequestPermissionsResult(requestCode, permissions, grantResults, this);
    }

    @CallSuper
    @Override
    public void onDestroy() {
        hideLoading();
        super.onDestroy();
    }

    @Override
    public void finish() {
        if (getActivity() != null) {
            getActivity().finish();
        }
    }
}
