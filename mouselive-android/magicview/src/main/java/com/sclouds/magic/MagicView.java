package com.sclouds.magic;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.databinding.DataBindingUtil;

import com.sclouds.basedroid.LogUtils;
import com.sclouds.magic.adapter.MagicViewPagerAdapter;
import com.sclouds.magic.config.MagicConfig;
import com.sclouds.magic.databinding.MagicDataBinding;
import com.sclouds.magic.eventbus.OnEffectLoadedEvent;
import com.sclouds.magic.manager.MagicDataManager;
import com.trello.rxlifecycle3.components.support.RxAppCompatDialogFragment;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

public class MagicView extends RxAppCompatDialogFragment {

    private static final String TAG = "MagicView";

    private MagicDataBinding mDataBinding = null;

    private WindowManager.LayoutParams mLayoutParams = null;
    private int mAnimStyle = 0;

    public MagicView() {

    }

    @Override
    public void onAttach(@NonNull Context context) {
        LogUtils.d(TAG, "onAttach");
        super.onAttach(context);
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        LogUtils.d(TAG, "onCreateView");
        initParams();

        mDataBinding = DataBindingUtil.inflate(inflater, R.layout.layout_magic_view, container, true);
        return mDataBinding.getRoot();
    }

    public void initParams() {
        if (null == mLayoutParams) {
            return;
        }
        Dialog dialog = getDialog();
        if (null == dialog) {
            return;
        }
        Window window = dialog.getWindow();
        if (null == window) {
            return;
        }
        if (0 != mAnimStyle) {
            window.setWindowAnimations(mAnimStyle);
        }
        window.setAttributes(mLayoutParams);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        LogUtils.d(TAG, "onViewCreated");
        super.onViewCreated(view, savedInstanceState);

        initView();
        initData();
    }

    private void initView() {
        LogUtils.d(TAG, "initView");
        MagicViewPagerAdapter adapter = new MagicViewPagerAdapter(getChildFragmentManager());
        adapter.setTitles(getResources().getStringArray(R.array.magic_view_title_array));
        mDataBinding.viewPager.setAdapter(adapter);
        mDataBinding.viewPager.setOffscreenPageLimit(MagicConfig.MAGIC_TYPE_NUMBER);
        mDataBinding.tabLayout.setupWithViewPager(mDataBinding.viewPager);
    }

    private void initData() {
        LogUtils.d(TAG, "initData");
        if (MagicDataManager.getInstance().isLoaded()) {
            dismissLoading();
        } else {
            showLoading(getResources().getString(R.string.magic_data_loading));
            MagicDataManager.getInstance().loadEffectTabList(getContext());
        }
    }

    private void showLoading(String text) {
        mDataBinding.textView.setText(text);
        mDataBinding.textView.setVisibility(View.VISIBLE);
        mDataBinding.tabLayout.setVisibility(View.INVISIBLE);
        mDataBinding.viewPager.setVisibility(View.INVISIBLE);
    }

    private void dismissLoading() {
        mDataBinding.textView.setVisibility(View.GONE);
        mDataBinding.tabLayout.setVisibility(View.VISIBLE);
        mDataBinding.viewPager.setVisibility(View.VISIBLE);
    }

    @Override
    public void onStart() {
        LogUtils.d(TAG, "onStart");
        super.onStart();

        EventBus.getDefault().register(this);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(STYLE_NORMAL, R.style.Dialog_Bottom_FullScreen);
    }

    @Override
    public void onStop() {
        LogUtils.d(TAG, "onStop");
        super.onStop();
        EventBus.getDefault().unregister(this);
    }

    @Override
    public void onDestroyView() {
        LogUtils.d(TAG, "onDestroyView");
        super.onDestroyView();
    }

    @Override
    public void onDetach() {
        LogUtils.d(TAG, "onDetach");
        super.onDetach();
    }

    public void setLayoutParams(WindowManager.LayoutParams layoutParams) {
        this.mLayoutParams = layoutParams;
    }

    public void setAnimStyle(int animStyle) {
        this.mAnimStyle = animStyle;
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void OnEffectLoadedEvent(OnEffectLoadedEvent event) {
        LogUtils.d(TAG, "OnEffectLoadedEvent: success = " + event.isSuccess());
        if (event.isSuccess()) {
            dismissLoading();
        } else {
            showLoading(getResources().getString(R.string.magic_data_loading_failure));
        }
    }

    public static class Builder {

        private float mAlpha = 1.0f; // 背景透明度，默认不透明
        private int mGravity = Gravity.BOTTOM; // 显示位置，默认底部
        private int mWidth = ViewGroup.LayoutParams.MATCH_PARENT; // 显示宽度，默认匹配父控件
        private int mHeight = ViewGroup.LayoutParams.WRAP_CONTENT; // 显示高度，默认自适应高度
        private int mAnimStyle = 0; // 进入退出动画，默认关闭
        private boolean mOutSideClickCancel = true; // 点击外部取消，默认取消

        public Builder setAlpha(float alpha) {
            this.mAlpha = alpha;
            return this;
        }

        public Builder setGravity(int gravity) {
            this.mGravity = gravity;
            return this;
        }

        public Builder setWidth(int width) {
            this.mWidth = width;
            return this;
        }

        public Builder setHeight(int height) {
            this.mHeight = height;
            return this;
        }

        public Builder setAnimStyle(int animStyle) {
            this.mAnimStyle = animStyle;
            return this;
        }

        public Builder setOutSideClickCancel(boolean outSideClickCancel) {
            this.mOutSideClickCancel = outSideClickCancel;
            return this;
        }

        public MagicView build() {
            MagicView magicView = new MagicView();
            magicView.setLayoutParams(getLayoutParams());
            magicView.setAnimStyle(mAnimStyle);
            magicView.setCancelable(mOutSideClickCancel);
            return magicView;
        }

        private WindowManager.LayoutParams getLayoutParams() {
            WindowManager.LayoutParams layoutParams = new WindowManager.LayoutParams();
            layoutParams.alpha = mAlpha;
            layoutParams.gravity = mGravity;
            layoutParams.width = mWidth;
            layoutParams.height = mHeight;
            return  layoutParams;
        }

    }

}
