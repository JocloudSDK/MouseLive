package com.sclouds.datasource.bean

import android.os.Parcel
import android.os.Parcelable
import androidx.annotation.IntDef
import java.util.Objects

/**
 * 房间信息
 *
 * @author Aslan chenhengfei@yy.com
 * @date 2020/3/17
 */
@Target(AnnotationTarget.VALUE_PARAMETER, AnnotationTarget.PROPERTY)
@Retention(AnnotationRetention.SOURCE)
@MustBeDocumented
@IntDef(Room.ROOM_TYPE_LIVE, Room.ROOM_TYPE_CHAT, Room.ROOM_TYPE_KTV)
annotation class RoomType

@Target(AnnotationTarget.VALUE_PARAMETER, AnnotationTarget.PROPERTY)
@Retention(AnnotationRetention.SOURCE)
@MustBeDocumented
@IntDef(Room.RTC, Room.CDN)
annotation class PublishMode

data class Room(var RoomId: Int) : Parcelable {
    constructor() : this(0)//Gson需要一个默认构造函数

    companion object {
        const val ROOM_TYPE_LIVE = 1//直播房间
        const val ROOM_TYPE_CHAT = 2//语音房间
        const val ROOM_TYPE_KTV = 3//在线KTV

        const val RTC = 1//RTC 模式
        const val CDN = 2//CDN 模式

        @JvmField
        val CREATOR = object : Parcelable.Creator<Room> {
            override fun createFromParcel(parcel: Parcel): Room {
                return Room(parcel)
            }

            override fun newArray(size: Int): Array<Room?> {
                return arrayOfNulls(size)
            }
        }
    }

    /**
     * 房间类型
     */
    @RoomType
    var RType: Int = ROOM_TYPE_LIVE

    /**
     * 开播类型
     */
    @PublishMode
    var RPublishMode: Int = RTC

    /**
     * 上流
     */
    var RUpStream: String? = null

    /**
     * 下流
     */
    var RDownStream: String? = null

    /**
     * 房主信息
     */
    lateinit var ROwner: User

    /**
     * 房间人数
     */
    var RCount: Int = 0

    /**
     * 聊天室id，hummer的房间号
     */
    var RChatId: Long? = null

    /**
     * 房间名字
     */
    var RName: String? = null

    /**
     * 房间头像
     */
    var RCover: String? = null

    /**
     * 全局禁言
     */
    var isAllNoTyping = false

    /**
     * 全局禁麦
     */
    var RMicEnable = true

    /**
     * 房间是否还在开播
     */
    var Rliving = true

    /**
     * 成员列表
     */
    var members: List<RoomUser>? = null

    constructor(parcel: Parcel) : this(parcel.readInt()) {
        RType = parcel.readInt()
        RPublishMode = parcel.readInt()
        RUpStream = parcel.readString()
        RDownStream = parcel.readString()
        ROwner = parcel.readParcelable(User::class.java.classLoader)!!
        RCount = parcel.readInt()
        RChatId = parcel.readValue(Long::class.java.classLoader) as? Long
        RName = parcel.readString()
        RCover = parcel.readString()
        isAllNoTyping = parcel.readByte() != 0.toByte()
        RMicEnable = parcel.readByte() != 0.toByte()
        Rliving = parcel.readByte() != 0.toByte()
        members = parcel.createTypedArrayList(RoomUser.CREATOR)
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is Room) return false

        if (RoomId != other.RoomId) return false
        if (RType != other.RType) return false

        return true
    }

    override fun hashCode(): Int {
        return Objects.hashCode(RoomId)
    }

    override fun writeToParcel(parcel: Parcel, flags: Int) {
        parcel.writeInt(RoomId)
        parcel.writeInt(RType)
        parcel.writeInt(RPublishMode)
        parcel.writeString(RUpStream)
        parcel.writeString(RDownStream)
        parcel.writeParcelable(ROwner, flags)
        parcel.writeInt(RCount)
        parcel.writeValue(RChatId)
        parcel.writeString(RName)
        parcel.writeString(RCover)
        parcel.writeByte(if (isAllNoTyping) 1 else 0)
        parcel.writeByte(if (RMicEnable) 1 else 0)
        parcel.writeByte(if (Rliving) 1 else 0)
        parcel.writeTypedList(members)
    }

    override fun describeContents(): Int {
        return 0
    }

    override fun toString(): String {
        return "Room(RoomId=$RoomId, RType=$RType, RPublishMode=$RPublishMode, RUpStream=$RUpStream, RDownStream=$RDownStream, ROwner=$ROwner, RChatId=$RChatId, RName=$RName, isAllNoTyping=$isAllNoTyping, isAllMicEnable=$RMicEnable, Rliving=$Rliving, members=$members)"
    }
}
