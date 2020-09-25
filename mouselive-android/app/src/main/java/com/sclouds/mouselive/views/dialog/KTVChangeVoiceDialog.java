package com.sclouds.mouselive.views.dialog;

import android.os.Bundle;
import android.view.View;

import com.sclouds.basedroid.BaseDataBindDialog;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.databinding.LayoutKtvPreSingBinding;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;

/**
 * KTV-调音
 *
 * @author chenhengfei@yy.com
 * @since 2020年07月07日
 */
public class KTVChangeVoiceDialog extends BaseDataBindDialog<LayoutKtvPreSingBinding> implements
        View.OnClickListener {
    private static final String TAG = KTVChangeVoiceDialog.class.getSimpleName();

    @Override
    public void initView(@NonNull View view) {
        setCancelable(false);
    }

    @Override
    public void initData() {
    }

    @Override
    public int getLayoutResId() {
        return R.layout.layout_ktv_change_voice;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(STYLE_NORMAL, R.style.Dialog_NoBackground);
    }

    public void show(@NonNull FragmentManager manager) {
        show(manager, TAG);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            default:
        }
    }
}
