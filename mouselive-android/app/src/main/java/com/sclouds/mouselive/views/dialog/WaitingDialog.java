package com.sclouds.mouselive.views.dialog;

import android.os.Bundle;
import android.view.View;

import com.sclouds.basedroid.BaseDataBindDialog;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.databinding.LayoutProgressTimeoutBinding;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;

/**
 * 提示等待框
 *
 * @author chenhengfei@yy.com
 * @since 2020年5月6日
 */
public class WaitingDialog extends BaseDataBindDialog<LayoutProgressTimeoutBinding> {
    private static final String TAG = WaitingDialog.class.getSimpleName();
    private static final String TAG_MSG = "message";

    @Override
    public void initView(View view) {
        setCancelable(false);
    }

    @Override
    public void initData() {
        Bundle bundle = getArguments();
        assert bundle != null;
        mBinding.tvTime.setText(bundle.getString(TAG_MSG));
    }

    @Override
    public int getLayoutResId() {
        return R.layout.layout_progress_timeout;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(STYLE_NORMAL, R.style.Dialog_NoBackground);
    }

    public void showWithMessage(@NonNull FragmentManager manager, @NonNull String msg) {
        Bundle bundle = new Bundle();
        bundle.putString(TAG_MSG, msg);
        setArguments(bundle);
        show(manager, TAG);
    }
}
