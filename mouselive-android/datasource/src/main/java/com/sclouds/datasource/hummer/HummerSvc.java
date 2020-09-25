package com.sclouds.datasource.hummer;

import android.content.Context;
import android.text.TextUtils;
import android.util.ArrayMap;
import android.util.Log;

import com.google.gson.Gson;
import com.hummer.im.Error;
import com.hummer.im.HMR;
import com.hummer.im.HMR.CompletionArg;
import com.hummer.im.chatroom.Challenges;
import com.hummer.im.chatroom.ChatRoomInfo;
import com.hummer.im.chatroom.ChatRoomService;
import com.hummer.im.model.chat.Content;
import com.hummer.im.model.chat.Message;
import com.hummer.im.model.chat.contents.Text;
import com.hummer.im.model.id.ChatRoom;
import com.hummer.im.service.Channel;
import com.hummer.im.service.ChannelStateService;
import com.hummer.im.service.ChatService;
import com.sclouds.basedroid.LogUtils;
import com.sclouds.datasource.Callback;
import com.sclouds.datasource.TokenGetter;
import com.sclouds.datasource.bean.User;
import com.sclouds.datasource.hummer.listener.IMessageListener;
import com.sclouds.datasource.hummer.listener.IRoomListener;
import com.sclouds.datasource.hummer.listener.IUserListener;

import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.reactivex.Maybe;
import io.reactivex.Observable;
import io.reactivex.Single;

/**
 * @author xipeitao
 * @description:
 * @date : 2020-02-18 19:16
 */
public class HummerSvc implements HMR.TokenInvalidListener {

    public static final String TAG = HummerSvc.class.getSimpleName();

    public static final String TAG_ROLE_ADMIN = "admin";
    private static final String CMD_CHAT_REQ = "CMD_CHAT_REQ";

    private static HummerSvc sInstance;
    private static ChatRoomService mServiceImpl;
    private static ChatService mChatService;
    private long uid;
    private long appId;
    private String appScret;

    private Gson mGson = new Gson();

    private ChatRoom channel;
    private RoomInfo mRoomInfo = new RoomInfo();

    private IUserListener userListener;

    private HummerSvc() {
    }

    public synchronized static HummerSvc getInstance() {
        if (sInstance == null) {
            synchronized (HummerSvc.class) {
                if (sInstance == null) {
                    sInstance = new HummerSvc();
                }
            }
        }
        return sInstance;
    }

    public void addRoomListener(@NonNull IRoomListener l) {
        LogUtils.d(TAG, "addMemListener() called");
        roomlisteners.add(l);
    }

    public void removeRoomListener(@NonNull IRoomListener l) {
        LogUtils.d(TAG, "removeMemListener() called");
        roomlisteners.remove(l);
    }

    public void addChatListener(@NonNull IMessageListener l) {
        LogUtils.d(TAG, "addMessageListener() called");
        chatlisteners.add(l);
    }

    public void removeChatListener(@NonNull IMessageListener l) {
        LogUtils.d(TAG, "removeMessageListener() called");
        chatlisteners.remove(l);
    }

    private boolean isIni = false;
    private boolean isHummerConnected = false;

    /**
     * SDK 初始化
     *
     * @param context
     */
    @MainThread
    public void ini(@NonNull Context context, long appid, String appScret) {
        LogUtils.d(TAG, "ini() called isIni= [" + isIni + "]");
        if (isIni) {
            return;
        }
        this.appId = appid;
        this.appScret = appScret;
        this.isHummerConnected = false;

        HMR.init(context, appid);
        HMR.getService(ChannelStateService.class).addChannelStateListener(mChannelStateListener);
        HMR.addStateListener(mStateListener);

        mServiceImpl = HMR.getService(ChatRoomService.class);
        mChatService = HMR.getService(ChatService.class);
        mServiceImpl.addListener(roomHandler);
        mServiceImpl.addMemberListener(roomHandler);
        isIni = true;
    }

