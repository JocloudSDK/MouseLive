package com.sclouds.mouselive.widget;

import android.content.Context;
import android.graphics.Rect;
import android.view.View;

import com.sclouds.basedroid.util.AppUtil;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

public class LiveDecoration extends RecyclerView.ItemDecoration {

    private int offset = 0;

    public LiveDecoration(Context context) {
        offset = AppUtil.dip2px(4);
    }

    @Override
    public void getItemOffsets(@NonNull Rect outRect, @NonNull View view,
                               @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
        super.getItemOffsets(outRect, view, parent, state);
        if (parent.getChildAdapterPosition(view) == 0) {
            outRect.set(0, 0, offset, 0);
        } else if (parent.getChildAdapterPosition(view) == state.getItemCount() - 1) {
            outRect.set(offset, 0, 0, 0);
        } else {
            outRect.set(offset, 0, offset, 0);
        }
    }
}
