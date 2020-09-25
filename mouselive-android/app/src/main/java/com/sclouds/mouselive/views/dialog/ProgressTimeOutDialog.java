package com.sclouds.mouselive.views.dialog;

import android.content.DialogInterface;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.sclouds.mouselive.R;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.FragmentManager;

/**
 * 等待，有超时处理
 *
 * @author chenhengfei@yy.com
 * @since 2020年2月20日
 */
public class ProgressTimeOutDialog extends DialogFragment {
    private static final String TAG = ProgressTimeOutDialog.class.getSimpleName();

    private TextView tvTime;
    private ProgressBar pb;

    private CountDownTimer mTimer;

    private IProgressCallback mCallback;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.layout_progress_timeout, container);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        setCancelable(false);
        tvTime = view.findViewById(R.id.tvTime);

        mTimer = new CountDownTimer(15 * 1000L, 999L) {
            @Override
            public void onTick(long millisUntilFinished) {
                tvTime.setText(getString(R.string.requesting_chating, millisUntilFinished / 1000));
            }

            @Override
            public void onFinish() {
                mCallback.onTimeUp();
                dismiss();
            }
        };
        mTimer.start();
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(STYLE_NORMAL, R.style.Dialog_NoBackground);
    }

    public void show(FragmentManager manager, IProgressCallback mCallback) {
        this.mCallback = mCallback;
        Bundle bundle = new Bundle();
        setArguments(bundle);
        show(manager, TAG);
    }

    public interface IProgressCallback {
        void onTimeUp();
    }

    @Override
    public void onDismiss(@NonNull DialogInterface dialog) {
        mTimer.cancel();
        super.onDismiss(dialog);
    }
}
