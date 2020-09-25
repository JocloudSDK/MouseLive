package com.sclouds.datasource.flyservice.funws;

import com.sclouds.basedroid.LogUtils;
import com.sclouds.datasource.BuildConfig;
import com.sclouds.datasource.business.pkg.BasePacket;
import com.sclouds.datasource.business.pkg.ChatLimitPacket;
import com.sclouds.datasource.business.pkg.ChatPacket;
import com.sclouds.datasource.business.pkg.LeavePacksge;
import com.sclouds.datasource.business.pkg.MicPacket;
import com.sclouds.datasource.business.pkg.RoomPacket;
import com.sclouds.datasource.flyservice.funws.listener.WSRoomListener;

import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import androidx.annotation.Nullable;
import io.reactivex.Observable;

public class FunWSSvc implements FunWSClientHandler.onMsglistener {

    private static final String TAG = FunWSSvc.class.getSimpleName();
    private static FunWSSvc sInstance;

    private String mHost = BuildConfig.WS_HOST;

    private ExecutorService connectExecutor;

    //接受到的连麦请求
    private Map<Long, ChatPacket> mRcvChat =
            Collections.synchronizedMap(new HashMap<Long, ChatPacket>() {
                @Nullable
                @Override
                public ChatPacket put(Long key, ChatPacket value) {
                    LogUtils.d(TAG,
                            "mRcvChat put() called with: key = [" + key + "], value = [" + value +
                                    "]");
                    return super.put(key, value);
                }

                @Nullable
                @Override
                public ChatPacket remove(@Nullable Object key) {
                    ChatPacket rlt = super.remove(key);
                    LogUtils.d(TAG,
                            "mRcvChat remove() called with: key = [" + key + "], value = [" + rlt +
                                    "]");
                    return rlt;
                }
            });
    //发送到的连麦请求
    private Map<Long, ChatPacket> mSendChat = Collections.synchronizedMap(new HashMap<Long,
            ChatPacket>() {
        @Nullable
        @Override
        public ChatPacket put(Long key, ChatPacket value) {
            LogUtils.d(TAG,
                    "mSendChat put() called with: key = [" + key + "], value = [" + value + "]");
            return super.put(key, value);
        }

        @Nullable
        @Override
        public ChatPacket remove(@Nullable Object key) {
            ChatPacket rlt = super.remove(key);
            LogUtils.d(TAG,
                    "mSendChat remove() called with: key = [" + key + "], value = [" + rlt + "]");
            return rlt;
        }
    });

    private HashMap<Integer, BasePacket> pkgMap = new HashMap<Integer, BasePacket>() {

        @Nullable
        @Override
        public BasePacket get(@Nullable Object key) {
            BasePacket pkg = super.get(key);
            if (pkg == null) {
                return super.get(BasePacket.EV_CS_BASE);
            }
            return pkg;
        }
    };

    private long uid;
    private long roomId;
    private long chatRoomId;
    private int chatType;
    private ObserverBox<Integer> chatObserverBox;
    FunWSClientHandler mClientHandler;

    private WSRoomListener listener;
    private long appid;

    public synchronized static FunWSSvc getInstance() {
        if (sInstance == null) {
            sInstance = new FunWSSvc();
        }
        return sInstance;
    }

    public void setNeedReconnect(boolean needReconnect) {
        mClientHandler.setAlwaysReconnect(needReconnect);
    }

    public FunWSSvc() {
        mClientHandler = new FunWSClientHandler(mHost);
        mClientHandler.setListener(new FunWSClientHandler.onConnectListener() {
            @Override
            public void onConnectStateChanged(int state) {
                switch (state) {
                    case FunWSClientHandler.ConnectState.CONNECT_STATE_CONNECTED: {
                        sendPkg(new RoomPacket(appid, genTraceId(), BasePacket.EV_CS_ENTER_ROOM_NTY,
                                uid,
                                roomId,
                                chatRoomId));
                    }
                    break;
                    default:
                        break;
                }
                if (listener != null) {
                    listener.onConnectStateChanged(state);
                }

            }
        });
        mClientHandler.setMsgListener(this);
        connectExecutor = Executors.newSingleThreadExecutor();
    }

