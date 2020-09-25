package com.sclouds.datasource.database

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import com.sclouds.datasource.bean.User

@Dao
interface UserDao {

    @Query("SELECT * FROM user")
    fun queryUser(): User

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(user: User)

    @Query("DELETE FROM user")
    fun deleteAll()

    @Delete
    fun delete(user: User)

    @Update
    fun update(user: User)
}