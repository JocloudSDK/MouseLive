package com.sclouds.mouselive.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.sclouds.datasource.bean.RoomUser;
import com.sclouds.mouselive.R;

import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.core.util.ObjectsCompat;

/**
 * 聊天室头像
 *
 * @author chenhengfei@yy.com
 * @since 2020年1月17日
 */
public class RoomUserHeader extends ConstraintLayout {

    private ImageView ivHead;
    private ImageView ivMic;
    private TextView tvName;

    private RoomUser user;

    public RoomUserHeader(Context context) {
        super(context);
        ini(context, null, 0, 0);
    }

    public RoomUserHeader(Context context, AttributeSet attrs) {
        super(context, attrs);
        ini(context, attrs, 0, 0);
    }

    public RoomUserHeader(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        ini(context, attrs, defStyleAttr, 0);
    }

    public RoomUserHeader(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        ini(context, attrs, defStyleAttr, defStyleRes);
    }

    private void ini(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        LayoutInflater.from(context).inflate(R.layout.layout_room_master_header, this);
        ivHead = findViewById(R.id.ivHead);
        ivMic = findViewById(R.id.ivMic);
        tvName = findViewById(R.id.tvName);
    }

    /**
     * 设置其他人
     *
     * @param user
     */
    public void setUserInfo(@Nullable RoomUser user) {
        if (user == null) {
            clearUser("");
            return;
        }

        if (ObjectsCompat.equals(user, this.user) == false) {
            RequestOptions requestOptions = new RequestOptions()
                    .circleCrop()
                    .placeholder(R.mipmap.default_user_icon)
                    .error(R.mipmap.default_user_icon);
            Glide.with(ivHead.getContext()).load(user.getCover()).apply(requestOptions)
                    .into(ivHead);
            tvName.setText(user.getNickName());
            this.user = user;
        }

        //闭麦
        ivMic.setVisibility(VISIBLE);
        //观众优先级
        //1：被房主关闭
        //2：本地关闭
        //3：打开
        if (user.isMicEnable() == false) {
            ivMic.setEnabled(false);
            ivMic.setImageResource(R.mipmap.ic_voice_item_owner_mic_off);
        } else if (user.isSelfMicEnable() == false) {
            ivMic.setEnabled(true);
            ivMic.setImageResource(R.mipmap.ic_voice_item_mic_off);
        } else {
            ivMic.setEnabled(true);
            ivMic.setImageResource(R.mipmap.ic_voice_item_mic_on);
        }
    }

    /**
     * 只处理房主逻辑显示
     */
    public void setOwnerUserInfo(@Nullable RoomUser owner) {
        if (owner == null) {
            return;
        }

        this.user = owner;
        RequestOptions requestOptions = new RequestOptions()
                .circleCrop()
                .placeholder(R.mipmap.default_user_icon)
                .error(R.mipmap.default_user_icon);
        Glide.with(ivHead.getContext()).load(owner.getCover()).apply(requestOptions)
                .into(ivHead);
        tvName.setText(owner.getNickName());

        //闭麦
        //房主只要关心本地
        ivMic.setVisibility(VISIBLE);
        ivMic.setEnabled(true);
        if (owner.isSelfMicEnable()) {
            ivMic.setImageResource(R.mipmap.ic_voice_item_mic_on);
        } else {
            ivMic.setImageResource(R.mipmap.ic_voice_item_mic_off);
        }
    }

    public void clearUser(String text) {
        this.user = null;
        ivHead.setImageResource(R.mipmap.ic_voice_item_default1);
        tvName.setText(text);
        ivMic.setVisibility(GONE);
    }
}
