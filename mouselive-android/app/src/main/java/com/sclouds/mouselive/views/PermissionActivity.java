package com.sclouds.mouselive.views;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import com.sclouds.datasource.bean.Room;
import com.sclouds.mouselive.R;

import java.util.List;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentActivity;
import pub.devrel.easypermissions.AfterPermissionGranted;
import pub.devrel.easypermissions.AppSettingsDialog;
import pub.devrel.easypermissions.EasyPermissions;
import pub.devrel.easypermissions.EasyPermissions.PermissionCallbacks;
import pub.devrel.easypermissions.PermissionRequest;

/**
 * 权限检查申请界面，在进入房间之前做检查，并且进行申请，以及错误提示。
 *
 * @author Aslan chenhengfei@yy.com
 * @since 2020/03/01
 */
public class PermissionActivity extends FragmentActivity implements PermissionCallbacks {
    private static final int PERMISSION_REQUEST_CODE = 100;
    private static final String[] REQUEST_PERMISSIONS = new String[]{
            Manifest.permission.CAMERA,
            Manifest.permission.WRITE_EXTERNAL_STORAGE,
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.INTERNET,
            Manifest.permission.ACCESS_NETWORK_STATE,
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.MODIFY_AUDIO_SETTINGS,
            Manifest.permission.BLUETOOTH,
            Manifest.permission.BLUETOOTH_ADMIN
    };

    public static void startPermissionActivity(Context context, Room room) {
        Intent intent = new Intent(context, PermissionActivity.class);
        intent.putExtra(LivingRoomActivity.EXTRA_ROOM, room);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestPermission();
    }

    private Room getIntentParams() {
        return this.getIntent().getParcelableExtra(LivingRoomActivity.EXTRA_ROOM);
    }

    @AfterPermissionGranted(PERMISSION_REQUEST_CODE)
    private void requestPermission() {
        if (!EasyPermissions.hasPermissions(this, REQUEST_PERMISSIONS)) {
            EasyPermissions.requestPermissions(
                    new PermissionRequest.Builder(this, PERMISSION_REQUEST_CODE,
                            REQUEST_PERMISSIONS)
                            .setRationale(R.string.request_live)
                            .setPositiveButtonText(R.string.ok)
                            .setNegativeButtonText(R.string.cancel)
                            .build());
            return;
        }
        startRoomActivity();
        this.finish();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        EasyPermissions.onRequestPermissionsResult(requestCode, permissions, grantResults, this);
    }

    private void startRoomActivity() {
        Room room = getIntentParams();
        if (Room.ROOM_TYPE_CHAT == room.getRType()) {
            VoiceRoomActivity.startActivity(this, room);
        } else if (Room.ROOM_TYPE_LIVE == room.getRType()) {
            LivingRoomActivity.startActivity(this, room);
        } else if (Room.ROOM_TYPE_KTV == room.getRType()) {
            KTVRoomActivity.startActivity(this, room);
        }
    }

    @Override
    public void onPermissionsGranted(int requestCode, @NonNull List<String> perms) {

    }

    @Override
    public void onPermissionsDenied(int requestCode, @NonNull List<String> perms) {
        // 用户手动点击取消授权后需去设置授权
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (EasyPermissions.somePermissionPermanentlyDenied(this, perms)) {
                new AppSettingsDialog.Builder(this).setTitle(R.string.request_error_title)
                        .setRationale(R.string.request_live).build().show();
            }
        }
        this.finish();
    }
}
