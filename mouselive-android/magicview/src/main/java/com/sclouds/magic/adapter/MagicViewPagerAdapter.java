package com.sclouds.magic.adapter;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentPagerAdapter;

import com.sclouds.magic.fragment.MagicBeautyFragment;
import com.sclouds.magic.fragment.MagicEmptyFragment;
import com.sclouds.magic.fragment.MagicFaceFragment;
import com.sclouds.magic.fragment.MagicFilterFragment;
import com.sclouds.magic.fragment.MagicGestureFragment;
import com.sclouds.magic.fragment.MagicStickerFragment;
import com.sclouds.magic.config.MagicConfig;

public class MagicViewPagerAdapter extends FragmentPagerAdapter {

    private String[] mTitles = null;

    public MagicViewPagerAdapter(@NonNull FragmentManager fm) {
        super(fm);
    }

    @NonNull
    @Override
    public Fragment getItem(int position) {
        if (MagicConfig.MagicTypeEnum.MAGIC_TYPE_SKIN.getValue() == position) {
            return new MagicBeautyFragment();
        } else if (MagicConfig.MagicTypeEnum.MAGIC_TYPE_FILTER.getValue() == position) {
            return new MagicFilterFragment();
        } else if (MagicConfig.MagicTypeEnum.MAGIC_TYPE_FACE.getValue() == position) {
            return new MagicFaceFragment();
        } else if (MagicConfig.MagicTypeEnum.MAGIC_TYPE_STICKER.getValue() == position) {
            return new MagicStickerFragment();
        } else if (MagicConfig.MagicTypeEnum.MAGIC_TYPE_GESTURE.getValue() == position) {
            return new MagicGestureFragment();
        } else {
            return new MagicEmptyFragment();
        }
    }

    @Override
    public int getCount() {
        return mTitles.length;
    }

    @Nullable
    @Override
    public CharSequence getPageTitle(int position) {
        return mTitles[position];
    }

    public void setTitles(String[] titles) {
        this.mTitles = titles;
        notifyDataSetChanged();
    }

}
