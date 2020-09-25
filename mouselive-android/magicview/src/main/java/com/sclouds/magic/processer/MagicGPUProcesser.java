package com.sclouds.magic.processer;

import android.content.Context;
import android.opengl.GLES11Ext;
import android.opengl.GLES20;
import android.os.Handler;
import android.os.Looper;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;

import com.orangefilter.OrangeFilter;
import com.sclouds.basedroid.LogUtils;
import com.sclouds.basedroid.ToastUtil;
import com.sclouds.magic.R;
import com.sclouds.magic.config.MagicConfig;
import com.sclouds.magic.helper.OrangeHelper;
import com.sclouds.magic.manager.MagicDataManager;
import com.sclouds.magic.utils.CameraUtil;
import com.sclouds.magic.utils.OFLogUtils;
import com.thunder.livesdk.video.IVideoCaptureObserver;
import com.yy.mediaframework.gles.Drawable2d;
import com.yy.mediaframework.gpuimage.custom.IGPUProcess;
import com.yy.mediaframework.gpuimage.util.GLShaderProgram;
import com.yy.mediaframework.gpuimage.util.GLTexture;

/**
 * 美颜特效功能实现类
 */
public class MagicGPUProcesser implements IGPUProcess {

    private final static String TAG = MagicGPUProcesser.class.getSimpleName();

    private final static String noeffect_vs =
            "attribute vec4 aPosition;\n" +
                    "attribute vec4 aTextureCoord;\n" +
                    "varying vec2 vTexCoord;\n" +
                    "\n" +
                    "void main()\n" +
                    "{\n" +
                    "    gl_Position = aPosition;\n" +
                    "    vTexCoord = aTextureCoord.xy;\n" +
                    "}";

    private static String noeffect_fs =
            "precision mediump float;\n" +
                    "varying vec2 vTexCoord;\n" +
                    "uniform sampler2D uTexture0;\n" +
                    "\n" +
                    "void main()\n" +
                    "{\n" +
                    "    vec4 color = texture2D(uTexture0, vTexCoord);\n" +
                    "    gl_FragColor = color; //vec4(color.y, color.y, color.y, 1.0);\n" +
                    "}";

    private final static String passthrouth_vs =
            "attribute vec4 aPosition;\n" +
                    "attribute vec4 aTextureCoord;\n" +
                    "varying vec2 vTexCoord;\n" +
                    "\n" +
                    "void main()\n" +
                    "{\n" +
                    "    gl_Position = aPosition;\n" +
                    "    vTexCoord = aTextureCoord.xy;\n" +
                    "}";

    private final static String passthrouth_fs =
            "precision mediump float;\n" +
                    "varying vec2 vTexCoord;\n" +
                    "uniform sampler2D uTexture0;\n" +
                    "\n" +
                    "void main()\n" +
                    "{\n" +
                    "    vec4 color = texture2D(uTexture0, vTexCoord);\n" +
                    "    gl_FragColor = color; //vec4(color.y, color.y, color.y, 1.0);\n" +
                    "}";

    private final static String mOESFragmentShader =
            "#extension GL_OES_EGL_image_external : require\n" +
                    noeffect_fs.replace("uniform sampler2D uTexture0;",
                            "uniform samplerExternalOES uTexture0;");

    private static final float[] CUBE = {
            -1.0f, -1.0f,
            1.0f, -1.0f,
            -1.0f, 1.0f,
            1.0f, 1.0f,
    };

    private final FloatBuffer mVertexBuffer = ByteBuffer.allocateDirect(CUBE.length * 4)
            .order(ByteOrder.nativeOrder())
            .asFloatBuffer();

    private GLShaderProgram mNoEffectShader = null;
    private GLShaderProgram mPassthroughShader = null;

    private GLTexture mInputTexture = null;
    private GLTexture mOutputTexture = null;
    private IntBuffer mFramebuffer = null;
    private IntBuffer mOldFramebuffer = null;
    private Drawable2d mRectDrawable = new Drawable2d(Drawable2d.Prefab.FULL_RECTANGLE);

    private int mTextureTarget;
    private int mOutputWidth = 0;
    private int mOutputHeight = 0;

    private Context mContext;

    private String mSerialNumber;

    private Handler mHandler = null;

    private boolean mHasInit = false;

    private static final Object mCaptureVideoFrameLock = new Object();
    private byte[] mImageData;
    private int mImgHeight;
    private int mImgWidth;

    public MagicGPUProcesser(Context context, String serialNumber) {
        this.mContext = context;
        this.mSerialNumber = serialNumber;
    }

