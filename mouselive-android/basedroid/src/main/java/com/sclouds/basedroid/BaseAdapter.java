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
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.StaggeredGridLayoutManager;

/**
 * 基础类
 *
 * @author chenhengfei@yy.com
 * @since 2020年2月20日
 */
public abstract class BaseAdapter<D, BVH extends BaseAdapter.BaseViewHolder<D>>
        extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    @Nullable
    protected List<D> mData;
    protected Context mContext;
    protected OnItemClickListener mItemClickListener;

    private final List<FixedViewInfo> mHeaderViewInfos = new ArrayList<>();

    public interface OnItemClickListener {
        void onItemClick(@NonNull View view, @Size(min = 0) int position);
    }

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.mItemClickListener = listener;
    }

    public BaseAdapter(Context context) {
        this.mContext = context;
    }

    public BaseAdapter(Context context, @NonNull List<D> mData) {
        this.mContext = context;
        this.mData = mData;
    }

    /**
     * 添加HeaderView
     *
     * @param view
     */
    public void addHeaderView(View view) {
        addHeaderView(view, generateUniqueViewType());
    }

    private void addHeaderView(View view, int viewType) {
        //包装HeaderView数据并添加到列表
        FixedViewInfo info = new FixedViewInfo();
        info.view = view;
        info.itemViewType = viewType;
        mHeaderViewInfos.add(info);
        notifyDataSetChanged();
    }

    /**
     * 删除HeaderView
     *
     * @param view
     * @return 是否删除成功
     */
    public boolean removeHeaderView(View view) {
        for (FixedViewInfo info : mHeaderViewInfos) {
            if (info.view == view) {
                mHeaderViewInfos.remove(info);
                notifyDataSetChanged();
                return true;
            }
        }
        return false;
    }

    /**
     * 用于包装HeaderView和FooterView的数据类
     */
    private static class FixedViewInfo {
        //保存HeaderView或FooterView
        View view;

        //保存HeaderView或FooterView对应的viewType。
        int itemViewType;
    }

    /**
     * 生成一个唯一的数，用于标识HeaderView或FooterView的type类型，并且保证类型不会重复。
     */
    private int generateUniqueViewType() {
        int count = getItemCount();
        while (true) {
            //生成一个随机数。
            int viewType = (int) (Math.random() * Integer.MAX_VALUE) + 1;

            //判断该viewType是否已使用。
            boolean isExist = false;
            for (int i = 0; i < count; i++) {
                if (viewType == getItemViewType(i)) {
                    isExist = true;
                    break;
                }
            }

            //判断该viewType还没被使用，则返回。否则进行下一次循环，重新生成随机数。
            if (!isExist) {
                return viewType;
            }
        }
    }

    /**
     * 根据viewType查找对应的HeaderView 或 FooterView。没有找到则返回null。
     *
     * @param viewType 查找的viewType
     */
    private View findViewForInfos(int viewType) {
        for (FixedViewInfo info : mHeaderViewInfos) {
            if (info.itemViewType == viewType) {
                return info.view;
            }
        }
        return null;
    }

    /**
     * 判断当前位置是否是头部View。
     *
     * @param position 这里的position是整个列表(包含HeaderView和FooterView)的position。
     */
    public boolean isHeader(int position) {
        return position < getHeadersCount();
    }

    /**
     * 获取HeaderView的个数
     */
    public int getHeadersCount() {
        return mHeaderViewInfos.size();
    }

    @Override
    public int getItemViewType(int position) {
        //如果当前item是HeaderView，则返回HeaderView对应的itemViewType。
        if (isHeader(position)) {
            return mHeaderViewInfos.get(position).itemViewType;
        }

        //将列表实际的position调整成mAdapter对应的position。
        //交由mAdapter处理。
        int adjPosition = position - getHeadersCount();
        return super.getItemViewType(adjPosition);
    }

    @Override
    public int getItemCount() {
        return mHeaderViewInfos.size() + (mData == null ? 0 : mData.size());
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
        this.mData = data;
        notifyDataSetChanged();
    }

    @Override
    public void onViewAttachedToWindow(@NonNull RecyclerView.ViewHolder holder) {
        super.onViewAttachedToWindow(holder);

        //处理StaggeredGridLayout，保证HeaderView和FooterView占满一行。
        if (isStaggeredGridLayout(holder)) {
            handleLayoutIfStaggeredGridLayout(holder, holder.getLayoutPosition());
        }
    }

    private boolean isStaggeredGridLayout(RecyclerView.ViewHolder holder) {
        ViewGroup.LayoutParams layoutParams = holder.itemView.getLayoutParams();
        if (layoutParams != null &&
                layoutParams instanceof StaggeredGridLayoutManager.LayoutParams) {
            return true;
        }
        return false;
    }

    private void handleLayoutIfStaggeredGridLayout(RecyclerView.ViewHolder holder, int position) {
        if (isHeader(position)) {
            StaggeredGridLayoutManager.LayoutParams p = (StaggeredGridLayoutManager.LayoutParams)
                    holder.itemView.getLayoutParams();
            p.setFullSpan(true);
        }
    }

    @LayoutRes
    protected abstract int getLayoutId(int viewType);

    protected abstract BVH createViewHolder(@NonNull View itemView);

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = findViewForInfos(viewType);
        if (view != null) {
            return new HeaderViewHolder(view);
        } else {
            View itemView =
                    LayoutInflater.from(mContext).inflate(getLayoutId(viewType), parent, false);
            BVH mHolder = createViewHolder(itemView);
            mHolder.setItemClickListener(mItemClickListener);
            return mHolder;
        }
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        // 如果是HeaderView 或者是 FooterView则不绑定数据。
        // 因为HeaderView和FooterView是由外部传进来的，它们不由列表去更新。
        if (isHeader(position)) {
            return;
        }

        if (mData == null) {
            return;
        }
        ((BVH) holder).bind(mData.get(position));
    }

    /**
     * 添加数据 更新数据集不是用adapter.notifyDataSetChanged()而是notifyItemInserted(position)与notifyItemRemoved(position)
     * 否则没有动画效果
     */
    public void addItem(@NonNull D data) {
        if (mData == null) {
            mData = new ArrayList<>();
        }

        mData.add(data);
        notifyItemInserted(mData.size() - 1);
    }

    /**
     * 添加数据 更新数据集不是用adapter.notifyDataSetChanged()而是notifyItemInserted(position)与notifyItemRemoved(position)
     * 否则没有动画效果
     */
    public void addItem(@Size(min = 0) int postion, @NonNull D data) {
        if (mData == null) {
            mData = new ArrayList<>();
        }

        mData.add(postion, data);
        notifyItemInserted(postion);
    }

    /**
     * 删除
     */
    public void deleteItem(@Size(min = 0) int posion) {
        if (mData == null || mData.isEmpty()) {
            return;
        }

        if (0 <= posion && posion < mData.size()) {
            mData.remove(posion);
            notifyItemRemoved(posion);
        }
    }

    /**
     * 删除
     */
    public void deleteItem(@NonNull D data) {
        if (mData == null || mData.isEmpty()) {
            return;
        }

        int index = mData.indexOf(data);
        if (0 <= index && index < mData.size()) {
            mData.remove(data);
            notifyItemRemoved(index);
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

        public BaseViewHolder(@NonNull View itemView) {
            super(itemView);
            mContext = itemView.getContext();
            itemView.setOnClickListener((view) -> {
                if (mItemClickListener != null) {
                    mItemClickListener.onItemClick(view, getAdapterPosition());
                }
            });
        }

        public void setItemClickListener(OnItemClickListener itemClickListener) {
            mItemClickListener = itemClickListener;
        }

        protected abstract void bind(@NonNull D d);
    }

    private static class HeaderViewHolder extends RecyclerView.ViewHolder {
        HeaderViewHolder(View itemView) {
            super(itemView);
        }
    }
}
