package com.sclouds.datasource.bean;

public class MyMusicsInfo implements Comparable<MyMusicsInfo> {

    private String mName = null;
    private long mDate = 0;
    private long mDuration = 0; // 单位：ms

    public MyMusicsInfo(String name, long date, long duration) {
        this.mName = name;
        this.mDate = date;
        this.mDuration = duration;
    }

    public String getName() {
        return mName;
    }

    public void setName(String mName) {
        this.mName = mName;
    }

    public long getDate() {
        return mDate;
    }

    public void setDate(long mDate) {
        this.mDate = mDate;
    }

    public long getDuration() {
        return mDuration;
    }

    public void setDuration(long mDuration) {
        this.mDuration = mDuration;
    }

    @Override
    public int compareTo(MyMusicsInfo myMusicsInfo) {
        return (int) (myMusicsInfo.getDate() - this.getDate());
    }
}
