package com.sclouds.mouselive.views.dialog;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.sclouds.basedroid.BaseDialog;
import com.sclouds.basedroid.ToastUtil;
import com.sclouds.datasource.bean.RoomUser;
import com.sclouds.datasource.hummer.HummerSvc;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.utils.SimpleSingleObserver;
import com.trello.rxlifecycle3.android.FragmentEvent;

import androidx.fragment.app.FragmentManager;
import io.reactivex.android.schedulers.AndroidSchedulers;

/**
 * 房间用户头像菜单
 *
 * @author chenhengfei@yy.com
 * @since 2020年2月20日
 */
public class RoomUserMenuDialog extends BaseDialog implements View.OnClickListener {
    private static final String TAG = RoomUserMenuDialog.class.getSimpleName();

    private static final String TAG_USER = "user";
    private static final String TAG_TARGET_USER = "targetUser";

    private ImageView ivClose;

    private ImageView ivHead;
    private TextView tvName;

    private Button btUp;
    private Button btMute;
    private Button btkickOut;

    private IUserCallback iUserCallback;

    private RoomUser mRoomUser;//自己
    private RoomUser mTargetRoomUser;//对方

    @Override
    public void initView(View view) {
        ivClose = view.findViewById(R.id.ivClose);
        ivHead = view.findViewById(R.id.ivHead);
        tvName = view.findViewById(R.id.tvName);
        btUp = view.findViewById(R.id.btUp);
        btMute = view.findViewById(R.id.btMute);
        btkickOut = view.findViewById(R.id.btkickOut);

        ivClose.setOnClickListener(this);
        btUp.setOnClickListener(this);
        btMute.setOnClickListener(this);
        btkickOut.setOnClickListener(this);
    }

    @Override
    public void initData() {
        Bundle bundle = getArguments();
        assert bundle != null;
        mRoomUser = bundle.getParcelable(TAG_USER);
        mTargetRoomUser = bundle.getParcelable(TAG_TARGET_USER);
        assert mRoomUser != null;
        assert mTargetRoomUser != null;

        RequestOptions requestOptions = new RequestOptions()
                .circleCrop()
                .placeholder(R.mipmap.default_user_icon)
                .error(R.mipmap.default_user_icon);
        Glide.with(ivHead.getContext()).load(mTargetRoomUser.getCover()).apply(requestOptions)
                .into(ivHead);
        tvName.setText(mTargetRoomUser.getNickName());

        //角色控制
        setRoleText();

        //禁言
        setMuteText();

        //踢出
        setKickout();
    }

    @Override
    public int getLayoutResId() {
        return R.layout.layout_room_user_menu;
    }

    private void setRoleText() {
        if (mRoomUser.getRoomRole() == RoomUser.RoomRole.Owner) {
            btUp.setVisibility(View.VISIBLE);
            if (mTargetRoomUser.getRoomRole() == RoomUser.RoomRole.Owner) {
                btUp.setVisibility(View.GONE);
            } else if (mTargetRoomUser.getRoomRole() == RoomUser.RoomRole.Admin) {
                btUp.setText(R.string.room_user_menu_down);
            } else {
                btUp.setText(R.string.room_user_menu_up);
            }
        } else {
            btUp.setVisibility(View.GONE);
        }
    }

    private void setMuteText() {
        if (mRoomUser.getRoomRole() == RoomUser.RoomRole.Owner ||
                mRoomUser.getRoomRole() == RoomUser.RoomRole.Admin) {
            btMute.setVisibility(View.VISIBLE);
            if (mTargetRoomUser.isNoTyping()) {
                btMute.setText(R.string.room_user_menu_no_mute);
            } else {
                btMute.setText(R.string.room_user_menu_mute);
            }
        } else {
            btMute.setVisibility(View.GONE);
        }
    }

