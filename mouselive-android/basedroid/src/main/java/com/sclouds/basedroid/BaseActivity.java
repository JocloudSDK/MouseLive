package com.sclouds.basedroid;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

import com.trello.rxlifecycle3.components.support.RxAppCompatActivity;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.widget.Toolbar;
import androidx.databinding.DataBindingUtil;
import androidx.databinding.ViewDataBinding;
import pub.devrel.easypermissions.EasyPermissions;

/**
 * 基础类
 *
 * @author chenhengfei@yy.com
 * @since 2020年2月20日
 */
public abstract class BaseActivity<B extends ViewDataBinding> extends RxAppCompatActivity
        implements IBaseView {

    public B mBinding;
    private ProgressDialog mProgressDialog = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStatusBar();
        setCustomContentView();
        setToolBar();

        Intent intent = getIntent();
        if (intent == null) {
            initBundle(null);
        } else {
            initBundle(intent.getExtras());
        }

        iniBeforeView();
        initView();
        initData();
    }

    protected void iniBeforeView() {

    }

    protected void setCustomContentView() {
        mBinding = DataBindingUtil.setContentView(this, getLayoutResId());
    }

    private void setStatusBar() {
        // 状态栏侵入式透明
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            Window window = getWindow();
            window.setFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS, WindowManager
                    .LayoutParams.FLAG_TRANSLUCENT_STATUS);
        }
    }

    protected abstract int getLayoutResId();

    private void setToolBar() {
        Toolbar toolbar = findViewById(R.id.toolbar);
        if (null == toolbar) {
            return;
        }
        //一定要优先设置
        setSupportActionBar(toolbar);
        toolbar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        ActionBar actionBar = getSupportActionBar();
        if (null == actionBar) {
            return;
        }
        actionBar.setDisplayHomeAsUpEnabled(true);
        actionBar.setHomeButtonEnabled(true);
    }

    protected void initBundle(@Nullable Bundle bundle) {

    }

    protected abstract void initView();

    protected abstract void initData();

    protected ProgressDialog createProgressDialog() {
        if (mProgressDialog == null) {
            mProgressDialog = new ProgressDialog();
        }
        return mProgressDialog;
    }

    public void showLoading() {
        ProgressDialog mProgressDialog = createProgressDialog();

        try {
            mProgressDialog.show(getSupportFragmentManager());
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public void showLoading(@StringRes int rid) {
        showLoading(getString(rid));
    }

    public void showLoading(@NonNull String message) {
        ProgressDialog mProgressDialog = createProgressDialog();

        try {
            mProgressDialog.showWithMessage(getSupportFragmentManager(), message);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public void hideLoading() {
        if (null == mProgressDialog) {
            return;
        }

        try {
            mProgressDialog.dismiss();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    @CallSuper
    @Override
    protected void onDestroy() {
        hideLoading();
        super.onDestroy();
    }

    @CallSuper
    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        EasyPermissions.onRequestPermissionsResult(requestCode, permissions, grantResults, this);
    }
}
