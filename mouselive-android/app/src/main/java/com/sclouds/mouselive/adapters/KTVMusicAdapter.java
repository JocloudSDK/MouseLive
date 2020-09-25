package com.sclouds.mouselive.adapters;

import android.content.Context;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.sclouds.basedroid.BaseAdapter;
import com.sclouds.mouselive.R;

import java.io.Serializable;

import androidx.annotation.LayoutRes;
import androidx.annotation.NonNull;
import androidx.constraintlayout.widget.ConstraintLayout;

/**
 * KTV-排序列表
 *
 * @author chenhengfei@yy.com
 * @since 2020年07月07日
 */
public class KTVMusicAdapter extends
        BaseAdapter<KTVMusicAdapter.MusicModel, KTVMusicAdapter.ViewHolder> {

    public KTVMusicAdapter(Context context) {
        super(context);
    }

    @LayoutRes
    @Override
    protected int getLayoutId(int viewType) {
        return R.layout.item_ktv_music;
    }

    @NonNull
    @Override
    protected KTVMusicAdapter.ViewHolder createViewHolder(@NonNull View itemView) {
        return new ViewHolder(itemView);
    }

    class ViewHolder extends BaseAdapter.BaseViewHolder<MusicModel> {

        private ConstraintLayout root;
        private TextView tvTitle;
        private TextView tvInfo;
        private ImageView iv;

        public ViewHolder(View itemView) {
            super(itemView);
            root = itemView.findViewById(R.id.root);
            tvTitle = itemView.findViewById(R.id.tvTitle);
            tvInfo = itemView.findViewById(R.id.tvInfo);
            iv = itemView.findViewById(R.id.iv);
        }

        @Override
        protected void bind(@NonNull MusicModel item) {

        }
    }

    public class MusicModel implements Serializable {

    }
}
