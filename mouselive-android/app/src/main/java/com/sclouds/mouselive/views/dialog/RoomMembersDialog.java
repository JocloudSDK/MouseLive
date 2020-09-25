package com.sclouds.mouselive.views.dialog;

import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.TextView;

import com.sclouds.basedroid.BaseAdapter;
import com.sclouds.basedroid.BaseDialog;
import com.sclouds.datasource.bean.Room;
import com.sclouds.datasource.bean.RoomUser;
import com.sclouds.datasource.hummer.HummerSvc;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.adapters.RoomMemberAdapter;
import com.sclouds.mouselive.utils.SimpleSingleObserver;
import com.trello.rxlifecycle3.android.FragmentEvent;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.util.ObjectsCompat;
import androidx.fragment.app.FragmentManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import io.reactivex.android.schedulers.AndroidSchedulers;

/**
 * 房间用户列表
 *
 * @author chenhengfei@yy.com
 * @since 2020年2月20日
 */
public class RoomMembersDialog extends BaseDialog implements View.OnClickListener {

    private static final String TAG = RoomMembersDialog.class.getSimpleName();

    private static final String TAG_ROOM = "room";
    private static final String TAG_USER = "user";
    private static final String TAG_MEMBERS = "members";
    private static final String TAG_ALL_MUTE = "isAllMute";

    private TextView tvAllMute;
    private RecyclerView rvMembers;
    private RoomMemberAdapter mAdapter;

    private Room mRoom;
    private RoomUser mMine;//自己
    private ArrayList<RoomUser> mMembers;//房间成员

