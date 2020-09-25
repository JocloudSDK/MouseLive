package com.sclouds.mouselive.views;

import android.app.Activity;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.view.View;

import com.sclouds.basedroid.BaseFragment;
import com.sclouds.basedroid.ToastUtil;
import com.sclouds.basedroid.Tools;
import com.sclouds.datasource.Constants;
import com.sclouds.datasource.bean.User;
import com.sclouds.datasource.database.DatabaseSvc;
import com.sclouds.mouselive.BuildConfig;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.adapters.FeedbackPhotoAdapter;
import com.sclouds.mouselive.databinding.FragmentFeedbackBinding;
import com.sclouds.mouselive.utils.DoubleUtils;
import com.sclouds.mouselive.utils.FileUtil;

import org.jetbrains.annotations.NotNull;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;
import androidx.lifecycle.Observer;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import tv.athena.core.axis.Axis;
import tv.athena.feedback.api.FeedbackData;
import tv.athena.feedback.api.IFeedbackService;

/**
 * 意见反馈，主要实现把日志上传给后台。
 *
 * @author chenhengfei@yy.com
 * @since 2020/03/01
 */
public class FeedbackFragment extends BaseFragment<FragmentFeedbackBinding> {

    private static final int REQUESTCODE = 100;

    /**
     * 默认反馈只会上传主目录下的日志，不能上传文件夹下面日志，所以需要我们手动添加。
     */
    private void addFiles(@NonNull List<File> files, @NonNull File fileDirectory) {
        if (fileDirectory.exists()) {
            if (fileDirectory.isDirectory()) {
                File[] listFiles = fileDirectory.listFiles();
                if (listFiles == null) {
                    return;
                }

                for (File file : listFiles) {
                    if (file.exists()) {
                        if (file.isDirectory()) {
                            addFiles(files, file);
                        } else {
                            files.add(file);
                        }
                    }
                }
            } else {
                files.add(fileDirectory);
            }
        }
    }

    private void feedback() {
        User user = DatabaseSvc.getIntance().getUser();
        if (user == null) {
            ToastUtil.showToast(getContext(), R.string.login_fail);
            return;
        }

        String feedbackContent = mBinding.etFeedbackContent.getText().toString().trim();
        String contact = mBinding.etContacts.getText().toString().trim();
        if (TextUtils.isEmpty(feedbackContent)) {
            ToastUtil.showToast(getContext(), R.string.input_content_tip1);
            return;
        }

        showLoading();

        new Thread(new Runnable() {
            @Override
            public void run() {
                doFeedback(user, feedbackContent, contact);
            }
        }).start();
    }

    private void doFeedback(User user, String feedbackContent, String contact) {
        File fileLogs = new File(FileUtil.getLog(getContext()));
        List<File> files = new ArrayList<>();
        addFiles(files, fileLogs);

        FeedbackData.Builder builder = new FeedbackData.Builder(Constants.FEEDBACK_CRASHLOGID,
                user.getUid(), feedbackContent)
                .setContactInfo(contact)
                .setExternPathlist(files)
                .setFeedbackStatusListener(new FeedbackData.FeedbackStatusListener() {
                    @Override
                    public void onFailure(@NotNull FailReason failReason) {
                        mBinding.etFeedbackContent.post(() -> {
                            ToastUtil.showToast(getContext(), R.string.feedback_fail);
                            hideLoading();
                        });
                    }

                    @Override
                    public void onComplete() {
                        long cur = System.currentTimeMillis();
                        for (File file : files) {
                            deleteFile(file, cur);
                        }

                        mBinding.etFeedbackContent.post(() -> {
                            mBinding.etFeedbackContent.setText("");
                            mBinding.etContacts.setText("");
                            ToastUtil.showToast(getContext(), R.string.feedback_success);
                            hideLoading();

                            Activity activity = getActivity();
                            if (activity instanceof MainActivity) {

                            } else if (activity instanceof FragmentActivity) {
                                activity.finish();
                            }
                        });
                    }

                    @Override
                    public void onProgressChange(int i) {

                    }
                });

        if (adapter.getItemCount() > 1) {
            ArrayList<String> arrayList = new ArrayList<>();
            for (int i = 0; i < adapter.getItemCount() - 1; i++) {
                arrayList.add(adapter.getDataAtPosition(i));
            }
            builder.setImagePathlist(arrayList);
        }

        FeedbackData feedbackData = builder.create();
        Axis.Companion.getService(IFeedbackService.class).sendNewLogUploadFeedback(feedbackData);
    }

