package com.sclouds.datasource.flyservice.http.network;

import android.os.SystemClock;

import java.io.IOException;
import java.util.Date;

import okhttp3.Interceptor;
import okhttp3.Request;
import okhttp3.Response;

public class CustomInterceptor implements Interceptor {

    //服务器时间
    private static volatile long lastNetTime = 0L;
    //服务器同步时的开机时间
    private static volatile long lastElapsedRealtime = 0L;

    @Override
    public Response intercept(Chain chain) throws IOException {
        Request request = chain.request();
        Request.Builder requestBuilder = request.newBuilder();
        // .addHeader("device_id", AppUtil.getUuid(context))
        // .addHeader("device_type", "0")
        // .addHeader("device_version", android.os.Build.VERSION.RELEASE)
        // .addHeader("app_version", AppUtil.getVersionName(context));
        Response response = chain.proceed(requestBuilder.build());
        Date date = response.headers().getDate("Date");
        if (date != null) {
            updateNetTime(date.getTime());
        }
        return response;
    }

    public static void updateNetTime(long time) {
        if (time != 0) {
            lastNetTime = time;
            lastElapsedRealtime = SystemClock.elapsedRealtime();
        }
    }

    public static long getCurrentNetTime() {
        if (lastNetTime == 0L) {
            return System.currentTimeMillis();
        }
        return lastNetTime + SystemClock.elapsedRealtime() - lastElapsedRealtime;
    }

}
