package com.sclouds.mouselive.adapters;

import android.content.Context;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.sclouds.basedroid.BaseAdapter;
import com.sclouds.mouselive.R;

import java.util.ArrayList;
import java.util.List;

import androidx.annotation.LayoutRes;
import androidx.annotation.NonNull;
import androidx.constraintlayout.widget.ConstraintLayout;

/**
 * 创建房间
 *
 * @author chenhengfei@yy.com
 * @since 2020年1月17日
 */
public class CreateRoomAdapter extends
        BaseAdapter<CreateRoomAdapter.RoomType, CreateRoomAdapter.ViewHolder> {

    private int selectIndex = 0;

    public CreateRoomAdapter(Context context) {
        super(context);
        String[] titles = context.getResources().getStringArray(R.array.create_rooms_title);
        String[] create_rooms_info =
                context.getResources().getStringArray(R.array.create_rooms_info);
        List<RoomType> list = new ArrayList<>();
        list.add(new RoomType(R.mipmap.ic_create_video, titles[0], create_rooms_info[0]));
        list.add(new RoomType(R.mipmap.ic_create_audio, titles[1], create_rooms_info[1]));
        setData(list);
    }

    @LayoutRes
    @Override
    protected int getLayoutId(int viewType) {
        return R.layout.item_create_room;
    }

    @NonNull
    @Override
    protected ViewHolder createViewHolder(@NonNull View itemView) {
        return new ViewHolder(itemView);
    }

    class ViewHolder extends BaseAdapter.BaseViewHolder<RoomType> {

        private ConstraintLayout root;
        private TextView tvTitle;
        private TextView tvInfo;
        private ImageView iv;

        public ViewHolder(View itemView) {
            super(itemView);
            root = itemView.findViewById(R.id.root);
            tvTitle = itemView.findViewById(R.id.tvTitle);
            tvInfo = itemView.findViewById(R.id.tvInfo);
            iv = itemView.findViewById(R.id.iv);
        }

        @Override
        protected void bind(@NonNull RoomType item) {
            if (selectIndex == getAdapterPosition()) {
                root.setBackgroundResource(R.drawable.shape_create_room_item_selected);
                itemView.setAlpha(1);
            } else {
                root.setBackgroundResource(R.drawable.shape_create_room_item_unselecte);
                itemView.setAlpha(0.5f);
            }

            tvTitle.setText(item.getTitle());
            tvInfo.setText(item.getInfo());
            iv.setImageResource(item.getResId());
        }
    }

    public int getSelectIndex() {
        return selectIndex;
    }

    public void setSelectIndex(int selectIndex) {
        this.selectIndex = selectIndex;
        notifyDataSetChanged();
    }

    class RoomType {
        private int resId;
        private String title;
        private String info;

        public RoomType(int resId, String title, String info) {
            this.resId = resId;
            this.title = title;
            this.info = info;
        }

        public int getResId() {
            return resId;
        }

        public void setResId(int resId) {
            this.resId = resId;
        }

        public String getTitle() {
            return title;
        }

        public void setTitle(String title) {
            this.title = title;
        }

        public String getInfo() {
            return info;
        }

        public void setInfo(String info) {
            this.info = info;
        }
    }
}
