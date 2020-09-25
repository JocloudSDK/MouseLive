package com.sclouds.mouselive.view;

import com.sclouds.datasource.bean.Room;

import androidx.annotation.UiThread;

/**
 * 房间
 *
 * @author chenhengfei@yy.com
 * @since 2020/05/04
 */
@UiThread
public interface IKTVRoomView extends IRoomView {
    void onRoomMemberCountChanged(Room room);
}
