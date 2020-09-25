package com.sclouds.mouselive.view;

import com.sclouds.basedroid.IBaseView;
import com.sclouds.datasource.bean.RoomUser;
import com.sclouds.mouselive.bean.FakeMessage;

import androidx.annotation.NonNull;
import androidx.annotation.UiThread;

/**
 * 房间
 *
 * @author chenhengfei@yy.com
 * @since 2020/05/04
 */
@UiThread
public interface IRoomView extends IBaseView {
    void onSendMessage(@NonNull FakeMessage message);

    void onMemberJoin(@NonNull RoomUser user);

    void onMemberLeave(@NonNull RoomUser user);

    void onVideoStart(@NonNull RoomUser user);

    void onVideoStop(@NonNull RoomUser user);

    void onMemberMicStatusChanged(@NonNull RoomUser user);

    void onPlayVolumeIndication(@NonNull RoomUser user);

    void onNetworkQuality(@NonNull RoomUser user);

    void onMuteChanged(@NonNull RoomUser user);

    void onRoleChanged(@NonNull RoomUser user);

    void onMemberKicked(@NonNull RoomUser user);

    void onMemberChatStart(@NonNull RoomUser user);

    void onMemberChatStop(@NonNull RoomUser user);

    void onMessage(@NonNull FakeMessage message);
}
