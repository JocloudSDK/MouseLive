package com.sclouds.mouselive.adapters;

import android.content.Context;
import android.view.View;

import com.sclouds.basedroid.BaseAdapter;
import com.sclouds.datasource.bean.RoomUser;
import com.sclouds.datasource.bean.User;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.widget.MyThunderPlayerView;
import com.sclouds.mouselive.widget.MyThunderPreviewView;

import java.util.ArrayList;

import androidx.annotation.NonNull;

/**
 * 直播视频
 *
 * @author chenhengfei@yy.com
 * @since 2020年1月17日
 */
public class LiveAdapter extends BaseAdapter<RoomUser, LiveAdapter.ViewHolder> {

    private static final int TYPE_PREVIEW = 1;//本地
    private static final int TYPE_PLAYVIEW = 2;//远程

    private User ROwner;

    public LiveAdapter(Context context, User ROwner) {
        super(context);
        this.ROwner = ROwner;
    }

    @Override
    protected int getLayoutId(int viewType) {
        int layoutId = 0;
        switch (viewType) {
            case TYPE_PREVIEW:
                layoutId = R.layout.item_preview;
                break;
            case TYPE_PLAYVIEW:
                layoutId = R.layout.item_playview;
                break;
            default:
                break;
        }
        return layoutId;
    }

    @Override
    protected ViewHolder createViewHolder(@NonNull View itemView) {
        return new ViewHolder(itemView);
    }

    @Override
    public int getItemViewType(int position) {
        RoomUser user = getDataAtPosition(position);
        if (user.getUserType() == RoomUser.UserType.Local) {
            return TYPE_PREVIEW;
        }
        return TYPE_PLAYVIEW;
    }

    class ViewHolder extends BaseAdapter.BaseViewHolder<RoomUser> {

        private View myview;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            myview = itemView.findViewById(R.id.myview);
        }

        @Override
        protected void bind(@NonNull RoomUser item) {
            if (item.getUserType() == RoomUser.UserType.Local) {
                MyThunderPreviewView mPreviewView = (MyThunderPreviewView) myview;
                mPreviewView.bindUID(item.getUid());

                mPreviewView.setLinkRoomUser(ROwner, item);
            } else {
                MyThunderPlayerView mPlayerView = (MyThunderPlayerView) myview;
                mPlayerView.bindUID(item.getUid());

                mPlayerView.setLinkRoomUser(ROwner, item);
            }
        }
    }

    @Override
    public void addItem(int postion, @NonNull RoomUser data) {
        if (mData == null) {
            mData = new ArrayList<>();
        }

        if (mData.contains(data)) {
            return;
        }

        super.addItem(postion, data);
    }

    @Override
    public void addItem(@NonNull RoomUser data) {
        if (mData == null) {
            mData = new ArrayList<>();
        }

        if (mData.contains(data)) {
            return;
        }

        super.addItem(data);
    }

    @Override
    public void deleteItem(@NonNull RoomUser data) {
        if (mData == null || mData.isEmpty()) {
            return;
        }

        if (mData.contains(data) == false) {
            return;
        }

        super.deleteItem(data);
    }

    public void refreshUser(RoomUser user) {
        if (mData == null || mData.isEmpty()) {
            return;
        }

        int index = mData.indexOf(user);
        if (index >= 0) {
            notifyItemChanged(index);
        }
    }
}
