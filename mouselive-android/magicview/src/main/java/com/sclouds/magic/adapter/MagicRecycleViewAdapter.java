package com.sclouds.magic.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.Size;
import androidx.recyclerview.widget.RecyclerView;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.bumptech.glide.request.RequestOptions;
import com.sclouds.magic.R;
import com.sclouds.magic.bean.MagicEffect;
import com.sclouds.magic.config.MagicConfig;

public class MagicRecycleViewAdapter extends RecyclerView.Adapter<MagicRecycleViewAdapter.ViewHolder> {

    private Context mContext;

    private int mType;

    protected OnItemClickListener mItemClickListener = null;
    private OnEffectEnableListener mEffectEnableListener = null;

    private static final Object mDataLockObject = new Object();
    private List<MagicEffect> mData = new ArrayList<>();

    public MagicRecycleViewAdapter(Context context, int type) {
        this.mContext = context;
        this.mType = type;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View itemView = LayoutInflater.from(mContext).inflate(R.layout.layout_magic_recyclerview_item, parent, false);
        ViewHolder viewHolder = new ViewHolder(itemView, mType);
        viewHolder.setItemClickListener(mItemClickListener);
        return viewHolder;
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        holder.bind(mData.get(position));
    }

    @Override
    public int getItemCount() {
        return mData.size();
    }

    @Nullable
    public MagicEffect getDataAtPosition(@Size(min = 0) int position) {
        synchronized (mDataLockObject) {
            if ((null == mData) || (position < 0) || (position >= mData.size())) {
                return null;
            }
            return mData.get(position);
        }
    }

    public MagicEffect getSelectedData() {
        synchronized (mDataLockObject) {
            if ((mType >= MagicConfig.MagicTypeEnum.MAGIC_TYPE_FILTER.getValue())
                    || (mType <= MagicConfig.MagicTypeEnum.MAGIC_TYPE_STICKER.getValue())) {
                // 滤镜、高级整形、贴纸只允许同时选中一个
                for (int i = 0; i < mData.size(); i++) {
                    MagicEffect magicEffect = mData.get(i);
                    if (magicEffect.isSelected()) {
                        return magicEffect;
                    }
                }
            }
            return null;
        }
    }

    public int getSelectedPosition() {
        synchronized (mDataLockObject) {
            if ((mType >= MagicConfig.MagicTypeEnum.MAGIC_TYPE_FILTER.getValue())
                    || (mType <= MagicConfig.MagicTypeEnum.MAGIC_TYPE_STICKER.getValue())) {
                // 滤镜、高级整形、贴纸只允许同时选中一个
                for (int i = 0; i < mData.size(); i++) {
                    MagicEffect magicEffect = mData.get(i);
                    if (magicEffect.isSelected()) {
                        return i;
                    }
                }
            }
            return -1;
        }
    }

    public void updateDownloadStatus(MagicEffect magicEffect) {
        synchronized (mDataLockObject) {
            if ((null == mData) || (null == magicEffect)) {
                return;
            }
            for (MagicEffect effect : mData) {
                if (effect.getName().equals(magicEffect.getName())) {
                    effect.setDownloadStatus(magicEffect.getDownloadStatus());
                }
            }
            notifyDataSetChanged();
        }
    }

    public void updateSelectedStatusAtPosition(int position) {
        synchronized (mDataLockObject) {
            if ((null == mData) || (position < 0) || (position >= mData.size())) {
                return;
            }
            if (mType <= MagicConfig.MagicTypeEnum.MAGIC_TYPE_STICKER.getValue()) {
                // 滤镜、五官整形、贴纸三种类型只允许同时选中一个效果，选中一个效果时取消之前选中效果
                for (int i = 0; i < mData.size(); i++) {
                    MagicEffect magicEffect = mData.get(i);
                    if (i == position) {
                        continue;
                    }
                    if (!magicEffect.isSelected()) {
                        continue;
                    }
                    if (null != mEffectEnableListener) {
                        mEffectEnableListener.onEffectEnable(i, false);
                    }
                    magicEffect.setSelected(false);
                    notifyItemChanged(i);
                    break;
                }
            }
            MagicEffect effect = mData.get(position);
            if (null != mEffectEnableListener) {
                mEffectEnableListener.onEffectEnable(position, !effect.isSelected());
            }
            effect.setSelected(!effect.isSelected());
            notifyItemChanged(position);
        }
    }

    public List<MagicEffect> getData() {
        synchronized (mDataLockObject) {
            return mData;
        }
    }

