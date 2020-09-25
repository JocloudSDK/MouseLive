package com.sclouds.mouselive.widget;

import android.content.Context;
import android.graphics.Outline;
import android.os.Build;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewOutlineProvider;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.sclouds.datasource.bean.RoomUser;
import com.sclouds.datasource.bean.User;
import com.sclouds.datasource.thunder.ThunderSvc;
import com.sclouds.mouselive.R;
import com.thunder.livesdk.ThunderRtcConstant;
import com.thunder.livesdk.video.ThunderPreviewView;

import java.util.Objects;

import androidx.annotation.NonNull;
import androidx.core.util.ObjectsCompat;

/**
 * 自定义本地视频视图，增加一些状态
 *
 * @author Aslan chenhengfei@yy.com
 * @since 2019/12/26
 */
public class MyThunderPreviewView extends RelativeLayout {

    private ThunderPreviewView mThunderVideoView;
    private LinearLayout llUser;
    private ImageView ivRoomOwner;
    private TextView tvOwnerName;

    private Long UID;
    private RoomUser user;

    public MyThunderPreviewView(Context context) {
        super(context);
        ini(context, null, 0);
    }

    public MyThunderPreviewView(Context context, AttributeSet attrs) {
        super(context, attrs);
        ini(context, attrs, 0);
    }

    public MyThunderPreviewView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        ini(context, attrs, defStyleAttr);
    }

    private void ini(Context context, AttributeSet attrs, int defStyleAttr) {
        LayoutInflater.from(context).inflate(R.layout.layout_thunder_local, this);

        llUser = findViewById(R.id.llUser);
        ivRoomOwner = findViewById(R.id.ivRoomOwner);
        tvOwnerName = findViewById(R.id.tvOwnerName);

        llUser.setVisibility(GONE);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            setClipToOutline(true);
            setOutlineProvider(new ViewOutlineProvider() {
                @Override
                public void getOutline(View view, Outline outline) {
                    outline.setRoundRect(0, 0, view.getWidth(), view.getHeight(), 20);
                }
            });
        }
    }

    /**
     * 绑定UID
     */
    public void bindUID(Long UID) {
        if (Objects.equals(this.UID, UID)) {
            return;
        }
        this.UID = UID;

        releaseThunderPreviewView();
        mThunderVideoView =
                ThunderSvc.getInstance().createPreviewView(getContext().getApplicationContext());
        addView(mThunderVideoView, 0,
                new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.MATCH_PARENT));

        ThunderSvc.getInstance().prepareLocalVideo(String.valueOf(UID), mThunderVideoView,
                ThunderRtcConstant.ThunderVideoViewScaleMode.THUNDERVIDEOVIEW_SCALE_MODE_CLIP_TO_BOUNDS);
    }

    private void releaseThunderPreviewView() {
        if (mThunderVideoView != null) {
            mThunderVideoView.clearViews();
            removeView(mThunderVideoView);
            mThunderVideoView = null;
        }
    }

    /**
     * 解绑UID
     */
    public void unbindUID() {
        if (UID == null) {
            return;
        }
        this.UID = null;

        releaseThunderPreviewView();
    }

    /**
     * 不要保留最后一帧
     */
    public void resetView() {
        mThunderVideoView.clearViews();
        mThunderVideoView.addViews(mThunderVideoView.getSurfaceView());
    }

    /**
     * 设置连麦玩家信息
     *
     * @param ROwner
     * @param user
     */
    public void setLinkRoomUser(@NonNull User ROwner, @NonNull RoomUser user) {
        if (ObjectsCompat.equals(ROwner, user)) {
            llUser.setVisibility(GONE);
        } else {
            if (!ObjectsCompat.equals(user, this.user)) {
                this.user = user;
                RequestOptions requestOptions = new RequestOptions()
                        .circleCrop()
                        .placeholder(R.mipmap.default_user_icon)
                        .error(R.mipmap.default_user_icon);
                Glide.with(getContext()).load(user.getCover()).apply(requestOptions)
                        .into(ivRoomOwner);

                tvOwnerName.setText(user.getNickName());
            }
            llUser.setVisibility(VISIBLE);
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        unbindUID();
        super.onDetachedFromWindow();
    }
}
