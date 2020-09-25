package com.sclouds.datasource.flyservice.funws;

import android.util.Log;

import com.sclouds.basedroid.net.NetworkMgr;
import com.sclouds.datasource.business.pkg.HeartPacket;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class FunWSHeart {

    private static final long DEFAULT_HEART_PERIOD = 500L;

    private ScheduledExecutorService mScheduledExecutorService;

    private int heartCount = 0;

    private static final long HEART_COUNT_MAX =
            FunWSClientHandler.WSTIMEOUT/DEFAULT_HEART_PERIOD;
    FunWSClientHandler mClientHandler;


    public FunWSHeart(FunWSClientHandler handler) {
        mClientHandler = handler;
    }

    protected void startHeart() {
        if (mScheduledExecutorService == null) {
            mScheduledExecutorService = Executors.newSingleThreadScheduledExecutor();
        }else {
            return;
        }
        mScheduledExecutorService.scheduleAtFixedRate(new Runnable() {
            @Override
            public void run() {
                    if (heartCount > HEART_COUNT_MAX && mClientHandler.getConnectState() !=
                            FunWSClientHandler.ConnectState.CONNECT_STATE_LOST) {
                        mClientHandler.notifyTimeOut(false);
                        return;
                    }

                    if (!heartSync()) {
                        heartCount++;
                        Log.w("FunWSHeart", "startHeart"+heartCount);
                    }
            }
        }, DEFAULT_HEART_PERIOD, DEFAULT_HEART_PERIOD, TimeUnit.MILLISECONDS);
    }

    protected void stopHeart() {
        resetHeartCount();
        if (mScheduledExecutorService != null) {
            mScheduledExecutorService.shutdown();
            mScheduledExecutorService = null;
        }
    }

    protected void resetHeartCount() {
        heartCount = 0;
    }

    protected boolean heartSync() {
        if (mClientHandler.getConnectState() != FunWSClientHandler.ConnectState.CONNECT_STATE_CONNECTED)
            return false;
        mClientHandler.sendHeart(new HeartPacket());
        return true;
    }
}