    public void setData(List<MagicEffect> data) {
        synchronized (mDataLockObject) {
            this.mData.clear();
            if (mType >= MagicConfig.MagicTypeEnum.MAGIC_TYPE_STICKER.getValue()) {
                // 贴纸和手势第一个 Item 为点击关闭特效图标
                MagicEffect magicEffect = new MagicEffect();
                magicEffect.setName(mContext.getResources().getString(R.string.magic_close_tip));
                magicEffect.setSelected(false);
                magicEffect.setDownloadStatus(MagicEffect.DownloadStatus.DOWNLOADED);
                this.mData.add(magicEffect);
            }
            this.mData.addAll(data);
            notifyDataSetChanged();
        }
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.mItemClickListener = listener;
    }

    public void setEffectEnableListener(OnEffectEnableListener effectEnableListener) {
        mEffectEnableListener = effectEnableListener;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {

        private RequestOptions mSkinFaceRoundOptions = new RequestOptions().
                placeholder(R.drawable.magic_original).transform(new RoundedCorners(10));

        private RequestOptions mStickerGestureRoundOptions = new RequestOptions().
                placeholder(R.mipmap.magic_default).transform(new RoundedCorners(10));

        private int mType;
        private Context mContext;
        private ImageView mEffectImageView;
        private ImageView mSelectedImageView;
        private ImageView mReadyImageView;
        private ImageView mDownloadImageView;
        private ProgressBar mLoadingProgressBar;
        private TextView mNameTextView;

        private OnItemClickListener mItemClickListener;

        @SuppressLint("ClickableViewAccessibility")
        public ViewHolder(@NonNull View itemView, int type) {
            super(itemView);

            mType = type;

            mContext = itemView.getContext();

            mEffectImageView = itemView.findViewById(R.id.effectImageView);
            mSelectedImageView = itemView.findViewById(R.id.selectedImageView);
            mReadyImageView = itemView.findViewById(R.id.readyImageView);
            mDownloadImageView = itemView.findViewById(R.id.downloadImageView);
            mLoadingProgressBar = itemView.findViewById(R.id.loadingProgressBar);
            mNameTextView = itemView.findViewById(R.id.nameTextView);

            itemView.setOnClickListener(this);
            mDownloadImageView.setOnClickListener(this);
        }

        public void bind(MagicEffect magicEffect) {
            if (mType <= MagicConfig.MagicTypeEnum.MAGIC_TYPE_FACE.getValue()) {
                Glide.with(mContext).load(magicEffect.getThumb()).apply(mSkinFaceRoundOptions).into(mEffectImageView);
            } else {
                Glide.with(mContext).load(magicEffect.getThumb()).apply(mStickerGestureRoundOptions).into(mEffectImageView);
            }
            if ((null != magicEffect.getPath()) && new File(magicEffect.getPath()).exists()) {
                magicEffect.setDownloadStatus(MagicEffect.DownloadStatus.DOWNLOADED);
            }
            mDownloadImageView.setVisibility(MagicEffect.DownloadStatus.UNDOWNLOAD.equals(magicEffect.getDownloadStatus()) ? View.VISIBLE : View.GONE);
            mReadyImageView.setVisibility((mType == MagicConfig.MagicTypeEnum.MAGIC_TYPE_GESTURE.getValue())
                    && magicEffect.isSelected() && MagicEffect.DownloadStatus.DOWNLOADED.equals(magicEffect.getDownloadStatus())? View.VISIBLE : View.GONE);
            mSelectedImageView.setVisibility(magicEffect.isSelected() ? View.VISIBLE : View.GONE);
            mLoadingProgressBar.setVisibility(MagicEffect.DownloadStatus.DOWNLOADING.equals(magicEffect.getDownloadStatus()) ? View.VISIBLE : View.GONE);
            mNameTextView.setVisibility(mType <= MagicConfig.MagicTypeEnum.MAGIC_TYPE_FACE.getValue() ? View.VISIBLE : View.GONE);
            mNameTextView.setText(magicEffect.getShowName());
            mNameTextView.setTextColor(magicEffect.isSelected() ?
                    mContext.getResources().getColor(R.color.magic_tab_text_selected) : mContext.getResources().getColor(R.color.magic_tab_text_unselected));
        }

        public void setItemClickListener(OnItemClickListener itemClickListener) {
            mItemClickListener = itemClickListener;
        }

        @Override
        public void onClick(View v) {
            if (null != mItemClickListener) {
                mItemClickListener.onItemClick(v, getAdapterPosition());
            }
        }

    }

    public interface OnItemClickListener {
        void onItemClick(@NonNull View view, @Size(min = 0) int position);
    }

    public interface OnEffectEnableListener {
        void onEffectEnable(int position, boolean enable);
    }

}
