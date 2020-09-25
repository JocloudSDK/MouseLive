package com.sclouds.datasource.flyservice.funws;

import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import android.os.SystemClock;

import com.sclouds.basedroid.LogUtils;
import com.sclouds.basedroid.net.NetWorkMonitor;
import com.sclouds.basedroid.net.NetWorkState;
import com.sclouds.basedroid.net.NetworkMgr;
import com.sclouds.datasource.business.pkg.HeartPacket;

import org.java_websocket.enums.ReadyState;

import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.Enumeration;

import androidx.annotation.NonNull;

/**
 * @author xipeitao
 * @description:
 * @date : 2020-04-01 12:22
 */
public class FunWSClientHandler implements FunWSClient.WSListener {

    private static final String TAG = FunWSClientHandler.class.getSimpleName();
    public static final long WSTIMEOUT = 20000L;    //ms
    private String mHost;

    private boolean alwaysReconnect = true;

    /**
     * 连接状态
     */
    public static final class ConnectState {
        public static final int CONNECT_STATE_IDLE = 0X01;
        public static final int CONNECT_STATE_CONNECTING = 0X02;
        public static final int CONNECT_STATE_RECONNECTING = 0X03;
        public static final int CONNECT_STATE_CONNECTED = 0X04;
        public static final int CONNECT_STATE_LOST = 0X05;
    }

    public static final int MSG_CONNECT = 0x01;
    public static final int MSG_DISCONNECT = 0x02;
    public static final int MSG_RECONNECT = 0x03;
    public static final int MSG_STOP = 0x04;
    public static final int MSG_PING = 0x05;

    private int mConnectState = ConnectState.CONNECT_STATE_IDLE;

    private static final long NETTY_RECONNECT_INTERVAL_TIME = 250L;

    private FunWSClient client;
    private FunWSHeart funWSHeart;
    private HandlerThread mHandlerThread;
    private Handler mHandler;
    private long lastHeartTime = 0;

    public FunWSClientHandler(String host) {
        mHost = host;
        client = new FunWSClient(host, this);
        mHandlerThread = new HandlerThread("FunWebSocket");
        mHandlerThread.start();
        mHandler = new WSClientHander(mHandlerThread.getLooper());
    }

    public void start() {
        NetworkMgr.getInstance().register(this);
        mHandler.sendEmptyMessage(MSG_CONNECT);
    }

    public void stop() {
        mHandler.removeCallbacksAndMessages(null);
        mHandler.sendEmptyMessage(MSG_STOP);
    }

