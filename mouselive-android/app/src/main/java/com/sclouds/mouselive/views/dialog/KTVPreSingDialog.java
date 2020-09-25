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
 * KTV-预备等待阶段
 *
 * @author chenhengfei@yy.com
 * @since 2020年07月07日
 */
public class KTVPreSingDialog extends BaseDataBindDialog<LayoutKtvPreSingBinding> implements
        View.OnClickListener {
    private static final String TAG = KTVPreSingDialog.class.getSimpleName();

    private IPreSingCallback mIPreSingCallback;

    @Override
    public void initView(@NonNull View view) {
        setCancelable(false);
    }

    @Override
    public void initData() {
    }

    @Override
    public int getLayoutResId() {
        return R.layout.layout_ktv_pre_sing;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(STYLE_NORMAL, R.style.Dialog_NoBackground);
    }

    public void show(@NonNull FragmentManager manager, IPreSingCallback callback) {
        this.mIPreSingCallback = callback;

        show(manager, TAG);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            default:
        }
    }

    private void doGiveUp() {
        mIPreSingCallback.doGiveUp();
    }

    private void doStart() {
        mIPreSingCallback.doStart();
    }

    public interface IPreSingCallback {
        void doGiveUp();

        void doStart();
    }
}
