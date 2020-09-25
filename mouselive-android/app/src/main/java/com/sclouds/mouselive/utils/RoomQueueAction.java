package com.sclouds.mouselive.utils;

import com.sclouds.datasource.bean.RoomUser;

import java.util.ArrayList;

import androidx.annotation.NonNull;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.Observer;

/**
 * 房间操作队列处理类
 *
 * @author chenhengfei@yy.com
 * @since 2020年3月14日
 */
public class RoomQueueAction {

    public static final int TYPE_CHAT = 1;
    public static final int TYPE_PK = 2;

    private MutableLiveData<Request> data = new MutableLiveData<>();

    private ArrayList<Request> queue = new ArrayList<>();
    private boolean isStart = false;

    public void observe(@NonNull LifecycleOwner owner, @NonNull Observer<Request> observer) {
        data.observe(owner, observer);
    }

    public void clear() {
        queue.clear();
        isStart = false;
    }

    public void onChatRequestMeesage(RoomUser user) {
        queue.add(new Request(TYPE_CHAT, user));
        start();
    }

    public void onPKRequestMeesage(RoomUser user) {
        queue.add(new Request(TYPE_PK, user));
        start();
    }

    public void onCancel(long uid) {
        //数据移除
        int index = 0;
        while (index < queue.size()) {
            if (queue.get(index).getRoomUser().getUid() == uid) {
                queue.remove(index);
                break;
            }
            index++;
        }

        //如果当前对象，就移除
        Request cur = data.getValue();
        if (cur != null) {
            if (cur.getRoomUser().getUid() == uid) {
                data.postValue(null);
            }
        }

        //下一个
        next();
    }

    private void start() {
        if (isStart) {
            return;
        }

        isStart = true;
        data.postValue(queue.remove(0));
    }

    public void next() {
        if (queue.size() <= 0) {
            isStart = false;
        } else {
            Request request = queue.remove(0);
            data.postValue(request);
        }
    }

    public class Request {
        private int type;
        private RoomUser roomUser;

        public Request(int type, RoomUser roomUser) {
            this.type = type;
            this.roomUser = roomUser;
        }

        public int getType() {
            return type;
        }

        public void setType(int type) {
            this.type = type;
        }

        public RoomUser getRoomUser() {
            return roomUser;
        }

        public void setRoomUser(RoomUser roomUser) {
            this.roomUser = roomUser;
        }
    }
}
