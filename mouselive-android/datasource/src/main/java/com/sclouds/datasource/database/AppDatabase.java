package com.sclouds.datasource.database;

import android.content.Context;

import com.sclouds.datasource.bean.User;

import androidx.room.Database;
import androidx.room.Room;
import androidx.room.RoomDatabase;
import androidx.room.migration.Migration;
import androidx.sqlite.db.SupportSQLiteDatabase;

@Database(entities = {User.class}, version = 3, exportSchema = false)
public abstract class AppDatabase extends RoomDatabase {
    //数据库名称
    private static final String DB_NAME = "mouse.db";
    private static final Object sLock = new Object();

    public abstract UserDao userDao();

    protected static AppDatabase create(Context context) {
        AppDatabase datebase = null;
        synchronized (sLock) {
            datebase = Room.databaseBuilder(context.getApplicationContext(),
                    AppDatabase.class,
                    DB_NAME)
                    .allowMainThreadQueries()//允许在主线程访问数据库
                    .fallbackToDestructiveMigration()//数据库被清空
                    // .addMigrations(MIGRATION_1_2)
                    .build();
        }
        return datebase;
    }

    static final Migration MIGRATION_1_2 = new Migration(1, 2) {
        @Override
        public void migrate(SupportSQLiteDatabase database) {
            database.execSQL("DROP TABLE User");
        }
    };
}