    private RoomHandler roomHandler = new RoomHandler();
    private ChatHandler chatHandler = new ChatHandler();
    private Set<IRoomListener> roomlisteners =
            Collections.synchronizedSet(new HashSet<>());
    private Set<IMessageListener> chatlisteners =
            Collections.synchronizedSet(new HashSet<>());
    private ChannelStateService.ChannelStateListener mChannelStateListener =
            new ChannelStateService.ChannelStateListener() {
                @Override
                public void onUpdateChannelState(ChannelStateService.ChannelState fromState,
                                                 ChannelStateService.ChannelState toState) {
                    LogUtils.d(TAG,
                            "onUpdateChannelState() called with: fromState = [" + fromState +
                                    "], toState = [" + toState + "]");
                }
            };
    private HMR.StateListener mStateListener = new HMR.StateListener() {
        @Override
        public void onUpdateHummerState(HMR.State fromState, HMR.State toState) {
            LogUtils.d(TAG, "onUpdateHummerState() called with: fromState = [" + fromState +
                    "], toState = [" + toState + "]");
        }
    };

    class RoomHandler implements ChatRoomService.ChatRoomListener, ChatRoomService.MemberListener {

        @Override
        public void onBasicInfoChanged(@NonNull ChatRoom chatRoom,
                                       @NonNull Map<ChatRoomInfo.BasicInfoType, String> propInfo) {
            if (chatRoom.equals(channel)) {
                for (IRoomListener l : roomlisteners) {
                    l.onBasicInfoChanged(chatRoom, propInfo);
                }
            }
        }

        @Override
        public void onChatRoomDismissed(@NonNull ChatRoom chatRoom,
                                        @NonNull com.hummer.im.model.id.User member) {
            if (chatRoom.equals(channel)) {
                for (IRoomListener l : roomlisteners) {
                    l.onChatRoomDismissed(chatRoom, member);
                }
            }
        }

        @Override
        public void onMemberJoined(@NonNull ChatRoom chatRoom,
                                   @NonNull List<com.hummer.im.model.id.User> members) {
            if (chatRoom.equals(channel)) {
                for (IRoomListener l : roomlisteners) {
                    l.onMemberJoined(chatRoom, members);
                }
            }
        }

        @Override
        public void onMemberLeaved(@NonNull ChatRoom chatRoom,
                                   @NonNull List<com.hummer.im.model.id.User> members, int type,
                                   @NonNull String reason) {
            if (chatRoom.equals(channel)) {
                for (IRoomListener l : roomlisteners) {
                    l.onMemberLeaved(chatRoom, members, type, reason);
                }
            }
        }

        @Override
        public void onMemberCountChanged(@NonNull ChatRoom chatRoom, int count) {
            if (chatRoom.equals(channel)) {
                for (IRoomListener l : roomlisteners) {
                    l.onMemberCountChanged(chatRoom, count);
                }
            }
        }

        @Override
        public void onRoleAdded(@NonNull ChatRoom chatRoom, @NonNull String role,
                                @NonNull com.hummer.im.model.id.User admin,
                                @NonNull com.hummer.im.model.id.User fellow) {
            if (chatRoom.equals(channel)) {
                for (IRoomListener l : roomlisteners) {
                    l.onRoleAdded(chatRoom, role, admin, fellow);
                }
            }
        }

        @Override
        public void onRoleRemoved(@NonNull ChatRoom chatRoom, @NonNull String role,
                                  @NonNull com.hummer.im.model.id.User admin,
                                  @NonNull com.hummer.im.model.id.User fellow) {
            if (chatRoom.equals(channel)) {
                for (IRoomListener l : roomlisteners) {
                    l.onRoleRemoved(chatRoom, role, admin, fellow);
                }
            }
        }

