package com.sclouds.datasource.hummer;

import com.hummer.im.chatroom.ChatRoomInfo;
import com.hummer.im.model.chat.Message;
import com.hummer.im.model.id.ChatRoom;
import com.hummer.im.model.id.User;
import com.sclouds.basedroid.LogUtils;
import com.sclouds.datasource.hummer.listener.IMessageListener;
import com.sclouds.datasource.hummer.listener.IRoomListener;

import java.util.List;
import java.util.Map;
import java.util.Set;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class SimpleChannelServiceListener implements IRoomListener, IMessageListener {

    @CallSuper
    @Override
    public void onBasicInfoChanged(@NonNull ChatRoom chatRoom,
                                   @NonNull Map<ChatRoomInfo.BasicInfoType, String> propInfo) {
        LogUtils.d(HummerSvc.TAG,
                "onBasicInfoChanged() called with: chatRoom = [" + chatRoom + "], propInfo = [" +
                        propInfo + "]");
    }

    @CallSuper
    @Override
    public void onChatRoomDismissed(@NonNull ChatRoom chatRoom, @NonNull User member) {
        LogUtils.d(HummerSvc.TAG,
                "onChatRoomDismissed() called with: chatRoom = [" + chatRoom + "], member = [" +
                        member + "]");
    }

    @CallSuper
    @Override
    public void onMemberJoined(@NonNull ChatRoom chatRoom, @NonNull List<User> members) {
        for (User member : members) {
            LogUtils.d(HummerSvc.TAG,
                    "HMRChannelCallback onMemberJoined() called with: chatRoom = [" + chatRoom +
                            "], member = [" + member + "]");
        }
    }

    @CallSuper
    @Override
    public void onMemberLeaved(@NonNull ChatRoom chatRoom, @NonNull List<User> members, int type,
                               @NonNull String reason) {
        for (User member : members) {
            LogUtils.d(HummerSvc.TAG,
                    "onMemberLeaved() called with: chatRoom = [" + chatRoom + "], member = [" +
                            member + "], type = [" + type + "], reason = [" + reason + "]");
        }
    }

    @CallSuper
    @Override
    public void onMemberCountChanged(@NonNull ChatRoom chatRoom, int count) {
        LogUtils.d(HummerSvc.TAG,
                "onMemberCountChanged() called with: chatRoom = [" + chatRoom + "], count = [" +
                        count + "]");
    }

    @CallSuper
    @Override
    public void onRoleAdded(@NonNull ChatRoom chatRoom, @NonNull String role, @NonNull User admin,
                            @NonNull User fellow) {
        LogUtils.d(HummerSvc.TAG,
                "HMRChannelCallback onRoleAdded() called with: chatRoom = [" + chatRoom +
                        "], role = [" + role +
                        "], admin = [" + admin + "], fellow = [" + fellow + "]");
    }

    @CallSuper
    @Override
    public void onRoleRemoved(@NonNull ChatRoom chatRoom, @NonNull String role, @NonNull User admin,
                              @NonNull User fellow) {
        LogUtils.d(HummerSvc.TAG,
                "onRoleRemoved() called with: chatRoom = [" + chatRoom + "], role = [" + role +
                        "], admin = [" + admin + "], fellow = [" + fellow + "]");
    }

    @CallSuper
    @Override
    public void onMemberKicked(@NonNull ChatRoom chatRoom, @NonNull User admin,
                               @NonNull List<User> member, @NonNull String reason) {
        LogUtils.d(HummerSvc.TAG,
                "onMemberKicked() called with: chatRoom = [" + chatRoom + "], admin = [" +
                        admin + "], member = [" + member + "], reason = [" + reason + "]");
    }

    @CallSuper
    @Override
    public void onMemberMuted(@NonNull ChatRoom chatRoom, @NonNull User operator,
                              @NonNull Set<User> members, @Nullable String reason) {
        LogUtils.d(HummerSvc.TAG,
                "onMemberMuted() called with: chatRoom = [" + chatRoom + "], operator = [" +
                        operator + "], members = [" + members + "], reason = [" + reason + "]");
    }

    @CallSuper
    @Override
    public void onMemberUnmuted(@NonNull ChatRoom chatRoom, @NonNull User operator,
                                @NonNull Set<User> members, @Nullable String reason) {
        LogUtils.d(HummerSvc.TAG,
                "onMemberUnmuted() called with: chatRoom = [" + chatRoom + "], operator = [" +
                        operator + "], members = [" + members + "], reason = [" + reason + "]");
    }

    @Override
    public void onUserInfoSet(@NonNull ChatRoom chatRoom, @NonNull User user,
                              @NonNull Map<String, String> infoMap) {
        LogUtils.d(HummerSvc.TAG,
                "onUserInfoSet() called with: chatRoom = [" + chatRoom + "], user = [" + user +
                        "], infoMap = [" + infoMap + "]");
    }

    @Override
    public void onUserInfoDeleted(@NonNull ChatRoom chatRoom, @NonNull User user,
                                  @NonNull Map<String, String> infoMap) {
        LogUtils.d(HummerSvc.TAG,
                "onUserInfoDeleted() called with: chatRoom = [" + chatRoom + "], user = [" + user +
                        "], infoMap = [" + infoMap + "]");
    }

    @CallSuper
    @Override
    public void onMessageTxt(Message message) {
        LogUtils.d(HummerSvc.TAG, "onMessageTxt() called with: message = [" + message + "]");
    }

    @CallSuper
    @Override
    public void onSignle(Message signal) {
        LogUtils.d(HummerSvc.TAG, "onSignle() called with: signal = [" + signal + "]");
    }
}