    private void setKickout() {
        if (mRoomUser.getRoomRole() == RoomUser.RoomRole.Owner ||
                mRoomUser.getRoomRole() == RoomUser.RoomRole.Admin) {
            btkickOut.setVisibility(View.VISIBLE);
        } else {
            btkickOut.setVisibility(View.GONE);
        }
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.ivClose) {
            dismiss();
        } else if (id == R.id.btUp) {
            toggleRole();
        } else if (id == R.id.btMute) {
            toggleMute();
        } else if (id == R.id.btkickOut) {
            kickOut();
        }
    }

    private void kickOut() {
        showLoading();
        HummerSvc.getInstance().kick(mTargetRoomUser)
                .subscribeOn(AndroidSchedulers.mainThread())
                .compose(bindUntilEvent(FragmentEvent.DESTROY))
                .subscribe(new SimpleSingleObserver<Boolean>() {
                    @Override
                    public void onSuccess(Boolean aBoolean) {
                        hideLoading();
                        if (aBoolean) {
                            iUserCallback.onKickout();
                            dismiss();
                        } else {
                            ToastUtil.showToast(getContext(), R.string.room_kick_error);
                        }
                    }

                    @Override
                    public void onError(Throwable e) {
                        super.onError(e);
                        hideLoading();
                        ToastUtil.showToast(getContext(), R.string.room_kick_error);
                    }
                });
    }

    private void toggleRole() {
        if (mTargetRoomUser.getRoomRole() == RoomUser.RoomRole.Owner) {

        } else if (mTargetRoomUser.getRoomRole() == RoomUser.RoomRole.Admin) {
            showLoading();
            HummerSvc.getInstance().removeRole(mTargetRoomUser)
                    .subscribeOn(AndroidSchedulers.mainThread())
                    .compose(bindUntilEvent(FragmentEvent.DESTROY))
                    .subscribe(new SimpleSingleObserver<Boolean>() {
                        @Override
                        public void onSuccess(Boolean aBoolean) {
                            hideLoading();
                            if (aBoolean) {
                                mTargetRoomUser.setRoomRole(RoomUser.RoomRole.Spectator);
                                setRoleText();
                                iUserCallback.onUserRoleChanged(mTargetRoomUser.getRoomRole());
                                dismiss();
                            } else {
                                ToastUtil.showToast(getContext(), R.string.room_remote_role_error);
                            }
                        }

                        @Override
                        public void onError(Throwable e) {
                            super.onError(e);
                            hideLoading();
                            ToastUtil.showToast(getContext(), R.string.room_remote_role_error);
                        }
                    });
        } else {
            showLoading();
            HummerSvc.getInstance().addRole(mTargetRoomUser)
                    .subscribeOn(AndroidSchedulers.mainThread())
                    .compose(bindUntilEvent(FragmentEvent.DESTROY))
                    .subscribe(new SimpleSingleObserver<Boolean>() {
                        @Override
                        public void onSuccess(Boolean aBoolean) {
                            hideLoading();
                            if (aBoolean) {
                                mTargetRoomUser.setRoomRole(RoomUser.RoomRole.Admin);
                                setRoleText();
                                iUserCallback.onUserRoleChanged(mTargetRoomUser.getRoomRole());
                                dismiss();
                            } else {
                                ToastUtil.showToast(getContext(), R.string.room_add_role_error);
                            }
                        }

                        @Override
                        public void onError(Throwable e) {
                            super.onError(e);
                            hideLoading();
                            ToastUtil.showToast(getContext(), R.string.room_add_role_error);
                        }
                    });
        }
    }

    private void toggleMute() {
        if (mTargetRoomUser.isNoTyping()) {
            showLoading();
            HummerSvc.getInstance().unmuteMember(mTargetRoomUser)
                    .subscribeOn(AndroidSchedulers.mainThread())
                    .compose(bindUntilEvent(FragmentEvent.DESTROY))
                    .subscribe(new SimpleSingleObserver<Boolean>() {
                        @Override
                        public void onSuccess(Boolean aBoolean) {
                            hideLoading();
                            if (aBoolean) {
                                mTargetRoomUser.setNoTyping(false);
                                setMuteText();
                                iUserCallback.onMuteChanged(mTargetRoomUser.isNoTyping());
                                dismiss();
                            } else {
                                ToastUtil.showToast(getContext(), R.string.room_unmute_error);
                            }
                        }

                        @Override
                        public void onError(Throwable e) {
                            super.onError(e);
                            hideLoading();
                            ToastUtil.showToast(getContext(), R.string.room_unmute_error);
                        }
                    });
        } else {
            showLoading();
            HummerSvc.getInstance().muteMember(mTargetRoomUser)
                    .subscribeOn(AndroidSchedulers.mainThread())
                    .compose(bindUntilEvent(FragmentEvent.DESTROY))
                    .subscribe(new SimpleSingleObserver<Boolean>() {
                        @Override
                        public void onSuccess(Boolean aBoolean) {
                            hideLoading();
                            if (aBoolean) {
                                mTargetRoomUser.setNoTyping(true);
                                setMuteText();
                                iUserCallback.onMuteChanged(mTargetRoomUser.isNoTyping());
                                dismiss();
                            } else {
                                ToastUtil.showToast(getContext(), R.string.room_mute_error);
                            }
                        }

                        @Override
                        public void onError(Throwable e) {
                            super.onError(e);
                            hideLoading();
                            ToastUtil.showToast(getContext(), R.string.room_mute_error);
                        }
                    });
        }
    }

    public void show(FragmentManager manager, RoomUser user, RoomUser target,
                     IUserCallback iUserCallback) {
        this.iUserCallback = iUserCallback;

        Bundle bundle = new Bundle();
        bundle.putParcelable(TAG_USER, user);
        bundle.putParcelable(TAG_TARGET_USER, target);
        setArguments(bundle);
        show(manager, TAG);
    }

    public interface IUserCallback {
        void onUserRoleChanged(RoomUser.RoomRole mRoomRole);

        void onMuteChanged(boolean isMute);

        void onKickout();
    }
}
