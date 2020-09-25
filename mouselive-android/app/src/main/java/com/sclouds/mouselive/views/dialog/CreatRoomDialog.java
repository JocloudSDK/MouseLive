package com.sclouds.mouselive.views.dialog;

import android.graphics.Paint;
import android.os.Bundle;
import android.view.View;

import com.sclouds.basedroid.BaseAdapter;
import com.sclouds.basedroid.BaseDataBindDialog;
import com.sclouds.basedroid.ToastUtil;
import com.sclouds.datasource.bean.Room;
import com.sclouds.datasource.bean.User;
import com.sclouds.datasource.database.DatabaseSvc;
import com.sclouds.datasource.flyservice.http.FlyHttpSvc;
import com.sclouds.datasource.flyservice.http.network.BaseObserver;
import com.sclouds.datasource.flyservice.http.network.CustomThrowable;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.adapters.CreateRoomAdapter;
import com.sclouds.mouselive.databinding.LayoutCreateRoomBinding;
import com.trello.rxlifecycle3.android.FragmentEvent;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import io.reactivex.android.schedulers.AndroidSchedulers;

/**
 * 创建房间
 *
 * @author chenhengfei@yy.com
 * @since 2020年2月20日
 */
public class CreatRoomDialog extends BaseDataBindDialog<LayoutCreateRoomBinding>
        implements View.OnClickListener {

    private static final String TAG = CreatRoomDialog.class.getSimpleName();

    private CreateRoomAdapter adapter;

    private ICreateRoomCallback callback;

    @Override
    public void initView(View view) {
        mBinding.tvBack.getPaint().setFlags(Paint.UNDERLINE_TEXT_FLAG);//下划线
        mBinding.tvBack.getPaint().setAntiAlias(true);//抗锯齿

        mBinding.rvList.setLayoutManager(
                new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false));
        adapter = new CreateRoomAdapter(getContext());
        adapter.setOnItemClickListener(new BaseAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position) {
                adapter.setSelectIndex(position);
            }
        });
        mBinding.rvList.setAdapter(adapter);

        mBinding.btCreate.setOnClickListener(this);
        mBinding.tvBack.setOnClickListener(this);
    }

    @Override
    public void initData() {

    }

    @Override
    public int getLayoutResId() {
        return R.layout.layout_create_room;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(STYLE_NORMAL, R.style.Dialog_FullScreen);
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.btCreate) {
            creatRoom();
        } else if (id == R.id.tvBack) {
            dismiss();
        }
    }

    private void creatRoom() {
        User user = DatabaseSvc.getIntance().getUser();
        if (user == null) {
            return;
        }

        int index = adapter.getSelectIndex();
        int roomType = Room.ROOM_TYPE_LIVE;
        if (index == 0) {
            SelecteRoomPublishModeDialog dialog = new SelecteRoomPublishModeDialog();
            dialog.show(getParentFragmentManager(),
                    new SelecteRoomPublishModeDialog.IMenuCallback() {
                        @Override
                        public void onPublishMode(int publishMode) {
                            Room room = new Room();
                            room.setRType(Room.ROOM_TYPE_LIVE);
                            room.setRPublishMode(publishMode);
                            handleCreatRoom(user, room);
                        }
                    });
            return;
        } else if (index == 1) {
            roomType = Room.ROOM_TYPE_CHAT;
        }

        Room room = new Room();
        room.setRType(roomType);
        handleCreatRoom(user, room);
    }

    private void handleCreatRoom(User user, Room room) {
        showLoading();
        FlyHttpSvc.getInstance().createRoom(user, room)
                .compose(bindUntilEvent(FragmentEvent.DESTROY))
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new BaseObserver<Room>(getContext()) {
                    @Override
                    public void handleSuccess(@NonNull Room room) {
                        hideLoading();
                        callback.onCreateRoom(room);
                        dismiss();
                    }

                    @Override
                    public void handleError(CustomThrowable e) {
                        super.handleError(e);
                        hideLoading();
                        ToastUtil.showToast(getContext(), e.message);
                    }
                });
    }

    public void show(FragmentManager manager, ICreateRoomCallback callback) {
        this.callback = callback;
        show(manager, TAG);
    }

    public interface ICreateRoomCallback {
        void onCreateRoom(Room room);
    }
}
