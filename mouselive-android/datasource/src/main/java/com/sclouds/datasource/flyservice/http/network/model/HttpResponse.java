package com.sclouds.datasource.flyservice.http.network.model;

public class HttpResponse<T> {

    public int Code;
    public String Msg;
    public T Data;

    public HttpResponse(int code, String msg) {
        this.Code = code;
        this.Msg = msg;
    }

    public HttpResponse() {

    }

    public boolean isSuccessful() {
        return 5000 == Code;
    }

}
