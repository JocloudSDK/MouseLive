package com.sclouds.mouselive.adapters;

import android.content.Context;
import android.view.View;
import android.widget.ImageView;

import com.bumptech.glide.Glide;
import com.sclouds.basedroid.BaseAdapter;
import com.sclouds.mouselive.R;

import androidx.annotation.NonNull;

/**
 * 意见反馈，图片列表
 *
 * @author chenhengfei@yy.com
 * @since 2020年1月17日
 */
public class FeedbackPhotoAdapter extends BaseAdapter<String, FeedbackPhotoAdapter.ViewHolder> {

    private ISubViewClick mISubViewClick;

    public FeedbackPhotoAdapter(Context context, ISubViewClick mISubViewClick) {
        super(context);
        this.mISubViewClick = mISubViewClick;
    }

    @Override
    protected int getLayoutId(int viewType) {
        return R.layout.item_photos;
    }

    @Override
    protected ViewHolder createViewHolder(@NonNull View itemView) {
        return new ViewHolder(itemView);
    }

    class ViewHolder extends BaseAdapter.BaseViewHolder<String> {

        private ImageView ivClose;
        private ImageView ivPhoto;

        public ViewHolder(View itemView) {
            super(itemView);
            ivClose = itemView.findViewById(R.id.ivClose);
            ivPhoto = itemView.findViewById(R.id.ivPhoto);

            ivClose.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    deleteItem(getAdapterPosition());
                }
            });

            ivClose.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    deleteItem(getAdapterPosition());
                }
            });
            ivPhoto.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (getAdapterPosition() != mData.size() - 1) {
                        return;
                    }
                    mISubViewClick.onSubViewClick(v, getAdapterPosition());
                }
            });
        }

        @Override
        protected void bind(@NonNull String item) {
            if (getAdapterPosition() == mData.size() - 1) {
                ivClose.setVisibility(View.GONE);
                Glide.with(itemView).load(R.mipmap.ic_feedback_upload_photo).into(ivPhoto);
            } else {
                ivClose.setVisibility(View.VISIBLE);
                Glide.with(itemView).load(item).into(ivPhoto);
            }
        }
    }

    public interface ISubViewClick {
        void onSubViewClick(@NonNull View view, int position);
    }
}
