package com.sclouds.mouselive.views.dialog;

import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;

import com.sclouds.basedroid.BaseAdapter;
import com.sclouds.datasource.bean.Anchor;
import com.sclouds.datasource.bean.Room;
import com.sclouds.datasource.bean.RoomUser;
import com.sclouds.datasource.flyservice.http.FlyHttpSvc;
import com.sclouds.datasource.flyservice.http.network.BaseObserver;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.adapters.RoomPKMemberAdapter;
import com.trello.rxlifecycle3.android.FragmentEvent;
import com.trello.rxlifecycle3.components.support.RxAppCompatDialogFragment;

import java.util.ArrayList;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import io.reactivex.android.schedulers.AndroidSchedulers;

/**
 * 房间PK成员列表
 *
 * @author chenhengfei@yy.com
 * @since 2020年2月20日
 */
public class RoomPKMembersDialog extends RxAppCompatDialogFragment {

    private static final String TAG = RoomPKMembersDialog.class.getSimpleName();

    private static final String TAG_ROOM = "room";
    private static final String TAG_USER = "user";

    private RecyclerView rvMembers;
    private RoomPKMemberAdapter mAdapter;

    private Room mRoom;
    private RoomUser mRoomUser;//自己

    private IPKCallback mCallback;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        Window win = getDialog().getWindow();
        WindowManager.LayoutParams params = win.getAttributes();
        params.gravity = Gravity.BOTTOM;
        params.width = ViewGroup.LayoutParams.MATCH_PARENT;
        params.height = ViewGroup.LayoutParams.WRAP_CONTENT;
        win.setAttributes(params);
        return inflater.inflate(R.layout.layout_room_pk_memebers, container);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        rvMembers = view.findViewById(R.id.rvMembers);

        mAdapter = new RoomPKMemberAdapter(getContext());
        rvMembers.setLayoutManager(new LinearLayoutManager(getContext()));
        rvMembers.setAdapter(mAdapter);
        mAdapter.setOnItemClickListener(new BaseAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position) {
                Anchor user = mAdapter.getDataAtPosition(position);
                mCallback.onPK(user);
            }
        });


        Bundle bundle = getArguments();
        assert bundle != null;
        mRoom = bundle.getParcelable(TAG_ROOM);
        mRoomUser = bundle.getParcelable(TAG_USER);

        setMemebers();
    }

    private void setMemebers() {
        FlyHttpSvc.getInstance().getPKMembers(mRoomUser.getUid(), mRoom.getRType())
                .observeOn(AndroidSchedulers.mainThread())
                .compose(bindUntilEvent(FragmentEvent.DESTROY))
                .subscribe(new BaseObserver<List<Anchor>>(getContext()) {
                    @Override
                    public void handleSuccess(@NonNull List<Anchor> members) {
                        List<Anchor> membersNew = new ArrayList<>();
                        for (Anchor anchor : members) {
                            if (anchor.getAId() != mRoomUser.getUid()) {
                                membersNew.add(anchor);
                            }
                        }
                        mAdapter.setData(membersNew);
                    }
                });
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(STYLE_NORMAL, R.style.Dialog_Bottom);
    }

    public void show(FragmentManager manager, Room mRoom, RoomUser user, IPKCallback callback) {
        this.mCallback = callback;

        Bundle bundle = new Bundle();
        bundle.putParcelable(TAG_ROOM, mRoom);
        bundle.putParcelable(TAG_USER, user);
        setArguments(bundle);
        show(manager, TAG);
    }

    public interface IPKCallback {
        void onPK(Anchor user);
    }
}
