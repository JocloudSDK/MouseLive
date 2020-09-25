package com.sclouds.basedroid;

import android.content.DialogInterface;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import java.util.HashMap;
import java.util.Map;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.FragmentManager;

/**
 * 等待提醒对话框
 *
 * @author chenhengfei@yy.com
 * @since 2020年2月20日
 */
public class ProgressDialog extends DialogFragment {

    private static final String TAG = ProgressDialog.class.getSimpleName();

    private static final String TAG_MANAGER = "manager";
    private static final String TAG_MESSAGE = "message";
    private static final int DEFAULT_SHOW_DELAY = 1500;
    private static final int DEFAULT_SHOW_TIMEOUT = 15000;
    private static final int SHOW_DELAY = 1;
    private static final int SHOW_TIME_OUT = 2;

    private TextView tvMessage;
    private Handler mHandler = new Handler(new Handler.Callback() {
        @Override
        public boolean handleMessage(@NonNull Message msg) {
            if (msg.what == SHOW_DELAY) {
                Map<String, Object> map = (HashMap<String, Object>) msg.obj;
                FragmentManager manager = (FragmentManager) map.get(TAG_MANAGER);
                assert manager != null;
                if (map.containsKey(TAG_MESSAGE)) {
                    String message = (String) map.get(TAG_MESSAGE);
                    if (isShowing()) {
                        if (!TextUtils.isEmpty(message)) {
                            refreshText(message);
                        }
                    } else {
                        Bundle bundle = new Bundle();
                        bundle.putString(TAG_MESSAGE, message);
                        setArguments(bundle);
                    }
                }

                if (isAdded()) {
                    return false;
                }

                if (isShowing()) {
                    return false;
                }

                show(manager, TAG);
                mHandler.sendEmptyMessageDelayed(SHOW_TIME_OUT, DEFAULT_SHOW_TIMEOUT);
            }
            if (msg.what == SHOW_TIME_OUT) {
                dismiss();
            }
            return false;
        }
    });

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.layout_progress, container);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        setCancelable(false);

        tvMessage = view.findViewById(R.id.tvTime);
        tvMessage.setText(null != getArguments() ? getArguments().getString(TAG_MESSAGE) : "");
    }

    private void refreshText(@NonNull String msg) {
        tvMessage.setText(msg);
    }

    /**
     * 进行延迟显示，因为有些操作很快就结束了，避免闪屏现象
     */
    public void show(@NonNull FragmentManager manager) {
        if (isShowing()) {
            return;
        }

        Map<String, Object> map = new HashMap<>();
        map.put(TAG_MANAGER, manager);
        mHandler.sendMessageDelayed(Message.obtain(mHandler, SHOW_DELAY, map), DEFAULT_SHOW_DELAY);
    }

    /**
     * 进行延迟显示，因为有些操作很快就结束了，避免闪屏现象
     *
     * @param msg 需要显示的文字
     */
    public void showWithMessage(@NonNull FragmentManager manager, @Nullable String msg) {
        if (isShowing()) {
            if (!TextUtils.isEmpty(msg)) {
                refreshText(msg);
            }
            return;
        }

        Map<String, Object> map = new HashMap<>();
        map.put(TAG_MANAGER, manager);
        map.put(TAG_MESSAGE, msg);
        mHandler.sendMessageDelayed(Message.obtain(mHandler, SHOW_DELAY, map), DEFAULT_SHOW_DELAY);
    }

    /**
     * 是否显示
     */
    public boolean isShowing() {
        return (null != getDialog()) && getDialog().isShowing();
    }

    @Override
    public void onDismiss(@NonNull DialogInterface dialog) {
        releaseHandler();
        super.onDismiss(dialog);
    }

    private void releaseHandler() {
        mHandler.removeMessages(SHOW_DELAY);
        mHandler.removeMessages(SHOW_TIME_OUT);
    }

    @Override
    public void dismiss() {
        releaseHandler();

        if (isShowing()) {
            super.dismiss();
        }
    }
}
