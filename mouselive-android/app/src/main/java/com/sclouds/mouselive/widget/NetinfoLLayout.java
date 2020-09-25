package com.sclouds.mouselive.widget;

import android.content.Context;
import android.os.Build;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.sclouds.datasource.bean.User;
import com.sclouds.mouselive.R;
import com.thunder.livesdk.ThunderNotification;
import com.thunder.livesdk.ThunderRtcConstant;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

/**
 * 网络码率日志界面封装
 *
 * @author Aslan chenhengfei@yy.com
 * @since 2020/03/01
 */
public class NetinfoLLayout extends LinearLayout {

    static String strNetQuality1;
    static String strNetQuality2;
    static String strNetQuality3;
    static String strNetQuality4;
    static String strNetQuality5;
    static String strNetQuality6;
    static String strNetUnknow;

    private TextView roomid;
    private TextView uid;
    private TextView name;

    private TextView txnetQuality;//上行网络质量
    private TextView txQuality;//上行
    private TextView txQualityM;//上行

    private TextView rxnetQuality;//下行网络质量
    private TextView rxQuality;//下行
    private TextView rxQualityM;//下行

    public NetinfoLLayout(Context context) {
        super(context);
        init(context);
    }

    public NetinfoLLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public NetinfoLLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public NetinfoLLayout(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        init(context);
    }

    private void init(Context context) {
        LayoutInflater.from(context).inflate(R.layout.layout_room_user_info, this);
        setBackgroundResource(R.drawable.shape_room_msg_item_background);
        setOrientation(VERTICAL);

        roomid = findViewById(R.id.tvRoomId);
        this.roomid.setVisibility(GONE);

        uid = findViewById(R.id.tvUID);
        name = findViewById(R.id.tvName);

        //上行
        txnetQuality = findViewById(R.id.tvTxNetQuality);
        txQuality = findViewById(R.id.tvTxQuality);
        txQualityM = findViewById(R.id.tvTxQualityM);

        //下行
        rxnetQuality = findViewById(R.id.tvRxNetQuality);
        rxQuality = findViewById(R.id.tvRxQuality);
        rxQualityM = findViewById(R.id.tvRxQualityM);

        strNetQuality1 = getContext().getString(R.string.net_quality1);
        strNetQuality2 = getContext().getString(R.string.net_quality2);
        strNetQuality3 = getContext().getString(R.string.net_quality3);
        strNetQuality4 = getContext().getString(R.string.net_quality4);
        strNetQuality5 = getContext().getString(R.string.net_quality5);
        strNetQuality6 = getContext().getString(R.string.net_quality6);
        strNetUnknow = getContext().getString(R.string.net_unknown);

        this.txnetQuality.setVisibility(GONE);
        this.rxnetQuality.setVisibility(GONE);
        this.txQuality.setVisibility(GONE);
        this.txQualityM.setVisibility(GONE);
        this.rxQuality.setVisibility(GONE);
        this.rxQualityM.setVisibility(GONE);
    }

    public void setRoomInfo(@Nullable String roomId) {
        if (roomId == null) {
            roomid.setVisibility(GONE);
            roomid.setText(getContext().getString(R.string.info_roomid, ""));
        } else {
            roomid.setVisibility(VISIBLE);
            roomid.setText(getContext().getString(R.string.info_roomid, roomId));
        }
    }

    public void setUser(@NonNull User user) {
        uid.setText(getContext().getString(R.string.info_uid, String.valueOf(user.getUid())));
        name.setText(user.getNickName());
    }

    /**
     * 网络质量
     *
     * @param txquality 上行
     * @param rxquality 下行
     */
    public void setNetworkInfo(int txquality, int rxquality) {
        this.txnetQuality.setVisibility(VISIBLE);
        this.rxnetQuality.setVisibility(VISIBLE);

        this.txnetQuality
                .setText(getContext().getString(R.string.net_tx_quality, getQuality(txquality)));
        this.rxnetQuality
                .setText(getContext().getString(R.string.net_rx_quality, getQuality(rxquality)));
    }

    private String getQuality(int quality) {
        if (quality == ThunderRtcConstant.NetworkQuality.THUNDER_QUALITY_UNKNOWN) {
            return strNetUnknow;
        } else if (quality == ThunderRtcConstant.NetworkQuality.THUNDER_QUALITY_EXCELLENT) {
            return strNetQuality1;
        } else if (quality == ThunderRtcConstant.NetworkQuality.THUNDER_QUALITY_GOOD) {
            return strNetQuality2;
        } else if (quality == ThunderRtcConstant.NetworkQuality.THUNDER_QUALITY_POOR) {
            return strNetQuality3;
        } else if (quality == ThunderRtcConstant.NetworkQuality.THUNDER_QUALITY_BAD) {
            return strNetQuality4;
        } else if (quality == ThunderRtcConstant.NetworkQuality.THUNDER_QUALITY_VBAD) {
            return strNetQuality5;
        } else if (quality == ThunderRtcConstant.NetworkQuality.THUNDER_QUALITY_DOWN) {
            return strNetQuality6;
        } else {
            return strNetUnknow;
        }
    }

    /**
     * 房间码率
     *
     * @param stats 码率
     */
    public void setRoomStats(@Nullable ThunderNotification.RoomStats stats) {
        if (stats == null) {
            this.txQuality.setVisibility(GONE);
            this.txQualityM.setVisibility(GONE);
            this.rxQuality.setVisibility(GONE);
            this.rxQualityM.setVisibility(GONE);
            return;
        }

        this.txQuality.setVisibility(VISIBLE);
        this.txQualityM.setVisibility(VISIBLE);
        this.rxQuality.setVisibility(VISIBLE);
        this.rxQualityM.setVisibility(VISIBLE);

        this.txQuality
                .setText(getContext().getString(R.string.bitrates_up, stats.txBitrate / 8192));
        this.txQualityM.setText(getContext()
                .getString(R.string.bitrates_m, stats.txAudioBitrate / 8192,
                        stats.txVideoBitrate / 8192));

        this.rxQuality
                .setText(getContext().getString(R.string.bitrates_down, stats.rxBitrate / 8192));
        this.rxQualityM.setText(getContext()
                .getString(R.string.bitrates_m, stats.rxAudioBitrate / 8192,
                        stats.rxVideoBitrate / 8192));
    }

    public void resetView() {
        this.txnetQuality.setVisibility(GONE);
        this.rxnetQuality.setVisibility(GONE);

        this.txQuality.setVisibility(GONE);
        this.txQualityM.setVisibility(GONE);
        this.rxQuality.setVisibility(GONE);
        this.rxQualityM.setVisibility(GONE);
    }
}
