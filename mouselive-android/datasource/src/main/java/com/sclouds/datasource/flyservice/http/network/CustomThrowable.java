package com.sclouds.datasource.flyservice.http.network;

public class CustomThrowable extends Exception {

    public int code;
    public String message;

    public CustomThrowable(Throwable throwable, int code) {
        super(throwable);
        this.code = code;
    }

    public CustomThrowable(int code, String message) {
        super(message);
        this.code = code;
        this.message = message;
    }

}