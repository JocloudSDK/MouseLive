package com.sclouds.datasource.bean;

import android.os.Parcel;
import android.os.Parcelable;

import com.thunder.livesdk.ThunderNotification;

import java.io.Serializable;

/**
 * 音视频信息
 *
 * @author chenhengfei@yy.com
 * @since 2020年1月17日
 */
public class RoomUser extends User implements Parcelable {

    /**
     * 用户类型，涉及到视频流用说明View显示
     */
    public enum UserType {
        Local, //本地
        Remote//远程
    }

    /**
     * 角色信息
     */
    public enum RoomRole implements Serializable {
        Owner(0),//房主
        Admin(1), //管理员
        Spectator(2);//观众

        private int value = 0;

        private RoomRole(int value) {
            this.value = value;
        }
    }

    /**
     * 房间号
     */
    private long roomId;

    /**
     * 上行数据
     */
    private int txQuality = -1;

    /**
     * 下行数据
     */
    private int rxQuality = -1;

    /**
     * 房间码流信息
     */
    private ThunderNotification.RoomStats stats;

    /**
     * 音量
     */
    private int volume;

    /**
     * 用户类型
     */
    private UserType userType;

    /**
     * 房间角色
     */
    private RoomRole mRoomRole = RoomRole.Spectator;

    /**
     * 连麦对方UID
     */
    private long LinkUid = 0;

    /**
     * 连麦对方房间号
     */
    private long LinkRoomId = 0;

    /**
     * 管理员把当前对象禁言
     */
    private boolean isNoTyping = false;

    /**
     * 管理员把当前对象禁麦
     */
    private boolean MicEnable = true;

    /**
     * 当前对象自己禁麦
     */
    private boolean SelfMicEnable = true;

    /**
     * 视频
     */
    private boolean isVideoStart = false;

    public RoomUser() {
        //gson构造使用
    }

    public RoomUser(long userId, long roomId, UserType userType) {
        setUid(userId);
        this.roomId = roomId;
        this.userType = userType;
    }

    public RoomUser(User user, long roomId, UserType userType) {
        this(user.getUid(), roomId, userType);
        setNickName(user.getNickName());
        setCover(user.getCover());
    }

    protected RoomUser(Parcel in) {
        super(in);
        roomId = in.readLong();
        txQuality = in.readInt();
        rxQuality = in.readInt();
        volume = in.readInt();
        LinkUid = in.readLong();
        LinkRoomId = in.readLong();
        isNoTyping = in.readByte() != 0;
        MicEnable = in.readByte() != 0;
        SelfMicEnable = in.readByte() != 0;
        isVideoStart = in.readByte() != 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        super.writeToParcel(dest, flags);
        dest.writeLong(roomId);
        dest.writeInt(txQuality);
        dest.writeInt(rxQuality);
        dest.writeInt(volume);
        dest.writeLong(LinkUid);
        dest.writeLong(LinkRoomId);
        dest.writeByte((byte) (isNoTyping ? 1 : 0));
        dest.writeByte((byte) (MicEnable ? 1 : 0));
        dest.writeByte((byte) (SelfMicEnable ? 1 : 0));
        dest.writeByte((byte) (isVideoStart ? 1 : 0));
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<RoomUser> CREATOR = new Creator<RoomUser>() {
        @Override
        public RoomUser createFromParcel(Parcel in) {
            return new RoomUser(in);
        }

        @Override
        public RoomUser[] newArray(int size) {
            return new RoomUser[size];
        }
    };

    public long getRoomId() {
        return roomId;
    }

    public void setRoomId(long roomId) {
        this.roomId = roomId;
    }

    public boolean isNoTyping() {
        return isNoTyping;
    }

    public void setNoTyping(boolean noTyping) {
        isNoTyping = noTyping;
    }

    public RoomRole getRoomRole() {
        return mRoomRole;
    }

    public void setRoomRole(RoomRole roomRole) {
        mRoomRole = roomRole;
    }

    public UserType getUserType() {
        return userType;
    }

    public void setUserType(UserType userType) {
        this.userType = userType;
    }

    public int getTxQuality() {
        return txQuality;
    }

    public void setTxQuality(int txQuality) {
        this.txQuality = txQuality;
    }

    public int getRxQuality() {
        return rxQuality;
    }

    public void setRxQuality(int rxQuality) {
        this.rxQuality = rxQuality;
    }

    public ThunderNotification.RoomStats getStats() {
        return stats;
    }

    public void setStats(ThunderNotification.RoomStats stats) {
        this.stats = stats;
    }

    public int getVolume() {
        return volume;
    }

    public void setVolume(int volume) {
        this.volume = volume;
    }

    public boolean isSelfMicEnable() {
        return SelfMicEnable;
    }

    public void setSelfMicEnable(boolean selfMicEnable) {
        SelfMicEnable = selfMicEnable;
    }

    public long getLinkUid() {
        return LinkUid;
    }

    public void setLinkUid(long linkUid) {
        LinkUid = linkUid;
    }

    public long getLinkRoomId() {
        return LinkRoomId;
    }

    public void setLinkRoomId(long linkRoomId) {
        LinkRoomId = linkRoomId;
    }

    public boolean isMicEnable() {
        return MicEnable;
    }

    public void setMicEnable(boolean micEnable) {
        MicEnable = micEnable;
    }

    public boolean isVideoStart() {
        return isVideoStart;
    }

    public void setVideoStart(boolean videoStart) {
        isVideoStart = videoStart;
    }

    @Override
    public String toString() {
        return super.toString() + "RoomUser{" +
                "roomId=" + roomId +
                ", userType=" + userType +
                ", mRoomRole=" + mRoomRole +
                ", LinkUid=" + LinkUid +
                ", LinkRid=" + LinkRoomId +
                ", isNoTyping=" + isNoTyping +
                ", MicEnable=" + MicEnable +
                ", SelfMicEnable=" + SelfMicEnable +
                ", isVideoStart=" + isVideoStart +
                "} ";
    }
}
