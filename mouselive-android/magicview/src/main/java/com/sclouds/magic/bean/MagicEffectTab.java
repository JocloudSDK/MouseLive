package com.sclouds.magic.bean;

import java.util.List;

public class MagicEffectTab {

    private String mId;
    private String mGroupType;
    private List<MagicEffect> mMagicEffectList;

    public MagicEffectTab() {

    }

    public MagicEffectTab(String id, String groupType, List<MagicEffect> magicEffectList) {
        this.mId = id;
        this.mGroupType = groupType;
        this.mMagicEffectList = magicEffectList;
    }

    public String getId() {
        return mId;
    }

    public void setId(String id) {
        this.mId = id;
    }

    public String getGroupType() {
        return mGroupType;
    }

    public void setGroupType(String groupType) {
        this.mGroupType = groupType;
    }

    public List<MagicEffect> getMagicEffectList() {
        return mMagicEffectList;
    }

    public void setMagicEffectList(List<MagicEffect> magicEffectList) {
        this.mMagicEffectList = magicEffectList;
    }

}
