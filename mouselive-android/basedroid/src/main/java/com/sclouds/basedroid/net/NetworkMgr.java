package com.sclouds.basedroid.net;

import android.app.Activity;
import android.app.Application;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.LinkProperties;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkInfo;
import android.net.NetworkRequest;
import android.os.Build;
import android.telephony.TelephonyManager;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

/**
 * use
 *
 * @NetWorkMonitor(monitorFilter = {NetWorkState.GPRS})//只接受网络状态变为GPRS类型的消息
 * public void onNetWorkStateChange(NetWorkState netWorkState) {
 * Log.i("TAG", "onNetWorkStateChange >>> :" + netWorkState.name());
 * }
 */
public class NetworkMgr {

    public static final String TAG = "NetWorkMonitor >>> : ";
    private static NetworkMgr sInstance;
    private Application application;

    private NetWorkState state = NetWorkState.NONE;

    public static NetworkMgr getInstance() {
        synchronized (NetworkMgr.class) {
            if (sInstance == null) {
                sInstance = new NetworkMgr();
            }
        }
        return sInstance;
    }

    /**
     * 存储接受网络状态变化消息的方法的map
     */
    Map<Object, NetWorkStateReceiverMethod> netWorkStateChangedMethodMap = new HashMap<>();

    private NetworkMgr() {
    }

    /**
     * 初始化 传入application
     *
     * @param application
     */
    public void init(Application application) {
        if (application == null) {
            throw new NullPointerException("application can not be null");
        }
        this.application = application;
        initMonitor();
        state = getNetworkType(application);
    }

