package com.sclouds.mouselive.views;

import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModel;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import com.sclouds.basedroid.BaseMVVMActivity;
import com.sclouds.datasource.bean.MyMusicsInfo;
import com.sclouds.datasource.thunder.ThunderSvc;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.adapters.MyMusicsAdapter;
import com.sclouds.mouselive.databinding.ActivityMyMusicsBinding;
import com.sclouds.mouselive.utils.FileUtil;
import com.sclouds.mouselive.viewmodel.MyMusicsViewModel;
import com.thunder.livesdk.IThunderAudioFilePlayerEventCallback;
import com.thunder.livesdk.ThunderRtcConstant;

public class MyMusicsActivity extends BaseMVVMActivity<ActivityMyMusicsBinding, MyMusicsViewModel> {

    private static final String TAG = "MyMusicsActivity";

    private static final int DEFAULT_VOL = 50;

    private MyMusicsAdapter mMyMusicsAdapter = null;

    private ImageView mPlayImageView = null;
    private TextView mEmptyTextView = null;
    private TextView mPlayNameTextView = null;
    private TextView mPlayTimeTextView = null;
    private SeekBar mPlaySeekBar = null;

    private PlayStatus mPlayStatus = PlayStatus.IDLE;

    private long mPlayTotalDuration = 0;

    private IThunderAudioFilePlayerEventCallback mPlayerCallback =
            new IThunderAudioFilePlayerEventCallback() {
                @Override
                public void onAudioFileVolume(long volume, long currentMs, long totalMs) {
                    Log.d(TAG, "onAudioFileVolume: volume = " + volume + ", currentMs = " + currentMs + ", totalMs = " + totalMs);
                    super.onAudioFileVolume(volume, currentMs, totalMs);
                    updatePlayView(currentMs, totalMs);
                }

                @Override
                public void onAudioFileStateChange(int event, int errorCode) {
                    super.onAudioFileStateChange(event, errorCode);
                    Log.d(TAG, "onAudioFileStateChange: event = " + event + ", errorCode = " + errorCode);
                    if (ThunderRtcConstant.ThunderAudioFilePlayerEvent.AUDIO_PLAY_EVENT_END == event) {
                        updatePlayView(mPlayTotalDuration, mPlayTotalDuration);
                    }
                }
            };

    private void updatePlayView(long currentMs, long totalMs) {
        if ((null != mPlaySeekBar) && (totalMs > 0)) {
            mPlaySeekBar.setProgress((int) (currentMs * 100 / totalMs));
        }
        if (null != mPlayTimeTextView) {
            mPlayTimeTextView.setText(getTimeFormatString(currentMs, totalMs));
        }
    }

    @Override
    protected MyMusicsViewModel iniViewModel() {
        return new ViewModelProvider(this, new ViewModelProvider.Factory() {
            @NonNull
            @Override
            public <T extends ViewModel> T create(@NonNull Class<T> modelClass) {
                //noinspection unchecked
                return (T) new MyMusicsViewModel(getApplication());
            }
        }).get(MyMusicsViewModel.class);
    }

    @Override
    protected int getLayoutResId() {
        return R.layout.activity_my_musics;
    }

    @Override
    protected void initView() {
        initBackImageView();

        initDeleteAllButton();

        initPlayView();

        initMyMusicsRecyclerView();

        initViewModel();
    }

    private void initBackImageView() {
        ImageView imageView = findViewById(R.id.backImageView);
        imageView.setOnClickListener(v -> doBack());
    }

    private void doBack() {
        Log.d(TAG, "doBack");
        this.finish();
    }

    private void initDeleteAllButton() {
        Button button = findViewById(R.id.deleatAllButton);
        button.setOnClickListener( v -> doDeleteAll());
    }

