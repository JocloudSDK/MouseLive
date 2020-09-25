package com.sclouds.mouselive.viewmodel;

import android.app.Application;

import com.sclouds.basedroid.BaseViewModel;
import com.sclouds.basedroid.IBaseView;
import com.sclouds.datasource.bean.Room;
import com.sclouds.datasource.bean.User;
import com.sclouds.datasource.database.DatabaseSvc;
import com.sclouds.datasource.flyservice.http.FlyHttpSvc;
import com.sclouds.datasource.flyservice.http.bean.RoomListBean;
import com.sclouds.datasource.flyservice.http.network.BaseObserver;
import com.sclouds.datasource.flyservice.http.network.CustomThrowable;

import java.util.List;

import androidx.annotation.NonNull;
import androidx.core.util.ObjectsCompat;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.Observer;
import io.reactivex.android.schedulers.AndroidSchedulers;

/**
 * 房间列表
 *
 * @author chenhengfei@yy.com
 * @since 2020/03/01
 */
public class RoomListModel extends BaseViewModel {

    private MutableLiveData<List<Room>> mRooms = new MutableLiveData<>();
    private int mRoomType = Room.ROOM_TYPE_LIVE;

    public RoomListModel(@NonNull Application application, @NonNull IBaseView mView,
                         int mRoomType) {
        super(application, mView);
        this.mRoomType = mRoomType;
    }

    public void observeRoomList(LifecycleOwner owner, Observer<List<Room>> observer) {
        mRooms.observe(owner, observer);
    }

    @Override
    public void initData() {

    }

    /**
     * 获取房间列表
     */
    public void getRoomList() {
        User user = DatabaseSvc.getIntance().getUser();
        if (user == null) {
            mRooms.postValue(null);
            return;
        }

        FlyHttpSvc.getInstance().getRoomList(user.getUid(), mRoomType, 0)
                .observeOn(AndroidSchedulers.mainThread())
                .compose(bindToLifecycle())
                .subscribe(new BaseObserver<RoomListBean>(getApplication()) {
                    @Override
                    public void handleSuccess(@NonNull RoomListBean data) {
                        List<Room> list = data.getRoomList();
                        if (list == null) {
                            mRooms.setValue(null);
                            return;
                        }

                        //移除房主是我的房间
                        int index = 0;
                        while (index < list.size()) {
                            Room room = list.get(index);
                            if (ObjectsCompat.equals(user, room.getROwner())) {
                                list.remove(index);
                                continue;
                            }
                            index++;
                        }

                        mRooms.setValue(list);
                    }

                    @Override
                    public void handleError(CustomThrowable e) {
                        super.handleError(e);
                        mRooms.setValue(null);
                    }
                });
    }
}
