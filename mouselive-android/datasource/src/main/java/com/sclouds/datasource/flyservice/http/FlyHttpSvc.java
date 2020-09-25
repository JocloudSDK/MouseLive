package com.sclouds.datasource.flyservice.http;

import com.sclouds.datasource.BuildConfig;
import com.sclouds.datasource.TokenGetter;
import com.sclouds.datasource.bean.Anchor;
import com.sclouds.datasource.bean.EffectTab;
import com.sclouds.datasource.bean.Room;
import com.sclouds.datasource.bean.RoomType;
import com.sclouds.datasource.bean.User;
import com.sclouds.datasource.flyservice.http.bean.GetChatIdBean;
import com.sclouds.datasource.flyservice.http.bean.GetRoomInfo;
import com.sclouds.datasource.flyservice.http.bean.RoomListBean;
import com.sclouds.datasource.flyservice.http.network.CustomHttpClient;
import com.sclouds.datasource.flyservice.http.network.model.HttpResponse;

import java.util.HashMap;
import java.util.List;

import io.reactivex.Observable;
import okhttp3.ResponseBody;
import retrofit2.http.Url;

/**
 * @author xipeitao
 * @since 2020-03-09 11:39
 */
public class FlyHttpSvc {

    private Long appId;

    private FlyApi mService;

    private static FlyHttpSvc sInstance;

    public static FlyHttpSvc getInstance() {
        if (null == sInstance) {
            synchronized (FlyHttpSvc.class) {
                if (null == sInstance) {
                    sInstance = new FlyHttpSvc();
                }
            }
        }
        return sInstance;
    }

    private FlyHttpSvc() {
        mService = CustomHttpClient.getInstance().load(BuildConfig.HTTP_HOST, FlyApi.class);
    }

    /**
     * @param uid     // 首次为0，服务器反回，记录本地，后基于这个登陆，10001～(100*10000*10000)的随机数
     * @param DevName // 设备名称：android：例如：XiaoMi8
     * @param DevUUID // 设备UUID：android：例如：9774d56d682e549c
     * @return 返回对象
     */
    public Observable<User> login(long uid, String DevName, String DevUUID,
                                  long appId, String appSecret) {
        HashMap<String, Object> params = createParams();
        params.put("AppId", appId);
        params.put("AppSecret", appSecret);
        params.put("ValidTime", TokenGetter.EXPIRED_TIME);
        params.put("Uid", uid);
        params.put("DevName", DevName);
        params.put("DevUUID", DevUUID);
        return mService.login(params).flatMap(new ObservableFunction<>());
    }

    public Observable<HttpResponse<String>> getToken(long uid, long appid, String appScret,
                                                     long expireTime) {
        HashMap<String, Object> params = createParams();
        params.put("AppId", appid);
        params.put("AppSecret", appScret);
        params.put("ValidTime", expireTime);
        params.put("Uid", uid);
        return mService.getToken(params);
    }

    /**
     * 获取主播列表（PK使用）
     *
     * @param Uid   用户id
     * @param RType 房间类型 {@link RoomType}
     * @return 返回对象
     */
    public Observable<List<Anchor>> getPKMembers(long Uid, @RoomType int RType) {
        HashMap<String, Object> params = createParams();
        params.put("Uid", Uid);
        params.put("RType", RType);
        return mService.getPKMembers(params).flatMap(new ObservableFunction<>());
    }

    /**
     * @param uid      用户id
     * @param roomType 房间类型 {@link RoomType}
     * @param offset   偏移量
     * @return 返回对象
     */
    public Observable<RoomListBean> getRoomList(long uid, @RoomType int roomType,
                                                int offset) {
        HashMap<String, Object> params = createParams();
        params.put("Uid", uid);
        params.put("RType", roomType);
        params.put("Offset", offset);
        params.put("Limit", 20);
        return mService.getRoomList(params).flatMap(new ObservableFunction<>());
    }

    /**
     * @param uid    用户id
     * @param roomId 房间ID
     * @param RType  房间类型
     * @return 返回对象
     */
    public Observable<GetRoomInfo> getRoomInfo(long uid, long roomId,
                                               @RoomType int RType) {
        HashMap<String, Object> params = createParams();
        params.put("Uid", uid);
        params.put("RoomId", roomId);
        params.put("RType", RType);
        return mService.getRoomInfo(params).flatMap(new ObservableFunction<>());
    }

    /**
     * 获取聊天室ID
     *
     * @param uid   用户id
     * @param rid   房间ID
     * @param rtype 房间类型 {@link RoomType}
     * @return 返回对象
     */
    public Observable<GetChatIdBean> getChatId(long uid, long rid,
                                               @RoomType int rtype) {
        HashMap<String, Object> params = createParams();
        params.put("Uid", uid);
        params.put("RoomId", rid);
        params.put("RType", rtype);
        return mService.getChatId(params).flatMap(new ObservableFunction<>());
    }

    /**
     * 设置聊天室ID
     *
     * @param uid      用户id
     * @param rid      房间ID
     * @param roomType 房间类型 {@link RoomType}
     * @param chatId   聊天室id
     * @return 返回对象
     */
    public Observable<String> setChatId(long uid, long rid,
                                        @RoomType int roomType, long chatId) {
        HashMap<String, Object> params = createParams();
        params.put("Uid", uid);
        params.put("RoomId", rid);
        params.put("RType", roomType);
        params.put("RChatId", chatId);
        return mService.setChatId(params).flatMap(new ObservableFunction<>());
    }

    /**
     * 创建房间
     *
     * @param user 当前登陆的用户
     * @param room 创建的房间信息
     * @return 返回对象
     */
    public Observable<Room> createRoom(User user, Room room) {
        HashMap<String, Object> params = createParams();
        params.put("Uid", user.getUid());
        params.put("RType", room.getRType());
        params.put("RPublishMode", room.getRPublishMode());
        return mService.createRoom(params).flatMap(new ObservableFunction<>());
    }

    /**
     * 获取用户信息
     *
     * @param uid 用户id
     * @return 返回对象
     */
    public Observable<User> getUserInfo(long uid) {
        HashMap<String, Object> params = createParams();
        params.put("Uid", uid);
        return mService.getUserInfo(params).flatMap(new ObservableFunction<>());
    }

    /**
     * 设置全局禁麦
     *
     * @param Rid        房间id
     * @param RType      房间类型
     * @param RMicEnable 是否可用
     * @return 返回对象
     */
    public Observable<String> setRoomMic(long Rid, @RoomType int RType,
                                         boolean RMicEnable) {
        HashMap<String, Object> params = createParams();
        params.put("RoomId", Rid);
        params.put("RType", RType);
        params.put("RMicEnable", RMicEnable);
        return mService.setRoomMic(params).flatMap(new ObservableFunction<>());
    }

    /**
     * 下载
     *
     * @param url 下载地址
     * @return 返回对象
     */
    public Observable<ResponseBody> download(@Url String url) {
        return mService.download(url);
    }

    /**
     * 获取特效列表
     *
     * @return 返回对象
     */
    public Observable<List<EffectTab>> getEffectList(String Version) {
        HashMap<String, Object> params = createParams();
        params.put("Version", Version);
        return mService.getEffectList(params).flatMap(new ObservableFunction<>());
    }

    private HashMap<String, Object> createParams() {
        HashMap<String, Object> params = new HashMap<>();
        params.put("SvrVer", BuildConfig.SERVICE_VERSION);
        params.put("AppId", appId);
        return params;
    }

    public void setAppId(Long appId) {
        this.appId = appId;
    }

}
