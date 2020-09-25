package com.sclouds.mouselive.views;

import android.content.Intent;
import android.os.Bundle;

import com.sclouds.basedroid.BaseActivity;
import com.sclouds.mouselive.R;

import androidx.annotation.Nullable;

/**
 * 飞屏界面
 *
 * @author Aslan chenhengfei@yy.com
 * @since 2019/12/24
 */
public class SplashActivity extends BaseActivity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (!this.isTaskRoot()) {
            //处理点击launcher启动多次问题
            finish();
        } else {
            goMainActivity();
        }
    }

    @Override
    protected int getLayoutResId() {
        return R.layout.activity_splash;
    }

    @Override
    protected void initView() {

    }

    @Override
    protected void initData() {

    }

    private void goMainActivity() {
        Intent intent = new Intent(this, MainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(intent);
        finish();
    }
}
