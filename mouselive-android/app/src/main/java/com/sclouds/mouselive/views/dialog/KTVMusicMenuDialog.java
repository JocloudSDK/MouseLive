package com.sclouds.mouselive.views.dialog;

import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;

import com.sclouds.basedroid.BaseDataBindDialog;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.adapters.KTVMusicAdapter;
import com.sclouds.mouselive.databinding.LayoutKtvMusicMenuBinding;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;

/**
 * KTV-排麦歌曲菜单
 *
 * @author chenhengfei@yy.com
 * @since 2020年2月20日
 */
public class KTVMusicMenuDialog extends BaseDataBindDialog<LayoutKtvMusicMenuBinding> implements
        View.OnClickListener {

    private static final String TAG = KTVMusicMenuDialog.class.getSimpleName();
    private static final String TAG_MODEL = "model";

    private KTVMusicAdapter.MusicModel mMusicModel;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        Window win = getDialog().getWindow();
        WindowManager.LayoutParams params = win.getAttributes();
        params.gravity = Gravity.BOTTOM;
        params.width = ViewGroup.LayoutParams.MATCH_PARENT;
        params.height = ViewGroup.LayoutParams.WRAP_CONTENT;
        win.setAttributes(params);
        return super.onCreateView(inflater, container, savedInstanceState);
    }

    @Override
    public void initBundle(@Nullable Bundle bundle) {
        super.initBundle(bundle);
        assert bundle != null;
        mMusicModel = (KTVMusicAdapter.MusicModel) bundle.getSerializable(TAG_MODEL);
    }

    @Override
    public void initView(@NonNull View view) {

    }

    @Override
    public void initData() {

    }

    @Override
    public int getLayoutResId() {
        return R.layout.layout_ktv_music_menu;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(STYLE_NORMAL, R.style.Dialog_Bottom);
    }

    private IMusicMenuCallback mIMusicMenuCallback;

    public void show(FragmentManager manager, KTVMusicAdapter.MusicModel model,
                     IMusicMenuCallback callback) {
        Bundle bundle = new Bundle();
        bundle.putSerializable(TAG_MODEL, model);
        setArguments(bundle);

        this.mIMusicMenuCallback = callback;
        show(manager, TAG);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.tvEar:
                break;
            default:
                break;
        }
    }

    public interface IMusicMenuCallback {
    }
}
