package com.sclouds.mouselive.utils;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Environment;
import android.text.TextUtils;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;

import androidx.annotation.RawRes;
import androidx.core.content.ContextCompat;

/**
 * 文件类
 *
 * @author Aslan chenhengfei@yy.com
 * @date 2020/1/3
 */
public class FileUtil {
    private static final String LOG = "log";
    private static final String MUSIC = "music";
    private static final String EFFECTS = "effects";
    private static final String RECORD = "record";

    private static String log;
    private static String music;
    private static String record;

    public static String getRecord(Context context) {
        if (!TextUtils.isEmpty(record)) {
            return record;
        }
        record = getFilesDir(context, RECORD).getAbsolutePath();
        return record;
    }

    public static String getMusic(Context context) {
        if (!TextUtils.isEmpty(music)) {
            return music;
        }

        music = getFilesDir(context, MUSIC).getAbsolutePath();
        return music;
    }

    public static String getLog(Context context) {
        if (!TextUtils.isEmpty(log)) {
            return log;
        }

        log = getFilesDir(context, LOG).getAbsolutePath();
        return log;
    }

    /**
     * 判断sd卡是否存在
     *
     * @return 如果存在就返回true，反之不存在
     */
    public static boolean isSdCardExist() {
        return Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED);
    }

    /**
     * 是否缺少权限
     *
     * @return true缺少权限，反之不缺少
     */
    public static Boolean isLackPermission(Context context) {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.M
                && (ContextCompat
                .checkSelfPermission(context, Manifest.permission.WRITE_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED
                || ContextCompat
                .checkSelfPermission(context, Manifest.permission.READ_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED);
    }

    /**
     * 获取本地文件路径,优先采用SD卡
     */
    private static File getFilesDir(Context context, String tag) {
        // if (isLackPermission(context) || !isSdCardExist()) {
        //     return context.getFilesDir();
        // } else {
        //     File file = context.getExternalFilesDir(tag);
        //     if (file == null) {
        //         return context.getFilesDir();
        //     } else {
        //         return file;
        //     }
        // }
        return context.getExternalFilesDir(tag);
    }

    /**
     * 批量删除文件
     *
     * @param file           文件夹
     * @param isDeleteDirect 是否需要删除文件夹
     */
    public static void deleteFile(File file, boolean isDeleteDirect) {
        if (file == null) {
            return;
        }

        if (file.isDirectory()) {
            File[] files = file.listFiles();
            for (File f : files) {
                deleteFile(f, isDeleteDirect);
            }

            if (isDeleteDirect) {
                file.delete();
            }
        } else if (file.exists()) {
            file.delete();
        }
    }

    /**
     * Raw文件拷贝
     *
     * @param context
     * @param resId
     */
    public static void copyRawFile(Context context, String desPath, String desName,
                                   @RawRes int resId) {
        String filePath = desPath + "/" + desName;
        try {
            File dir = new File(desPath);
            if (!dir.exists()) {
                dir.mkdirs();
            }

            File file = new File(filePath);
            if (file.exists()) {
                return;
            }

            InputStream is = context.getResources().openRawResource(resId);
            FileOutputStream fs = new FileOutputStream(file);
            byte[] buffer = new byte[1024];
            int count;
            while ((count = is.read(buffer)) > 0) {
                fs.write(buffer, 0, count);
            }
            fs.close();
            is.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
