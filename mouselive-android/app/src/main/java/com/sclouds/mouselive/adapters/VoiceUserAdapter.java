package com.sclouds.mouselive.adapters;

import android.content.Context;
import android.view.View;

import com.sclouds.basedroid.BaseAdapter;
import com.sclouds.datasource.bean.RoomUser;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.widget.RoomUserHeader;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

import androidx.annotation.LayoutRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.Size;
import androidx.recyclerview.widget.RecyclerView;

/**
 * 聊天室参与人员
 *
 * @author chenhengfei@yy.com
 * @since 2020年1月17日
 */
public class VoiceUserAdapter extends BaseAdapter<RoomUser, VoiceUserAdapter.ViewHolder> {

    /**
     * 为了保证每个手机上座位显示一致，所以进行UID排序
     */
    private Comparator<RoomUser> mComparable = new Comparator<RoomUser>() {
        @Override
        public int compare(RoomUser o1, RoomUser o2) {
            long rr1 = o1.getUid();
            long rr2 = o2.getUid();
            return Long.compare(rr1, rr2);
        }
    };

    public VoiceUserAdapter(Context context) {
        super(context);
    }

    @Override
    public int getItemCount() {
        return 8;
    }

    @LayoutRes
    @Override
    protected int getLayoutId(int viewType) {
        return R.layout.item_voice_room_user;
    }

    @Override
    protected ViewHolder createViewHolder(@NonNull View itemView) {
        return new ViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        RoomUser item = null;
        if (mData != null && position < mData.size()) {
            item = mData.get(position);
        }
        ((ViewHolder) holder).bind(item);
    }

    static class ViewHolder extends BaseAdapter.BaseViewHolder<RoomUser> {

        private RoomUserHeader viewUser;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            viewUser = itemView.findViewById(R.id.viewUser);
        }

        @Override
        protected void bind(@Nullable RoomUser item) {
            if (item == null) {
                viewUser.clearUser(mContext.getString(R.string.voice_user_name_default,
                        String.valueOf(getAdapterPosition() + 1)));
            } else {
                viewUser.setUserInfo(item);
            }
        }
    }

    @Override
    public void addItem(@NonNull RoomUser data) {
        if (mData == null) {
            mData = new ArrayList<>();
        }

        if (mData.contains(data)) {
            return;
        }

        mData.add(data);
        Collections.sort(mData, mComparable);
        notifyDataSetChanged();
    }

    @Override
    public void deleteItem(@NonNull RoomUser data) {
        if (mData == null || mData.isEmpty()) {
            return;
        }

        int index = mData.indexOf(data);
        if (index >= 0) {
            mData.remove(data);
            Collections.sort(mData, mComparable);
            notifyDataSetChanged();
        }
    }

    public boolean haveUser(@Size(min = 0) int position) {
        if (mData == null) {
            return false;
        }
        return position < mData.size();
    }

    public void refreshUser(@NonNull RoomUser user) {
        if (mData == null) {
            return;
        }

        int index = mData.indexOf(user);
        if (index >= 0) {
            notifyItemChanged(index);
        }
    }
}
