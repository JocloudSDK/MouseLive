package com.sclouds.mouselive.adapters;

import android.content.Context;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.sclouds.basedroid.BaseAdapter;
import com.sclouds.datasource.bean.RoomUser;
import com.sclouds.mouselive.R;

import androidx.annotation.NonNull;

/**
 * 房间用户列表
 *
 * @author chenhengfei@yy.com
 * @since 2020年1月17日
 */
public class RoomMemberAdapter extends BaseAdapter<RoomUser, RoomMemberAdapter.ViewHolder> {

    public RoomMemberAdapter(Context context) {
        super(context);
    }

    @Override
    protected int getLayoutId(int viewType) {
        return R.layout.item_room_members_list;
    }

    @Override
    protected ViewHolder createViewHolder(@NonNull View itemView) {
        return new ViewHolder(itemView);
    }

    class ViewHolder extends BaseAdapter.BaseViewHolder<RoomUser> {

        private TextView tvName;
        private TextView tvLevel;
        private ImageView ivHead;
        private TextView tvStatue;

        public ViewHolder(View itemView) {
            super(itemView);
            tvName = itemView.findViewById(R.id.tvName);
            tvLevel = itemView.findViewById(R.id.tvLevel);
            ivHead = itemView.findViewById(R.id.ivHead);
            tvStatue = itemView.findViewById(R.id.tvStatue);
        }

        @Override
        protected void bind(@NonNull RoomUser item) {
            RequestOptions requestOptions = new RequestOptions()
                    .circleCrop()
                    .placeholder(R.mipmap.default_user_icon)
                    .error(R.mipmap.default_user_icon);
            Glide.with(mContext).load(item.getCover()).apply(requestOptions).into(ivHead);
            tvName.setText(item.getNickName());

            if (item.getRoomRole() == RoomUser.RoomRole.Owner) {
                tvLevel.setText(R.string.room_members_level1);
                tvLevel.setVisibility(View.VISIBLE);
            } else if (item.getRoomRole() == RoomUser.RoomRole.Admin) {
                tvLevel.setText(R.string.room_members_level2);
                tvLevel.setVisibility(View.VISIBLE);
            } else {
                tvLevel.setVisibility(View.GONE);
            }

            if (item.isNoTyping()) {
                tvStatue.setText(R.string.room_members_statue_mute);
                tvStatue.setVisibility(View.VISIBLE);
            } else {
                tvStatue.setVisibility(View.GONE);
            }
        }
    }
}