    private void doDeleteAll() {
        Log.d(TAG, "doDeleteAll");
        if ((null != mMyMusicsAdapter) && (mMyMusicsAdapter.getItemCount() == 0)) {
            Log.d(TAG, "doDeleteAll: nothing need to delete");
            return;
        }
        stopMusic();
        hidePlayMusicView();
        mViewModel.deleteAll();
    }
    private void hidePlayMusicView() {
        Log.d(TAG, "hidePlayMusicView");
        if (null != mPlayImageView) {
            mPlayImageView.setVisibility(View.GONE);
        }
        if (null != mPlaySeekBar) {
            mPlaySeekBar.setVisibility(View.GONE);
        }
        if (null != mPlayNameTextView) {
            mPlayNameTextView.setVisibility(View.GONE);
        }
        if (null != mPlayTimeTextView) {
            mPlayTimeTextView.setVisibility(View.GONE);
        }
    }

    private void initPlayView() {
        mPlayImageView = findViewById(R.id.playImageView);
        mPlayImageView.setOnClickListener( v -> {
            Log.d(TAG, "onPlayImageViewClick(mPlayStatus = " + mPlayStatus + ")");
            if (PlayStatus.PLAYING == mPlayStatus) {
                pauseMusic();
            } else if (PlayStatus.PAUSED == mPlayStatus) {
                resumeMusic();
            } else {
                Log.d(TAG, "do nothing while IDLE");
            }
        });
        mPlayNameTextView = findViewById(R.id.playNameTextView);
        mPlayTimeTextView = findViewById(R.id.playTimeTextView);
        mPlaySeekBar = findViewById(R.id.playSeekBar);
        mPlaySeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                Log.d(TAG, "onProgressChanged(progress = " + progress + ", fromUser = " + fromUser + ")");
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
                Log.d(TAG, "onStartTrackingTouch(progress = " + seekBar.getProgress() + ")");
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                Log.d(TAG, "onStopTrackingTouch(progress = " + seekBar.getProgress() + ")");
                doSeekTo(seekBar.getProgress());
            }
        });
    }

    private void doSeekTo(int progress) {
        Log.d(TAG, "doSeekTo(progress = " + progress + ")");
        if (PlayStatus.PLAYING != mPlayStatus) {
            return;
        }
        long timeMs = progress * mPlayTotalDuration / 100;
        Log.d(TAG, "doSeekTo: timeMs = " + timeMs);
        ThunderSvc.getInstance().seekToPlayMusic(timeMs);
    }

    private void initMyMusicsRecyclerView() {
        final SwipeRefreshLayout swipeRefreshLayout = findViewById(R.id.swipeRefresh);
        swipeRefreshLayout.setOnRefreshListener(() -> {
            Log.d(TAG, "onRefresh");
            mViewModel.initData();
            swipeRefreshLayout.setRefreshing(false);
        });
        mMyMusicsAdapter = new MyMusicsAdapter(getApplicationContext());
        mMyMusicsAdapter.setOnItemClickListener((view, position) -> {
            MyMusicsInfo info = mMyMusicsAdapter.getDataAtPosition(position);
            if (null != info) {
                playMusic(info.getName(), info.getDuration());
            }
        });
        RecyclerView recyclerView = findViewById(R.id.recyclerView);
        recyclerView.setLayoutManager(new LinearLayoutManager(getApplicationContext()));
        recyclerView.setAdapter(mMyMusicsAdapter);
        mEmptyTextView = findViewById(R.id.emptyTextView);
    }

    private void playMusic(String name, long duration) {
        showPlayMusicView(name, duration);
        String file = FileUtil.getRecord(getApplication()) + File.separator + name;
        ThunderSvc.getInstance().openMusic(file, new ThunderSvc.IOpenMusicFileCallback() {
            @Override
            public void onOpenSuccess(long totalPlayTimeMS) {
                Log.d(TAG, "onOpenSuccess: totalPlayTimeMS = " + totalPlayTimeMS);
                mPlayTotalDuration = totalPlayTimeMS;
                ThunderSvc.getInstance().startPlayMusic(false);
                ThunderSvc.getInstance().setPlayerVolume(DEFAULT_VOL);

                if (null != mPlayImageView) {
                    mPlayImageView.setImageResource(R.mipmap.ic_voice_pause);
                }
                mPlayStatus = PlayStatus.PLAYING;
            }

            @Override
            public void onOpenError(int error) {
                Log.d(TAG, "onOpenError: error = " + error);
                Toast.makeText(getApplicationContext(), getResources().getString(R.string.my_musics_play_error) + "(" + error + ")", Toast.LENGTH_LONG).show();
            }
        });
    }

    private void showPlayMusicView(String name, long duration) {
        Log.d(TAG, "showPlayMusic(name = " + name + ", duration = " + duration + ")");
        if (null != mPlayImageView) {
            mPlayImageView.setImageResource(R.mipmap.ic_voice_pause);
            mPlayImageView.setVisibility(View.VISIBLE);
        }
        if (null != mPlaySeekBar) {
            mPlaySeekBar.setProgress(0);
            mPlaySeekBar.setVisibility(View.VISIBLE);
        }
        if (null != mPlayNameTextView) {
            mPlayNameTextView.setText(name);
            mPlayNameTextView.setVisibility(View.VISIBLE);
        }
        if (null != mPlayTimeTextView) {
            mPlayTimeTextView.setText(getTimeFormatString(0, duration));
            mPlayTimeTextView.setVisibility(View.VISIBLE);
        }
    }

    private String getTimeFormatString(long currentTime, long duration) {
        SimpleDateFormat format = new SimpleDateFormat("mm:ss", Locale.getDefault());
        return format.format(new Date(currentTime)) + File.separator + format.format(new Date(duration));
    }

    private void initViewModel() {
        mViewModel.getLiveData().observe(this, new Observer<List<MyMusicsInfo>>() {
            @Override
            public void onChanged(List<MyMusicsInfo> myMusicsInfos) {
                if (null != mMyMusicsAdapter) {
                    mMyMusicsAdapter.setData(myMusicsInfos);
                }
                if (null != mEmptyTextView) {
                    mEmptyTextView.setVisibility(myMusicsInfos.size() == 0 ? View.VISIBLE : View.GONE);
                }
            }
        });
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ThunderSvc.getInstance().addAudioListener(mPlayerCallback);
    }

    @Override
    protected void onResume() {
        super.onResume();
        resumeMusic();
    }

    private void resumeMusic() {
        Log.d(TAG, "resumeMusic");
        if (PlayStatus.PAUSED != mPlayStatus) {
            return;
        }
        ThunderSvc.getInstance().resumePlayMusic();
        if (null != mPlayImageView) {
            mPlayImageView.setImageResource(R.mipmap.ic_voice_pause);
        }
        mPlayStatus = PlayStatus.PLAYING;
    }

    @Override
    protected void onPause() {
        super.onPause();
        pauseMusic();
    }

    private void pauseMusic() {
        Log.d(TAG, "pauseMusic");
        if (PlayStatus.PLAYING != mPlayStatus) {
            return;
        }
        ThunderSvc.getInstance().pausePlayMusic();
        if (null != mPlayImageView) {
            mPlayImageView.setImageResource(R.mipmap.ic_voice_play);
        }
        mPlayStatus = PlayStatus.PAUSED;
    }


    @Override
    protected void onDestroy() {
        super.onDestroy();
        stopMusic();
    }

    public void stopMusic() {
        Log.d(TAG, "stopMusic");
        ThunderSvc.getInstance().removeAudioListener(mPlayerCallback);
        ThunderSvc.getInstance().stopPlayMusic();
        ThunderSvc.getInstance().closeMusic();
        mPlayStatus = PlayStatus.IDLE;
    }

    private enum PlayStatus {
        IDLE,
        PLAYING,
        PAUSED
    }
}