    public void start(long appid, long uid, long roomId, long chatRoomId, int chatType) {
        if (uid <= 0 || roomId <= 0) {
            throw new IllegalArgumentException("invild uid:" + uid + " roomid:" + roomId);
        }
        this.appid = appid;
        this.uid = uid;
        this.roomId = roomId;
        this.chatRoomId = chatRoomId;
        this.chatType = chatType;
        mClientHandler.start();
    }

    public void stop() {
        sendLeavePkg();
        mClientHandler.stop();
        mSendChat.clear();
        mRcvChat.clear();
        if (chatObserverBox != null) {
            chatObserverBox.getEmitter().onComplete();
            chatObserverBox = null;
        }
    }

    private void sendLeavePkg() {
        LeavePacksge.LeaveInfo info = new LeavePacksge.LeaveInfo(appid, genTraceId(), uid, roomId,
                chatRoomId);
        sendPkg(new LeavePacksge(info));
    }

    private void handleResp(String message) {
        BasePacket pkg = BasePacket.decode(message, BasePacket.class);
        if (pkg.MsgId == BasePacket.EV_SC_HEARTBEAT ||
                pkg.MsgId == BasePacket.EV_SC_HEARTBEAT + 10000) {
            return;
        } else {
            LogUtils.d(TAG, "handleResp() called with: message = [" + message + "]");
        }
        int msgId =
                pkg.MsgId > BasePacket.EV_SC_ERRNO_BGN ? pkg.MsgId - BasePacket.EV_SC_ERRNO_BGN :
                        pkg.MsgId;
        switch (msgId) {
            case BasePacket.EV_CC_CHAT_ACCEPT: {
                ChatPacket chatPkg = BasePacket.decode(message, ChatPacket.class);
                if (chatPkg.isError() && listener != null) {
                    listener.onSeverErr(chatPkg.MsgId, chatPkg.Body.Code);
                    return;
                }
                if (chatPkg.isAck()) {
                    return;
                }
                mSendChat.put(chatPkg.Body.SrcUid, chatPkg);
                if (chatObserverBox != null) {
                    chatObserverBox.getEmitter().onNext(BasePacket.EV_CC_CHAT_ACCEPT);
                    chatObserverBox.getEmitter().onComplete();
                    chatObserverBox = null;
                }
            }
            break;
            case BasePacket.EV_CC_CHAT_REJECT: {
                ChatPacket chatPkg = BasePacket.decode(message, ChatPacket.class);
                if (chatPkg.isError() && listener != null) {
                    listener.onSeverErr(chatPkg.MsgId, chatPkg.Body.Code);
                    return;
                }
                if (chatPkg.isAck()) {
                    return;
                }
                mSendChat.remove(chatPkg.Body.SrcUid);
                if (chatObserverBox != null) {
                    chatObserverBox.getEmitter().onNext(BasePacket.EV_CC_CHAT_REJECT);
                    chatObserverBox.getEmitter().onComplete();
                    chatObserverBox = null;
                }
            }
            break;
            case BasePacket.EV_SC_CHAT_LIMIT: {
                ChatLimitPacket chatPkg = BasePacket.decode(message, ChatLimitPacket.class);
                if (chatObserverBox != null) {
                    mSendChat.remove(((ChatPacket) chatObserverBox.getTarget()).Body.DestUid);
                    chatObserverBox.getEmitter().onNext(BasePacket.EV_SC_CHAT_LIMIT);
                    chatObserverBox.getEmitter().onComplete();
                    chatObserverBox = null;
                }

            }
            break;
            case BasePacket.EV_CC_CHAT_REQ: {   //连麦请求
                ChatPacket chatPkg = BasePacket.decode(message, ChatPacket.class);
                if (chatPkg.isError() && listener != null) {
                    listener.onSeverErr(chatPkg.MsgId, chatPkg.Body.Code);
                    return;
                }
                if (chatPkg.isAck()) {
                    return;
                }
                mRcvChat.put(chatPkg.Body.SrcUid, chatPkg);
                if (listener != null) {
                    listener.onChatRev(chatPkg);
                }
            }
            break;
            case BasePacket.EV_CC_CHAT_CANCEL: {    //收到取消连麦
                ChatPacket chatPkg = BasePacket.decode(message, ChatPacket.class);
                if (chatPkg.isError() && listener != null) {
                    listener.onSeverErr(chatPkg.MsgId, chatPkg.Body.Code);
                    return;
                }
                if (chatPkg.isAck()) {
                    return;
                }
                mRcvChat.remove(chatPkg.Body.SrcUid);
                if (listener != null) {
                    listener.onChatCanel(chatPkg);
                }
            }
            break;
            case BasePacket.EV_CC_CHAT_HANGUP: {    //挂断
                ChatPacket chatPkg = BasePacket.decode(message, ChatPacket.class);
                if (chatPkg.isError() && listener != null) {
                    listener.onSeverErr(chatPkg.MsgId, chatPkg.Body.Code);
                    return;
                }
                if (chatPkg.isAck()) {
                    return;
                }
                mRcvChat.remove(chatPkg.Body.SrcUid);
                mSendChat.remove(chatPkg.Body.SrcUid);
                if (listener != null) {
                    listener.onChatHangup(chatPkg);
                }
            }
            break;
            case BasePacket.EV_SCC_CHAT_HANGUP: {   //组播的挂断
                ChatPacket chatPkg = BasePacket.decode(message, ChatPacket.class);
                if (chatPkg.isError() && listener != null) {
                    listener.onSeverErr(chatPkg.MsgId, chatPkg.Body.Code);
                    return;
                }
                if (chatPkg.isAck()) {
                    return;
                }
                if (listener != null) {
                    listener.onMuiltCastChatHangup(chatPkg);
                }
            }
            break;
            case BasePacket.EV_SCC_CHATING: {
                ChatPacket chatPkg = BasePacket.decode(message, ChatPacket.class);
                if (chatPkg.isError() && listener != null) {
                    listener.onSeverErr(chatPkg.MsgId, chatPkg.Body.Code);
                    return;
                }
                if (chatPkg.isAck()) {
                    return;
                }
                if (listener != null) {
                    listener.onMuiltCastChating(chatPkg);
                }
            }
            break;
            case BasePacket.EV_SCC_ENTER_ROOM_NTY:
            case BasePacket.EV_CS_ENTER_ROOM_NTY: {
                RoomPacket roomPkg = BasePacket.decode(message, RoomPacket.class);
                if (roomPkg.isError() && listener != null) {
                    listener.onSeverErr(roomPkg.MsgId, roomPkg.Body.Code);
                    stop(); //进入房间失败，断开连接
                    return;
                }
                if (roomPkg.isAck()) {
                    roomPkg.Body.setUid(uid);
                    roomPkg.Body.setLiveRoomId(roomId);
                    roomPkg.Body.setChatRoomId(chatType);
                }
                if (listener != null) {
                    listener.onUserEnterRoom(roomPkg);
                }
            }
            break;
            case BasePacket.EV_SCC_LEAVE_ROOM_NTY: {
                RoomPacket roomPkg = BasePacket.decode(message, RoomPacket.class);
                if (roomPkg.isError() && listener != null) {
                    listener.onSeverErr(roomPkg.MsgId, roomPkg.Body.Code);
                    return;
                }
                if (roomPkg.isAck()) {
                    return;
                }
                if (listener != null) {
                    listener.onUserLeaveRoom(roomPkg);
                }
            }
            break;
            case BasePacket.EV_CS_LEAVE_ROOM_NTY: {
                mClientHandler.stop();
                mSendChat.clear();
                mRcvChat.clear();
                if (chatObserverBox != null) {
                    chatObserverBox.getEmitter().onComplete();
                    chatObserverBox = null;
                }
            }
            break;
            case BasePacket.EV_CC_MIC_ENABLE:
            case BasePacket.EV_SCC_MIC_ENABLE: {
                MicPacket micPkg = BasePacket.decode(message, MicPacket.class);
                if (micPkg.isError() && listener != null) {
                    listener.onSeverErr(micPkg.MsgId, micPkg.Body.Code);
                    return;
                }
                if (micPkg.isAck()) {
                    return;
                }
                if (listener != null) {
                    listener.onUserMicEnable(micPkg);
                }
            }
            break;
            default:
                break;
        }
    }