    /**
     * 视频 OpenGL 渲染线程初始化回调
     * 详见 md 文档介绍
     */
    @Override
    public void onInit(int textureTarget, int outputWidth, int outputHeight) {
        LogUtils.d(TAG, "onInit");
        initHandler();

        initOrangeFilter();

        if (( null == mInputTexture) || (null == mOutputTexture)) {
            mInputTexture = new GLTexture(GLES20.GL_TEXTURE_2D);
            mOutputTexture = new GLTexture(GLES20.GL_TEXTURE_2D);
        }

        mTextureTarget = textureTarget;
        mOutputWidth = outputWidth;
        mOutputHeight = outputHeight;

        if (GLES11Ext.GL_TEXTURE_EXTERNAL_OES == textureTarget) {
            noeffect_fs = mOESFragmentShader;
        }

        mVertexBuffer.put(CUBE).position(0);

        mFramebuffer = IntBuffer.allocate(1);
        GLES20.glGenFramebuffers(1, mFramebuffer);

        mNoEffectShader = new GLShaderProgram();
        mNoEffectShader.setProgram(noeffect_vs, noeffect_fs);

        mPassthroughShader = new GLShaderProgram();
        mPassthroughShader.setProgram(passthrouth_vs, passthrouth_fs);

        mOldFramebuffer = IntBuffer.allocate(1);

        mHasInit = true;
    }

    private void initHandler() {
        Looper looper = Looper.myLooper();
        if ((null == mHandler) && (null != looper)) {
            mHandler = new Handler(looper);
        }
    }

    private void initOrangeFilter() {
        OrangeHelper.setLogLevel(OrangeFilter.OF_LogLevel_Verbose);
        OrangeHelper.setLogCallback(new OrangeFilter.OF_LogListener() {
            @Override
            public void logCallBackFunc(String s) {
                OFLogUtils.d(TAG, s);
            }

            @Override
            public void logCallBackFunc2(String s, int i) {
                OFLogUtils.d(TAG, s);
            }
        });

        boolean result = OrangeHelper.createContext(mContext, mSerialNumber, OrangeHelper.VENUS_ALL,null,true);
        if (!result) {
            ToastUtil.showToast(mContext, mContext.getResources().getString(R.string.magic_license_invalid));
            return;
        }

        // 基础整形和高级整形互斥，高级美颜默认值：小脸 - 40，大眼 - 20，瘦鼻 -3
        OrangeHelper.enableEffect(OrangeHelper.EffectType.ET_SeniorBeautyType, true);
        OrangeHelper.setEffectParam(OrangeHelper.EffectParamType.EP_SeniorTypeSmallFaceIntensity, MagicConfig.DEFAULT_SMALL_FACE_VALUE);
        OrangeHelper.setEffectParam(OrangeHelper.EffectParamType.EP_SeniorTypeBigSmallEyeIntensity, MagicConfig.DEFAULT_BIG_EYE_VALUE);
        OrangeHelper.setEffectParam(OrangeHelper.EffectParamType.EP_SeniorTypeThinNoseIntensity, MagicConfig.DEFAULT_THIN_NOSE_VALUE);
        OrangeHelper.enableEffect(OrangeHelper.EffectType.ET_SeniorBeautyType, false);

        // 泛娱乐 Demo 默认开启基础美颜，默认值：美白 - 70，磨皮 - 70，
        OrangeHelper.enableEffect(OrangeHelper.EffectType.ET_BasicBeauty, true);
        OrangeHelper.setEffectParam(OrangeHelper.EffectParamType.EP_BasicBeautyIntensity, MagicConfig.DEFAULT_WHITEN_VALUE);
        OrangeHelper.setEffectParam(OrangeHelper.EffectParamType.EP_BasicBeautyOpacity, MagicConfig.DEFAULT_SMOOTHEN_VALUE);

        // 泛娱乐 Demo 默认开启基础整形，默认值：基础整形 - 40
        OrangeHelper.enableEffect(OrangeHelper.EffectType.ET_BasicBeautyType, true);
        OrangeHelper.setEffectParam(OrangeHelper.EffectParamType.EP_BasicTypeIntensity, MagicConfig.DEFAULT_BASIC_FACE_VALUE);

        MagicDataManager.getInstance().setDefaultSelectedStatus();
    }

    /**
     * 视频 OpenGL 渲染线程销毁回调
     * 详见 md 文档介绍
     */
    @Override
    public void onDestroy() {
        LogUtils.d(TAG, "onDestroy");
        OrangeHelper.destroyContext();

        MagicDataManager.getInstance().clearSelectedStatus();

        GLES20.glDeleteFramebuffers(1, mFramebuffer);
        if (null != mInputTexture) {
            mInputTexture.destory();
            mOutputTexture.destory();
        }
        mNoEffectShader.destory();
        mPassthroughShader.destory();

        mHasInit = false;
    }

    /**
     * 视频 openGl 渲染线程每一帧渲染回调
     * 详见 md 文档介绍
     */
    @Override
    public void onDraw(int textureId, final FloatBuffer textureBuffer) {
        if (!mHasInit || !OrangeHelper.isContextValid()) {
            LogUtils.d(TAG, "onDraw: not initialized or Orange Filter context id is invalid");
            return;
        }

        GLES20.glGetIntegerv(GLES20.GL_FRAMEBUFFER_BINDING, mOldFramebuffer);

        if (mInputTexture.getWidth() != mOutputWidth ||
                mInputTexture.getHeight() != mOutputHeight) {
            mInputTexture.create(mOutputWidth, mOutputHeight, GLES20.GL_RGBA);
            mOutputTexture.create(mOutputWidth, mOutputHeight, GLES20.GL_RGBA);
            LogUtils.d(TAG, "onDraw: mOutputWidth = " + mOutputWidth + " , mOutputHeight = " + mOutputHeight);
        }

        prepareWithApplyFrameData(textureId, textureBuffer);
    }

