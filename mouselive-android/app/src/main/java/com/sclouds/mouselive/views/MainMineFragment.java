package com.sclouds.mouselive.views;

import android.os.Bundle;
import android.view.View;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.sclouds.basedroid.BaseFragment;
import com.sclouds.datasource.bean.User;
import com.sclouds.datasource.database.DatabaseSvc;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.databinding.FragmentMainMineBinding;

import androidx.annotation.NonNull;

/**
 * 首页-我的
 *
 * @author chenhengfei@yy.com
 * @since 2020年2月19日
 */
public class MainMineFragment extends BaseFragment<FragmentMainMineBinding>
        implements View.OnClickListener {

    public static MainMineFragment newInstance() {
        Bundle args = new Bundle();
        MainMineFragment fragment = new MainMineFragment();
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void initView(View view) {
        mBinding.btSetting.setOnClickListener(this);
    }

    @Override
    public void initData() {
        User user = DatabaseSvc.getIntance().getUser();
        if (user != null) {
            setUserInfo(user);
        }
    }

    private void setUserInfo(@NonNull User user) {
        RequestOptions requestOptions = new RequestOptions()
                .circleCrop()
                .placeholder(R.mipmap.default_user_icon)
                .error(R.mipmap.default_user_icon);
        Glide.with(getContext()).load(user.getCover()).apply(requestOptions).into(mBinding.ivHead);

        mBinding.tvName.setText(user.getNickName());
        mBinding.tvUID.setText(getString(R.string.setting_uid, String.valueOf(user.getUid())));
    }

    @Override
    public int getLayoutResId() {
        return R.layout.fragment_main_mine;
    }

    private void gotoSetting() {
        SettingActivity.startActivity(getContext());
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.btSetting) {
            gotoSetting();
        }
    }
}
