package com.sclouds.mouselive.views;

import android.graphics.Typeface;
import android.os.Bundle;
import android.util.TypedValue;
import android.view.View;
import android.widget.TextView;

import com.google.android.material.tabs.TabLayout;
import com.sclouds.basedroid.BaseFragment;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.adapters.RoomPagerAdapter;
import com.sclouds.mouselive.databinding.FragmentMainRoomFatherBinding;

import androidx.core.content.ContextCompat;

/**
 * 首页-主页
 *
 * @author chenhengfei@yy.com
 * @since 2020年2月19日
 */
public class MainRoomsFatherFragment extends BaseFragment<FragmentMainRoomFatherBinding>
        implements TabLayout.OnTabSelectedListener {

    public static MainRoomsFatherFragment newInstance() {
        Bundle args = new Bundle();
        MainRoomsFatherFragment fragment = new MainRoomsFatherFragment();
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void initView(View view) {
        String[] titles = getResources().getStringArray(R.array.rooms_titles);
        RoomPagerAdapter adapter = new RoomPagerAdapter(getContext(), getParentFragmentManager());
        mBinding.viewpager.setAdapter(adapter);
        mBinding.tabLayout.setupWithViewPager(mBinding.viewpager);

        for (int i = 0; i < titles.length; i++) {
            TabLayout.Tab tabAt = mBinding.tabLayout.getTabAt(i);
            tabAt.setCustomView(R.layout.layout_tab_text);
            TextView textView = tabAt.getCustomView().findViewById(R.id.tvTab);
            textView.setText(titles[i]);

            if (i == 0) {
                textView.setSelected(true);
                textView.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));
                textView.setTextSize(TypedValue.COMPLEX_UNIT_PX, this.getResources()
                        .getDimensionPixelSize(R.dimen.main_room_tab_text_selected));
                textView.setTextColor(
                        ContextCompat.getColor(getContext(), R.color.main_room_tab_text_selected));
            }
        }

        mBinding.tabLayout.addOnTabSelectedListener(this);
    }

    @Override
    public void initData() {

    }

    @Override
    public int getLayoutResId() {
        return R.layout.fragment_main_room_father;
    }

    @Override
    public void onTabSelected(TabLayout.Tab tab) {
        View view = tab.getCustomView();
        if (view == null) {
            return;
        }
        TextView textView = view.findViewById(R.id.tvTab);
        textView.setSelected(true);
        textView.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));
        textView.setTextSize(TypedValue.COMPLEX_UNIT_PX, this.getResources()
                .getDimensionPixelSize(R.dimen.main_room_tab_text_selected));
        textView.setTextColor(
                ContextCompat.getColor(getContext(), R.color.main_room_tab_text_selected));
    }

    @Override
    public void onTabUnselected(TabLayout.Tab tab) {
        View view = tab.getCustomView();
        if (view == null) {
            return;
        }
        TextView textView = view.findViewById(R.id.tvTab);
        textView.setSelected(false);
        textView.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));
        textView.setTextSize(TypedValue.COMPLEX_UNIT_PX, this.getResources()
                .getDimensionPixelSize(R.dimen.main_room_tab_text_unselected));
        textView.setTextColor(
                ContextCompat.getColor(getContext(), R.color.main_room_tab_text_unselected));
    }

    @Override
    public void onTabReselected(TabLayout.Tab tab) {

    }

    @Override
    public void onDestroy() {
        mBinding.tabLayout.removeOnTabSelectedListener(this);
        super.onDestroy();
    }
}
