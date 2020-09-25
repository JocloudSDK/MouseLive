package com.sclouds.datasource;

import android.text.TextUtils;
import android.util.Log;

import com.sclouds.basedroid.LogUtils;
import com.sclouds.datasource.flyservice.http.FlyHttpSvc;

import io.reactivex.Observable;

/**
 * 业务鉴权 Token
 *
 * @author xipeitao
 * @since : 2020-03-18 14:50
 */
public class TokenGetter {

    private static String sToken = "";
    public static long EXPIRED_TIME = 60 * 60 * 24; // second

    public static Observable<Boolean> updateToken(long uid, long appId,String appSecret) {
        if(TextUtils.isEmpty(appSecret)) {  //如果传入的appSecret为空，则默认使用appid模式
            return Observable.just(true);
        }
        return FlyHttpSvc.getInstance().getToken(uid, appId,appSecret,EXPIRED_TIME)
                .map((response) -> {
                    sToken = response.Data;
                    LogUtils.d("peter",
                            "updateToken() called with: uid = [" + uid + "], appId = [" + appId +
                            "], appSecret = [" + appSecret + "]");
                    Log.d("peter", "updateToken() called with: sToken = [" + sToken + "]");
                    return !TextUtils.isEmpty(sToken);
                });
    }

    public static long getExpiredTime() {
        return EXPIRED_TIME;
    }

    public static void setExpiredTime(long expiredTime) {
        EXPIRED_TIME = expiredTime;
    }

    public static String getToken() {
        return sToken;
    }

    public static void updateToken(String token) {
        sToken = token;
    }

}