    private static final long OVER_TIME = 12 * 60 * 60 * 1000L;

    /**
     * 批量删除文件
     *
     * @param file 文件夹
     */
    private void deleteFile(File file, long nowTime) {
        if (file == null) {
            return;
        }

        if (file.isDirectory()) {
            File[] files = file.listFiles();
            if (files != null) {
                for (File f : files) {
                    deleteFile(f, nowTime);
                }
            }
        } else if (file.exists()) {
            if (nowTime - file.lastModified() >= OVER_TIME) {
                //只删除大于12小时的文件
                file.delete();
            }
        }
    }

    private FeedbackPhotoAdapter adapter;

    @Override
    public void initView(View view) {
        String version = this.getString(R.string.app_version, BuildConfig.VERSION_NAME,
                BuildConfig.VERSION_CODE);
        mBinding.tvAppVersion.setText(version);

        mBinding.btnFeedback.setOnClickListener(v -> {
            if (!Tools.networkConnected()) {
                ToastUtil.showToast(getContext(), R.string.network_error);
                return;
            }

            if (DoubleUtils.isFastClick()) {
                feedback();
            }
        });

        adapter = new FeedbackPhotoAdapter(getContext(),
                new FeedbackPhotoAdapter.ISubViewClick() {
                    @Override
                    public void onSubViewClick(@NonNull View view, int position) {
                        Intent intent = new Intent(Intent.ACTION_PICK);
                        intent.setData(
                                android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
                        startActivityForResult(intent, REQUESTCODE);
                    }
                });
        adapter.addItem("");
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(getContext(),
                RecyclerView.HORIZONTAL, false);
        linearLayoutManager.setStackFromEnd(true);
        mBinding.rvPhotos.setLayoutManager(linearLayoutManager);
        mBinding.rvPhotos.setAdapter(adapter);

        Toolbar toolbar = view.findViewById(R.id.toolbar);
        Activity activity = getActivity();
        if (activity instanceof MainActivity) {
            toolbar.setVisibility(View.GONE);
        } else {
            toolbar.setVisibility(View.VISIBLE);
        }
    }

    @Override
    public void initData() {
        setUID();
    }

    private void setUID() {
        DatabaseSvc.getIntance().mLiveData.observe(this, new Observer<User>() {
            @Override
            public void onChanged(User user) {
                if (user != null) {
                    mBinding.tvUID.setText(
                            getString(R.string.fadeback_uid, String.valueOf(user.getUid())));
                }
            }
        });

        User user = DatabaseSvc.getIntance().getUser();
        if (user != null) {
            mBinding.tvUID.setText(getString(R.string.fadeback_uid, String.valueOf(user.getUid())));
        }
    }

    @Override
    public int getLayoutResId() {
        return R.layout.fragment_feedback;
    }

    private String getRealPathFromURI(Uri contentURI) {
        String result;
        Cursor cursor = getContext().getContentResolver().query(contentURI, null, null, null, null);
        if (cursor == null) {
            result = contentURI.getPath();
        } else {
            cursor.moveToFirst();
            int idx = cursor.getColumnIndex(MediaStore.Images.ImageColumns.DATA);
            result = cursor.getString(idx);
            cursor.close();
        }
        return result;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUESTCODE && resultCode == Activity.RESULT_OK && data != null) {
            Uri selectedImage = data.getData();
            if (selectedImage != null) {
                File imageFile = new File(getRealPathFromURI(selectedImage));
                if (imageFile.exists()) {
                    adapter.addItem(adapter.getItemCount() - 1, imageFile.getAbsolutePath());
                } else {
                    ToastUtil.showToast(getContext(), R.string.error_picture);
                }
            }
        }
    }

    public static FeedbackFragment newInstance() {
        FeedbackFragment fragment = new FeedbackFragment();
        return fragment;
    }
}
