package com.schelly.iterable

import android.util.Log;
import android.app.Application
import androidx.annotation.Nullable;
import com.iterable.iterableapi.*
import java.util.*
// import com.iterable.iterableapi.CommerceItem;
// import com.iterable.iterableapi.IterableAction;
// import com.iterable.iterableapi.IterableActionContext;
// import com.iterable.iterableapi.IterableConfig;
// import com.iterable.iterableapi.IterableInAppCloseAction;
// import com.iterable.iterableapi.IterableInAppDeleteActionType;
// import com.iterable.iterableapi.IterableInAppHandler;
// import com.iterable.iterableapi.IterableInAppLocation;
// import com.iterable.iterableapi.IterableInAppMessage;
// import com.iterable.iterableapi.IterableLogger;

import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

// import java.util.ArrayList;
// import java.util.Iterator;
// import java.util.List;

private fun missingRequiredProperty(name: String) {
    Log.d(BuildConfig.TAG, "Missing required property: $name")
}

fun toIterableConfig(configMap: Map<*, *>): IterableConfig.Builder {
    val configBuilder = IterableConfig.Builder()

    val pushIntegrationName = configMap[PUSH_INTEGRATION_NAME] as? String
    val autoPushRegistration = configMap[AUTO_PUSH_REGISTRATION] as? Boolean ?: true
    val inAppDisplayInterval = configMap[INAPP_DISPLAY_INTERVAL] as? Double ?: 30.0
    val logLevel = configMap[LOG_LEVEL] as? Int

    if (!pushIntegrationName.isNullOrBlank()) {
        configBuilder.setPushIntegrationName(pushIntegrationName)
    }

    configBuilder.setAutoPushRegistration(autoPushRegistration)
    configBuilder.setInAppDisplayInterval(inAppDisplayInterval)

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
    val id = (itemMap["id"] as? String).let { it } ?: return null
    val name = (itemMap["name"] as? String).let { it } ?: return null
    val price = (itemMap["price"] as? Double).let { it } ?: return null
    val quantity = (itemMap["quantity"] as? Int).let { it } ?: return null
    val sku = itemMap["sku"] as? String
    val description = itemMap["description"] as? String
    val url = itemMap["url"] as? String
    val imageUrl = itemMap["imageUrl"] as? String
    val categories = itemMap["categories"] as? List<String>
    val dataFields = itemMap["dataFields"] as? Map<*,*>
    
    Log.d(BuildConfig.TAG, "categories: $categories")

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