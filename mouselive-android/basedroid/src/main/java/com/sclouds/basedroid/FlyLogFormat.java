package com.sclouds.basedroid;

import com.yy.spidercrab.model.Constants;
import com.yy.spidercrab.model.LogFormatter;
import com.yy.spidercrab.model.SCLogFlag;
import com.yy.spidercrab.model.SCLogMessage;

import java.text.SimpleDateFormat;
import java.util.Locale;

import androidx.annotation.NonNull;

/**
 * @author xipeitao
 * @description:
 * @date : 2020/4/29 3:24 PM
 */
public class FlyLogFormat implements LogFormatter {
    private static final ThreadLocal<SimpleDateFormat> DATE_FORMAT_THREAD_LOCAL =
            new ThreadLocal<SimpleDateFormat>() {
                @Override
                protected SimpleDateFormat initialValue() {
                    return new SimpleDateFormat(Constants.YYYY_MM_DD_HH_MM_SSS);
                }
            };

    @Override
    public String logMessage(@NonNull SCLogMessage logMessage) {
        String format = String.format(Locale.getDefault(), "#%d %s %s %s/%s %s",
                logMessage.getSeqId(),
                DATE_FORMAT_THREAD_LOCAL.get().format(logMessage.getDateTime()),
                logMessage.getProcessId() + logMessage.getThreadId() + ":" +
                        logMessage.getThreadName(),
                getFlag(logMessage.getFlag()),
                logMessage.getTag(),
                logMessage.getMessage());
        return format;
    }

    /**
     * log等级Int转换为String
     *
     * @param logFlag 等级
     * @return 等级 String型
     */
    private static String getFlag(SCLogFlag logFlag) {
        String flag;
        if (logFlag == SCLogFlag.INFO) {
            flag = "I";
        } else if (logFlag == SCLogFlag.DEBUG) {
            flag = "D";
        } else if (logFlag == SCLogFlag.WARN) {
            flag = "W";
        } else if (logFlag == SCLogFlag.ERROR) {
            flag = "E";
        } else if (logFlag == SCLogFlag.VERBOSE) {
            flag = "V";
        } else {
            flag = "U";
        }
        return flag;
    }
}
