package com.sclouds.datasource.hummer.listener;

/**
 * @author xipeitao
 * @description:
 * @date : 2020-04-16 11:03
 */
public interface IUserListener {

    /**
     * 用户登录
     */
    void onLogin();

    /**
     * 用户登出
     * @param reason 用户的登出的原因
     */
    void onLogout(int reason);

    /**
     * 需要鉴权
     * @return
     */
    String requiredToken();

}
