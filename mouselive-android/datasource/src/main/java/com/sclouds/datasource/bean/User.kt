package com.sclouds.datasource.bean

import android.os.Parcel
import android.os.Parcelable
import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "User")
open class User() : Parcelable {

    @PrimaryKey
    @ColumnInfo(name = "Uid")
    var Uid: Long = 0

    @ColumnInfo(name = "nick_name")
    var NickName: String? = null

    var Token: String? = null

    // 用户头像
    @ColumnInfo(name = "photo_url")
    var Cover: String? = null

    constructor(parcel: Parcel) : this() {
        Uid = parcel.readLong()
        Token = parcel.readString()
        NickName = parcel.readString()
        Cover = parcel.readString()
    }

    companion object {
        @JvmField
        val CREATOR = object : Parcelable.Creator<User> {
            override fun createFromParcel(parcel: Parcel): User {
                return User(parcel)
            }

            override fun newArray(size: Int): Array<User?> {
                return arrayOfNulls(size)
            }
        }
    }

    override fun writeToParcel(parcel: Parcel, flags: Int) {
        parcel.writeLong(Uid)
        parcel.writeString(Token)
        parcel.writeString(NickName)
        parcel.writeString(Cover)
    }

    override fun describeContents(): Int {
        return 0
    }

    override fun toString(): String {
        return "User(Uid=$Uid, NickName=$NickName)"
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is User) return false

        if (Uid != other.Uid) return false

        return true
    }

    override fun hashCode(): Int {
        return Uid.hashCode()
    }
}