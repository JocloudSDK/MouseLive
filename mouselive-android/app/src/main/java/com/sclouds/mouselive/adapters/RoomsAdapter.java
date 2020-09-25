package com.sclouds.mouselive.adapters;

import android.content.Context;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.sclouds.basedroid.BaseAdapter;
import com.sclouds.datasource.bean.Room;
import com.sclouds.mouselive.R;

import androidx.annotation.NonNull;

/**
 * 房间列表
 *
 * @author chenhengfei@yy.com
 * @since 2020年1月17日
 */
public class RoomsAdapter extends BaseAdapter<Room, RoomsAdapter.ViewHolder> {

    public RoomsAdapter(Context context) {
        super(context);
    }

    @Override
    protected int getLayoutId(int viewType) {
        return R.layout.item_main_list;
    }

    @Override
    protected ViewHolder createViewHolder(@NonNull View itemView) {
        return new ViewHolder(itemView);
    }

    class ViewHolder extends BaseAdapter.BaseViewHolder<Room> {

        private TextView tvPeople;
        private TextView tvRoomName;
        private TextView tvUserName;
        private ImageView ivHead;

        public ViewHolder(View itemView) {
            super(itemView);
            tvPeople = itemView.findViewById(R.id.tvPeople);
            tvRoomName = itemView.findViewById(R.id.tvRoomName);
            tvUserName = itemView.findViewById(R.id.tvUserName);
            ivHead = itemView.findViewById(R.id.ivHead);
        }

        @Override
        protected void bind(@NonNull Room item) {
            RequestOptions requestOptions = new RequestOptions()
                    .placeholder(R.mipmap.ic_room_list_default)
                    .error(R.mipmap.ic_room_list_default);
            Glide.with(ivHead.getContext()).load(item.getRCover()).apply(requestOptions)
                    .into(ivHead);
            tvRoomName.setText(item.getRName());
            tvUserName.setText(item.getROwner().getNickName());
            tvPeople.setText(String.valueOf(item.getRCount()));
        }
    }
}