        @Override
        public void onMemberKicked(@NonNull ChatRoom chatRoom,
                                   @NonNull com.hummer.im.model.id.User admin,
                                   @NonNull List<com.hummer.im.model.id.User> member,
                                   @NonNull String reason) {
            if (chatRoom.equals(channel)) {
                for (IRoomListener l : roomlisteners) {
                    l.onMemberKicked(chatRoom, admin, member, reason);
                }
            }
        }

        @Override
        public void onMemberMuted(@NonNull ChatRoom chatRoom,
                                  @NonNull com.hummer.im.model.id.User operator,
                                  @NonNull Set<com.hummer.im.model.id.User> members,
                                  @Nullable String reason) {
            if (chatRoom.equals(channel)) {
                for (IRoomListener l : roomlisteners) {
                    l.onMemberMuted(chatRoom, operator, members, reason);
                }
            }
        }

        @Override
        public void onMemberUnmuted(@NonNull ChatRoom chatRoom,
                                    @NonNull com.hummer.im.model.id.User operator,
                                    @NonNull Set<com.hummer.im.model.id.User> members,
                                    @Nullable String reason) {
            if (chatRoom.equals(channel)) {
                for (IRoomListener l : roomlisteners) {
                    l.onMemberUnmuted(chatRoom, operator, members, reason);
                }
            }
        }

        @Override
        public void onUserInfoSet(@NonNull ChatRoom chatRoom,
                                  @NonNull com.hummer.im.model.id.User user,
                                  @NonNull Map<String, String> infoMap) {
            if (chatRoom.equals(channel)) {
                for (IRoomListener l : roomlisteners) {
                    l.onUserInfoSet(chatRoom, user, infoMap);
                }
            }
        }

        @Override
        public void onUserInfoDeleted(@NonNull ChatRoom chatRoom,
                                      @NonNull com.hummer.im.model.id.User user,
                                      @NonNull Map<String, String> infoMap) {

        }
    }

    class ChatHandler implements ChatService.MessageListener {

        @Override
        public void beforeSendingMessage(@NonNull Message message) {
            Log.d(TAG, "beforeSendingMessage() called with: message = [" + message + "]");

        }

        @Override
        public void afterSendingMessage(@NonNull Message message) {
            Log.d(TAG, "afterSendingMessage() called with: message = [" + message + "]");

        }

        @Override
        public void beforeReceivingMessage(@NonNull Message message) {
            Log.d(TAG, "beforeReceivingMessage() called with: message = [" + message + "]");

        }

        @Override
        public void afterReceivingMessage(@NonNull Message message) {
            Log.d(TAG, "afterReceivingMessage() called with: message = [" + message + "]");
            if (message.getContent() instanceof Text) {
                for (IMessageListener l : chatlisteners) {
                    l.onMessageTxt(message);
                }
            } else if (message.getContent() instanceof ChatRoomService.Signal) {
                for (IMessageListener l : chatlisteners) {
                    l.onSignle(message);
                }
            }
        }
    }

    /**
     * SDK 登录业务
     *
     * @param uid     用户号
     * @param isChina 是否是国内
     * @param token   token
     */
    public Single<Integer> login(long uid, boolean isChina, String token) {
        LogUtils.d(TAG, "login Uid=" + uid + " isChina=" + isChina);

        return Single.create(emitter -> {
            mServiceImpl.setRegion("cn");
            HMR.open(uid, "cn", null, token,
                    new HMR.Completion() {
                        @Override
                        public void onSuccess() {
                            LogUtils.d(TAG, "login onSuccess");
                            HummerSvc.this.uid = uid;
                            //需要设置token过期的监听，避免token过期之后鉴权不通过
                            HMR.addTokenInvalidListener(HummerSvc.this);
                            HMR.getService(Channel.class).addStateListener(
                                    new Channel.StateChangedListener() {
                                        @Override
                                        public void onPreChannelConnected() {
                                            Log.d(TAG, "onPreChannelConnected() called");
                                        }

                                        @Override
                                        public void onChannelConnected() {
                                            Log.d(TAG, "onChannelConnected() called");
                                        }

                                        @Override
                                        public void onChannelDisconnected() {
                                            Log.d(TAG, "onChannelDisconnected() called");
                                        }
                                    });
                            if (userListener != null) {
                                userListener.onLogin();
                            }
                            emitter.onSuccess(1);
                        }

                        @Override
                        public void onFailed(Error err) {
                            LogUtils.d(TAG, "login onFailed " + err.toString());
                            emitter.onSuccess(0);
                        }
                    });
        });
    }

