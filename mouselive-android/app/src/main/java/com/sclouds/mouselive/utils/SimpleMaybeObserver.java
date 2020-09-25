package com.sclouds.mouselive.utils;

import com.sclouds.basedroid.LogUtils;

import androidx.annotation.CallSuper;
import io.reactivex.MaybeObserver;
import io.reactivex.annotations.NonNull;
import io.reactivex.disposables.Disposable;

/**
 * 基础实现
 *
 * @author Aslan chenhengfei@yy.com
 * @date 2020/3/22
 */
public abstract class SimpleMaybeObserver<T> implements MaybeObserver<T> {
    private static final String TAG = "Observer";

    @Override
    public void onSubscribe(Disposable d) {

    }

    @CallSuper
    @Override
    public void onError(@NonNull Throwable e) {
        e.printStackTrace();
        LogUtils.e(TAG, "onError() called with: e = [" + e.getMessage() + "]");
    }

    @Override
    public void onComplete() {

    }
}
