package com.sclouds.datasource.event;

import com.sclouds.datasource.bean.Room;

import androidx.annotation.NonNull;

/**
 * 离开房间房间
 *
 * @author Aslan chenhengfei@yy.com
 * @date 2020/04/27
 */
public class EventLeaveRoom {
    @NonNull
    private Room mRoom;

    public EventLeaveRoom(@NonNull Room room) {
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