    private void prepareWithApplyFrameData(int textureId, FloatBuffer textureBuffer) {
        OrangeHelper.GLTexture inGLTexture = new OrangeHelper.GLTexture();
        inGLTexture.mWidth = mInputTexture.getWidth();
        inGLTexture.mHeight = mInputTexture.getHeight();
        inGLTexture.mTextureId = mInputTexture.getTextureId();

        OrangeHelper.GLTexture outGLTexture = new OrangeHelper.GLTexture();
        outGLTexture.mWidth = mOutputTexture.getWidth();
        outGLTexture.mHeight = mOutputTexture.getHeight();
        outGLTexture.mTextureId = mOutputTexture.getTextureId();

        OrangeHelper.ImageInfo imageInfo = new OrangeHelper.ImageInfo();
        imageInfo.deviceType = 0;
        imageInfo.facePointDir = 1;
        imageInfo.data = mImageData;
        imageInfo.dir = MagicAccelerometerProcesser.getDirection();
        imageInfo.orientation = CameraUtil.getCameraRotation();
        imageInfo.width = mImgWidth;
        imageInfo.height = mImgHeight;
        imageInfo.format = OrangeFilter.OF_PixelFormat_NV21;
        imageInfo.frontCamera = CameraUtil.isFrontCamera();

        // Camera 出来的 OES 纹理转成 2D 纹理，OrangeFilter 输入需要 2D 纹理
        mInputTexture.bindFBO(mFramebuffer.get(0));
        GLES20.glClearColor(0, 0, 0, 1);
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT);
        mNoEffectShader.useProgram();
        mNoEffectShader.setUniformTexture("uTexture0", 0, textureId, mTextureTarget);
        drawQuad(mNoEffectShader, mVertexBuffer, textureBuffer);

        swap(mInputTexture, mOutputTexture);
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, mOldFramebuffer.get(0));

        boolean update = OrangeHelper.updateFrameParams(inGLTexture, outGLTexture, imageInfo);
        if (!update) {
            drawTexture(textureId, mVertexBuffer, textureBuffer);
            return;
        }
        mPassthroughShader.useProgram();
        mPassthroughShader.setUniformTexture("uTexture0", 0, mInputTexture.getTextureId(), mInputTexture.getTarget());
        drawQuad(mPassthroughShader, mRectDrawable.getVertexArray(), mRectDrawable.getTexCoordArray());
        GLES20.glBindTexture(mTextureTarget, 0);
    }

    /**
     * openGl 渲染，内部工具函数，业务不用关心
     */
    private void drawQuad(GLShaderProgram shader, FloatBuffer cubeBuffer,
                          FloatBuffer textureBuffer) {
        cubeBuffer.position(0);
        shader.setVertexAttribPointer("aPosition", 2, GLES20.GL_FLOAT, false, 0, cubeBuffer);

        textureBuffer.position(0);
        shader.setVertexAttribPointer("aTextureCoord", 2, GLES20.GL_FLOAT, false, 0, textureBuffer);

        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4);

        shader.disableVertexAttribPointer("aPosition");
        shader.disableVertexAttribPointer("aTextureCoord");
    }

    private void swap(GLTexture in, GLTexture out) {
        int inId = in.getTextureId();
        int outId = out.getTextureId();
        in.setTextureId(outId);
        out.setTextureId(inId);
    }

    private void drawTexture(int textureId, FloatBuffer cubeBuffer, FloatBuffer textureBuffer) {
        if (GLES11Ext.GL_TEXTURE_EXTERNAL_OES == mTextureTarget) {
            mNoEffectShader.useProgram();
            mNoEffectShader.setUniformTexture("uTexture0", 0, textureId, mTextureTarget);
            drawQuad(mNoEffectShader, cubeBuffer, textureBuffer);
            GLES20.glBindTexture(mTextureTarget, 0);
        }
    }

    /**
     * 视频帧纹理大小回调
     * 详见 md 文档介绍
     */
    @Override
    public void onOutputSizeChanged(final int width, final int height) {
        LogUtils.v(TAG, "onOutputSizeChanged: width = " + width + " , height = " + height);
        mOutputWidth = width;
        mOutputHeight = height;
    }

    public class VideoCaptureWrapper implements IVideoCaptureObserver {

        /**
         * 负责回调 camera 采集的原始 YUV(NV21) 给客户
         *
         * @param width  视频数据宽
         * @param height 视频数据高
         * @param data   视频NV21数据
         * @param length 视频数据长度
         */
        @Override
        public void onCaptureVideoFrame(int width, int height, byte[] data, int length,
                                        int imageFormat) {
            synchronized (mCaptureVideoFrameLock) {
                mImageData = data;
                mImgHeight = height;
                mImgWidth = width;
            }
        }
    }

}