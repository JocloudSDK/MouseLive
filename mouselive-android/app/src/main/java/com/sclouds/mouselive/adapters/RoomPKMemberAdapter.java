package com.sclouds.mouselive.adapters;

import android.content.Context;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.sclouds.basedroid.BaseAdapter;
import com.sclouds.datasource.bean.Anchor;
import com.sclouds.mouselive.R;

import androidx.annotation.NonNull;

/**
 * 房间PK用户列表
 *
 * @author chenhengfei@yy.com
 * @since 2020年1月17日
 */
public class RoomPKMemberAdapter extends BaseAdapter<Anchor, RoomPKMemberAdapter.ViewHolder> {

    public RoomPKMemberAdapter(Context context) {
        super(context);
    }

    @Override
    protected int getLayoutId(int viewType) {
        return R.layout.item_room_pk_members_list;
    }

    @Override
    protected ViewHolder createViewHolder(@NonNull View itemView) {
        return new ViewHolder(itemView);
    }

    static class ViewHolder extends BaseAdapter.BaseViewHolder<Anchor> {

        private TextView tvName;
        private ImageView ivHead;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            tvName = itemView.findViewById(R.id.tvName);
            ivHead = itemView.findViewById(R.id.ivHead);
        }

        @Override
        protected void bind(@NonNull Anchor item) {
            RequestOptions requestOptions = new RequestOptions()
                    .circleCrop()
                    .placeholder(R.mipmap.default_user_icon)
                    .error(R.mipmap.default_user_icon);
            Glide.with(mContext).load(item.getACover()).apply(requestOptions).into(ivHead);
            tvName.setText(item.getAName());
        }
    }
}
