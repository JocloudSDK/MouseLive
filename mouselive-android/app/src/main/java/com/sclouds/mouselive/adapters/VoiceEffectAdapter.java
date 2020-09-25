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
 * 声音效果
 *
 * @author chenhengfei@yy.com
 * @since 2020年1月17日
 */
public class VoiceEffectAdapter
        extends BaseAdapter<VoiceEffectAdapter.VoiceEffect, VoiceEffectAdapter.ViewHolder> {

    private int selectIndex = 0;

    public VoiceEffectAdapter(Context context) {
        super(context);
        int[] voices = new int[]{
                ThunderRtcConstant.VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_ETHEREAL,
                ThunderRtcConstant.VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_THRILLER,
                ThunderRtcConstant.VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_LUBAN,
                ThunderRtcConstant.VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_LORIE,
                ThunderRtcConstant.VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_UNCLE,
                ThunderRtcConstant.VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_DIEFAT,
                ThunderRtcConstant.VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_BADBOY,
                ThunderRtcConstant.VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_WRACRAFT,
                ThunderRtcConstant.VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_HEAVYMETAL,
                ThunderRtcConstant.VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_COLD,
                ThunderRtcConstant.VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_HEAVYMECHINERY,
                ThunderRtcConstant.VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_TRAPPEDBEAST,
                ThunderRtcConstant.VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_POWERCURRENT
        };
        String[] names = context.getResources().getStringArray(R.array.voice_effects);
        List<VoiceEffect> list = new ArrayList<>();
        for (int i = 0; i < names.length; i++) {
            list.add(new VoiceEffect(names[i], voices[i]));
        }
        setData(list);
    }

    @Override
    protected int getLayoutId(int viewType) {
        return R.layout.item_voice_effect;
    }

    @Override
    protected ViewHolder createViewHolder(@NonNull View itemView) {
        return new ViewHolder(itemView);
    }

    class ViewHolder extends BaseAdapter.BaseViewHolder<VoiceEffect> {

        private TextView tvName;

        public ViewHolder(View itemView) {
            super(itemView);
            tvName = itemView.findViewById(R.id.tvName);
        }

        @Override
        protected void bind(@NonNull VoiceEffect item) {
            tvName.setText(item.name);

            if (selectIndex == getAdapterPosition()) {
                tvName.setTextColor(ContextCompat.getColor(mContext, R.color.room_level));
            } else {
                tvName.setTextColor(Color.WHITE);
            }
        }
    }

    public int getSelectIndex() {
        return selectIndex;
    }

    public VoiceEffect getSelectItem() {
        return getDataAtPosition(selectIndex);
    }

    public void setSelectIndex(int selectIndex) {
        this.selectIndex = selectIndex;
        notifyDataSetChanged();
    }

    public class VoiceEffect {
        private String name;
        private int value;

        public VoiceEffect(String name, int value) {
            this.name = name;
            this.value = value;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public int getValue() {
            return value;
        }

        public void setValue(int value) {
            this.value = value;
        }
    }
}
