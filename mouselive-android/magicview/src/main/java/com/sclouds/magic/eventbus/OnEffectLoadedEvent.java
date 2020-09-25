package com.sclouds.magic.eventbus;

public class OnEffectLoadedEvent {

    private boolean isSuccess = false;

    public OnEffectLoadedEvent(boolean success) {
        this.isSuccess = success;
    }

    public boolean isSuccess() {
        return isSuccess;
    }

}
