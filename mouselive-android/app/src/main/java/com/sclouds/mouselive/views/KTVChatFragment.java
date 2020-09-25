package com.sclouds.mouselive.views;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;

import com.google.gson.Gson;
import com.sclouds.basedroid.BaseFragment;
import com.sclouds.datasource.bean.Room;
import com.sclouds.datasource.bean.RoomUser;
import com.sclouds.datasource.database.DatabaseSvc;
import com.sclouds.datasource.hummer.HummerSvc;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.adapters.FakeMsgAdapter;
import com.sclouds.mouselive.bean.FakeMessage;
import com.sclouds.mouselive.bean.PublicMessage;
import com.sclouds.mouselive.databinding.FragmentKtvChatBinding;
import com.sclouds.mouselive.utils.SimpleSingleObserver;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;

/**
 * KTV-聊天
 *
 * @author chenhengfei@yy.com
 * @since 2020/07/07
 */
public class KTVChatFragment extends BaseFragment<FragmentKtvChatBinding> implements
        View.OnClickListener {

    private Room mRoom;
    private FakeMsgAdapter mMsgAdapter;

    public KTVChatFragment() {
    }

    @Override
    public void initBundle(@Nullable Bundle bundle) {
        super.initBundle(bundle);
        assert bundle != null;
        mRoom = bundle.getParcelable(LivingRoomActivity.EXTRA_ROOM);
    }

    @Override
    public void initView(View view) {
        mBinding.tvInput.setOnClickListener(this);
        mBinding.btSend.setOnClickListener(this);
    }

    @Override
    public void initData() {
        LinearLayoutManager msgLLayoutManager = new LinearLayoutManager(
                getContext(), LinearLayoutManager.VERTICAL, false);
        msgLLayoutManager.setStackFromEnd(true);
        mBinding.rvMsg.setLayoutManager(msgLLayoutManager);
        mMsgAdapter = new FakeMsgAdapter(getContext(), DatabaseSvc.getIntance().getUser(),
                mRoom.getROwner());
        mBinding.rvMsg.setAdapter(mMsgAdapter);
        mMsgAdapter.addItem(new FakeMessage(getString(R.string.office_notie),
                FakeMessage.MessageType.Top));
    }

    public void addChatMessage(FakeMessage message) {
        mMsgAdapter.addItem(message);
        mBinding.rvMsg.smoothScrollToPosition(mMsgAdapter.getItemCount() - 1);
    }

    @Override
    public int getLayoutResId() {
        return R.layout.fragment_ktv_chat;
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.tvInput:
                doInput();
                break;
            case R.id.btSend:
                doSend();
                break;
            default:
                break;
        }
    }

    private void doInput() {
        mBinding.tvInput.setVisibility(View.GONE);
        mBinding.rlInput.setVisibility(View.VISIBLE);
    }

    private Gson mGson = new Gson();

    private void doSend() {
        String msg = mBinding.etInput.getText().toString().trim();
        if (TextUtils.isEmpty(msg)) {
            return;
        }

        RoomUser mine = getMine();
        if (mine == null) {
            return;
        }

        addChatMessage(new FakeMessage(mine, msg, FakeMessage.MessageType.Msg));
        PublicMessage message =
                new PublicMessage(mine.getNickName(), String.valueOf(mine.getUid()),
                        msg, FakeMessage.MessageType.Msg);
        HummerSvc.getInstance().sendChatRoomMessage(mGson.toJson(message)).subscribe(
                new SimpleSingleObserver<Boolean>() {
                    @Override
                    public void onSuccess(Boolean aBoolean) {

                    }
                });

        mBinding.etInput.setText("");
        mBinding.tvInput.setVisibility(View.VISIBLE);
        mBinding.rlInput.setVisibility(View.GONE);
    }

    @Nullable
    private RoomUser getMine() {
        if (getActivity() == null) {
            return null;
        }
        return ((KTVRoomActivity) getActivity()).getMine();
    }
}
