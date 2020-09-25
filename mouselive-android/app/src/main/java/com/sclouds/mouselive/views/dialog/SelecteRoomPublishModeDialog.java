package com.sclouds.mouselive.views.dialog;

import android.view.View;

import com.sclouds.basedroid.BaseAdapter;
import com.sclouds.basedroid.BaseDataBindDialog;
import com.sclouds.datasource.bean.PublishMode;
import com.sclouds.datasource.bean.Room;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.adapters.SelecteRoomPublishModeAdapter;
import com.sclouds.mouselive.databinding.LayoutSelecteRoomPublishModeBinding;

import androidx.annotation.NonNull;
import androidx.fragment.app.FragmentManager;
import androidx.recyclerview.widget.LinearLayoutManager;

/**
 * 创建房间，选择直播类型
 *
 * @author chenhengfei@yy.com
 * @since 2020年4月22日
 */
public class SelecteRoomPublishModeDialog extends
        BaseDataBindDialog<LayoutSelecteRoomPublishModeBinding> implements View.OnClickListener {

    private static final String TAG = SelecteRoomPublishModeDialog.class.getSimpleName();

    private SelecteRoomPublishModeAdapter adapter;
    private IMenuCallback mCallback;

    @Override
    public void initView(View view) {
        setCancelable(false);

        mBinding.ivClose.setOnClickListener(this);

        mBinding.rvList.setLayoutManager(
                new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false));
        adapter = new SelecteRoomPublishModeAdapter(getContext());
        adapter.setOnItemClickListener(new BaseAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position) {
                if (position == 0) {
                    mCallback.onPublishMode(Room.RTC);
                } else if (position == 1) {
                    mCallback.onPublishMode(Room.CDN);
                }
                dismiss();
            }
        });
        mBinding.rvList.setAdapter(adapter);
    }

    @Override
    public void initData() {

    }

    @Override
    public int getLayoutResId() {
        return R.layout.layout_selecte_room_publish_mode;
    }

    public void show(@NonNull FragmentManager manager, IMenuCallback mCallback) {
        this.mCallback = mCallback;
        super.show(manager, TAG);
    }

    @Override
    public void onClick(View v) {
        dismiss();
    }

    public interface IMenuCallback {
        void onPublishMode(@PublishMode int publishMode);
    }
}
