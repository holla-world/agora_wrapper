package com.typing.agora_wrapper.agora_wrapper

import android.util.Log
import androidx.annotation.NonNull
import com.typing.agora_wrapper.agora_wrapper.faceunity_plugin.FaceunityPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.StandardMessageCodec

/** AgoraWrapperPlugin */
class AgoraWrapperPlugin : FaceunityPlugin() {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var agoraChannel: MethodChannel
    private lateinit var messageChannel: BasicMessageChannel<Any>


    private lateinit var rtcObserverManager: RtcObserverManager

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        super.onAttachedToEngine(flutterPluginBinding)
        agoraChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "agora_rtc_rawdata")
        agoraChannel.setMethodCallHandler(this)

        val applicationContext = flutterPluginBinding.applicationContext
        messageChannel = BasicMessageChannel(
            flutterPluginBinding.binaryMessenger,
            "rtm_receiver_channel",
            StandardMessageCodec.INSTANCE
        )
        AgoraWrapper.init(applicationContext, rtmMsgReceiver = {
            Log.e(TAG, "准备推送rtm发送消息给flutter$it")
            if (this::messageChannel.isInitialized) {
                messageChannel.send(it)
                Log.e(TAG, "推送rtm发送消息给flutter$it")
            } else {
                Log.e(TAG, "messageChannel 未初始化,rtmMsg = $it")
            }
        })
        if (!this::rtcObserverManager.isInitialized) {
            rtcObserverManager = RtcObserverManager()
        } else {
            rtcObserverManager.reload()
        }


    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val rtcResolveResult = rtcObserverManager.onMethodCall(call, result)
        if (rtcResolveResult) return
        val rtmResolveResult = AgoraWrapper.onMethodCall(call, result)
        if (rtmResolveResult) return
        super.onMethodCall(call, result)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        super.onDetachedFromEngine(binding)
        agoraChannel.setMethodCallHandler(null)
        rtcObserverManager.onDetachedFromEngine(binding)
    }

    companion object {
        // Used to load the 'native-lib' library on application startup.
        init {
            System.loadLibrary("cpp")
        }

        const val TAG = "AgoraRawdataPlugin"
    }
}