    /**
     * 销毁
     */
    @MainThread
    public Single<Boolean> destory() {
        LogUtils.d(TAG, "destory() called");
        return Single.create(emitter -> {
            HMR.close(new HMR.Completion() {
                @Override
                public void onSuccess() {
                    LogUtils.d(TAG, "destory onSuccess() called");
                    emitter.onSuccess(true);
                }

                @Override
                public void onFailed(Error err) {
                    LogUtils.d(TAG, "destory onFailed() called " + err);
                    emitter.onSuccess(false);
                }
            });
        });
    }

    /**
     * 创建房间
     *
     * @param roomName 房间名称
     */
    public Single<Long> createRoom(String roomName) {
        LogUtils.d(TAG, "createRoom() called with: roomName = [" + roomName + "]");
        return Single.create(emitter -> {
            mServiceImpl.createChatRoom(new ChatRoomInfo(roomName, null, null, null),
                    new CompletionArg<ChatRoom>() {
                        @Override
                        public void onSuccess(ChatRoom channel) {
                            LogUtils.d(TAG,
                                    "createRoom onSuccess() called with: channel = [" + channel +
                                            "]");
                            emitter.onSuccess(channel.getId());
                        }

                        @Override
                        public void onFailed(Error err) {
                            LogUtils.d(TAG,
                                    "createChatRoom onFailed() called with: err = [" + err + "]");
                            emitter.onError(new Throwable(err.toString()));
                        }
                    });
        });
    }

    /**
     * 加入房间
     *
     * @param roomId 房间号
     * @param uid    用户号
     */
    public Single<Boolean> joinChannel(long roomId, long uid) {
        LogUtils.d(TAG, "joinChannel roomId=" + roomId + " Uid=" + uid);
        ChatRoom channel = new ChatRoom(roomId);
        return Single.create(emitter -> {
            mServiceImpl.join(channel, new ArrayMap<>(), new Challenges.JoiningCompletion() {
                @Override
                public void onSucceed() {
                    LogUtils.d(TAG, "joinChannel onSuccess");
                    mRoomInfo = new RoomInfo();
                    HummerSvc.this.channel = channel;
                    mChatService.addMessageListener(channel, chatHandler);
                    emitter.onSuccess(true);
                }

                @Override
                public void onFailure(@NonNull Error error) {
                    LogUtils.d(TAG, "joinChannel onFailed " + error.toString());
                    emitter.onSuccess(false);
                }

                @Override
                public void onReceiveChallenge(Challenges.Password challenge) {

                }

                @Override
                public void onReceiveChallenge(Challenges.AppChallenge challenge) {

                }
            });
        });
    }

    /**
     * 离开房间
     *
     * @param callback 回调
     */
    public void leaveChannel(@Nullable Callback callback) {
        LogUtils.d(TAG, "leaveChannel");
        if (channel == null) {
            return;
        }
        mServiceImpl.leave(channel, new HMR.Completion() {
            @Override
            public void onSuccess() {
                LogUtils.d(TAG, "leaveChannel onSuccess");
                mChatService.removeMessageListener(channel, chatHandler);
                HummerSvc.this.channel = null;
                if (callback != null) {
                    callback.onSuccess();
                }
            }

            @Override
            public void onFailed(Error err) {
                LogUtils.d(TAG, "leaveChannel onFailed " + err.toString());
                if (callback != null) {
                    callback.onFailed(err.code);
                }
            }
        });
    }

