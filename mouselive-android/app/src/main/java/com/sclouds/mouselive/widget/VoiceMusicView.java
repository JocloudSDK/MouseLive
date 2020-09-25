package com.sclouds.mouselive.widget;

import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.SeekBar;

import com.sclouds.datasource.thunder.ThunderSvc;
import com.sclouds.mouselive.R;
import com.sclouds.mouselive.utils.FileUtil;
import com.thunder.livesdk.IThunderAudioFilePlayerEventCallback;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

/**
 * 聊天室音乐控件，主要处理背景音乐播放逻辑
 *
 * @author Aslan chenhengfei@yy.com
 * @since 2019/12/26
 */
public class VoiceMusicView extends LinearLayout {

    private static final int DEFAULT_VOL = 50;
    private boolean isOpen = false;
    private boolean isPlay = false;
    private boolean isPause = false;
    private ProgressImageView ivMusic;
    private View line;
    private ImageView ivVol;
    private SeekBar sbVol;
    private long totalPlayTimeMS;

    private IThunderAudioFilePlayerEventCallback mCallback =
            new IThunderAudioFilePlayerEventCallback() {
                @Override
                public void onAudioFileVolume(long volume, long currentMs, long totalMs) {
                    super.onAudioFileVolume(volume, currentMs, totalMs);
                    if (isOpen) {
                        ivMusic.setPercentage(currentMs * 100 / totalPlayTimeMS);
                    }
                }
            };

    private Handler mHandler = new Handler();
    private Runnable mRunnableClose = new Runnable() {
        @Override
        public void run() {
            closeMenu();
        }
    };

    public VoiceMusicView(Context context) {
        super(context);
        ini();
    }

    public VoiceMusicView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        ini();
    }

    public VoiceMusicView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        ini();
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public VoiceMusicView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        ini();
    }

    private void ini() {
        LayoutInflater.from(getContext()).inflate(R.layout.layout_voice_music, this);

        ivMusic = findViewById(R.id.ivMusic);
        line = findViewById(R.id.line);
        ivVol = findViewById(R.id.ivVol);
        sbVol = findViewById(R.id.sbVol);

        sbVol.setProgress(DEFAULT_VOL);
        sbVol.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                ThunderSvc.getInstance().setPlayerVolume(progress);

                mHandler.removeCallbacks(mRunnableClose);
                mHandler.postDelayed(mRunnableClose, 5000L);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });

        ivMusic.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (isOpen == false) {
                    showMenu();
                    return;
                }

                if (isPlay == false) {
                    playMusic();
                } else if (isPause) {
                    resumeMusic();
                } else {
                    pauseMusic();
                }

                mHandler.removeCallbacks(mRunnableClose);
                mHandler.postDelayed(mRunnableClose, 5000L);
            }
        });

        stopMusic();
        closeMenu();
    }

    public void showMenu() {
        ivMusic.showPercentage();
        line.setVisibility(VISIBLE);
        ivVol.setVisibility(VISIBLE);
        sbVol.setVisibility(VISIBLE);
        isOpen = true;

        if (isPlay == false || isPause) {
            ivMusic.setImageResource(R.mipmap.ic_voice_play);
        } else {
            ivMusic.setImageResource(R.mipmap.ic_voice_pause);
        }
        mHandler.postDelayed(mRunnableClose, 5000L);
    }

    public void closeMenu() {
        ivMusic.setImageResource(R.mipmap.ic_voice_music);
        ivMusic.hidenPercentage();
        line.setVisibility(GONE);
        ivVol.setVisibility(GONE);
        sbVol.setVisibility(GONE);
        isOpen = false;
    }

    private void playMusic() {
        String file = FileUtil.getMusic(getContext()) + "/music.mp3";
        ThunderSvc.getInstance().openMusic(file, new ThunderSvc.IOpenMusicFileCallback() {
            @Override
            public void onOpenSuccess(long totalPlayTimeMS) {
                VoiceMusicView.this.totalPlayTimeMS = totalPlayTimeMS;
                ThunderSvc.getInstance().startPlayMusic(true);
                ThunderSvc.getInstance().setPlayerVolume(DEFAULT_VOL);
                ivMusic.setImageResource(R.mipmap.ic_voice_pause);
                isPlay = true;
                isPause = false;
            }

            @Override
            public void onOpenError(int error) {

            }
        });
    }

    private void resumeMusic() {
        ThunderSvc.getInstance().resumePlayMusic();
        ivMusic.setImageResource(R.mipmap.ic_voice_pause);
        isPause = false;
    }

    private void pauseMusic() {
        ThunderSvc.getInstance().pausePlayMusic();
        ivMusic.setImageResource(R.mipmap.ic_voice_play);
        isPause = true;
    }

    public void stopMusic() {
        ThunderSvc.getInstance().stopPlayMusic();
        ThunderSvc.getInstance().closeMusic();
        isPlay = false;
        isPause = false;
        VoiceMusicView.this.totalPlayTimeMS = 0;
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        ThunderSvc.getInstance().addAudioListener(mCallback);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        ThunderSvc.getInstance().removeAudioListener(mCallback);
    }
}