    public Observable<Boolean> sendPkg(BasePacket pkg) {
        boolean ret = mClientHandler.sendMsg(pkg.encode(), true);
        return Observable.just(ret);
    }

    public Observable<Boolean> sendString(String pkg) {
        boolean ret = mClientHandler.sendMsg(pkg, true);
        return Observable.just(ret);
    }

    /**
     * 连麦请求
     *
     * @param dstUid
     * @param dstRid
     * @param chatType
     * @return
     */
    public Observable<Integer> sendChat(long dstUid, long dstRid, int chatType) {
        ChatPacket pkg =
                new ChatPacket(appid, genTraceId(), "", BasePacket.EV_CC_CHAT_REQ, uid, roomId,
                        dstUid,
                        dstRid, chatType);
        sendPkg(pkg);
        mSendChat.put(dstUid, pkg);
        chatObserverBox = new ObserverBox<>();
        chatObserverBox.setTarget(pkg);
        return Observable.create(chatObserverBox.getObserver());
    }

    private SimpleDateFormat myFmt = new SimpleDateFormat("yyyyMMdd-HHmmss-SSS");

    private String genTraceId() {
        SimpleDateFormat myFmt = new SimpleDateFormat("yyyyMMdd-HHmmss-SSS");
        return uid + "-" + myFmt.format(System.currentTimeMillis());
    }