    /**
     * 添加角色,目前只能设置 "Admin"
     *
     * @param user 对方用户
     */
    public Single<Boolean> addRole(@NonNull User user) {
        LogUtils.d(TAG, "addRole user=" + mGson.toJson(user));
        return Single.create(emitter -> {
            mServiceImpl.addRole(channel, new com.hummer.im.model.id.User(user.getUid()),
                    TAG_ROLE_ADMIN,
                    new HMR.Completion() {
                        @Override
                        public void onSuccess() {
                            LogUtils.d(TAG, "addRole onSuccess");
                            emitter.onSuccess(true);
                        }

                        @Override
                        public void onFailed(Error err) {
                            LogUtils.d(TAG, "addRole onFailed " + err.toString());
                            emitter.onSuccess(false);
                        }
                    });
        });
    }

    /**
     * 移除角,目前只能设置成 "Admin"
     *
     * @param user 对方用户
     */
    public Single<Boolean> removeRole(@NonNull User user) {
        LogUtils.d(TAG, "removeRole user=" + mGson.toJson(user));
        return Single.create(emitter -> {
            mServiceImpl
                    .removeRole(channel, new com.hummer.im.model.id.User(user.getUid()),
                            TAG_ROLE_ADMIN,
                            new HMR.Completion() {
                                @Override
                                public void onSuccess() {
                                    LogUtils.d(TAG, "removeRole onSuccess");
                                    emitter.onSuccess(true);
                                }

                                @Override
                                public void onFailed(Error err) {
                                    LogUtils.d(TAG, "removeRole onFailed " + err.toString());
                                    emitter.onSuccess(false);
                                }
                            });
        });
    }

    /**
     * 禁言成员
     *
     * @param user 对方用户
     */
    public Single<Boolean> muteMember(@NonNull User user) {
        LogUtils.d(TAG, "muteMember user=" + mGson.toJson(user));
        return Single.create(emitter -> {
            mServiceImpl
                    .muteMember(channel, new com.hummer.im.model.id.User(user.getUid()), "reason",
                            new HMR.Completion() {
                                @Override
                                public void onSuccess() {
                                    LogUtils.d(TAG, "muteMember onSuccess");
                                    emitter.onSuccess(true);
                                }

                                @Override
                                public void onFailed(Error err) {
                                    LogUtils.d(TAG, "muteMember onFailed " + err.toString());
                                    emitter.onSuccess(false);
                                }
                            });
        });
    }

    /**
     * 解除禁言成员
     *
     * @param user 对方用户
     */
    public Single<Boolean> unmuteMember(@NonNull User user) {
        LogUtils.d(TAG, "unmuteMember user=" + mGson.toJson(user));
        return Single.create(emitter -> {
            mServiceImpl
                    .unmuteMember(channel, new com.hummer.im.model.id.User(user.getUid()), "reason",
                            new HMR.Completion() {
                                @Override
                                public void onSuccess() {
                                    LogUtils.d(TAG, "unmuteMember onSuccess");
                                    emitter.onSuccess(true);
                                }

                                @Override
                                public void onFailed(Error err) {
                                    LogUtils.d(TAG, "unmuteMember onFailed " + err.toString());
                                    emitter.onSuccess(false);
                                }
                            });
        });
    }

    /**
     * 踢人
     *
     * @param user 对方用户
     */
    public Single<Boolean> kick(@NonNull User user) {
        LogUtils.d(TAG, "kick user=" + mGson.toJson(user));
        return Single.create(emitter -> {
            mServiceImpl.kick(channel, new com.hummer.im.model.id.User(user.getUid()), null,
                    new HMR.Completion() {
                        @Override
                        public void onSuccess() {
                            LogUtils.d(TAG, "kick onSuccess");
                            emitter.onSuccess(true);
                        }

                        @Override
                        public void onFailed(Error err) {
                            LogUtils.d(TAG, "kick onFailed " + err.toString());
                            emitter.onSuccess(false);
                        }
                    });
        });
    }

