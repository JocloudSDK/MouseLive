package com.sclouds.mouselive.views.dialog;

import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.CompoundButton;
import android.widget.Switch;
import android.widget.TextView;

import com.sclouds.basedroid.BaseAdapter;
import com.sclouds.datasource.thunder.ThunderSvc;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.adapters.VoiceEffectAdapter;
import com.sclouds.mouselive.widget.GalleryItemDecoration;
import com.thunder.livesdk.ThunderRtcConstant;
import com.trello.rxlifecycle3.components.support.RxAppCompatDialogFragment;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;
import androidx.recyclerview.widget.DefaultItemAnimator;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.LinearSnapHelper;
import androidx.recyclerview.widget.RecyclerView;

/**
 * 变声
 *
 * @author chenhengfei@yy.com
 * @since 2020年2月20日
 */
public class VoiceChangerDialog extends RxAppCompatDialogFragment implements
        View.OnClickListener {

    private static final String TAG = VoiceChangerDialog.class.getSimpleName();

    public static boolean isEnableEar = false;
    public static boolean isVoiceChanged = false;

    private TextView tvEar;
    private Switch sOnOff;
    private RecyclerView rvMembers;
    private VoiceEffectAdapter mAdapter;

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
        return inflater.inflate(R.layout.layout_voice_setting, container);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        tvEar = view.findViewById(R.id.tvEar);
        sOnOff = view.findViewById(R.id.sOnOff);
        rvMembers = view.findViewById(R.id.rvMembers);

        mAdapter = new VoiceEffectAdapter(getContext());
        LinearSnapHelper movieSnapHelper = new LinearSnapHelper();
        movieSnapHelper.attachToRecyclerView(rvMembers);
        rvMembers.addItemDecoration(new GalleryItemDecoration());
        // rvMembers.setLayoutManager(
        //         new CenterLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false));
        rvMembers.setLayoutManager(
                new LinearLayoutManager(getContext(), LinearLayoutManager.HORIZONTAL, false));
        rvMembers.setHasFixedSize(true);
        rvMembers.setItemAnimator(new DefaultItemAnimator());
        rvMembers.setAdapter(mAdapter);


        mAdapter.setOnItemClickListener(new BaseAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position) {
                rvMembers.smoothScrollToPosition(position);
                mAdapter.setSelectIndex(position);

                if (sOnOff.isChecked()) {
                    VoiceEffectAdapter.VoiceEffect voiceEffect = mAdapter.getSelectItem();
                    ThunderSvc.getInstance().setVoiceChanger(voiceEffect.getValue());
                }
            }
        });
        mAdapter.setSelectIndex(0);

        tvEar.setOnClickListener(this);
        setEraText();

        sOnOff.setChecked(isVoiceChanged);
        sOnOff.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                isVoiceChanged = isChecked;
                if (isChecked) {
                    VoiceEffectAdapter.VoiceEffect voiceEffect = mAdapter.getSelectItem();
                    ThunderSvc.getInstance().setVoiceChanger(voiceEffect.getValue());
                } else {
                    ThunderSvc.getInstance().setVoiceChanger(
                            ThunderRtcConstant.VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_NONE);
                }
            }
        });
    }

    private void setEraText() {
        if (isEnableEar) {
            tvEar.setText(R.string.voice_changer_ear_off);
        } else {
            tvEar.setText(R.string.voice_changer_ear_on);
        }
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(STYLE_NORMAL, R.style.Dialog_Bottom);
    }

    private void toggleVoiceChange() {

    }

    public void show(FragmentManager manager) {
        show(manager, TAG);
    }

    private void toggleEar() {
        isEnableEar = !isEnableEar;
        ThunderSvc.getInstance().setEnableInEarMonitor(isEnableEar);

        setEraText();
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.tvEar:
                toggleEar();
                break;
            default:
                break;
        }
    }
}
