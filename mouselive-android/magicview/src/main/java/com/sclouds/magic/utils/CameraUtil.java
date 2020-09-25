package com.sclouds.magic.utils;

import com.yy.mediaframework.CameraInterface;
import com.yy.mediaframework.CameraUtils;

public class CameraUtil {

    public static boolean isFrontCamera() {
        return CameraInterface.getInstance().getCameraFacing() == CameraUtils.CameraFacing.FacingFront;
    }

    public static int getCameraRotation() {
        return CameraInterface.getInstance().getCameraInfo().orientation;
    }
}
