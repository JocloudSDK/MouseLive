package com.sclouds.datasource.bean;

import java.util.List;

public class EffectTab {
    private String Id;
    private String GroupType;
    private List<Effect> Icons;

    public String getId() {
        return Id;
    }

    public void setId(String id) {
        this.Id = id;
    }

    public String getGroupType() {
        return GroupType;
    }

    public void setGroupType(String groupType) {
        this.GroupType = groupType;
    }

    public List<Effect> getIcons() {
        return Icons;
    }

    public void setIcons(List<Effect> icons) {
        this.Icons = icons;
    }
}
