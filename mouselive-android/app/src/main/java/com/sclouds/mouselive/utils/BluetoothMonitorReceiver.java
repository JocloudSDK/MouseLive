package com.sclouds.mouselive.utils;

import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.sclouds.datasource.thunder.ThunderSvc;

public class BluetoothMonitorReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        if (action != null) {
            switch (action) {
                case BluetoothDevice.ACTION_ACL_CONNECTED:
                    Log.i("zyrzs", "蓝牙设备已连接");
                    ThunderSvc.getInstance().setEnableSpeakerphone(false);
                    break;

                case BluetoothDevice.ACTION_ACL_DISCONNECTED:
                    Log.i("zyrzs", "蓝牙设备已断开");
                    break;
                default:
                    break;
            }
        }
    }
}
