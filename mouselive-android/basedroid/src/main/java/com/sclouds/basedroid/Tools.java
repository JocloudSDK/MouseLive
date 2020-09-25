package com.sclouds.basedroid;

import android.app.Activity;
import android.content.Context;
import android.net.ConnectivityManager;

public class Tools {

    public static Context m_Context = null;

    public static void initCtx(Context ctx) {
        m_Context = ctx;
    }

    public static boolean networkConnected() {
        if (null == m_Context) {
            return false;
        }

        ConnectivityManager conn =
                (ConnectivityManager) m_Context.getSystemService(Activity.CONNECTIVITY_SERVICE);
        boolean wifi = conn.getNetworkInfo(ConnectivityManager.TYPE_WIFI).isConnectedOrConnecting();
        boolean internet =
                conn.getNetworkInfo(ConnectivityManager.TYPE_MOBILE).isConnectedOrConnecting();
        String statStr = "未连接网络。";
        boolean isConnected = false;
        isConnected = wifi | internet;

        return isConnected;
    }
}