    /**
     * 接受连麦
     *
     * @param dstUid
     * @param dstRid
     * @return
     */
    public Observable<Boolean> acceptChat(long dstUid, long dstRid) {
        ChatPacket pkg = mRcvChat.get(dstUid);
        if (pkg == null) {
            return Observable.error(new Throwable("no dstUid pkg"));
        }
        pkg.setMsgId(BasePacket.EV_CC_CHAT_ACCEPT);
        return sendPkg(pkg.Body.SrcUid == uid ? pkg : pkg.swapUser());
    }

    /**
     * 拒绝连麦
     *
     * @param dstUid
     * @param dstRid
     * @return
     */
    public Observable<Boolean> rejectChat(long dstUid, long dstRid) {
        ChatPacket pkg = mRcvChat.remove(dstUid);
        if (pkg == null) {
            return Observable.error(new Throwable("no dstUid pkg"));
        }
        pkg.setMsgId(BasePacket.EV_CC_CHAT_REJECT);
        return sendPkg(pkg.Body.SrcUid == uid ? pkg : pkg.swapUser());
    }

    /**
     * 取消连麦
     *
     * @param dstUid
     * @param dstRid
     * @return
     */
    public Observable<Boolean> cancelChat(long dstUid, long dstRid) {
        if (chatObserverBox == null) {
            return Observable.just(true);
        }
        ChatPacket pkg = mSendChat.remove(dstUid);
        if (pkg == null) {
            if (chatObserverBox != null && chatObserverBox.getEmitter() != null) {
                chatObserverBox.getEmitter().onComplete();
            }
            return Observable.just(true);
        }
        pkg.setMsgId(BasePacket.EV_CC_CHAT_CANCEL);
        return
                sendPkg(pkg).map(aBoolean -> {
                    if (chatObserverBox != null && chatObserverBox.getEmitter() != null) {
                        chatObserverBox.getEmitter().onComplete();
                    }
                    chatObserverBox = null;
                    return aBoolean;
                });
    }

    /**
     * 挂断连麦
     *
     * @param
     * @return
     */
    public Observable<Boolean> handupChat(long dstUid, long dstRid) {
        return handupChat(dstUid, dstRid, false);
    }

    /**
     * 挂断连麦
     *
     * @param
     * @return
     */
    public Observable<Boolean> handupChat(long dstUid, long dstRid, boolean force) {
        ChatPacket pkg = mRcvChat.remove(dstUid);
        if (pkg == null) {
            pkg = mSendChat.remove(dstUid);
        }
        if (force && pkg == null) { //强制挂断，用于语聊房管理员下麦用户
            pkg = new ChatPacket(appid, genTraceId(), "", BasePacket.EV_CC_CHAT_HANGUP, uid, roomId,
                    dstUid,
                    dstRid, chatType);
        }

        if (pkg == null) {
            //有可能对象已经被移除了，这时候执行handupChat已经没什么意义了
            return Observable.just(false);
        }

        pkg.setMsgId(BasePacket.EV_CC_CHAT_HANGUP);
        return sendPkg(pkg.Body.SrcUid == uid ? pkg : pkg.swapUser());
    }

    public Observable<Boolean> enableRemoteMic(long dstUid, int chatType, boolean enable) {
        return sendPkg(new MicPacket(appid, genTraceId(), BasePacket.EV_CC_MIC_ENABLE, uid, roomId,
                dstUid,
                roomId,
                chatType, enable));
    }

    public void setListener(WSRoomListener listener) {
        this.listener = listener;
    }

    @Override
    public void onMsg(String msg) {
        handleResp(msg);
    }


}
