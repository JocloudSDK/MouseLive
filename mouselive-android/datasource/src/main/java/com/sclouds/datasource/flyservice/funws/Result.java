package com.sclouds.datasource.flyservice.funws;

import android.util.Pair;

/**
 * @author xipeitao
 * @description:
 * @date : 2020-03-26 17:54
 */
public class Result<R,B> extends Pair<R,B> {

    /**
     * Constructor for a Pair.
     *
     * @param first  the first object in the Pair
     * @param second the second object in the pair
     */
    public Result(R first, B second) {
        super(first, second);
    }


}
