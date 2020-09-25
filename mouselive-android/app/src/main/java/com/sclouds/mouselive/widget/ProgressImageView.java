package com.sclouds.mouselive.widget;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.os.Build;
import android.util.AttributeSet;

/**
 * 聊天室音乐播放进度条效果
 *
 * @author Aslan chenhengfei@yy.com
 * @since 2020/03/01
 */
public class ProgressImageView extends SquareImageView {

    private Paint mPaint;
    private float progressPercent;
    private float width = 3;
    private RectF rectF;

    private boolean isShownPercentage = false;

    public ProgressImageView(Context context) {
        super(context);
        init();
    }

    public ProgressImageView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public ProgressImageView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            setClipToOutline(true);
        }
        mPaint = new Paint();
        mPaint.setStyle(Paint.Style.STROKE);
        mPaint.setStrokeCap(Paint.Cap.ROUND);
        mPaint.setAntiAlias(true);
        mPaint.setColor(Color.WHITE);
        mPaint.setStrokeWidth(width);
    }

    public void setPercentage(float percentage) {
        this.progressPercent = percentage;
        invalidate();
    }

    public void showPercentage() {
        this.isShownPercentage = true;
        invalidate();
    }

    public void hidenPercentage() {
        this.isShownPercentage = false;
        invalidate();
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        rectF = new RectF(width, width, getMeasuredWidth() - width, getMeasuredHeight() - width);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        if (isShownPercentage) {
            canvas.drawArc(rectF, -90, 3.6f * progressPercent, false, mPaint);   //画比例圆弧
        }
    }
}