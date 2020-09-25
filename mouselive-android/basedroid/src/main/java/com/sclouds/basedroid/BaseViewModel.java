package com.sclouds.basedroid;

import android.app.Application;

import com.trello.rxlifecycle3.LifecycleTransformer;
import com.trello.rxlifecycle3.RxLifecycle;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.annotation.StringRes;
import androidx.lifecycle.AndroidViewModel;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.MutableLiveData;
import io.reactivex.Observable;
import io.reactivex.subjects.BehaviorSubject;

/**
 * 增加 RxLifecycle
 *
 * @author Aslan
 * @date 2018/4/11
 */
public abstract class BaseViewModel<V extends IBaseView> extends AndroidViewModel {

    protected V mView;

    public MutableLiveData<String> mLiveDataLoading = new MutableLiveData<>();

    private final BehaviorSubject<Lifecycle.Event> lifecycleSubject = BehaviorSubject.create();

    public BaseViewModel(@NonNull Application application, @NonNull V mView) {
        super(application);
        this.mView = mView;
    }

    @CallSuper
    public void onCreate() {
        lifecycleSubject.onNext(Lifecycle.Event.ON_CREATE);
    }

    @CallSuper
    public void onStart() {
        lifecycleSubject.onNext(Lifecycle.Event.ON_START);
    }

    @CallSuper
    public void onResume() {
        lifecycleSubject.onNext(Lifecycle.Event.ON_RESUME);
    }

    @CallSuper
    public void onPause() {
        lifecycleSubject.onNext(Lifecycle.Event.ON_PAUSE);
    }

    @CallSuper
    public void onStop() {
        lifecycleSubject.onNext(Lifecycle.Event.ON_STOP);
    }

    @CallSuper
    public void onDestroy() {
        lifecycleSubject.onNext(Lifecycle.Event.ON_DESTROY);
    }

    @NonNull
    public Observable<Lifecycle.Event> lifecycle() {
        return lifecycleSubject.hide();
    }

    @NonNull
    public <T> LifecycleTransformer<T> bindUntilEvent(@NonNull Lifecycle.Event event) {
        return RxLifecycle.bindUntilEvent(lifecycleSubject, event);
    }

    @NonNull
    public <T> LifecycleTransformer<T> bindToLifecycle() {
        return RxLifecycle.bindUntilEvent(lifecycleSubject, Lifecycle.Event.ON_DESTROY);
    }

    public abstract void initData();

    public void showLoading() {
        mLiveDataLoading.postValue("");
    }

    public void showLoading(@StringRes int rid) {
        showLoading(getApplication().getString(rid));
    }

    public void showLoading(@NonNull String message) {
        mLiveDataLoading.postValue(message);
    }

    public void hideLoading() {
        mLiveDataLoading.postValue(null);
    }
}
