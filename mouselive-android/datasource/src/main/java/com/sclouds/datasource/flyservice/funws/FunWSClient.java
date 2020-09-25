package com.sclouds.datasource.flyservice.funws;

import org.java_websocket.client.WebSocketClient;
import org.java_websocket.handshake.ServerHandshake;

import java.net.URI;

public class FunWSClient extends WebSocketClient {

    private static final String TAG = FunWSClient.class.getSimpleName();

    private WSListener mWSListener;

    public FunWSClient(String host, WSListener wsSvc) {
        super(URI.create(host));
        mWSListener = wsSvc;
    }

    @Override
    public void onOpen(ServerHandshake handshakedata) {
        if (mWSListener != null) {
            mWSListener.onConnected();
        }
    }

    @Override
    public void onMessage(String message) {
        if (mWSListener != null) {
            mWSListener.onMsgResp(message);
        }

    }

    @Override
    public void onClose(int code, String reason, boolean remote) {
        if (mWSListener != null) {
            mWSListener.onDisConnected(code, reason, remote);
        }

    }

    @Override
    public void onError(Exception ex) {
        if (mWSListener != null) {
            mWSListener.onError(ex);
        }

    }

    @Override
    public void send(String text) {
        super.send(text);
    }

    @Override
    public void send(byte[] data) {
        super.send(data);
    }

    protected void setWSListener(WSListener listener) {
        this.mWSListener = listener;
    }

    public interface WSListener {

        void onMsgResp(String message);

        void onConnected();

        void onDisConnected(int code, String reason, boolean b);

        void onError(Exception ex);
    }
}
