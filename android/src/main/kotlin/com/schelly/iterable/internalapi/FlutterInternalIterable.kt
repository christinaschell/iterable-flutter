package com.iterable.iterableapi

import com.iterable.iterableapi.IterableInAppHandler.InAppResponse
import org.json.JSONObject

class FlutterInternalIterable {

    companion object {

        fun getEmail(): String? {
            return IterableApi.getInstance().getEmail()
        }

        fun getUserId(): String? {
            return IterableApi.getInstance().getUserId()
        }

        fun getInAppMessageJson(message: IterableInAppMessage): JSONObject {
            return message.toJSONObject()
        }

        fun getMessageById(messageId: String?): IterableInAppMessage? {
            return IterableApi.getInstance().inAppManager.getMessageById(messageId)
        }

        fun setAttributionInfo(attributionInfo: IterableAttributionInfo) {
            IterableApi.getInstance().setAttributionInfo(attributionInfo)
        }

        fun trackPushOpenWithCampaignId(
            campaignId: Int,
            templateId: Int,
            messageId: String,
            dataFields: JSONObject?
        ) {
            IterableApi.getInstance().trackPushOpen(
                campaignId, templateId,
                messageId, dataFields
            )
        }

        fun trackInAppClose(messageId: String, clickedUrl: String, source: IterableInAppCloseAction, location: IterableInAppLocation) {
            IterableApi.getInstance().trackInAppClose(messageId, clickedUrl, source, location)
        }

    }

}