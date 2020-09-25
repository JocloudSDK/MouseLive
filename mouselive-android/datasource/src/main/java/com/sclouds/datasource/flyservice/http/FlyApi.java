package com.sclouds.datasource.flyservice.http;

import com.sclouds.datasource.bean.Anchor;
import com.sclouds.datasource.bean.EffectTab;
import com.sclouds.datasource.bean.Room;
import com.sclouds.datasource.bean.User;
import com.sclouds.datasource.flyservice.http.bean.GetChatIdBean;
import com.sclouds.datasource.flyservice.http.bean.GetRoomInfo;
import com.sclouds.datasource.flyservice.http.bean.RoomListBean;
import com.sclouds.datasource.flyservice.http.network.model.HttpResponse;

import java.util.List;
import java.util.Map;

import io.reactivex.Observable;
import okhttp3.ResponseBody;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.POST;
import retrofit2.http.Streaming;
import retrofit2.http.Url;

/**
 * @author xipeitao
 * @since 2020-03-06 15:33
 */
public interface FlyApi {
    //登录
    @POST("/fun/api/v1/login")
    Observable<HttpResponse<User>> login(@Body Map<String, Object> params);

    //获取token
    @POST("/fun/api/v1/getToken")
    Observable<HttpResponse<String>> getToken(@Body Map<String, Object> params);

    //获取房间列表
    @POST("/fun/api/v1/getRoomList")
    Observable<HttpResponse<RoomListBean>> getRoomList(@Body Map<String, Object> params);

    //获取房间信息
    @POST("/fun/api/v1/getRoomInfo")
    Observable<HttpResponse<GetRoomInfo>> getRoomInfo(@Body Map<String, Object> params);

    //创建房间
    @POST("/fun/api/v1/createRoom")
    Observable<HttpResponse<Room>> createRoom(@Body Map<String, Object> params);

    //获取PK主播列表
    @POST("/fun/api/v1/getAnchorList")
    Observable<HttpResponse<List<Anchor>>> getPKMembers(@Body Map<String, Object> params);

    //获取聊天室id
    @POST("/fun/api/v1/getChatId")
    Observable<HttpResponse<GetChatIdBean>> getChatId(@Body Map<String, Object> params);

    //设置聊天室id
    @POST("/fun/api/v1/setChatId")
    Observable<HttpResponse<String>> setChatId(@Body Map<String, Object> params);

    //获取用户信息
    @POST("/fun/api/v1/getUserInfo")
    Observable<HttpResponse<User>> getUserInfo(@Body Map<String, Object> params);

    //设置房间禁麦状态
    @POST("/fun/api/v1/setRoomMic")
    Observable<HttpResponse<String>> setRoomMic(@Body Map<String, Object> params);

    //下载
    @Streaming
    @GET
    Observable<ResponseBody> download(@Url String url);

    //获取特效
    @POST("/fun/api/v1/getBeauty")
    Observable<HttpResponse<List<EffectTab>>> getEffectList(@Body Map<String, Object> params);
}
