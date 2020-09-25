package com.sclouds.mouselive.adapters;

import android.content.Context;
import android.graphics.Color;
import android.view.View;
import android.widget.TextView;

import com.sclouds.basedroid.BaseAdapter;
import com.sclouds.mouselive.R;
import com.thunder.livesdk.ThunderRtcConstant;

import java.util.ArrayList;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;

/**
 * 房间清晰度设置
 *
 * @author chenhengfei@yy.com
 * @since 2020年1月17日
 */
public class RoomSharpnessAdapter
        extends BaseAdapter<RoomSharpnessAdapter.Sharpness, RoomSharpnessAdapter.ViewHolder> {

    private int selectIndex = 0;

    public RoomSharpnessAdapter(Context context) {
        super(context);
        int[] publishModes = new int[]{
                ThunderRtcConstant.ThunderPublishVideoMode.THUNDERPUBLISH_VIDEO_MODE_FLUENCY,
                ThunderRtcConstant.ThunderPublishVideoMode.THUNDERPUBLISH_VIDEO_MODE_NORMAL,
                ThunderRtcConstant.ThunderPublishVideoMode.THUNDERPUBLISH_VIDEO_MODE_HIGHQULITY};
        String[] optinal1 = context.getResources().getStringArray(R.array.sharpness_optinal1);
        String[] optinal2 = context.getResources().getStringArray(R.array.sharpness_optinal2);
        String[] optinal3 = context.getResources().getStringArray(R.array.sharpness_optinal3);
        String[] optinal4 = context.getResources().getStringArray(R.array.sharpness_optinal4);
        List<Sharpness> list = new ArrayList<>();
        for (int i = 0; i < optinal1.length; i++) {
            list.add(new RoomSharpnessAdapter.Sharpness(publishModes[i], optinal1[i], optinal2[i],
                    optinal3[i], optinal4[i]));
        }
        setData(list);
    }

    @Override
    protected int getLayoutId(int viewType) {
        return R.layout.item_sharpeness;
    }

    @Override
    protected ViewHolder createViewHolder(@NonNull View itemView) {
        return new ViewHolder(itemView);
    }

    class ViewHolder extends BaseAdapter.BaseViewHolder<RoomSharpnessAdapter.Sharpness> {

        private TextView tvOptinal1;
        private TextView tvOptinal2;
        private TextView tvOptinal3;
        private TextView tvOptinal4;

        public ViewHolder(View itemView) {
            super(itemView);
            tvOptinal1 = itemView.findViewById(R.id.tvOptinal1);
            tvOptinal2 = itemView.findViewById(R.id.tvOptinal2);
            tvOptinal3 = itemView.findViewById(R.id.tvOptinal3);
            tvOptinal4 = itemView.findViewById(R.id.tvOptinal4);
        }

        @Override
        protected void bind(@NonNull RoomSharpnessAdapter.Sharpness item) {
            tvOptinal1.setText(item.getOptinal1());
            tvOptinal2.setText(item.getOptinal2());
            tvOptinal3.setText(item.getOptinal3());
            tvOptinal4.setText(item.getOptinal4());

            if (selectIndex == getAdapterPosition()) {
                itemView.setBackgroundColor(
                        ContextCompat.getColor(mContext, R.color.main_menu_text_unselected));
            } else {
                itemView.setBackgroundColor(Color.TRANSPARENT);
            }
        }
    }

    public int getSelectIndex() {
        return selectIndex;
    }

    public void setSelectIndex(int selectIndex) {
        this.selectIndex = selectIndex;
        notifyDataSetChanged();
    }

    public class Sharpness {
        private int publishMode;
        private String optinal1;
        private String optinal2;
        private String optinal3;
        private String optinal4;

        public Sharpness() {

        }

        public Sharpness(int publishMode, String optinal1, String optinal2, String optinal3,
                         String optinal4) {
            this.publishMode = publishMode;
            this.optinal1 = optinal1;
            this.optinal2 = optinal2;
            this.optinal3 = optinal3;
            this.optinal4 = optinal4;
        }

        public int getPublishMode() {
            return publishMode;
        }

        public void setPublishMode(int publishMode) {
            this.publishMode = publishMode;
        }

        public String getOptinal1() {
            return optinal1;
        }

        public void setOptinal1(String optinal1) {
            this.optinal1 = optinal1;
        }

        public String getOptinal2() {
            return optinal2;
        }

        public void setOptinal2(String optinal2) {
            this.optinal2 = optinal2;
        }

        public String getOptinal3() {
            return optinal3;
        }

        public void setOptinal3(String optinal3) {
            this.optinal3 = optinal3;
        }

        public String getOptinal4() {
            return optinal4;
        }

        public void setOptinal4(String optinal4) {
            this.optinal4 = optinal4;
        }
    }
}
