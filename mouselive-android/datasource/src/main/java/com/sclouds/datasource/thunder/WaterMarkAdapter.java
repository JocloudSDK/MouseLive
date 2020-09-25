package com.sclouds.datasource.thunder;

import android.util.Log;

import com.thunder.livesdk.ThunderBoltImage;

/**
 * @author xipeitao
 * @description:    基于720P
 * @date : 2020-04-15 17:49
 */
public class WaterMarkAdapter {

    private static final String TAG = WaterMarkAdapter.class.getSimpleName();

    private float DEF_WIDTH = 1080;
    private float DEF_HEIGHT = 720;

    private float startX = -1;
    private float startY = -1;
    private float width = -1;
    private float height = -1;
    private String url = "";

    /**
     * @param startX
     * @param starY
     * @param width
     * @param heifht
     */
    public WaterMarkAdapter(String url,float startX, float starY, float width, float heifht) {
        this.startX = startX;
        this.startY = starY;
        this.width = width;
        this.height = heifht;
        this.url = url;
    }

    public ThunderBoltImage createThunderBoltImage(float videoWidth, float videoHeight,
                                                   int rotation) {
        Log.d(TAG, "createThunderBoltImage() called with: videoWidth = [" + videoWidth +
                "], videoHeight = [" + videoHeight + "], rotation = [" + rotation + "]");
        ThunderBoltImage thunderBoltImage = new ThunderBoltImage();
        thunderBoltImage.url = url;
        thunderBoltImage.x = (int) (startX*videoWidth/DEF_WIDTH);
        thunderBoltImage.y = (int) (startY*videoHeight/DEF_HEIGHT);
        float scale = getScale(videoWidth,videoHeight,rotation);
        thunderBoltImage.width = (int) (width*scale);
        thunderBoltImage.height = (int) (height*scale);
        Log.d(TAG,
                "createThunderBoltImage() called with: thunderBoltImage = [" + thunderBoltImage +"]");
       return thunderBoltImage;
    }

    private float getScale(float videoWidth, float videoHeight, int rotation) {
        return Math.max(videoWidth/DEF_WIDTH,videoHeight/DEF_HEIGHT);
    }


}
