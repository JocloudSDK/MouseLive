package com.sclouds.mouselive.views;

import android.view.View;

import com.sclouds.basedroid.BaseAdapter;
import com.sclouds.basedroid.BaseFragment;
import com.sclouds.datasource.bean.Room;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.adapters.KTVMusicAdapter;
import com.sclouds.mouselive.databinding.FragmentKtvChatingBinding;
import com.sclouds.mouselive.views.dialog.KTVMusicMenuDialog;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;

/**
 * KTV-排麦
 *
 * @author chenhengfei@yy.com
 * @since 2020/07/07
 */
public class KTVChatingFragment extends BaseFragment<FragmentKtvChatingBinding> {

    private Room mRoom;
    private KTVMusicAdapter mAdapter;

    public KTVChatingFragment() {
    }

    @Override
    public void initView(View view) {
        mAdapter = new KTVMusicAdapter(getContext());
        mBinding.rvMusics.setLayoutManager(new LinearLayoutManager(getContext()));
        mBinding.rvMusics.setAdapter(mAdapter);
        mAdapter.setOnItemClickListener(new BaseAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(@NonNull View view, int position) {

            }
        });
    }

    @Override
    public void initData() {
    }

    @Override
    public int getLayoutResId() {
        return R.layout.fragment_ktv_chating;
    }

    private void addItem(KTVMusicAdapter.MusicModel model) {
        mAdapter.addItem(model);
    }

    private void showMenu(KTVMusicAdapter.MusicModel model, int position) {
        KTVMusicMenuDialog dialog = new KTVMusicMenuDialog();
        dialog.show(getParentFragmentManager(), model, new KTVMusicMenuDialog.IMusicMenuCallback() {
        });
    }
}