    private void connect() {
        try {
            if (client == null) {
                client = new FunWSClient(mHost, this);
            }
            if (funWSHeart == null) {
                funWSHeart = new FunWSHeart(this);
            }
            if (!client.isOpen()) {
                if (client.getReadyState().equals(ReadyState.NOT_YET_CONNECTED)) {
                    try {
                        if (mConnectState != ConnectState.CONNECT_STATE_RECONNECTING)
                            setConnectState(ConnectState.CONNECT_STATE_CONNECTING);
                        client.setReuseAddr(true);
                        client.setConnectionLostTimeout(1000);
                        client.setTcpNoDelay(true);
                        client.addHeader("Origin", getLocalIpAddress());
                        LogUtils.d(TAG, "FunWSClient-->connect" + mHost);
                        client.connectBlocking();
                    } catch (IllegalStateException e) {
                        LogUtils.e(TAG, "connect() called", e);
                        disconnect(false);
                        mHandler.sendEmptyMessage(MSG_RECONNECT);
                    }
                } else if (client.getReadyState().equals(ReadyState.CLOSING) ||
                        client.getReadyState().equals(ReadyState.CLOSED)) {
                    client.reconnectBlocking();
                    LogUtils.d(TAG, "FunWSClient-->reconnect" + mHost);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            // reconnectAsync(true);
        }
    }

    private void disconnect(boolean destory) {
        if (client != null) {
            LogUtils.e(TAG, "FunWSClient-->disconnect " + destory);
            client.close();
            client = null;
            mHandler.removeCallbacksAndMessages(null);
            setConnectState(destory ? ConnectState.CONNECT_STATE_IDLE : getConnectState());
        }
        if (destory) {
            if (funWSHeart != null) {
                funWSHeart.stopHeart();
            }
            lastHeartTime = 0;
        }
    }



    public void notifyTimeOut(boolean force) {
        LogUtils.w(TAG, "notifyTimeOut() called alwaysReconnect:"+alwaysReconnect);
        if (alwaysReconnect && !force) {
            reconnect();
        }else {
            setConnectState(ConnectState.CONNECT_STATE_LOST);
            mHandler.sendEmptyMessage(MSG_STOP);
        }

    }

    private void reconnect() {
        LogUtils.d(TAG, "reconnect() called");
        mHandler.removeMessages(MSG_CONNECT);
        setConnectState(ConnectState.CONNECT_STATE_RECONNECTING);
        if (NetworkMgr.getInstance().isNetworkConnected())
            mHandler.sendEmptyMessageDelayed(MSG_CONNECT, NETTY_RECONNECT_INTERVAL_TIME);
    }

    public void reconnectClient() {
        mHandler.sendEmptyMessage(MSG_RECONNECT);
    }

    //callback
    @Override
    public void onMsgResp(String message) {
        funWSHeart.resetHeartCount();
        if (msgListener != null) {
            msgListener.onMsg(message);
        }
    }

    @Override
    public void onConnected() {
        LogUtils.d(TAG, "onConnected() called" + lastHeartTime);
        if (lastHeartTime == 0) {
            lastHeartTime = SystemClock.elapsedRealtime();
            funWSHeart.startHeart();
        } else if (SystemClock.elapsedRealtime() - lastHeartTime > WSTIMEOUT) {
            notifyTimeOut(false);
        }
        //login
        setConnectState(ConnectState.CONNECT_STATE_CONNECTED);
    }

    @Override
    public void onDisConnected(int code, String reason, boolean b) {
        LogUtils.d(TAG, "onDisConnected() called with: code = [" + code + "], reason = [" + reason +
                "], b = [" + b + "]");
        if (mConnectState != ConnectState.CONNECT_STATE_IDLE) {
            mHandler.sendEmptyMessage(MSG_RECONNECT);
        }
    }

    @Override
    public void onError(Exception ex) {
        LogUtils.d(TAG, "onError() called with: ex = [" + ex + "]");
        if (mConnectState != ConnectState.CONNECT_STATE_IDLE) {
            mHandler.sendEmptyMessage(MSG_RECONNECT);
        }
    }

    public String getLocalIpAddress() {
        try {
            for (Enumeration<NetworkInterface> en = NetworkInterface.getNetworkInterfaces();
                 en.hasMoreElements(); ) {
                NetworkInterface intf = en.nextElement();
                for (Enumeration<InetAddress> enumIpAddr = intf.getInetAddresses();
                     enumIpAddr.hasMoreElements(); ) {
                    InetAddress inetAddress = enumIpAddr.nextElement();
                    if (!inetAddress.isLoopbackAddress()) {
                        return inetAddress.getHostAddress().toString();
                    }
                }
            }
        } catch (SocketException ex) {
            LogUtils.e(TAG, "getLocalIpAddress", ex);
        }
        return "";
    }

    public int getConnectState() {
        return mConnectState;
    }

    private void setConnectState(int connectState) {
        if (mConnectState == connectState) {
            return;
        }
        LogUtils.d(TAG, "setConnectState() called with: connectState = [" + connectState + "]");
        mConnectState = connectState;
        if (listener != null) {
            listener.onConnectStateChanged(mConnectState);
        }
    }

    protected void sendHeart(HeartPacket pkg) {
        sendMsg(pkg.encode(), false);
        mHandler.sendEmptyMessage(MSG_PING);
        lastHeartTime = SystemClock.elapsedRealtime();
    }

    public boolean sendMsg(String msg, boolean needLog) {
        if (needLog) {
            LogUtils.d(TAG, "sendMsg() called with: msg = [" + msg + "]");
        }
        if (client != null && client.isOpen()) {
            client.send(msg);
            return true;
        } else {
            return false;
        }
    }

    @NetWorkMonitor(monitorFilter = {NetWorkState.GPRS, NetWorkState.WIFI, NetWorkState.NONE})
    public void onNetWorkChanage(NetWorkState state) {
        LogUtils.w(TAG, "onNetWorkChanage() called with: state = [" + state + "]"+mConnectState);
        if (mConnectState == ConnectState.CONNECT_STATE_IDLE || mConnectState == ConnectState.CONNECT_STATE_LOST) return;
        if (state != NetWorkState.NONE) {
            mHandler.sendEmptyMessage(MSG_RECONNECT);
        } else {
            mHandler.sendEmptyMessage(MSG_DISCONNECT);
        }
    }

    private onConnectListener listener;
    private onMsglistener msgListener;

    public void setMsgListener(
            onMsglistener msgListener) {
        this.msgListener = msgListener;
    }

    public void setListener(
            onConnectListener listener) {
        this.listener = listener;
    }

    interface onConnectListener {
        void onConnectStateChanged(int state);
    }

    interface onMsglistener {
        void onMsg(String msg);
    }

    private class WSClientHander extends Handler {

        public WSClientHander(Looper looper) {
            super(looper);
        }

        @Override
        public void handleMessage(@NonNull Message msg) {
            switch (msg.what) {
                case MSG_CONNECT: {
                    connect();
                }
                break;
                case MSG_STOP: {
                    disconnect(true);
                }
                break;
                case MSG_DISCONNECT: {
                    disconnect(false);
                }
                break;
                case MSG_RECONNECT: {
                    reconnect();
                }
                break;
                case MSG_PING: {
                    if (client != null && client.isOpen()) {
                        client.sendPing();
                    }
                }
                break;
                default: {

                }
                break;
            }
        }
    }

    public void setAlwaysReconnect(boolean alwaysReconnect) {
        this.alwaysReconnect = alwaysReconnect;
    }
}
