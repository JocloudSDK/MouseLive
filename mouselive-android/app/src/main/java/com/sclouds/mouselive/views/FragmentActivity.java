package com.sclouds.mouselive.views;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import com.sclouds.basedroid.BaseActivity;
import com.sclouds.mouselive.R;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

/**
 * Fragment外壳，为了方便打开一个Fragment
 *
 * @author chenhengfei@yy.com
 * @since 2020年1月17日
 */
public class FragmentActivity extends BaseActivity {

    private static final String TAG_BUNDLE = "bundle";
    private static final String TAG_CLASS = "class";

    private String aClass;
    private Bundle bundle;

    @Override
    protected void initBundle(@Nullable Bundle bundle) {
        super.initBundle(bundle);
        assert bundle != null;
        FragmentActivity.this.aClass = bundle.getString(TAG_CLASS);
        FragmentActivity.this.bundle = bundle.getBundle(TAG_BUNDLE);
    }

    @Override
    protected void initView() {

    }

    @Override
    protected void initData() {
        Fragment fragment = getSupportFragmentManager().getFragmentFactory()
                .instantiate(this.getClassLoader(), aClass);
        if (bundle != null) {
            fragment.setArguments(bundle);
        }

        getSupportFragmentManager().beginTransaction()
                .replace(R.id.flFragment, fragment)
                .commit();
    }

    @Override
    protected int getLayoutResId() {
        return R.layout.activity_fragment;
    }

    public static void startActivity(Context context, Class<? extends Fragment> aClass) {
        Intent intent = new Intent(context, FragmentActivity.class);
        intent.putExtra(TAG_CLASS, aClass.getName());
        context.startActivity(intent);
    }

    public static void startActivity(Context context, Class<? extends Fragment> aClass,
                                     @NonNull Bundle bundle) {
        Intent intent = new Intent(context, FragmentActivity.class);
        intent.putExtra(TAG_CLASS, aClass.getName());
        intent.putExtra(TAG_BUNDLE, bundle);
        context.startActivity(intent);
    }
}
