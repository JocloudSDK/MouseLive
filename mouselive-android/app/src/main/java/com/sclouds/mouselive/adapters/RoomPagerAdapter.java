package com.sclouds.mouselive.adapters;

import android.content.Context;

import com.sclouds.datasource.bean.Room;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.views.MainRoomListFragment;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentStatePagerAdapter;

/**
 * 房间列表
 *
 * @author Aslan chenhengfei@yy.com
 * @date 2020/3/6
 */
public class RoomPagerAdapter extends FragmentStatePagerAdapter {
    private String[] titles;

    public RoomPagerAdapter(Context context, @NonNull FragmentManager fm) {
        super(fm);
        titles = context.getResources().getStringArray(R.array.rooms_titles);
    }

    @NonNull
    @Override
    public Fragment getItem(int position) {
        if (position == 0) {
            return MainRoomListFragment.newInstance(Room.ROOM_TYPE_LIVE);
        } else if (position == 1) {
            return MainRoomListFragment.newInstance(Room.ROOM_TYPE_CHAT);
        } else {
            return MainRoomListFragment.newInstance(Room.ROOM_TYPE_KTV);
        }
    }

    @Override
    public int getCount() {
        return titles.length;
    }

    @Nullable
    @Override
    public CharSequence getPageTitle(int position) {
        return titles[position];
    }
}