    /**
     * 聊天室发送消息共频信息
     *
     * @param msg 消息体
     */
    public Single<Boolean> sendChatRoomMessage(@NonNull String msg) {
        LogUtils.d(TAG, "sendMessage() called with: msg = [" + msg + "]");
        return Single.create(emitter -> {
            Content content = new Text(msg);
            Message message = new Message(channel, content);
            mChatService.send(message, new HMR.Completion() {
                @Override
                public void onSuccess() {
                    LogUtils.d(TAG, "sendMessage onSuccess() called");
                    emitter.onSuccess(true);
                }

                @Override
                public void onFailed(Error err) {
                    LogUtils.d(TAG, "sendMessage onFailed() called with: err = [" + err + "]");
                    emitter.onSuccess(false);
                }
            });
        });
    }

    /**
     * 全体禁言，目前通过changeBasicInfo实现
     *
     * @param isAllMute
     */
    public Single<Boolean> muteAll(boolean isAllMute) {
        LogUtils.d(TAG, "muteAll() called with: isAllMute = [" + isAllMute + "]");
        return Single.create(emitter -> {
            mRoomInfo.setAllMute(isAllMute);
            Map<ChatRoomInfo.BasicInfoType, String> map = new HashMap<>();
            map.put(ChatRoomInfo.BasicInfoType.AppExtra, mGson.toJson(mRoomInfo));
            mServiceImpl.changeBasicInfo(channel, map, new HMR.Completion() {
                @Override
                public void onSuccess() {
                    LogUtils.d(TAG, "muteAll onSuccess() called");
                    emitter.onSuccess(true);
                }

                @Override
                public void onFailed(Error err) {
                    LogUtils.d(TAG, "muteAll onFailed() called with: err = [" + err + "]");
                    emitter.onSuccess(false);
                }
            });
        });
    }

    /**
     * 全体闭麦，目前通过changeBasicInfo实现
     *
     * @param micEnable
     */
    public Single<Boolean> setAllMicEnable(boolean micEnable) {
        LogUtils.d(TAG, "setAllMicEnable() called with: micEnable = [" + micEnable + "]");
        return Single.create(emitter -> {
            mRoomInfo.setAllMicOff(!micEnable);
            Map<ChatRoomInfo.BasicInfoType, String> map = new HashMap<>();
            map.put(ChatRoomInfo.BasicInfoType.AppExtra, mGson.toJson(mRoomInfo));
            mServiceImpl.changeBasicInfo(channel, map, new HMR.Completion() {
                @Override
                public void onSuccess() {
                    LogUtils.d(TAG, "setAllMicEnable onSuccess() called");
                    emitter.onSuccess(true);
                }

                @Override
                public void onFailed(Error err) {
                    LogUtils.d(TAG, "setAllMicEnable onFailed() called with: err = [" + err + "]");
                    emitter.onSuccess(false);
                }
            });
        });
    }

    /**
     * 获取角色列表
     */
    public Maybe<List<com.hummer.im.model.id.User>> fetchRoleMembers() {
        LogUtils.d(TAG, "fetchRoleMembers() called");
        return Maybe.create(emitter -> {
            mServiceImpl.fetchRoleMembers(channel, false,
                    new CompletionArg<Map<String, List<com.hummer.im.model.id.User>>>() {
                        @Override
                        public void onSuccess(Map<String, List<com.hummer.im.model.id.User>> arg) {
                            LogUtils.d(TAG,
                                    "fetchRoleMembers onSuccess() called " + mGson.toJson(arg));
                            List<com.hummer.im.model.id.User> list = arg.get(TAG_ROLE_ADMIN);
                            if (list != null) {
                                emitter.onSuccess(list);
                            } else {
                                emitter.onComplete();
                            }
                        }

                        @Override
                        public void onFailed(Error err) {
                            LogUtils.d(TAG,
                                    "fetchRoleMembers onFailed() called with: err = [" + err + "]");
                            emitter.onError(new Throwable(err.toString()));
                        }
                    });
        });
    }

