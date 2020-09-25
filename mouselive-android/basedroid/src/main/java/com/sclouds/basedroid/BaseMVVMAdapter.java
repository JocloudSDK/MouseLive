package com.sclouds.basedroid;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import java.util.ArrayList;
import java.util.List;

import androidx.annotation.LayoutRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.Size;
import androidx.core.util.ObjectsCompat;
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.RecyclerView;

/**
 * 基础类，集成了DiffUtil.Callback
 *
 * @author chenhengfei@yy.com
 * @since 2020年2月20日
 */
public abstract class BaseMVVMAdapter<D, BVH extends BaseMVVMAdapter.BaseViewHolder<D>>
        extends RecyclerView.Adapter<BVH> {
    protected List<D> mData;
    protected Context mContext;
    protected OnItemClickListener mItemClickListener;

    public interface OnItemClickListener {
        void onItemClick(@NonNull View view, @Size(min = 0) int position);
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.mItemClickListener = listener;
    }

    public BaseMVVMAdapter(Context context) {
        this.mContext = context;
    }

    public BaseMVVMAdapter(Context context, List<D> mData) {
        this.mContext = context;
        this.mData = mData;
    }

    @Override
    public int getItemCount() {
        return mData == null ? 0 : mData.size();
    }

    @Nullable
    public D getDataAtPosition(@Size(min = 0) int position) {
        if (mData == null) {
            return null;
        }

        if (position >= mData.size()) {
            return null;
        }
        return mData.get(position);
    }

    public void setData(@NonNull List<D> data) {
        if (mData == null) {
            mData = new ArrayList<>(data);
            notifyDataSetChanged();
        } else {
            DiffUtil.DiffResult diffResult =
                    DiffUtil.calculateDiff(createCallback(mData, data), true);
            mData.clear();
            mData.addAll(data);
            diffResult.dispatchUpdatesTo(this);
        }
    }

    @LayoutRes
    protected abstract int getLayoutId(int viewType);

    @NonNull
    protected abstract BVH createViewHolder(@NonNull View itemView);

    protected abstract DiffUtil.Callback createCallback(@NonNull List<D> oldData,
                                                        @NonNull List<D> newData);

    @NonNull
    @Override
    public BVH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View itemView =
                LayoutInflater.from(mContext).inflate(getLayoutId(viewType), parent, false);
        BVH mHolder = createViewHolder(itemView);
        mHolder.setItemClickListener(mItemClickListener);
        return mHolder;
    }

    @Override
    public void onBindViewHolder(@NonNull BVH holder, int position) {
        holder.bind(mData.get(position));
    }

    @Override
    public void onBindViewHolder(@NonNull BVH holder, int position,
                                 @NonNull List<Object> payloads) {
        if (payloads.isEmpty()) {
            onBindViewHolder(holder, position);
        } else {
            holder.onChangePayloads(payloads);
        }
    }

    public void clear() {
        if (mData == null || mData.isEmpty()) {
            return;
        }

        mData.clear();
        notifyDataSetChanged();
    }

    public static abstract class BaseViewHolder<D> extends RecyclerView.ViewHolder {
        protected Context mContext;
        protected OnItemClickListener mItemClickListener;

        public BaseViewHolder(View itemView) {
            super(itemView);
            mContext = itemView.getContext();
            itemView.setOnClickListener((view) -> {
                if (mItemClickListener != null) {
                    mItemClickListener.onItemClick(view, getAdapterPosition());
                }
            });
        }

        public void setItemClickListener(
                OnItemClickListener itemClickListener) {
            mItemClickListener = itemClickListener;
        }

        protected abstract void bind(@NonNull D d);

        protected abstract void onChangePayloads(@NonNull List<Object> payloads);
    }

    public static abstract class BaseDiffCallBack<D> extends DiffUtil.Callback {

        protected List<D> oldData;
        protected List<D> newData;

        public BaseDiffCallBack(List<D> oldData, List<D> newData) {
            this.oldData = oldData;
            this.newData = newData;
        }

        @Override
        public int getOldListSize() {
            return oldData.size();
        }

        @Override
        public int getNewListSize() {
            return newData.size();
        }

        @Override
        public boolean areItemsTheSame(int oldItemPosition, int newItemPosition) {
            return ObjectsCompat.equals(oldData.get(oldItemPosition), newData.get(newItemPosition));
        }

        @Override
        public boolean areContentsTheSame(int oldItemPosition, int newItemPosition) {
            return ObjectsCompat.equals(oldData.get(oldItemPosition), newData.get(newItemPosition));
        }

        @Nullable
        @Override
        public Object getChangePayload(int oldItemPosition, int newItemPosition) {
            return newData.get(newItemPosition);
        }
    }
}
