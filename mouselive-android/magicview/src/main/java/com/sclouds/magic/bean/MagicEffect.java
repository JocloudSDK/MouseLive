package com.sclouds.magic.bean;

public class MagicEffect extends Effect {

    private DownloadStatus mDownloadStatus = DownloadStatus.UNDOWNLOAD;
    private boolean isSelected = false;
    private String mShowName = "";

    public MagicEffect() {
        super();
    }

    public MagicEffect(Effect effect) {
        super(effect);
    }

    public DownloadStatus getDownloadStatus() {
        return mDownloadStatus;
    }

    public void setDownloadStatus(DownloadStatus downloadStatus) {
        mDownloadStatus = downloadStatus;
    }

    public boolean isSelected() {
        return isSelected;
    }

    public void setSelected(boolean selected) {
        isSelected = selected;
    }

    public String getShowName() {
        return mShowName;
    }

    public void setShowName(String showName) {
        this.mShowName = showName;
    }

    public enum DownloadStatus {
        UNDOWNLOAD, DOWNLOADING, DOWNLOADED
    }

}
