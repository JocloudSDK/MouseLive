package com.sclouds.mouselive.views;

import android.content.Context;
import android.content.Intent;

import com.sclouds.basedroid.BaseActivity;
import com.sclouds.mouselive.R;

/**
 * 设置界面
 *
 * @author chenhengfei@yy.com
 * @since 2020年1月17日
 */
public class SettingActivity extends BaseActivity {
    @Override
    protected void initView() {

    }

    @Override
    protected void initData() {
        getSupportFragmentManager().beginTransaction()
                .replace(R.id.flSetting, new SettingFragment())
                .commit();
    }

    @Override
    protected int getLayoutResId() {
        return R.layout.activity_setting;
    }

    public static void startActivity(Context context) {
        Intent intent = new Intent(context, SettingActivity.class);
        context.startActivity(intent);
    }
}
