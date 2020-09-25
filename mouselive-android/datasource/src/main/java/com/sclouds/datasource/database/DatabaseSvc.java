package com.sclouds.datasource.database;

import android.app.Application;
import android.content.Context;

import com.sclouds.datasource.bean.User;

import androidx.annotation.Nullable;
import androidx.lifecycle.MutableLiveData;

/**
 * @author xipeitao
 * @description:
 * @date : 2020-03-09 15:11
 */
public class DatabaseSvc {

    private static DatabaseSvc sIntance;
    private final AppDatabase database;
    public MutableLiveData<User> mLiveData = new MutableLiveData<>();

    private Context mContext;

    public static synchronized DatabaseSvc getIntance() {
        if (sIntance == null) {
            throw new ExceptionInInitializerError();
        }
        return sIntance;
    }

    public static void init(Application app) {
        if (sIntance == null) {
            sIntance = new DatabaseSvc(app);
        }
    }

    public DatabaseSvc(Application app) {
        mContext = app;
        database = AppDatabase.create(app);
    }

    @Nullable
    public User getUser() {
        User user = mLiveData.getValue();
        if (user == null) {
            user = getLocalUser();
            mLiveData.postValue(user);
        }
        return mLiveData.getValue();
    }

    public User getLocalUser() {
        UserDao userDao = database.userDao();
        return userDao.queryUser();
    }

    public void insertUser(User user) {
        UserDao userDao = database.userDao();
        userDao.deleteAll();
        userDao.insert(user);
        mLiveData.postValue(user);
    }
}
