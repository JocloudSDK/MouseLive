package com.sclouds.mouselive;

/**
 * @author xipeitao
 * @description: 配置参数
 * @date : 2020-03-18 14:12
 */
public class Consts {

    /**
     * 聚联云官网申请的AppId，请关注https://www.jocloud.com
     */
    public static long APPID = 请填写appid;

    /**
     * 聚联云官网申请的AppId所对应的AppSecret
     * <p>
     * 2种模式：
     * App ID模式：hummer和thunder会跳过token验证
     * Token验证模式：适用于安全性要求较高的场景，hummer和thunder会验证token，验证过期或者不通过则无法使用服务
     * <p>
     * 模式需要先在后台配置（https://www.jocloud.com）。如果是Token模式，一定要填写此值。如果是App ID模式，可以不填写，留空即可。
     */
    public static String APP_SECRET = "";

    /**
     * orangeFilter sdk sn: 鉴权串。请联系技术支持相关的同学。
     * 如果不需要加载美颜模块，请直接注销app模块下的effectAdapter模块即可
     */
    public static String OF_SERIAL_NAMBER = 请填写鉴权串;
}
