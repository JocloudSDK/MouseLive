package com.sclouds.basedroid;

import android.content.Context;
import android.view.Gravity;
import android.widget.Toast;

/**
 * @author xipeitao
 * @description:
 * @date : 2020-01-18 11:28
 */
public class ToastUtil {
    private static Toast sToast;

    public static void showToast(Context context, String s,
                                 int gravity) {
        if (sToast != null) {
            sToast.cancel();
        }
        sToast = Toast.makeText(context, s, Toast.LENGTH_SHORT);
        sToast.setGravity(gravity, 0, 0);
        sToast.show();
    }

    public static void showToast(Context context, CharSequence s,
                                 int gravity) {
        if (sToast != null) {
            sToast.cancel();
        }
        sToast = Toast.makeText(context, s, Toast.LENGTH_SHORT);
        sToast.setGravity(gravity, 0, 0);
        sToast.show();
    }

    public static void showToast(Context context, CharSequence s) {
        if (sToast != null) {
            sToast.cancel();
        }
        sToast = Toast.makeText(context, s, Toast.LENGTH_SHORT);
        sToast.setGravity(Gravity.CENTER, 0, 0);
        sToast.show();
    }

    public static void showToast(Context context, String s) {
        if (sToast != null) {
            sToast.cancel();
        }
        sToast = Toast.makeText(context, s, Toast.LENGTH_SHORT);
        sToast.setGravity(Gravity.CENTER, 0, 0);
        sToast.show();
    }

    public static void showToast(Context context, int s,
                                 int gravity) {
        if (sToast != null) {
            sToast.cancel();
        }
        sToast = Toast.makeText(context, s, Toast.LENGTH_SHORT);
        sToast.setGravity(gravity, 0, 0);
        sToast.show();
    }

    public static void showToast(Context context, int s) {
        if (sToast != null) {
            sToast.cancel();
        }
        sToast = Toast.makeText(context, s, Toast.LENGTH_SHORT);
        sToast.setGravity(Gravity.CENTER, 0, 0);
        sToast.show();
    }
}
