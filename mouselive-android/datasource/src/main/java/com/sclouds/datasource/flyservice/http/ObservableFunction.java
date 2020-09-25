package com.sclouds.datasource.flyservice.http;

import com.sclouds.datasource.flyservice.http.network.CustomThrowable;
import com.sclouds.datasource.flyservice.http.network.model.HttpResponse;

import io.reactivex.Observable;
import io.reactivex.functions.Function;

/**
 * 数据转换
 *
 * @author Aslan chenhengfei@yy.com
 * @date 2020/6/12
 */
public class ObservableFunction<T> implements Function<HttpResponse<T>, Observable<T>> {
    @Override
    public Observable<T> apply(HttpResponse<T> respone) throws Exception {
        if (respone.isSuccessful()) {
            if (respone.Data == null) {
                return Observable.error(new NullPointerException("respone data is empty"));
            } else {
                return Observable.just(respone.Data);
            }
        } else {
            return Observable.error(new CustomThrowable(respone.Code, respone.Msg));
        }
    }
}
