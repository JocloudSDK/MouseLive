package com.sclouds.magic.bean;

import android.text.TextUtils;

import androidx.core.util.ObjectsCompat;

import java.util.Objects;

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

    public Effect(Effect effect) {
        this.Id = effect.Id;
        this.Name = effect.Name;
        this.Md5 = effect.Md5;
        this.Thumb = effect.Thumb;
        this.Url = effect.Url;
        this.path = effect.path;
        this.OperationType = effect.OperationType;
        this.ResourceTypeName = effect.ResourceTypeName;
    }

    public Effect(String id, String name, String md5, String thumb, String url, int operationType, String resourceTypeName, String path) {
        this.Id = id;
        this.Name = name;
        this.Md5  = md5;
        this.Thumb = thumb;
        this.Url = url;
        this.OperationType = operationType;
        this.ResourceTypeName = resourceTypeName;
        this.path = path;
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
