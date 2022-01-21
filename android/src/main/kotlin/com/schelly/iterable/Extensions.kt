package com.schelly.iterable

import android.graphics.Rect
import android.util.Log
import com.iterable.iterableapi.*
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.util.*
import com.google.gson.Gson
import com.google.gson.annotations.SerializedName

fun toIterableConfig(configMap: Map<*, *>): IterableConfig.Builder {
    val configBuilder = IterableConfig.Builder()

    val pushIntegrationName = configMap[PUSH_INTEGRATION_NAME] as? String
    val autoPushRegistration = configMap[AUTO_PUSH_REGISTRATION] as? Boolean ?: true
    val inAppDisplayInterval = configMap[INAPP_DISPLAY_INTERVAL] as? Double ?: 30.0
    val expiringAuthTokenRefreshPeriod = configMap[AUTH_TOKEN_REFRESH] as? Double ?: 60.0
    val logLevel = configMap[LOG_LEVEL] as? Int
    val allowedProtocols = configMap[ALLOWED_PROTOCOLS] as? List<String>

    if (!pushIntegrationName.isNullOrBlank()) {
        configBuilder.setPushIntegrationName(pushIntegrationName)
    }

    allowedProtocols?.let {
        configBuilder.setAllowedProtocols(it.toTypedArray());
    }

    configBuilder.setAutoPushRegistration(autoPushRegistration)
    configBuilder.setInAppDisplayInterval(inAppDisplayInterval)
    configBuilder.setExpiringAuthTokenRefreshPeriod(expiringAuthTokenRefreshPeriod.toLong())

    when (logLevel) {
        1 -> configBuilder.setLogLevel(Log.DEBUG)
        2 -> configBuilder.setLogLevel(Log.VERBOSE)
        3 -> configBuilder.setLogLevel(Log.ERROR)
        else -> configBuilder.setLogLevel(Log.ERROR)
    }

    return configBuilder
}

@Throws(JSONException::class)
fun JSONObject.toFriendlyMap(): MutableMap<String, Any?> {
    val map = mutableMapOf<String, Any?>()
    val iterator = keys()
    while (iterator.hasNext()) {
        val key = iterator.next()
        when (val value = this[key]) {
            is JSONObject -> {
                map[key] = value.toFriendlyMap()
            }
            is JSONArray -> {
                map[key] = value.toFriendlyList().toList()
            }
            else -> {
                map[key] = value
            }
        }
    }
    return map
}

@Throws(JSONException::class)
fun JSONArray.toFriendlyList(): MutableList<Any?> {
    val list = mutableListOf<Any?>()
    for (i in 0 until length()) {
        when (val value = this[i]) {
            is JSONObject -> {
                list.add(value.toFriendlyMap())
            }
            is JSONArray -> {
                list.add(value.toFriendlyList())
            }
            is Boolean, is Int, is Double, is String -> {
                list.add(value)
            }
            else -> {
                list.add(value.toString())
            }
        }
    }
    return list
}

fun commerceItemFromMap(itemMap: Map<*,*>): CommerceItem? {
    val id = (itemMap["id"] as? String) ?: return null
    val name = (itemMap["name"] as? String) ?: return null
    val price = (itemMap["price"] as? Double) ?: return null
    val quantity = (itemMap["quantity"] as? Int) ?: return null
    val sku = itemMap["sku"] as? String
    val description = itemMap["description"] as? String
    val url = itemMap["url"] as? String
    val imageUrl = itemMap["imageUrl"] as? String
    val categories = itemMap["categories"] as? List<String>
    val dataFields = itemMap["dataFields"] as? MutableMap<*, *>
    
    return CommerceItem(id,
                        name,
                        price,
                        quantity,
                        sku,
                        description,
                        url,
                        imageUrl,
                        categories?.toTypedArray(),
                        JSONObject(dataFields)
    );
}

private fun actionToMap(action: IterableAction): Map<String, Any> {
    val actionMap = mutableMapOf<String, String>()

    action.type?.let { type ->
        actionMap["type"] = type
    }
    action.data?.let { data ->
        actionMap["data"] = data
    }
    action.userInput?.let { userInput ->
        actionMap["userInput"] = userInput
    }

    return actionMap
}

