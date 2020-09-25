package com.sclouds.basedroid;

import android.util.Log;

import com.yy.spidercrab.SCLog;
import com.yy.spidercrab.SCLogger;
import com.yy.spidercrab.manager.SCLogFileConfig;
import com.yy.spidercrab.model.SCLogLevel;
import com.yy.spidercrab.model.SCLogModule;

public final class LogUtils {
    private static final String MODULE_NAME = "MouseLive_android";
    private static final boolean DEBUG = BuildConfig.DEBUG;

    static {
        SCLog.addLogger(new SCLogger(new SCLogModule(MODULE_NAME), new FlyLogFormat(),
                new SCLogFileConfig()));
        SCLog.changeLogLevel(MODULE_NAME, SCLogLevel.VERBOSE);
    }

    public static void i(String tag, String log) {
        if (DEBUG) {
            Log.i(tag, log);
            return;
        }
        SCLog.i(MODULE_NAME, tag, null, null, 0, getDebugLog(tag, log));
    }

    public static void w(String tag, String log) {
        if (DEBUG) {
            Log.w(tag, log);
            return;
        }
        SCLog.w(MODULE_NAME, tag, null, null, 0, getDebugLog(tag, log));
    }

    public static void e(String tag, String log) {
        if (DEBUG) {
            Log.e(tag, log);
            return;
        }
        SCLog.e(MODULE_NAME, tag, null, null, 0, getDebugLog(tag, log));
    }

    public static void d(String tag, String log) {
        if (DEBUG) {
            Log.d(tag, log);
            return;
        }
        SCLog.d(MODULE_NAME, tag, null, null, 0, getDebugLog(tag, log));
    }

    public static void v(String tag, String log) {
        if (DEBUG) {
            Log.v(tag, log);
            return;
        }
        SCLog.i(MODULE_NAME, tag, null, null, 0, getDebugLog(tag, log));
    }

    public static void e(String tag, String log, Throwable error) {
        if (DEBUG) {
            Log.e(tag, log, error);
            return;
        }
        SCLog.e(MODULE_NAME, tag, null, null, 0,
                getDebugLog(tag, log) + "\n Error: " + getThrowableLog(error));
    }

    private static String getDebugLog(String tag, String log) {
        return log;
    }

    private static final String SUPPRESSED_CAPTION = "Suppressed: ";
    private static final String CAUSE_CAPTION = "Caused by: ";

    private static String getThrowableLog(Throwable throwable) {
        StackTraceElement[] trace = throwable.getStackTrace();
        StringBuffer sb = new StringBuffer(throwable.toString());
        for (StackTraceElement traceElement : trace) {
            sb.append("\n\tat " + traceElement);
        }

        // Print suppressed exceptions, if any
        for (Throwable se : throwable.getSuppressed()) {
            sb.append("\n\t  " + SUPPRESSED_CAPTION + getThrowableLog(se));
        }

        // Print cause, if any
        Throwable ourCause = throwable.getCause();
        if (ourCause != null) {
            sb.append("\n\t " + CAUSE_CAPTION + getThrowableLog(ourCause));
        }
        return sb.toString();
    }
}
