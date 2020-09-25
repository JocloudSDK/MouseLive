package com.sclouds.datasource.flyservice.http.bean;

import com.sclouds.datasource.bean.Room;
import com.sclouds.datasource.bean.RoomUser;

import java.io.Serializable;
import java.util.List;

/**
 * @author xipeitao
 * @description:
 * @date : 2020-03-09 15:19
 */
public class GetRoomInfo implements Serializable {
    private Room RoomInfo;
    private List<RoomUser> UserList;

    public Room getRoomInfo() {
        return RoomInfo;
    }

    public void setRoomInfo(Room roomInfo) {
        RoomInfo = roomInfo;
    }

    public List<RoomUser> getUserList() {
        return UserList;
    }

    public void setUserList(List<RoomUser> userList) {
        UserList = userList;
    }
}
