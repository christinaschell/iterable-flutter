package com.iterable.iterableapi

public class FlutterInternalIterable {

    companion object {

        public fun getEmail(): String? {
            return IterableApi.getInstance().getEmail();
        }

        public fun getUserId(): String? {
            return IterableApi.getInstance().getUserId();
        }

        public fun setAttributionInfo(attributionInfo: IterableAttributionInfo) {
            IterableApi.getInstance().setAttributionInfo(attributionInfo);
        }

    }

}