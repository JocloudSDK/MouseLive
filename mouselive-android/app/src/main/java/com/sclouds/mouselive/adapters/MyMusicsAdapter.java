package com.sclouds.mouselive.adapters;

import android.content.Context;
import android.view.View;
import android.widget.TextView;
import androidx.annotation.NonNull;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import com.sclouds.basedroid.BaseAdapter;
import com.sclouds.datasource.bean.MyMusicsInfo;
import com.sclouds.mouselive.R;

public class MyMusicsAdapter extends BaseAdapter<MyMusicsInfo, MyMusicsAdapter.ViewHolder> {

    public MyMusicsAdapter(Context context) {
        super(context);
    }

    @Override
    protected int getLayoutId(int viewType) {
        return R.layout.item_my_musics_list;
    }

    @Override
    protected ViewHolder createViewHolder(@NonNull View itemView) {
        return new ViewHolder(itemView);
    }

    class ViewHolder extends BaseAdapter.BaseViewHolder<MyMusicsInfo> {

        private TextView mNameTextView;
        private TextView mDateTextView;
        private TextView mDurationTextView;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);

            mNameTextView = itemView.findViewById(R.id.nameTextView);
            mDateTextView = itemView.findViewById(R.id.dateTextView);
            mDurationTextView = itemView.findViewById(R.id.durationTextView);
        }

        @Override
        protected void bind(@NonNull MyMusicsInfo myMusicsInfo) {
            if (null != mNameTextView) {
                mNameTextView.setText(myMusicsInfo.getName());
            }
            if (null != mDateTextView) {
                mDateTextView.setText(formatDateString(myMusicsInfo.getDate()));
            }
            if (null != mDurationTextView) {
                mDurationTextView.setText(formatDurationString(myMusicsInfo.getDuration()));
            }
        }
    }

    private String formatDateString(long date) {
        return new SimpleDateFormat("MM-dd HH:mm", Locale.getDefault()).format(new Date(date));
    }

    private String formatDurationString(long duration) {
        return new SimpleDateFormat("mm:ss", Locale.getDefault()).format(new Date(duration));
    }

}
