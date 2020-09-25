package com.sclouds.mouselive.views.dialog;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.sclouds.basedroid.BaseDialog;
import com.sclouds.basedroid.ToastUtil;
import com.sclouds.datasource.bean.Room;
import com.sclouds.datasource.bean.RoomUser;
import com.sclouds.datasource.flyservice.funws.FunWSSvc;
import com.sclouds.mouselive.R;
import com.trello.rxlifecycle3.android.FragmentEvent;

import androidx.fragment.app.FragmentManager;
import io.reactivex.android.schedulers.AndroidSchedulers;

/**
 * 聊天室用户操作
 *
 * @author chenhengfei@yy.com
 * @since 2020年2月20日
 */
public class VoiceUserMenuDialog extends BaseDialog implements View.OnClickListener {
    private static final String TAG = VoiceUserMenuDialog.class.getSimpleName();

    private static final String TAG_ROOM = "room";
    private static final String TAG_USER = "user";
    private static final String TAG_TARGET_USER = "targetUser";

    private ImageView ivClose;

    private ImageView ivHead;
    private TextView tvName;

    private Button btXiaMai;
    private Button btMute;

    private IUserCallback iUserCallback;

    private Room mRoom;
    private RoomUser mRoomUser;//自己
    private RoomUser mTargetRoomUser;//对方

    @Override
    public void initView(View view) {
        ivClose = view.findViewById(R.id.ivClose);
        ivHead = view.findViewById(R.id.ivHead);
        tvName = view.findViewById(R.id.tvName);
        btXiaMai = view.findViewById(R.id.btXiaMai);
        btMute = view.findViewById(R.id.btMute);

        ivClose.setOnClickListener(this);
        btXiaMai.setOnClickListener(this);
        btMute.setOnClickListener(this);

        Bundle bundle = getArguments();
        assert bundle != null;
        mRoom = bundle.getParcelable(TAG_ROOM);
        mRoomUser = bundle.getParcelable(TAG_USER);
        mTargetRoomUser = bundle.getParcelable(TAG_TARGET_USER);
        assert mRoom != null;
        assert mRoomUser != null;
        assert mTargetRoomUser != null;

        RequestOptions requestOptions = new RequestOptions()
                .circleCrop()
                .placeholder(R.mipmap.default_user_icon)
                .error(R.mipmap.default_user_icon);
        Glide.with(ivHead.getContext()).load(mTargetRoomUser.getCover()).apply(requestOptions)
                .into(ivHead);
        tvName.setText(mTargetRoomUser.getNickName());
    }

    @Override
    public void initData() {
        setMuteText();
    }

    @Override
    public int getLayoutResId() {
        return R.layout.layout_room_voice_user_menu;
    }

    private void setMuteText() {
        if (mRoomUser.getRoomRole() == RoomUser.RoomRole.Owner ||
                mRoomUser.getRoomRole() == RoomUser.RoomRole.Admin) {
            btMute.setVisibility(View.VISIBLE);
            if (mTargetRoomUser.isMicEnable()) {
                btMute.setText(R.string.voice_user_dialog_mute);
            } else {
                btMute.setText(R.string.voice_user_dialog_no_mute);
            }
        } else {
            btMute.setVisibility(View.GONE);
        }
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.ivClose) {
            dismiss();
        } else if (id == R.id.btMute) {
            toggleMute();
        } else if (id == R.id.btXiaMai) {
            closeChat(mTargetRoomUser);
        }
    }

    @SuppressLint("CheckResult")
    private void closeChat(RoomUser user) {
        long targetUID = user.getUid();
        long targetRID = user.getRoomId();
        showLoading();

        boolean force = (mRoomUser.getRoomRole() == RoomUser.RoomRole.Admin);
        FunWSSvc.getInstance()
                .handupChat(targetUID, targetRID, force)
                .observeOn(AndroidSchedulers.mainThread())
                .compose(bindUntilEvent(FragmentEvent.DESTROY))
                .subscribe(aBoolean -> {
                    hideLoading();
                    if (aBoolean) {
                        iUserCallback.onUserXiaMai();
                        dismiss();
                    } else {
                        ToastUtil.showToast(getContext(), R.string.room_xiamai_error);
                    }
                });
    }

    @SuppressLint("CheckResult")
    private void toggleMute() {
        if (mTargetRoomUser.isMicEnable()) {
            mTargetRoomUser.setMicEnable(false);
        } else {
            mTargetRoomUser.setMicEnable(true);
        }

        showLoading();
        FunWSSvc.getInstance()
                .enableRemoteMic(mTargetRoomUser.getUid(), mRoom.getRType(),
                        mTargetRoomUser.isMicEnable())
                .observeOn(AndroidSchedulers.mainThread())
                .compose(bindUntilEvent(FragmentEvent.DESTROY))
                .subscribe(aBoolean -> {
                    hideLoading();
                    if (aBoolean) {
                        setMuteText();
                        iUserCallback.onUserMicEnableChanged(mTargetRoomUser.isMicEnable());
                        dismiss();
                    } else {

                    }
                });
    }

    public void show(FragmentManager manager, Room mRoom, RoomUser user, RoomUser target,
                     IUserCallback iUserCallback) {
        this.iUserCallback = iUserCallback;

        Bundle bundle = new Bundle();
        bundle.putParcelable(TAG_ROOM, mRoom);
        bundle.putParcelable(TAG_USER, user);
        bundle.putParcelable(TAG_TARGET_USER, target);
        setArguments(bundle);
        show(manager, TAG);
    }

    public interface IUserCallback {
        void onUserMicEnableChanged(boolean isEnable);

        void onUserXiaMai();
    }
}
