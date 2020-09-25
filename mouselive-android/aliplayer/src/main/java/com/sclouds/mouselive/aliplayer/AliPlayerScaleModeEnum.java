package com.sclouds.mouselive.aliplayer;

/**
 * 播放画面填充模式枚举类
 *
 * @author zhoupingyu@yy.com
 * @since  2020/4/16
 */
public enum AliPlayerScaleModeEnum {
    /**
     * 宽高比适应（将按照视频宽高比等比缩小到view内部，不会有画面变形）
     */
    SCALE_ASPECT_FIT,
    /**
     * 宽高比填充（将按照视频宽高比等比放大，充满view，不会有画面变形）
     */
    SCALE_ASPECT_FILL,
    /**
     * 拉伸填充（如果视频宽高比例与view比例不一致，会导致画面变形）
     */
    SCALE_TO_FILL
}
