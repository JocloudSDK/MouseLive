package com.sclouds.mouselive.adapters;

import android.content.Context;
import android.view.View;
import android.widget.TextView;

import com.sclouds.basedroid.BaseAdapter;
import com.sclouds.mouselive.R;

import java.util.Arrays;

import androidx.annotation.NonNull;

/**
 * 创建房间-选择直播模式
 *
 * @author chenhengfei@yy.com
 * @since 2020年04月22日
 */
public class SelecteRoomPublishModeAdapter extends BaseAdapter<String,
        SelecteRoomPublishModeAdapter.ViewHolder> {

    public SelecteRoomPublishModeAdapter(Context context) {
        super(context);
        String[] create_rooms_info =
                context.getResources().getStringArray(R.array.creat_room_publish_mode);
        setData(Arrays.asList(create_rooms_info));
    }

    @Override
    protected int getLayoutId(int viewType) {
        return R.layout.item_selecte_room_publish_mode;
    }

    @Override
    protected ViewHolder createViewHolder(@NonNull View itemView) {
        return new ViewHolder(itemView);
    }

    static class ViewHolder extends BaseAdapter.BaseViewHolder<String> {

        private TextView tvName;

        public ViewHolder(View itemView) {
            super(itemView);
            tvName = itemView.findViewById(R.id.tvName);
        }

        @Override
        protected void bind(@NonNull String item) {
            tvName.setText(item);
        }
    }
}
