package com.sclouds.mouselive.views;

import android.content.Context;
import android.content.DialogInterface;
import android.graphics.Color;
import android.os.Bundle;

import com.sclouds.datasource.TokenGetter;
import com.sclouds.mouselive.R;

import androidx.appcompat.app.AlertDialog;
import androidx.preference.CheckBoxPreference;
import androidx.preference.EditTextPreference;
import androidx.preference.Preference;
import androidx.preference.PreferenceFragmentCompat;
import androidx.preference.PreferenceManager;

/**
 * 设置界面
 *
 * @author chenhengfei@yy.com
 * @since 2020年1月17日
 */
public class SettingFragment extends PreferenceFragmentCompat {

    private static final String KEY_IS_CHINA = "area_is_china";
    private static final String KEY_TOKEN_TIMEOUT = "token_timeout";

    public static boolean isChina(Context context) {
        return PreferenceManager.getDefaultSharedPreferences(context)
                .getBoolean(KEY_IS_CHINA, true);
    }

    public static long getTokenTimeOut(Context context) {
        return PreferenceManager.getDefaultSharedPreferences(context)
                .getLong(KEY_TOKEN_TIMEOUT, TokenGetter.getExpiredTime());
    }

    @Override
    public void onCreatePreferences(Bundle savedInstanceState, String rootKey) {
        addPreferencesFromResource(R.xml.setting_preference);

        CheckBoxPreference area_is_china = findPreference(KEY_IS_CHINA);
        assert area_is_china != null;
        area_is_china.setOnPreferenceChangeListener(new Preference.OnPreferenceChangeListener() {
            @Override
            public boolean onPreferenceChange(Preference preference, Object newValue) {
                showOnAreChangedDialog();
                return true;
            }
        });

        EditTextPreference token_timeot = findPreference(KEY_TOKEN_TIMEOUT);
        assert token_timeot != null;
        token_timeot.setTitle(getContext().getString(R.string.setting_token_content) + "      " +
                String.valueOf(TokenGetter.getExpiredTime()));
        token_timeot.setText(String.valueOf(TokenGetter.getExpiredTime()));
        token_timeot.setOnPreferenceChangeListener(new Preference.OnPreferenceChangeListener() {
            @Override
            public boolean onPreferenceChange(Preference preference, Object newValue) {
                TokenGetter.setExpiredTime(Long.parseLong(String.valueOf(newValue)));
                token_timeot.setTitle(
                        getContext().getString(R.string.setting_token_content) + "      " +
                                String.valueOf(TokenGetter.getExpiredTime()));
                return true;
            }
        });
    }

    private void showOnAreChangedDialog() {
        new AlertDialog.Builder(getContext())
                .setMessage(R.string.change_are)
                .setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        getActivity().finish();
                    }
                })
                .show()
                .getButton(AlertDialog.BUTTON_POSITIVE).setTextColor(Color.BLUE);;
    }
}
