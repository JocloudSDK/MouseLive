package com.sclouds.datasource.business;

import com.sclouds.datasource.flyservice.funws.FunWSSvc;

import io.reactivex.Observable;

/**
 * @author xipeitao
 * @description:
 * @date : 2020-04-16 16:21
 */
public class FlyMouseCall extends IMouseCall{





    @Override
    public Observable<Boolean> sendCall(long uid, String call) {
        return FunWSSvc.getInstance().sendString(call);
    }
}
