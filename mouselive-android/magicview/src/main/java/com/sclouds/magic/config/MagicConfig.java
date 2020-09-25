package com.sclouds.magic.config;

public class MagicConfig {

    // 配置美颜界面分页总数
    public static final int MAGIC_TYPE_NUMBER = 5;

    // 配置手势和贴图页面每行显示个数
    public static final int MAGIC_GRID_LAYOUT_SPAN_COUNT = 5;

    // 配置美颜下载失败最大重试次数
    public static final int MAGIC_MAX_HTTP_RETRY_COUNT = 3;

    // 配置美颜版本号
    public static final String MAGIC_VERSION_TAG = "1.4.2";

    // 配置美颜特效包存储路径文件夹名称
    public static final String MAGIC_EFFECT_STORAGE_FILE_DIR = "/orangefilter/effects/";

    // 美白默认值为 70
    public static final int DEFAULT_WHITEN_VALUE = 70;

    // 磨皮默认值为 70
    public static final int DEFAULT_SMOOTHEN_VALUE = 70;

    // 基础整形默认值为 40
    public static final int DEFAULT_BASIC_FACE_VALUE = 40;

    // 小脸默认值为 40
    public static final int DEFAULT_SMALL_FACE_VALUE = 40;

    // 大眼默认值为 20
    public static final int DEFAULT_BIG_EYE_VALUE = 20;

    // 瘦鼻默认值为 -3
    public static final int DEFAULT_THIN_NOSE_VALUE = -3;

    /**
     * 配置美颜界面分页类型枚举类
     */
    public enum MagicTypeEnum {
        MAGIC_TYPE_SKIN(0, "Skin"),       // 美肤
        MAGIC_TYPE_FILTER(1, "Filter"),   // 滤镜
        MAGIC_TYPE_FACE(2, "Face"),       // 整形
        MAGIC_TYPE_STICKER(3, "Sticker"), // 贴纸
        MAGIC_TYPE_GESTURE(4, "Gesture"); // 手势

        private int mValue;
        private String mType;

        MagicTypeEnum(int value, String type) {
            this.mValue = value;
            this.mType = type;
        }

        public int getValue() {
            return mValue;
        }

        public String getType() {
            return mType;
        }
    }
}
