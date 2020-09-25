package com.sclouds.magic.fragment;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.databinding.DataBindingUtil;
import androidx.databinding.ViewDataBinding;
import androidx.fragment.app.Fragment;

import com.sclouds.magic.adapter.MagicRecycleViewAdapter;
import com.sclouds.magic.bean.MagicEffect;
import com.sclouds.magic.config.MagicConfig;
import com.sclouds.magic.eventbus.OnEffectDownloadedEvent;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

public abstract class MagicBaseFragment<D extends ViewDataBinding> extends Fragment implements MagicRecycleViewAdapter.OnEffectEnableListener {

    private static final String TAG = "MagicBaseFragment";

    public D mDataBinding = null;

    public MagicRecycleViewAdapter mAdapter = null;

    public MagicConfig.MagicTypeEnum mMagicTypeEnum = null;

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        mDataBinding = DataBindingUtil.inflate(inflater, getLayoutResId(), container, false);
        return mDataBinding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initToolbar(view);
        initView(view);
        initData();
    }

    private void initToolbar(View view) {
        Toolbar toolbar = view.findViewById(com.sclouds.basedroid.R.id.toolbar);
        if (null == toolbar) {
            return;
        }
        Activity activity = getActivity();
        if (activity instanceof AppCompatActivity) {
            final AppCompatActivity appCompatActivity = (AppCompatActivity) getActivity();
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

    public abstract int getLayoutResId();

    public abstract void initView(View view);

    public abstract void initData();

    public abstract void onEffectEnable(int position, boolean enable);

    public abstract void onEffectDownloaded(MagicEffect magicEffect);

    @Override
    public void onStart() {
        super.onStart();
        EventBus.getDefault().register(this);
    }

    @Override
    public void onStop() {
        super.onStop();
        EventBus.getDefault().unregister(this);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void OnEffectDownloadedEvent(OnEffectDownloadedEvent event) {
        if ((null == mMagicTypeEnum) || (null == mAdapter)) {
            return;
        }
        if (mMagicTypeEnum.getType().equals(event.getGroupType())) {
            MagicEffect magicEffect = event.getEffect();
            Log.d(TAG, "OnEffectDownloadedEvent: gropuType = " + event.getGroupType() + ", name = " + magicEffect.getName()
                    + ", downloadStatus = " + magicEffect.getDownloadStatus().toString());
            mAdapter.updateDownloadStatus(magicEffect);
            if (MagicEffect.DownloadStatus.DOWNLOADED.equals(magicEffect.getDownloadStatus())) {
                onEffectDownloaded(magicEffect);
            }
        }
    }

}
