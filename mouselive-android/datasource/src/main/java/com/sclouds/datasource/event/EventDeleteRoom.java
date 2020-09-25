package com.sclouds.datasource.event;

import com.sclouds.datasource.bean.Room;

import androidx.annotation.NonNull;

/**
 * 删除房间
 *
 * @author Aslan chenhengfei@yy.com
 * @date 2020/3/24
 */
public class EventDeleteRoom {
    @NonNull
    private Room mRoom;

    public EventDeleteRoom(@NonNull Room room) {
        mRoom = room;
    }

    @NonNull
    public Room getRoom() {
        return mRoom;
    }

    public void setRoom(@NonNull Room room) {
        mRoom = room;
    }
}
