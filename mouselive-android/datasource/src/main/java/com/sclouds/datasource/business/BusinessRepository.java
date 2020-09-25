package com.sclouds.datasource.business;

import android.util.Log;

import com.sclouds.basedroid.LogUtils;
import com.sclouds.datasource.business.listener.BusinerssListener;
import com.sclouds.datasource.business.pkg.BasePacket;
import com.sclouds.datasource.business.pkg.ChatLimitPacket;
import com.sclouds.datasource.business.pkg.ChatPacket;
import com.sclouds.datasource.business.pkg.MicPacket;
import com.sclouds.datasource.business.pkg.RoomPacket;
import com.sclouds.datasource.flyservice.funws.ObserverBox;

import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import androidx.annotation.Nullable;
import io.reactivex.Observable;
import io.reactivex.functions.Function;

/**
 * @author xipeitao
 * @description: 业务实现
 * @date : 2020-04-16 15:39
 */
public class BusinessRepository {
    private static String TAG = "BusinessRepository";


    private long uid;
    private long rid;
    private int chatType;
    private IMouseCall call;

    public BusinessRepository(long uid, long rid,BusinerssListener listener) {
        this.uid = uid;
        this.rid = rid;
        call = new HMRMouseCall();
        call.setEcho(mSigleHandler);
    }

    private BusinerssListener listener;

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
    private ObserverBox<Integer> chatObserverBox;


    private final IMouseCall.IMouseEcho mSigleHandler = new IMouseCall.IMouseEcho() {
        @Override
        public void onCall(String call) {
            handleResp(call);
        }
    };

    private void handleResp(String message) {
        BasePacket pkg = BasePacket.decode(message, BasePacket.class);
        if (pkg.MsgId == BasePacket.EV_SC_HEARTBEAT ||
                pkg.MsgId == BasePacket.EV_SC_HEARTBEAT + 10000) {
            return;
        } else {
            LogUtils.d(TAG, "handleResp() called with: message = [" + message + "]");
        }
        int msgId = pkg.MsgId;
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
                    return;
                }
                if (roomPkg.isAck()) {
                    roomPkg.Body.setUid(uid);
                    roomPkg.Body.setLiveRoomId(rid);
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

    /**
     * 连麦请求
     *
     * @param dstUid
     * @param dstRid
     * @param chatType
     * @return
     */
    public Observable<Integer> applyChat(long dstUid, long dstRid, int chatType) {

        ChatPacket pkg =
                new ChatPacket(2123,genTraceId(), "", BasePacket.EV_CC_CHAT_REQ, uid, rid,
                        dstUid,
                        dstRid, chatType);
        mSendChat.put(dstUid, pkg);
        chatObserverBox = new ObserverBox<>();
        chatObserverBox.setTarget(pkg);
        Observable<Integer> result = Observable.create(chatObserverBox.getObserver());
        call.sendCall(uid,pkg.encode()).subscribe(aBoolean -> {
                if (!aBoolean && chatObserverBox.getEmitter() != null){
                    chatObserverBox.getEmitter().onError(new Throwable());
                    chatObserverBox= null;
                }
        });
        return result;
    }

    /**
     * 接受连麦
     *
     * @param dstUid
     * @param dstRid
     * @return
     */
    @Deprecated
    public Observable<Boolean> acceptChat(long dstUid, long dstRid) {
        ChatPacket pkg = mRcvChat.get(dstUid);
        if (pkg == null) {
            return Observable.error(new Throwable("no dstUid pkg"));
        }
        pkg.setMsgId(BasePacket.EV_CC_CHAT_ACCEPT);
        return
                call.sendCall(dstUid,
                                    (pkg.Body.SrcUid == uid ? pkg : pkg.swapUser()).encode());
    }

    /**
     * 拒绝连麦
     *
     * @param dstUid
     * @param dstRid
     * @return
     */
    @Deprecated
    public Observable<Boolean> rejectChat(long dstUid, long dstRid) {
        ChatPacket pkg = mRcvChat.remove(dstUid);
        if (pkg == null) {
            return Observable.error(new Throwable("no dstUid pkg"));
        }
        pkg.setMsgId(BasePacket.EV_CC_CHAT_REJECT);
        return call.sendCall(dstUid,(pkg.Body.SrcUid == uid ? pkg : pkg.swapUser()).encode());
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
        return call.sendCall(dstUid,(pkg.Body.SrcUid == uid ? pkg : pkg.swapUser()).encode()).map(
                (Function<Boolean, Boolean>) aBoolean -> {
                    if (aBoolean) {
                        Log.d(TAG, "cancelChat onSuccess() called");
                        if (chatObserverBox != null &&
                                chatObserverBox.getEmitter() != null) {
                            chatObserverBox.getEmitter().onComplete();
                        }
                        chatObserverBox = null;
                    }
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
        ChatPacket pkg = mRcvChat.remove(dstUid);
        if (pkg == null) {
            pkg = mSendChat.remove(dstUid);
        }

        if (pkg == null) {
            //有可能对象已经被移除了，这时候执行handupChat已经没什么意义了
            return Observable.just(false);
        }

        pkg.setMsgId(BasePacket.EV_CC_CHAT_HANGUP);
        ChatPacket finalPkg = pkg;
        return call.sendCall(dstUid,(finalPkg.Body.SrcUid == uid ? finalPkg : finalPkg.swapUser()).encode());
    }

    public Observable<Boolean> enableRemoteMic(long dstUid, int chatType, boolean enable) {
        MicPacket pkg = new MicPacket(123,genTraceId(), BasePacket.EV_CC_MIC_ENABLE, uid, rid,
                dstUid,
                rid,chatType, enable);
        return call.sendCall(dstUid,pkg.encode());
    }

    private String genTraceId() {
        SimpleDateFormat myFmt = new SimpleDateFormat("yyyyMMdd-HHmmss-SSS");
        return uid + "-" + myFmt.format(System.currentTimeMillis());
    }
}
