package com.sclouds.mouselive.views;

import android.os.Bundle;
import android.view.View;

import com.sclouds.basedroid.BaseAdapter;
import com.sclouds.basedroid.BaseFragment;
import com.sclouds.datasource.bean.Room;
import com.sclouds.datasource.bean.RoomUser;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.adapters.RoomMemberAdapter;
import com.sclouds.mouselive.databinding.FragmentKtvMembersBinding;
import com.sclouds.mouselive.views.dialog.RoomMembersDialog;
import com.sclouds.mouselive.views.dialog.RoomUserMenuDialog;

import java.util.ArrayList;
import java.util.Collections;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.util.ObjectsCompat;
import androidx.recyclerview.widget.LinearLayoutManager;

/**
 * KTV-观众
 *
 * @author chenhengfei@yy.com
 * @since 2020/07/07
 */
public class KTVMembersFragment extends BaseFragment<FragmentKtvMembersBinding> implements
        View.OnClickListener {

    private Room mRoom;
    private RoomMemberAdapter mAdapter;

    private ArrayList<RoomUser> mMembers;//房间成员

    public KTVMembersFragment() {
    }

    @Override
    public void initBundle(@Nullable Bundle bundle) {
        super.initBundle(bundle);
        assert bundle != null;
        mRoom = bundle.getParcelable(LivingRoomActivity.EXTRA_ROOM);
    }

    @Override
    public void initView(View view) {
        mAdapter = new RoomMemberAdapter(getContext());
        mBinding.rvMembers.setLayoutManager(new LinearLayoutManager(getContext()));
        mBinding.rvMembers.setAdapter(mAdapter);
        mAdapter.setOnItemClickListener(new BaseAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(@NonNull View view, int position) {
                RoomUser mine = getMine();
                if (mine == null) {
                    return;
                }

                if (mine.getRoomRole() == RoomUser.RoomRole.Spectator) {
                    return;
                }

                RoomUser user = mAdapter.getDataAtPosition(position);
                if (user.getRoomRole() == RoomUser.RoomRole.Owner) {
                    return;
                }

                if (ObjectsCompat.equals(user, mine)) {
                    return;
                }

                if (mine.getRoomRole() == RoomUser.RoomRole.Admin &&
                        user.getRoomRole() == RoomUser.RoomRole.Admin) {
                    return;
                }
                showUserDialog(user, position);
            }
        });

        mBinding.tvAllMute.setOnClickListener(this);
    }

    @Override
    public void initData() {

    }

    @Override
    public int getLayoutResId() {
        return R.layout.fragment_ktv_members;
    }

    @Override
    public void onClick(View v) {
        toggleAllMute();
    }

    @Nullable
    private RoomUser getMine() {
        if (getActivity() == null) {
            return null;
        }
        return ((KTVRoomActivity) getActivity()).getMine();
    }

    private void toggleAllMute() {

    }

    /**
     * 用户列表需要进行排序显示
     * 1：根据职位排序，房主-管理员-观众
     * 2：如果我不是房主，我的位置，永远在第二位置
     *
     * @param mMembers
     */
    private void setMemebers(ArrayList<RoomUser> mMembers) {
        this.mMembers = mMembers;

        //先按照职位进行排序
        Collections.sort(mMembers, RoomMembersDialog.MEMBER_COMPARABLE);

        RoomUser mine = getMine();
        if (mine == null) {
            return;
        }

        if (mine.getRoomRole() != RoomUser.RoomRole.Owner) {
            //将我自己排到第二位
            int index = 0;
            while (index < mMembers.size()) {
                if (ObjectsCompat.equals(mMembers.get(index), mine)) {
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

    private void showUserDialog(RoomUser target, int position) {
        RoomUser mine = getMine();
        if (mine == null) {
            return;
        }

        RoomUserMenuDialog dialog = new RoomUserMenuDialog();
        dialog.show(getParentFragmentManager(), mine, target,
                new RoomUserMenuDialog.IUserCallback() {
                    @Override
                    public void onUserRoleChanged(RoomUser.RoomRole mRoomRole) {
                        target.setRoomRole(mRoomRole);
                        Collections.sort(mMembers, RoomMembersDialog.MEMBER_COMPARABLE);
                        mAdapter.notifyDataSetChanged();
                    }

                    @Override
                    public void onMuteChanged(boolean isMute) {
                        target.setNoTyping(isMute);
                        mAdapter.notifyItemChanged(position);
                    }

                    @Override
                    public void onKickout() {

                    }
                });
    }

    public void onMemberRoleChanged(RoomUser user) {

    }

    public void onMemberMuteChanged(RoomUser user) {

    }
}
