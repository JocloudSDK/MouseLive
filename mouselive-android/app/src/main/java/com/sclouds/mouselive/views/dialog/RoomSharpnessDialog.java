package com.sclouds.mouselive.views.dialog;

import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.TextView;

import com.sclouds.basedroid.BaseAdapter;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.adapters.RoomSharpnessAdapter;
import com.thunder.livesdk.ThunderRtcConstant;
import com.trello.rxlifecycle3.components.support.RxAppCompatDialogFragment;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.LinearSnapHelper;
import androidx.recyclerview.widget.RecyclerView;

/**
 * 房间清晰度列表
 *
 * @author chenhengfei@yy.com
 * @since 2020年2月20日
 */
public class RoomSharpnessDialog extends RxAppCompatDialogFragment
        implements View.OnClickListener {

    private static final String TAG = RoomSharpnessDialog.class.getSimpleName();

    private static final String TAG_PUBLISHMODE = "publishMode";

    private TextView tvCancel;
    private TextView tvOK;
    private RecyclerView rvList;

    private int publishMode;

    private ISharpnessCallback iSharpnessCallback;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        Window win = getDialog().getWindow();
        WindowManager.LayoutParams params = win.getAttributes();
        params.gravity = Gravity.BOTTOM;
        params.width = ViewGroup.LayoutParams.MATCH_PARENT;
        params.height = ViewGroup.LayoutParams.WRAP_CONTENT;
        win.setAttributes(params);
        return inflater.inflate(R.layout.layout_room_sharpness, container);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        tvCancel = view.findViewById(R.id.tvCancel);
        tvOK = view.findViewById(R.id.tvOK);
        rvList = view.findViewById(R.id.rvList);

        RoomSharpnessAdapter mAdapter = new RoomSharpnessAdapter(getContext());
        rvList.setLayoutManager(new LinearLayoutManager(getContext()));
        rvList.setAdapter(mAdapter);
        mAdapter.setOnItemClickListener(new BaseAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position) {
                mAdapter.setSelectIndex(position);

                RoomSharpnessAdapter.Sharpness sharpness = mAdapter.getDataAtPosition(position);
                publishMode = sharpness.getPublishMode();
            }
        });
        LinearSnapHelper mLinearSnapHelper = new LinearSnapHelper();
        mLinearSnapHelper.attachToRecyclerView(rvList);

        tvCancel.setOnClickListener(this);
        tvOK.setOnClickListener(this);

        Bundle bundle = getArguments();
        assert bundle != null;
        publishMode = bundle.getInt(TAG_PUBLISHMODE);

        if (publishMode ==
                ThunderRtcConstant.ThunderPublishVideoMode.THUNDERPUBLISH_VIDEO_MODE_FLUENCY) {
            mAdapter.setSelectIndex(0);
        } else if (publishMode ==
                ThunderRtcConstant.ThunderPublishVideoMode.THUNDERPUBLISH_VIDEO_MODE_NORMAL) {
            mAdapter.setSelectIndex(1);
        } else if (publishMode ==
                ThunderRtcConstant.ThunderPublishVideoMode.THUNDERPUBLISH_VIDEO_MODE_HIGHQULITY) {
            mAdapter.setSelectIndex(2);
        } else {
            publishMode =
                    ThunderRtcConstant.ThunderPublishVideoMode.THUNDERPUBLISH_VIDEO_MODE_FLUENCY;
            mAdapter.setSelectIndex(0);
        }
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(STYLE_NORMAL, R.style.Dialog_Bottom);
    }

    public void show(FragmentManager manager, int publishMode,
                     ISharpnessCallback iSharpnessCallback) {
        Bundle bundle = new Bundle();
        bundle.putInt(TAG_PUBLISHMODE, publishMode);
        setArguments(bundle);
        this.iSharpnessCallback = iSharpnessCallback;
        show(manager, TAG);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.tvCancel:
                dismiss();
                break;
            case R.id.tvOK:
                this.iSharpnessCallback.onSharpnessCallback(publishMode);
                dismiss();
                break;
            default:
                break;
        }
    }

    public interface ISharpnessCallback {
        void onSharpnessCallback(int publishMode);
    }
}
