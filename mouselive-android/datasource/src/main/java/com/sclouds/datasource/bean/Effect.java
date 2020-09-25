package com.sclouds.datasource.bean;

import android.text.TextUtils;

import java.util.Objects;

import androidx.core.util.ObjectsCompat;

public class Effect {
    private String Id;

    private String Name;

    private String Md5;

    private String Thumb;

    private String Url;

    private int OperationType = -1;

    private String ResourceTypeName;

    private String path;

    public Effect() {
    }

    public Effect(Effect mEffect) {
        this.Id = mEffect.Id;
        this.Name = mEffect.Name;
        this.Md5 = mEffect.Md5;
        this.Thumb = mEffect.Thumb;
        this.Url = mEffect.Url;
        this.path = mEffect.path;
        this.OperationType = mEffect.OperationType;
        this.ResourceTypeName = mEffect.ResourceTypeName;
    }

    public String getId() {
        return Id;
    }

    public void setId(String id) {
        Id = id;
    }

    public String getName() {
        return Name;
    }

    public void setName(String name) {
        this.Name = name;
    }

    public String getMd5() {
        return Md5;
    }

    public void setMd5(String md5) {
        this.Md5 = md5;
    }

    public String getThumb() {
        return Thumb;
    }

    public void setThumb(String thumb) {
        this.Thumb = thumb;
    }

    public String getUrl() {
        return Url;
    }

    public void setUrl(String url) {
        this.Url = url;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public int getOperationType() {
        return OperationType;
    }

    public void setOperationType(int operationType) {
        this.OperationType = operationType;
    }

    public String getResourceTypeName() {
        return ResourceTypeName;
    }

    public void setResourceTypeName(String resourceTypeName) {
        this.ResourceTypeName = resourceTypeName;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof Effect)) {
            return false;
        }
        Effect effect = (Effect) o;
        return ObjectsCompat.equals(this.Id, effect.Id);
    }

    @Override
    public int hashCode() {
        return TextUtils.isEmpty(Id) ? 0 : Objects.hash(Id);
    }
}
