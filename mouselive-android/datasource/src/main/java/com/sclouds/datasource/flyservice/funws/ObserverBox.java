package com.sclouds.datasource.flyservice.funws;

import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;

/**
 * @author xipeitao
 * @description:
 * @date : 2020-03-17 15:05
 */
public class ObserverBox<T> {
    private ObservableOnSubscribe<T> observer;
    private ObservableEmitter<T> mEmitter;
    private Object mTarget;

    public ObserverBox() {
        this.observer = new ObservableOnSubscribe<T>() {

            @Override
            public void subscribe(ObservableEmitter<T> emitter) throws Exception {
                mEmitter = emitter;
            }
        };
    }

    public Object getTarget() {
        return mTarget;
    }

    public void setTarget(Object target) {
        mTarget = target;
    }

    public static <T> Observable err(Throwable throwable) {
        return Observable.create(new ObservableOnSubscribe<T>() {
            @Override
            public void subscribe(ObservableEmitter<T> emitter) throws Exception {
                emitter.onError(throwable);
                emitter.onComplete();
            }
        });
    }

    public ObservableOnSubscribe<T> getObserver() {
        return observer;
    }

    public ObservableEmitter<T> getEmitter() {
        return mEmitter;
    }
}
