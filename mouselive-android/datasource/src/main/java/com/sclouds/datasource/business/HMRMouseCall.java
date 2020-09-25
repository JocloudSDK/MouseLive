package com.sclouds.datasource.business;

import com.hummer.im.chatroom.ChatRoomService;
import com.sclouds.datasource.hummer.HummerSvc;

import io.reactivex.Observable;

/**
 * @author xipeitao
 * @description:
 * @date : 2020-04-16 16:21
 */
public class HMRMouseCall extends IMouseCall{
    @Override
    public Observable<Boolean> sendCall(long uid,String call) {
        return HummerSvc.getInstance().sendSignal(ChatRoomService.Signal.unicast(new com.hummer.im.model.id.User(uid),
                call));
    }
}
