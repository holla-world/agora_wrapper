package com.typing.agora_wrapper.agora_wrapper_example

import android.content.Context
import androidx.multidex.MultiDex
import io.agora.rtm.internal.RtmManager
import io.flutter.app.FlutterApplication

/**
 * @author bezier
 * @date 2024/3/18 16:00
 * @version 1.0
 * @description:
 */
class TestApplication : FlutterApplication() {

    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        MultiDex.install(base)
    }

}