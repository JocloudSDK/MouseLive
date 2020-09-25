package com.sclouds.mouselive.widget;

import android.graphics.Rect;
import android.util.DisplayMetrics;
import android.view.View;

import com.sclouds.basedroid.util.AppUtil;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

/**
 * 变声滑动list间距，控制第一个和最后一个item
 *
 * @author Aslan chenhengfei@yy.com
 * @since 2019/12/26
 */
public class GalleryItemDecoration extends RecyclerView.ItemDecoration {
    private int mPageMargin;
    private int mLeftPageVisibleWidth;

    public GalleryItemDecoration() {
        mPageMargin = AppUtil.dip2px(10);
        DisplayMetrics displayMetrics = AppUtil.getDisplayMetrics();
        mLeftPageVisibleWidth = displayMetrics.widthPixels / 2;
    }

    @Override
    public void getItemOffsets(@NonNull Rect outRect, @NonNull View view,
                               @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
        int viewWidth = view.getMeasuredWidth();
        int edgeMargin = (parent.getWidth() - viewWidth) / 2;
        int position = parent.getChildAdapterPosition(view);

        // if (position == 0) {
        //     outRect.left = edgeMargin + 100;
        // } else {
        outRect.left = mPageMargin;
        // }

        // if (position == state.getItemCount() - 1) {
        //     outRect.right = edgeMargin;
        // } else {
        outRect.right = mPageMargin;
        // }
    }
}
