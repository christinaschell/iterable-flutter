package com.schelly.example

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.iterable.iterableapi.IterableApi
import com.iterable.iterableapi.IterableHelper
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
        val action: String? = intent?.action
        val data: Uri? = intent?.data
        Log.d("Iterable Deep Links", "action: " + action + "data: " + data)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent) {
        IterableApi.getInstance().getAndTrackDeepLink(
            intent.data.toString()
        ) { result ->
            IterableApi.getInstance().handleAppLink(intent.data.toString())
            Log.d("HandleDeeplink", "Redirected to: $result")
        }
    }
}
