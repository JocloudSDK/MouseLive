package com.sclouds.mouselive.views.dialog;

import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;

import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.sclouds.mouselive.R;

import androidx.annotation.NonNull;

/**
 * 输入框
 *
 * @author chenhengfei@yy.com
 * @since 2020年2月20日
 */
public class InputMessageDialog extends BottomSheetDialog {

    private EditText etInput;
    private Button btSend;

    private ISendMessageCallback iSendMessageCallback;

    public InputMessageDialog(@NonNull Context context) {
        super(context);
    }

    public InputMessageDialog(@NonNull Context context, int theme) {
        super(context, theme);
    }

    protected InputMessageDialog(@NonNull Context context, boolean cancelable,
                                 OnCancelListener cancelListener) {
        super(context, cancelable, cancelListener);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.layout_input_message);
        getWindow().getAttributes().dimAmount = 0f;
        getWindow().setLayout(ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT);

        etInput = findViewById(R.id.etInput);
        btSend = findViewById(R.id.btSend);

        btSend.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                sendMessage();
            }
        });

        setOnDismissListener(new OnDismissListener() {
            @Override
            public void onDismiss(DialogInterface dialogInterface) {
                etInput.setText("");
                handler.removeCallbacks(delayShowInput);
            }
        });
    }

    private void sendMessage() {
        String msg = etInput.getText().toString().trim();
        if (TextUtils.isEmpty(msg)) {
            return;
        }

        etInput.setText("");
        this.iSendMessageCallback.onSendMessage(msg);
        this.dismiss();
    }

    private Handler handler = new Handler();
    private Runnable delayShowInput = new Runnable() {
        @Override
        public void run() {
            InputMethodManager imm = (InputMethodManager) getContext()
                    .getSystemService(Context.INPUT_METHOD_SERVICE);
            imm.showSoftInput(etInput, InputMethodManager.SHOW_FORCED);
        }
    };

    public void show(ISendMessageCallback iSendMessageCallback) {
        super.show();
        this.iSendMessageCallback = iSendMessageCallback;
        handler.postDelayed(delayShowInput, 250L);
    }

    public interface ISendMessageCallback {
        void onSendMessage(String msg);
    }
}
