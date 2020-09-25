package com.sclouds.mouselive.viewmodel;

import android.app.Application;

import com.sclouds.datasource.bean.Room;
import com.sclouds.datasource.bean.RoomUser;
import com.sclouds.datasource.business.pkg.ChatPacket;
import com.sclouds.datasource.thunder.mode.KTVConfig;
import com.sclouds.datasource.thunder.mode.ThunderConfig;
import com.sclouds.mouselive.view.IKTVRoomView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * KTV，逻辑成代码
 * <p>
 *
 * @author chenhengfei@yy.com
 * @since 2020/03/01
 */
public class KTVRoomViewModel extends BaseRoomViewModel<IKTVRoomView> {

    public KTVRoomViewModel(@NonNull Application application, @NonNull IKTVRoomView mView,
                            @NonNull Room room) {
        super(application, mView, room);
    }

    @Override
    public boolean isInChating() {
        return false;
    }

    @Override
    public boolean isInChating(@NonNull RoomUser user) {
        return false;
    }

    @Nullable
    @Override
    public RoomUser getChatingMember(long userId) {
        return null;
    }

    @Override
    protected void onUserInChating(@NonNull RoomUser user) {

    }

    @Override
    protected ThunderConfig getThunderConfig() {
        return new KTVConfig();
    }

    @Override
    public void onChatRev(ChatPacket chatPkg) {

    }

    @Override
    public void onChatCanel(ChatPacket chatPkg) {

    }

    @Override
    public void onChatHangup(ChatPacket chatPkg) {

    }

    @Override
    public void onMuiltCastChatHangup(ChatPacket chatPkg) {

    }

    @Override
    public void onMuiltCastChating(ChatPacket chatPkg) {

    }

    private void showSaveDialog() {

    }
}
