package com.sclouds.mouselive.viewmodel;

import android.app.Application;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.lifecycle.MutableLiveData;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import com.sclouds.basedroid.BaseViewModel;
import com.sclouds.datasource.bean.MyMusicsInfo;
import com.sclouds.mouselive.utils.FileUtil;

public class MyMusicsViewModel extends BaseViewModel {

    private static final String TAG = "MyMusicsViewModel";

    private static final String RECORD_FORMAT = "aac";

    private static final String RECORD_TIME_SPERATOR = "_";

    private MutableLiveData<List<MyMusicsInfo>> mLiveData = new MutableLiveData<>();

    private final Object mDataLockObject = new Object();
    private List<MyMusicsInfo> mDataList = new ArrayList<>();

    public MyMusicsViewModel(@NonNull Application application) {
        super(application, null);
    }

    @Override
    public void initData() {
        String recordPath = FileUtil.getRecord(getApplication());
        Log.d(TAG, "initData: recordPath = " + recordPath);
        synchronized (mDataLockObject) {
            mDataList.clear();
            File recordDirectory = new File(recordPath);
            String[] filesName = recordDirectory.list();
            if (null == filesName) {
                Log.d(TAG, "no file existed in record path");
                return;
            }
            for (String fileName : filesName) {
                Log.d(TAG, "initData: fileName = " + fileName);
//            if (!fileName.endsWith(RECORD_FORMAT)) {
//                Log.d(TAG, "file format is not aac");
//                continue;
//            }
                long duration = 0;
                int startIndex = fileName.lastIndexOf(RECORD_TIME_SPERATOR) + 1;
                int endIndex = fileName.indexOf(".");
                if ((startIndex > 0) && (endIndex > startIndex)) {
                    try {
                        duration = Long.parseLong(fileName.substring(startIndex, endIndex));
                        Log.d(TAG, "initData: duration = " + duration);
                    } catch (Exception e) {
                        Log.d(TAG, e.toString());
                    }
                }
                File file = new File(recordPath, fileName);
                mDataList.add(new MyMusicsInfo(fileName, file.lastModified(), duration));
            }
            Collections.sort(mDataList);
            mLiveData.postValue(mDataList);
        }
    }

    public void deleteAll() {
        Log.d(TAG, "deleteAll: start");
        synchronized (mDataLockObject) {
            mDataList.clear();
            mLiveData.postValue(mDataList);
            String recordPath = FileUtil.getRecord(getApplication());
            File recordDirectory = new File(recordPath);
            String[] filesName = recordDirectory.list();
            if (null == filesName) {
                Log.d(TAG, "no file existed in record path");
                return;
            }
            for (String fileName : filesName) {
                Log.d(TAG, "deleteAll: fileName = " + fileName);
                File file = new File(recordPath, fileName);
                boolean result = file.delete();
                Log.d(TAG, "deleteAll: result = " + result);
            }
        }
        Log.d(TAG, "deleteAll: end");
    }

    public MutableLiveData<List<MyMusicsInfo>> getLiveData() {
        return mLiveData;
    }

}
