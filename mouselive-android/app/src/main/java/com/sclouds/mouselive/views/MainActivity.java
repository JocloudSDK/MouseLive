package com.sclouds.mouselive.views;

import android.Manifest;
import android.content.DialogInterface;
import android.graphics.Color;
import android.os.Bundle;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.sclouds.basedroid.BaseMVVMActivity;
import com.sclouds.datasource.bean.Room;
import com.sclouds.mouselive.BuildConfig;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.databinding.ActivityMainBinding;
import com.sclouds.mouselive.viewmodel.MainViewModel;
import com.sclouds.mouselive.views.dialog.CreatRoomDialog;

import java.text.SimpleDateFormat;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.fragment.app.FragmentTransaction;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModel;
import androidx.lifecycle.ViewModelProvider;
import pub.devrel.easypermissions.AfterPermissionGranted;
import pub.devrel.easypermissions.AppSettingsDialog;
import pub.devrel.easypermissions.EasyPermissions;
import pub.devrel.easypermissions.EasyPermissions.PermissionCallbacks;
import pub.devrel.easypermissions.PermissionRequest;

/**
 * 首页
 *
 * @author chenhengfei@yy.com
 * @since 2020年1月17日
 */
public class MainActivity extends BaseMVVMActivity<ActivityMainBinding, MainViewModel>
        implements BottomNavigationView.OnNavigationItemSelectedListener,
        View.OnClickListener, PermissionCallbacks {

    private static final int REQUEST_CODE = 1000;

    private MainRoomsFatherFragment fragmentMain = MainRoomsFatherFragment.newInstance();
    private MainMineFragment fragmentMine = MainMineFragment.newInstance();
    private FeedbackFragment fragmentFeedback = FeedbackFragment.newInstance();

    private SimpleDateFormat mSimpleDateFormat = new SimpleDateFormat("MM/dd/yyyy");

    @Override
    protected void initView() {
        TextView tvVersion = findViewById(R.id.tvVersion);
        tvVersion.setText(getString(R.string.main_version, BuildConfig.VERSION_NAME));
        TextView tvVersion2 = findViewById(R.id.tvVersion2);
        tvVersion2
                .setText(getString(R.string.main_version2, String.valueOf(BuildConfig.VERSION_CODE),
                        mSimpleDateFormat.format(BuildConfig.buildTime),
                        com.sclouds.datasource.BuildConfig.TB_VERSION,
                        com.sclouds.datasource.BuildConfig.HRM_VERSION));
        ImageView ivAdd = findViewById(R.id.ivAdd);
        ivAdd.setOnClickListener(this);

        mBinding.llBottom.setOnNavigationItemSelectedListener(this);

        getSupportFragmentManager()
                .beginTransaction()
                .replace(R.id.flMainRoomFather, fragmentMain)
                .show(fragmentMain)
                .commitAllowingStateLoss();
    }

    @Override
    protected void initData() {
        super.initData();
        observeError();

        requestSDPermission();
    }

    /**
     * 处理错误信息
     */
    private void observeError() {
        mViewModel.mLiveDataError.observe(this, new Observer<Integer>() {
            @Override
            public void onChanged(@Nullable Integer integer) {
                if (integer == null) {
                    return;
                }

                if (integer == MainViewModel.ERROR_NET) {
                    showNetworkDialog();
                } else if (integer == MainViewModel.ERROR_LOGIN_USER) {
                    showLoginError(getString(R.string.login_fail));
                } else if (integer == MainViewModel.ERROR_LOGIN_HUMMER) {
                    showLoginError(getString(R.string.sdk_login_fail));
                }
            }
        });
    }

    @AfterPermissionGranted(REQUEST_CODE)
    private void requestSDPermission() {
        String[] perms = {Manifest.permission.WRITE_EXTERNAL_STORAGE,
                Manifest.permission.READ_EXTERNAL_STORAGE};
        if (!EasyPermissions.hasPermissions(this, perms)) {
            EasyPermissions.requestPermissions(
                    new PermissionRequest.Builder(this, REQUEST_CODE, perms)
                            .setRationale(R.string.request_external_storage)
                            .setPositiveButtonText(R.string.ok)
                            .setNegativeButtonText(R.string.cancel)
                            .build());
        }
    }

    private void showLoginError(String msg) {
        new AlertDialog.Builder(this)
                .setCancelable(false)
                .setMessage(msg)
                .setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        mViewModel.login();
                    }
                })
                .show()
                .getButton(AlertDialog.BUTTON_POSITIVE).setTextColor(Color.BLUE);;
    }

    private void showNetworkDialog() {
        new AlertDialog.Builder(this)
                .setMessage(R.string.network_fail)
                .setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        mViewModel.checkNetwork();
                    }
                })
                .show()
                .getButton(AlertDialog.BUTTON_POSITIVE).setTextColor(Color.BLUE);;
    }

    @Override
    protected int getLayoutResId() {
        return R.layout.activity_main;
    }

    @Override
    public boolean onNavigationItemSelected(@NonNull MenuItem item) {
        int id = item.getItemId();
        if (id == R.id.menuMain) {
            showMainFragment();
        } else if (id == R.id.empty) {
            return false;
        } else if (id == R.id.menuFadeback) {
            showFeedback();
        }
        return true;
    }

    private void showMainFragment() {
        FragmentTransaction ft = getSupportFragmentManager()
                .beginTransaction()
                .hide(fragmentFeedback)
                .hide(fragmentMine);
        if (!fragmentMain.isAdded()) {
            ft.add(R.id.flMainRoomFather, fragmentMain);
        }
        ft.show(fragmentMain).commitAllowingStateLoss();
    }

    private void showFeedback() {
        FragmentTransaction ft = getSupportFragmentManager()
                .beginTransaction()
                .hide(fragmentMain)
                .hide(fragmentMine);
        if (!fragmentFeedback.isAdded()) {
            ft.add(R.id.flMainRoomFather, fragmentFeedback);
        }
        ft.show(fragmentFeedback).commitAllowingStateLoss();
    }

    private void showMineFragment() {
        FragmentTransaction ft = getSupportFragmentManager()
                .beginTransaction()
                .hide(fragmentMain)
                .hide(fragmentFeedback);
        if (!fragmentMine.isAdded()) {
            ft.add(R.id.flMainRoomFather, fragmentMine);
        }
        ft.show(fragmentMine).commitAllowingStateLoss();
    }

    @Override
    public void onClick(View v) {
        CreatRoomDialog dialog = new CreatRoomDialog();
        dialog.show(getSupportFragmentManager(), new CreatRoomDialog.ICreateRoomCallback() {
            @Override
            public void onCreateRoom(Room room) {
                PermissionActivity.startPermissionActivity(MainActivity.this, room);
            }
        });
    }

    @Override
    protected MainViewModel iniViewModel() {
        return new ViewModelProvider(this, new ViewModelProvider.Factory() {
            @NonNull
            @Override
            public <T extends ViewModel> T create(@NonNull Class<T> modelClass) {
                //noinspection unchecked
                return (T) new MainViewModel(getApplication(), MainActivity.this);
            }
        }).get(MainViewModel.class);
    }

    @Override
    protected void onRestoreInstanceState(@NonNull Bundle savedInstanceState) {
        super.onRestoreInstanceState(savedInstanceState);
        int id = mBinding.llBottom.getSelectedItemId();
        mBinding.llBottom.setSelectedItemId(id);
    }

    @Override
    public void onPermissionsGranted(int requestCode, @NonNull List<String> perms) {

    }

    @Override
    public void onPermissionsDenied(int requestCode, @NonNull List<String> perms) {
        // 用户手动点击取消授权后需去设置授权
        if (requestCode == REQUEST_CODE) {
            if (EasyPermissions.somePermissionPermanentlyDenied(this, perms)) {
                new AppSettingsDialog.Builder(this).setTitle(R.string.request_error_title)
                        .setRationale(R.string.request_external_storage).build().show();
            }
        }
    }

    @Override
    public void onBackPressed() {
        moveTaskToBack(false);
    }

}