fun actionContextToMap(actionContext: IterableActionContext): Map<String, Any> {
    var actionContextMap = mutableMapOf<String, Any>()

    actionContext.action.let { action ->
        actionContextMap["action"] = actionToMap(action)
    }
    actionContext.source.let { source ->
        actionContextMap["source"] = source.ordinal
    }

    return actionContextMap
}

fun customActionToMap(action: IterableAction, actionContext: IterableActionContext): Map<String, Any> {
    return mapOf("action" to actionToMap(action), "context" to actionContextToMap(actionContext))
}

private fun edgeInsetsToMap(edgeInsets: Rect): Map<String, Int> {
    val edgeInsetsMap = HashMap<String, Int>()

    edgeInsetsMap["top"] = edgeInsets.top
    edgeInsetsMap["left"] = edgeInsets.left
    edgeInsetsMap["bottom"] = edgeInsets.bottom
    edgeInsetsMap["right"] = edgeInsets.right

    return edgeInsetsMap
}

fun htmlContentToJsonString(content: IterableInAppMessage.Content): String {
    val contentMap = messageContentToMap(content)
    return Gson().toJson(contentMap)
}

fun messageContentToMap(content: IterableInAppMessage.Content): Map<*,*> {
    val messageContent = HashMap<String, Any>()

    messageContent["edgeInsets"] = edgeInsetsToMap(content.padding)
    messageContent["html"] = content.html

    return messageContent
}

private fun triggerTypeToInt(triggerType: String): Int {
    when (triggerType) {
        "immediate" -> return 0
        "event" -> return 1
        "never" -> return 2
        else -> return 0
    }
}

private fun trigggerMap(messageMap: Map<*,*>): Map<*,*> {
    var typeResult = 0
    (messageMap["trigger"] as? Map<*, *>)?.let { trigger ->
        (trigger["type"] as? String)?.let { type ->
            typeResult = triggerTypeToInt(type)
        }
    }
    return mapOf("type" to typeResult)
}

fun inAppMessageToMap(message: IterableInAppMessage): Map<*,*> {
    var messageMap = HashMap<String, Any?>()
    val internalMessage = FlutterInternalIterable.getInAppMessageJson(message).toFriendlyMap()

    messageMap.put("messageId", message.messageId)
    messageMap.put("campaignId", message.campaignId ?: 0)
    messageMap.put("content", messageContentToMap(message.content))
    messageMap.put("trigger", trigggerMap(internalMessage))
    messageMap.put("createdAt", internalMessage["createdAt"])
    messageMap.put("expiresAt", internalMessage["expiresAt"])
    messageMap.put("saveToInbox", internalMessage["saveToInbox"])
    messageMap.put("inboxMetadata", internalMessage["inboxMetadata"])
    messageMap.put("customPayload", message.customPayload.toFriendlyMap())
    messageMap.put("read", internalMessage["read"])
    messageMap.put("priorityLevel", message.priorityLevel)
    
    return messageMap
}

fun getIterableInAppLocationFromInteger(location: Int?): IterableInAppLocation? {
    if (location == null || location >= IterableInAppLocation.values().size || location < 0) {
        return null;
    } else {
        return IterableInAppLocation.values()[location];
    }
}

fun getIterableInAppCloseSourceFromInteger(source: Int?): IterableInAppCloseAction? {
    if (source == null || source >= IterableInAppCloseAction.values().size || source < 0) {
        return null;
    } else {
        return IterableInAppCloseAction.values()[source];
    }
}

fun getIterableDeleteActionTypeFromInteger(actionType: Int?): IterableInAppDeleteActionType? {
    if (actionType == null || actionType >= IterableInAppCloseAction.values().size || actionType < 0) {
        return null;
    } else {
        return IterableInAppDeleteActionType.values()[actionType];
    }
}

fun getInAppResponse(inAppResponseInteger: Int?): IterableInAppHandler.InAppResponse? {
    return if (inAppResponseInteger == null || inAppResponseInteger >= IterableInAppCloseAction.values().size || inAppResponseInteger < 0) {
        null
    } else {
        IterableInAppHandler.InAppResponse.values()[inAppResponseInteger]
    }
}