    private IMemberMenuCallback mCallback;
    private boolean isAllMute = false;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        Window win = getDialog().getWindow();
        WindowManager.LayoutParams params = win.getAttributes();
        params.gravity = Gravity.BOTTOM;
        params.width = ViewGroup.LayoutParams.MATCH_PARENT;
        params.height = ViewGroup.LayoutParams.WRAP_CONTENT;
        win.setAttributes(params);
        return super.onCreateView(inflater, container, savedInstanceState);
    }

    @Override
    public void initView(View view) {
        tvAllMute = view.findViewById(R.id.tvAllMute);
        rvMembers = view.findViewById(R.id.rvMembers);

        mAdapter = new RoomMemberAdapter(getContext());
        rvMembers.setLayoutManager(new LinearLayoutManager(getContext()));
        rvMembers.setAdapter(mAdapter);
        mAdapter.setOnItemClickListener(new BaseAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position) {
                if (mMine.getRoomRole() == RoomUser.RoomRole.Spectator) {
                    return;
                }

                RoomUser user = mAdapter.getDataAtPosition(position);
                if (user.getRoomRole() == RoomUser.RoomRole.Owner) {
                    return;
                }

                if (ObjectsCompat.equals(user, mMine)) {
                    return;
                }

                if (mMine.getRoomRole() == RoomUser.RoomRole.Admin &&
                        user.getRoomRole() == RoomUser.RoomRole.Admin) {
                    return;
                }
                showUserDialog(user, position);
            }
        });

        tvAllMute.setOnClickListener(this);
    }

    @Override
    public void initData() {
        Bundle bundle = getArguments();
        assert bundle != null;
        mRoom = bundle.getParcelable(TAG_ROOM);
        mMine = bundle.getParcelable(TAG_USER);
        mMembers = bundle.getParcelableArrayList(TAG_MEMBERS);
        isAllMute = bundle.getBoolean(TAG_ALL_MUTE);

        setMuteTextData();
        setMemebers(mMembers);
    }

    @Override
    public int getLayoutResId() {
        return R.layout.layout_room_memebers;
    }

    private void setMuteTextData() {
        if (mMine.getRoomRole() != RoomUser.RoomRole.Owner) {
            tvAllMute.setVisibility(View.GONE);
            return;
        }

        if (isAllMute) {
            tvAllMute.setText(R.string.room_all_yes_typing);
        } else {
            tvAllMute.setText(R.string.room_all_no_typing);
        }
    }

    /**
     * 根据职位排序，房主-管理员-观众
     */
    public static Comparator<RoomUser> MEMBER_COMPARABLE = new Comparator<RoomUser>() {
        @Override
        public int compare(RoomUser o1, RoomUser o2) {
            RoomUser.RoomRole rr1 = o1.getRoomRole();
            RoomUser.RoomRole rr2 = o2.getRoomRole();
            return rr1.compareTo(rr2);
        }
    };

    /**
     * 用户列表需要进行排序显示
     * 1：根据职位排序，房主-管理员-观众
     * 2：如果我不是房主，我的位置，永远在第二位置
     *
     * @param mMembers
     */
    private void setMemebers(ArrayList<RoomUser> mMembers) {
        //先按照职位进行排序
        Collections.sort(mMembers, MEMBER_COMPARABLE);

        if (mMine.getRoomRole() != RoomUser.RoomRole.Owner) {
            //将我自己排到第二位
            int index = 0;
            while (index < mMembers.size()) {
                if (ObjectsCompat.equals(mMembers.get(index), mMine)) {
                    break;
                }
                index++;
            }

            if (index > 1 && index < mMembers.size()) {
                RoomUser replease = mMembers.remove(index);
                mMembers.add(1, replease);
            }
        }
        mAdapter.setData(mMembers);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(STYLE_NORMAL, R.style.Dialog_Bottom);
    }

    private void toggleAllMute() {
        showLoading();
        HummerSvc.getInstance().muteAll(!isAllMute)
                .subscribeOn(AndroidSchedulers.mainThread())
                .compose(bindUntilEvent(FragmentEvent.DESTROY))
                .subscribe(new SimpleSingleObserver<Boolean>() {
                    @Override
                    public void onSuccess(Boolean aBoolean) {
                        hideLoading();
                        if (aBoolean) {
                            isAllMute = !isAllMute;
                            setMuteTextData();
                            mCallback.onAllMuteChanged(isAllMute);
                        }
                    }
                });
    }

    private void showUserDialog(RoomUser target, int position) {
        RoomUserMenuDialog dialog = new RoomUserMenuDialog();
        dialog.show(getParentFragmentManager(), mMine, target,
                new RoomUserMenuDialog.IUserCallback() {
                    @Override
                    public void onUserRoleChanged(RoomUser.RoomRole mRoomRole) {
                        target.setRoomRole(mRoomRole);
                        Collections.sort(mMembers, MEMBER_COMPARABLE);
                        mAdapter.notifyDataSetChanged();

                        mCallback.onUserRoleChanged(target);
                    }

                    @Override
                    public void onMuteChanged(boolean isMute) {
                        target.setNoTyping(isMute);
                        mAdapter.notifyItemChanged(position);

                        mCallback.onMuteChanged(target);
                    }

                    @Override
                    public void onKickout() {
                        mCallback.onKickout(target);
                    }
                });
    }

    public void show(FragmentManager manager, Room mRoom, RoomUser user,
                     ArrayList<RoomUser> mMembers, boolean isAllMute,
                     IMemberMenuCallback callback) {
        this.mCallback = callback;

        Bundle bundle = new Bundle();
        bundle.putParcelable(TAG_ROOM, mRoom);
        bundle.putParcelable(TAG_USER, user);
        bundle.putParcelableArrayList(TAG_MEMBERS, mMembers);
        bundle.putBoolean(TAG_ALL_MUTE, isAllMute);
        setArguments(bundle);
        show(manager, TAG);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.tvAllMute:
                toggleAllMute();
                break;
            default:
                break;
        }
    }

    public void onMemberUpdated(ArrayList<RoomUser> members) {
        setMemebers(members);
    }

    public interface IMemberMenuCallback {
        void onAllMuteChanged(boolean isMute);

        void onUserRoleChanged(RoomUser user);

        void onMuteChanged(RoomUser user);

        void onKickout(RoomUser user);
    }
}