    /**
     * 初始化网络监听 根据不同版本做不同的处理
     */
    private void initMonitor() {
        ConnectivityManager connectivityManager = (ConnectivityManager) this.application
                .getSystemService(Context.CONNECTIVITY_SERVICE);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {//API 大于26时
            connectivityManager.registerDefaultNetworkCallback(networkCallback);
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {//API 大于21时
            NetworkRequest.Builder builder = new NetworkRequest.Builder();
            NetworkRequest request = builder.build();
            connectivityManager.registerNetworkCallback(request, networkCallback);
        } else {//低版本
            IntentFilter intentFilter = new IntentFilter();
            intentFilter.addAction(ANDROID_NET_CHANGE_ACTION);
            this.application.registerReceiver(receiver, intentFilter);
        }
    }

    /**
     * 反注册广播
     */
    private void destroy() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            this.application.unregisterReceiver(receiver);
        }
    }

    /**
     * 注入
     *
     * @param object
     */
    public void register(Object object) {
        if (object != null) {
            NetWorkStateReceiverMethod netWorkStateReceiverMethod = findMethod(object);
            if (netWorkStateReceiverMethod != null) {
                netWorkStateChangedMethodMap.put(object, netWorkStateReceiverMethod);
            }
        }
    }

    /**
     * 删除
     *
     * @param object
     */
    public void unregister(Object object) {
        if (object != null && netWorkStateChangedMethodMap != null) {
            netWorkStateChangedMethodMap.remove(object);
        }
    }

    /**
     * 网络状态发生变化，需要去通知更改
     *
     * @param netWorkState
     */
    private void postNetState(NetWorkState netWorkState) {
        Set<Object> set = netWorkStateChangedMethodMap.keySet();
        Iterator iterator = set.iterator();
        while (iterator.hasNext()) {
            Object object = iterator.next();
            NetWorkStateReceiverMethod netWorkStateReceiverMethod =
                    netWorkStateChangedMethodMap.get(object);
            invokeMethod(netWorkStateReceiverMethod, netWorkState);

        }
    }

    /**
     * 具体执行方法
     *
     * @param netWorkStateReceiverMethod
     * @param netWorkState
     */
    private void invokeMethod(NetWorkStateReceiverMethod netWorkStateReceiverMethod,
                              NetWorkState netWorkState) {
        if (netWorkStateReceiverMethod != null) {
            try {
                NetWorkState[] netWorkStates = netWorkStateReceiverMethod.getNetWorkState();
                for (NetWorkState myState : netWorkStates) {
                    if (myState == netWorkState) {
                        netWorkStateReceiverMethod.getMethod()
                                .invoke(netWorkStateReceiverMethod.getObject(), netWorkState);
                        return;
                    }
                }

            } catch (IllegalAccessException e) {
                e.printStackTrace();
            } catch (InvocationTargetException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * 找到对应的方法
     *
     * @param object
     * @return
     */
    private NetWorkStateReceiverMethod findMethod(Object object) {
        NetWorkStateReceiverMethod targetMethod = null;
        if (object != null) {
            Class myClass = object.getClass();
            //获取所有的方法
            Method[] methods = myClass.getDeclaredMethods();
            for (Method method : methods) {
                //如果参数个数不是1个 直接忽略
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    if (method.getParameterCount() != 1) {
                        continue;
                    }
                }
                //获取方法参数
                Class[] parameters = method.getParameterTypes();
                if (parameters == null || parameters.length != 1) {
                    continue;
                }
                //参数的类型需要时NetWorkState类型
                if (parameters[0].getName().equals(NetWorkState.class.getName())) {
                    //是NetWorkState类型的参数
                    NetWorkMonitor netWorkMonitor = method.getAnnotation(NetWorkMonitor.class);
                    targetMethod = new NetWorkStateReceiverMethod();
                    //如果没有添加注解，默认就是所有网络状态变化都通知
                    if (netWorkMonitor != null) {
                        NetWorkState[] netWorkStates = netWorkMonitor.monitorFilter();
                        targetMethod.setNetWorkState(netWorkStates);
                    }
                    targetMethod.setMethod(method);
                    targetMethod.setObject(object);
                    //只添加第一个符合的方法
                    return targetMethod;
                }
            }
        }
        return targetMethod;
    }

    private static final String ANDROID_NET_CHANGE_ACTION = "android.net.conn.CONNECTIVITY_CHANGE";
    BroadcastReceiver receiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equalsIgnoreCase(ANDROID_NET_CHANGE_ACTION)) {
                //网络发生变化 没有网络-0：WIFI网络1：4G网络-4：3G网络-3：2G网络-2
                int netType = getAPNType(context);
                NetWorkState netWorkState = NetWorkState.NONE;
                switch (netType) {
                    case 0://None
                        netWorkState = NetWorkState.NONE;
                        break;
                    case 1://Wifi
                        netWorkState = NetWorkState.WIFI;
                        break;
                    default://GPRS
                        netWorkState = NetWorkState.GPRS;
                        break;
                }
                state = netWorkState;
                postNetState(netWorkState);
            }
        }
    };

    ConnectivityManager.NetworkCallback networkCallback =
            new ConnectivityManager.NetworkCallback() {
                /**
                 * 网络可用的回调连接成功
                 */
                @Override
                public void onAvailable(Network network) {
                    super.onAvailable(network);
                    int netType = getAPNType(NetworkMgr.this.application);
                    NetWorkState netWorkState = NetWorkState.NONE;
                    switch (netType) {
                        case 0://None
                            netWorkState = NetWorkState.NONE;
                            break;
                        case 1://Wifi
                            netWorkState = NetWorkState.WIFI;
                            break;
                        default://GPRS
                            netWorkState = NetWorkState.GPRS;
                            break;
                    }
                    state = netWorkState;
                    postNetState(netWorkState);
                }

                /**
                 * 网络不可用时调用和onAvailable成对出现
                 */
                @Override
                public void onLost(Network network) {
                    super.onLost(network);
                    state = NetWorkState.NONE;
                    postNetState(NetWorkState.NONE);
                }

                /**
                 * 在网络连接正常的情况下，丢失数据会有回调 即将断开时
                 */
                @Override
                public void onLosing(Network network, int maxMsToLive) {
                    super.onLosing(network, maxMsToLive);
                }

                /**
                 * 网络功能更改 满足需求时调用
                 * @param network
                 * @param networkCapabilities
                 */
                @Override
                public void onCapabilitiesChanged(Network network,
                                                  NetworkCapabilities networkCapabilities) {
                    super.onCapabilitiesChanged(network, networkCapabilities);
                }

                /**
                 * 网络连接属性修改时调用
                 * @param network
                 * @param linkProperties
                 */
                @Override
                public void onLinkPropertiesChanged(Network network,
                                                    LinkProperties linkProperties) {
                    super.onLinkPropertiesChanged(network, linkProperties);
                }

                /**
                 * 网络缺失network时调用
                 */
                @Override
                public void onUnavailable() {
                    super.onUnavailable();
                }
            };

    public static boolean isNetworkConnected(Context context) {
        if (null == context) {
            return false;
        }
        ConnectivityManager conn =
                (ConnectivityManager) context.getSystemService(Activity.CONNECTIVITY_SERVICE);
        boolean wifi = conn.getNetworkInfo(ConnectivityManager.TYPE_WIFI).isConnectedOrConnecting();
        boolean internet =
                conn.getNetworkInfo(ConnectivityManager.TYPE_MOBILE).isConnectedOrConnecting();
        return wifi | internet;
    }

    public static NetWorkState getNetworkType(Context context) {
        if (null == context) {
            return NetWorkState.NONE;
        }
        ConnectivityManager conn =
                (ConnectivityManager) context.getSystemService(Activity.CONNECTIVITY_SERVICE);
        boolean wifi = conn.getNetworkInfo(ConnectivityManager.TYPE_WIFI).isConnectedOrConnecting();
        if (wifi) {
            return NetWorkState.WIFI;
        }
        boolean internet =
                conn.getNetworkInfo(ConnectivityManager.TYPE_MOBILE).isConnectedOrConnecting();
        if (internet) {
            return NetWorkState.GPRS;
        }
        return NetWorkState.NONE;
    }

    public boolean isNetworkConnected() {
        return state != NetWorkState.NONE;
    }

    /**
     * 获取当前的网络状态 ：没有网络-0：WIFI网络1：4G网络-4：3G网络-3：2G网络-2
     * 自定义
     *
     * @param context
     * @return
     */
    public static int getAPNType(Context context) {
        //结果返回值
        int netType = 0;
        //获取手机所有连接管理对象
        ConnectivityManager manager = (ConnectivityManager) context.getSystemService(Context
                .CONNECTIVITY_SERVICE);
        //获取NetworkInfo对象
        NetworkInfo networkInfo = manager.getActiveNetworkInfo();
        //NetworkInfo对象为空 则代表没有网络
        if (networkInfo == null) {
            return netType;
        }
        //否则 NetworkInfo对象不为空 则获取该networkInfo的类型
        int nType = networkInfo.getType();
        if (nType == ConnectivityManager.TYPE_WIFI) {
            //WIFI
            netType = 1;
        } else if (nType == ConnectivityManager.TYPE_MOBILE) {
            int nSubType = networkInfo.getSubtype();
            TelephonyManager telephonyManager = (TelephonyManager) context.getSystemService
                    (Context.TELEPHONY_SERVICE);
            //3G   联通的3G为UMTS或HSDPA 电信的3G为EVDO
            if (nSubType == TelephonyManager.NETWORK_TYPE_LTE
                    && !telephonyManager.isNetworkRoaming()) {
                netType = 4;
            } else if (nSubType == TelephonyManager.NETWORK_TYPE_UMTS
                    || nSubType == TelephonyManager.NETWORK_TYPE_HSDPA
                    || nSubType == TelephonyManager.NETWORK_TYPE_EVDO_0
                    && !telephonyManager.isNetworkRoaming()) {
                netType = 3;
                //2G 移动和联通的2G为GPRS或EGDE，电信的2G为CDMA
            } else if (nSubType == TelephonyManager.NETWORK_TYPE_GPRS
                    || nSubType == TelephonyManager.NETWORK_TYPE_EDGE
                    || nSubType == TelephonyManager.NETWORK_TYPE_CDMA
                    && !telephonyManager.isNetworkRoaming()) {
                netType = 2;
            } else {
                netType = 2;
            }
        }
        return netType;
    }
}
