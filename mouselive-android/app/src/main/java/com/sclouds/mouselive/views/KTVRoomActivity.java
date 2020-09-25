package com.sclouds.mouselive.views;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import com.sclouds.basedroid.BaseMVVMActivity;
import com.sclouds.datasource.bean.Room;
import com.sclouds.datasource.bean.RoomUser;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.bean.FakeMessage;
import com.sclouds.mouselive.databinding.ActivityKtvRoomBinding;
import com.sclouds.mouselive.view.IKTVRoomView;
import com.sclouds.mouselive.viewmodel.KTVRoomViewModel;
import com.sclouds.mouselive.widget.MyFragmentFactory;

import java.util.Objects;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModel;
import androidx.lifecycle.ViewModelProvider;

/**
 * KTV房
 *
 * @author chenhengfei@yy.com
 * @since 2020/07/07
 */
public class KTVRoomActivity extends BaseMVVMActivity<ActivityKtvRoomBinding, KTVRoomViewModel>
        implements View.OnClickListener, IKTVRoomView {

    private Room room;

    public static void startActivity(Context context, Room room) {
        Intent intent = new Intent(context, KTVRoomActivity.class);
        intent.putExtra(LivingRoomActivity.EXTRA_ROOM, room);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        getSupportFragmentManager().setFragmentFactory(new MyFragmentFactory());
        super.onCreate(savedInstanceState);
    }

    @Override
    protected void initBundle(@Nullable Bundle bundle) {
        super.initBundle(bundle);
        assert bundle != null;
        room = bundle.getParcelable(LivingRoomActivity.EXTRA_ROOM);
    }

    @Override
    protected KTVRoomViewModel iniViewModel() {
        return new ViewModelProvider(this, new ViewModelProvider.Factory() {
            @NonNull
            @Override
            public <T extends ViewModel> T create(@NonNull Class<T> modelClass) {
                //noinspection unchecked
                return (T) new KTVRoomViewModel(getApplication(), KTVRoomActivity.this, room);
            }
        }).get(KTVRoomViewModel.class);
    }

    @Override
    protected int getLayoutResId() {
        return R.layout.activity_ktv_room;
    }

    @Override
    protected void initView() {
        mBinding.tvChat.setOnClickListener(this);
        mBinding.tvMembers.setOnClickListener(this);
        mBinding.tvChating.setOnClickListener(this);
    }

    @Override
    protected void initData() {
        super.initData();

        Bundle bundle = new Bundle();
        bundle.putParcelable(LivingRoomActivity.EXTRA_ROOM, room);
        Fragment fragment = getSupportFragmentManager().getFragmentFactory()
                .instantiate(Objects.requireNonNull(getClassLoader()),
                        KTVChatFragment.class.getSimpleName());
        fragment.setArguments(bundle);
        getSupportFragmentManager().beginTransaction()
                .replace(R.id.flFrame, fragment)
                .commit();
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.tvChat:
                switchChatFragment();
                break;
            case R.id.tvMembers:
                switchMemberFragment();
                break;
            case R.id.tvChating:
                switchChatingFragment();
                break;
            default:
                break;
        }
    }

    private void switchChatFragment() {
        Bundle bundle = new Bundle();
        bundle.putParcelable(LivingRoomActivity.EXTRA_ROOM, room);
        Fragment fragment = getSupportFragmentManager().getFragmentFactory()
                .instantiate(Objects.requireNonNull(getClassLoader()),
                        KTVChatFragment.class.getSimpleName());
        fragment.setArguments(bundle);
        getSupportFragmentManager().beginTransaction()
                .replace(R.id.flFrame, fragment)
                .commit();
    }

    private void switchMemberFragment() {
        Bundle bundle = new Bundle();
        bundle.putParcelable(LivingRoomActivity.EXTRA_ROOM, room);
        Fragment fragment = getSupportFragmentManager().getFragmentFactory()
                .instantiate(Objects.requireNonNull(getClassLoader()),
                        KTVMembersFragment.class.getSimpleName());
        fragment.setArguments(bundle);
        getSupportFragmentManager().beginTransaction()
                .replace(R.id.flFrame, fragment)
                .commit();
    }

    private void switchChatingFragment() {
        Bundle bundle = new Bundle();
        bundle.putParcelable(LivingRoomActivity.EXTRA_ROOM, room);
        Fragment fragment = getSupportFragmentManager().getFragmentFactory()
                .instantiate(Objects.requireNonNull(getClassLoader()),
                        KTVChatingFragment.class.getSimpleName());
        fragment.setArguments(bundle);
        getSupportFragmentManager().beginTransaction()
                .replace(R.id.flFrame, fragment)
                .commit();
    }

    @Override
    public void onSendMessage(@NonNull FakeMessage message) {

    }

    @Override
    public void onMemberJoin(@NonNull RoomUser user) {

    }

    @Override
    public void onMemberLeave(@NonNull RoomUser user) {

    }

    @Override
    public void onVideoStart(@NonNull RoomUser user) {

    }

    @Override
    public void onVideoStop(@NonNull RoomUser user) {

    }

    @Override
    public void onMemberMicStatusChanged(@NonNull RoomUser user) {

    }

    @Override
    public void onPlayVolumeIndication(@NonNull RoomUser user) {

    }

    @Override
    public void onNetworkQuality(@NonNull RoomUser user) {

    }

    @Override
    public void onMuteChanged(@NonNull RoomUser user) {

    }

    @Override
    public void onRoleChanged(@NonNull RoomUser user) {

    }

    @Override
    public void onMemberKicked(@NonNull RoomUser user) {

    }

    @Override
    public void onMemberChatStart(@NonNull RoomUser user) {

    }

    @Override
    public void onMemberChatStop(@NonNull RoomUser user) {

    }

    @Override
    public void onMessage(@NonNull FakeMessage message) {

    }

    @Nullable
    public RoomUser getMine() {
        return mViewModel.getMine();
    }

    @Override
    public void onRoomMemberCountChanged(Room room) {

    }
}
