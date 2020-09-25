package com.sclouds.mouselive.utils;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;

public class NetworkReceive extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        if (intent.getAction().equals(ConnectivityManager.CONNECTIVITY_ACTION)) {

        }
    }
}
