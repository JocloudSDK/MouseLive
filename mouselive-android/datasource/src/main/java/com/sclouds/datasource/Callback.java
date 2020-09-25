package com.sclouds.datasource;

/**
 * 回调
 *
 * @author Aslan chenhengfei@yy.com
 * @date 2020/1/9
 */
public interface Callback {
    void onSuccess();

    void onFailed(int error);
}
