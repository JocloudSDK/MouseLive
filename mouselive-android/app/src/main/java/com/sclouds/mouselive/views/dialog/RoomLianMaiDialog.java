package com.sclouds.mouselive.views.dialog;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.sclouds.datasource.bean.User;
import com.sclouds.mouselive.R;
import com.trello.rxlifecycle3.components.support.RxAppCompatDialogFragment;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;

/**
 * 房间用户申请连麦，申请PK，申请上麦
 *
 * @author chenhengfei@yy.com
 * @since 2020年2月20日
 */
public class RoomLianMaiDialog extends RxAppCompatDialogFragment implements View.OnClickListener {
    private static final String TAG = RoomLianMaiDialog.class.getSimpleName();

    private static final String TAG_USER = "user";
    private static final String TAG_TYPE = "type";

    private static final int TYPE_LIANMAI = 1;
    private static final int TYPE_PK = 2;
    private static final int TYPE_SHANGMAI = 3;

    private ImageView ivHead;
    private ImageView ivClose;
    private TextView tvName;
    private TextView tvMsg;

    private Button btAgree;
    private Button btRefuse;

    private IMenuCallback mCallback;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable
                                     Bundle savedInstanceState) {
        return inflater.inflate(R.layout.layout_room_user_lianmai, container);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        setCancelable(false);
        ivClose = view.findViewById(R.id.ivClose);
        ivHead = view.findViewById(R.id.ivHead);
        tvName = view.findViewById(R.id.tvName);
        tvMsg = view.findViewById(R.id.tvMsg);
        btAgree = view.findViewById(R.id.btAgree);
        btRefuse = view.findViewById(R.id.btRefuse);

        ivClose.setOnClickListener(this);
        btAgree.setOnClickListener(this);
        btRefuse.setOnClickListener(this);

        Bundle bundle = getArguments();
        assert bundle != null;
        User user = bundle.getParcelable(TAG_USER);
        assert user != null;
        int type = bundle.getInt(TAG_TYPE);

        if (type == TYPE_LIANMAI) {
            tvMsg.setText(R.string.request_lianmai);
        } else if (type == TYPE_PK) {
            tvMsg.setText(R.string.request_pk);
        } else if (type == TYPE_SHANGMAI) {
            tvMsg.setText(R.string.request_shangmai);
        }

        setView(user);
    }

    private void setView(@NonNull User user) {
        RequestOptions requestOptions = new RequestOptions()
                .circleCrop()
                .placeholder(R.mipmap.default_user_icon)
                .error(R.mipmap.default_user_icon);
        Glide.with(ivHead.getContext()).load(user.getCover()).apply(requestOptions).into(ivHead);

        tvName.setText(user.getNickName());
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.ivClose) {
            this.mCallback.onCancel();
            dismiss();
        } else if (id == R.id.btAgree) {
            this.mCallback.onAgree();
            dismiss();
        } else if (id == R.id.btRefuse) {
            this.mCallback.onRefuse();
            dismiss();
        }
    }

    public void showShangMai(User user, FragmentManager manager, IMenuCallback mCallback) {
        this.mCallback = mCallback;

        Bundle bundle = new Bundle();
        bundle.putParcelable(TAG_USER, user);
        bundle.putInt(TAG_TYPE, TYPE_SHANGMAI);
        setArguments(bundle);
        show(manager, TAG);
    }

    public void showLianMai(User user, FragmentManager manager, IMenuCallback mCallback) {
        this.mCallback = mCallback;

        Bundle bundle = new Bundle();
        bundle.putParcelable(TAG_USER, user);
        bundle.putInt(TAG_TYPE, TYPE_LIANMAI);
        setArguments(bundle);
        show(manager, TAG);
    }

    public void showPK(User user, FragmentManager manager, IMenuCallback mCallback) {
        this.mCallback = mCallback;

        Bundle bundle = new Bundle();
        bundle.putParcelable(TAG_USER, user);
        bundle.putInt(TAG_TYPE, TYPE_PK);
        setArguments(bundle);
        show(manager, TAG);
    }

    public interface IMenuCallback {
        void onCancel();

        void onAgree();

        void onRefuse();
    }
}
