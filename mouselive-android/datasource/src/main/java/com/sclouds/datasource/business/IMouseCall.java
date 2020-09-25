package com.sclouds.datasource.business;

import io.reactivex.Observable;

/**
 * @author xipeitao
 * @description:
 * @date : 2020-04-16 15:42
 */
public abstract class IMouseCall {

    protected IMouseEcho echo;

    public abstract Observable<Boolean> sendCall(long uid,String call);

    public IMouseEcho getEcho() {
        return echo;
    }

    public void setEcho(IMouseEcho echo) {
        this.echo = echo;
    }

    interface IMouseEcho{
        void onCall(String call);
    }


}
