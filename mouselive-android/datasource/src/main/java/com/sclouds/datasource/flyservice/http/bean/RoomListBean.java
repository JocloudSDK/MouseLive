package com.sclouds.datasource.flyservice.http.bean;

import com.sclouds.datasource.bean.Room;

import java.io.Serializable;
import java.util.List;

public class RoomListBean implements Serializable {
    private List<Room> RoomList;

    public List<Room> getRoomList() {
        return RoomList;
    }

    public void setRoomList(List<Room> roomList) {
        RoomList = roomList;
    }
}