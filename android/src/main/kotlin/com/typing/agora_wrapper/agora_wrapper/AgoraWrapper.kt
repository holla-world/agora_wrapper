package com.typing.agora_wrapper.agora_wrapper

import android.app.Application
import android.content.Context
import android.util.ArrayMap
import android.util.Log
import androidx.annotation.NonNull
import com.google.gson.Gson
import io.agora.rtm.ErrorInfo
import io.agora.rtm.ResultCallback
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * @author bezier
 * @date 2024/4/15 18:05
 * @version 1.0
 * @description:
 */
object AgoraWrapper {


    private var INSTANCE: Application? = null

    @JvmStatic
    val application: Application
        get() {
            if (null == INSTANCE) {
                Log.e("AgoraWrapper", "CCApplication is null")
            }
            return INSTANCE!!
        }

    fun init(context: Context, rtmMsgReceiver: ((String) -> Unit)?) {
        if (context is Application) {
            INSTANCE = context
            RtmHelper.instance.rtmMsgReceiver = rtmMsgReceiver
        } else {
            throw Exception("AgoraWrapper init error,context must be application")
        }
    }

    /**
     * 记录当前用户uid
     */
    @JvmStatic
    var currentUid: Long = -1

    /**
     * 当前用户rtmToken
     */
    @JvmStatic
    var currentRtmToken: String = ""

    @JvmStatic
    var agoraId: String = ""

    fun onMethodCall(
        @NonNull call: MethodCall,
        @NonNull result: MethodChannel.Result
    ): Boolean {
        when (call.method) {
            "loginRtm" -> {
                val uid = call.argument<Int>("uid")?.toLong() ?: return false
                val rtmToken = call.argument<String>("rtmToken") ?: return false
                val agoraId = call.argument<String>("agoraId") ?: return false
                if (uid != currentUid) {
                    currentUid = uid
                }
                if (rtmToken != currentRtmToken) {
                    currentRtmToken = rtmToken
                }
                this.agoraId = agoraId
            }

            "joinRtmChannel" -> {
                val roomId = call.argument<String>("roomId") ?: return false
                RtmHelper.instance.joinRtmChannel(roomId, object : ResultCallback<String> {
                    override fun onSuccess(roomId: String?) {
                        val map = ArrayMap<String, Any>()
                        map["result"] = true
                        map["roomId"] = roomId
                        result.success(Gson().toJson(map))
                        Log.i(AgoraWrapperPlugin.TAG, "成功加入频道${roomId}")
                    }

                    override fun onFailure(errorInfo: ErrorInfo?) {
                        val map = ArrayMap<String, Any>()
                        map["result"] = false
                        val error = "joinChannel error=>${errorInfo}"
                        map["error"] = error
                        result.success(Gson().toJson(map))
                        Log.i(AgoraWrapperPlugin.TAG, "加入频道失败${error}")
                    }
                })
            }

            "leaveRtmChannel" -> {
                RtmHelper.instance.leave()
            }

            "exitRtm" -> {
                currentUid = -1
                currentRtmToken = ""
                RtmHelper.instance.exitRtm()
            }

            "sendMessageChannel" -> {
                val json = call.argument<String>("json") ?: return false
                RtmHelper.instance.sendChannelMessage(json, object : ResultCallback<Void> {
                    override fun onSuccess(p0: Void?) {
                        Log.d(AgoraWrapperPlugin.TAG, "sendMessageChannel success")
                    }

                    override fun onFailure(p0: ErrorInfo?) {
                        Log.d(AgoraWrapperPlugin.TAG, "sendMessageChannel error=>$p0")
                    }
                })
            }

            else -> return false
        }
        return true
    }


//    fun getRtcEventHandler(): RtcEngineEventHandlerProxy? {
//        return mRtcEventHandler
//    }


}