    /**
     * 获取禁言成员
     */
    public Maybe<Set<com.hummer.im.model.id.User>> fetchMutedMembers() {
        LogUtils.d(TAG, "fetchMutedMembers() called");
        return Maybe.create(emitter -> {
            mServiceImpl.fetchMutedUsers(channel,
                    new HMR.CompletionArg<Set<com.hummer.im.model.id.User>>() {

                        @Override
                        public void onSuccess(Set<com.hummer.im.model.id.User> arg) {
                            LogUtils.d(TAG,
                                    "fetchMutedMembers onSuccess() called " + mGson.toJson(arg));
                            if (arg != null) {
                                emitter.onSuccess(arg);
                            } else {
                                emitter.onComplete();
                            }
                        }

                        @Override
                        public void onFailed(Error err) {
                            LogUtils.d(TAG,
                                    "fetchMutedMembers onFailed() called with: err = [" + err +
                                            "]");
                            emitter.onError(new Throwable(err.toString()));
                        }
                    });
        });
    }

    /**
     * 获取聊天室信息
     */
    public Single<ChatRoomInfo> fetchBasicInfo() {
        LogUtils.d(TAG, "fetchBasicInfo() called");
        return Single.create(emitter -> {
            mServiceImpl.fetchBasicInfo(channel, new HMR.CompletionArg<ChatRoomInfo>() {
                @Override
                public void onSuccess(ChatRoomInfo arg) {
                    LogUtils.d(TAG, "fetchBasicInfo onSuccess() called");
                    String AppExtra = arg.getAppExtra();
                    if (TextUtils.isEmpty(AppExtra) == false) {
                        mRoomInfo = mGson.fromJson(AppExtra, HummerSvc.RoomInfo.class);
                    }
                    emitter.onSuccess(arg);
                }

                @Override
                public void onFailed(Error err) {
                    LogUtils.d(TAG, "fetchBasicInfo onFailed() called with: err = [" + err + "]");
                    emitter.onError(new Throwable(err.toString()));
                }
            });
        });
    }

    public Observable<Boolean> sendSignal(ChatRoomService.Signal signal) {
        return Observable.create(emitter -> {
            mChatService.send(new Message(channel,
                            signal)
                    , new HMR.Completion() {
                        @Override
                        public void onSuccess() {
                            Log.d(TAG, "sendSignal onSuccess() called");
                            emitter.onNext(true);
                            emitter.onComplete();
                        }

                        @Override
                        public void onFailed(Error err) {
                            emitter.onError(new Throwable(err.toString()));
                        }
                    });
        });
    }

    @Override
    public void onHummerTokenInvalid(HMR.TokenInvalidCode code, String desc) {
        LogUtils.d(TAG,
                "onHummerTokenInvalid() called with: code = [" + code + "], desc = [" + desc + "]");
        TokenGetter.updateToken(uid, appId, appScret)
                .subscribe(aBoolean -> HMR.refreshToken(TokenGetter.getToken()));

    }

    public static class RoomInfo {
        private boolean isAllMute = false;
        private boolean isAllMicOff = false;

        public boolean isAllMute() {
            return isAllMute;
        }

        public void setAllMute(boolean allMute) {
            isAllMute = allMute;
        }

        public boolean isAllMicOff() {
            return isAllMicOff;
        }

        public void setAllMicOff(boolean allMicOff) {
            isAllMicOff = allMicOff;
        }
    }
}
