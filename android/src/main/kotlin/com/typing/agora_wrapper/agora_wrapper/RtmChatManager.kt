package com.typing.agora_wrapper.agora_wrapper

import android.content.Context
import android.util.Log
import com.typing.agora_wrapper.agora_wrapper.adapter.RtmClientListenerAdapter
import io.agora.rtm.ErrorInfo
import io.agora.rtm.ResultCallback
import io.agora.rtm.RtmClient
import io.agora.rtm.RtmClientListener
import io.agora.rtm.RtmMessage
import io.agora.rtm.SendMessageOptions
import io.flutter.BuildConfig

class RtmChatManager(private val mContext: Context) {
    var rtmClient: RtmClient? = null
    var sendMessageOptions: SendMessageOptions? = null
        private set
    var listener: RtmClientListener? = null

    private val mMessagePool = RtmMessagePool()

    fun init(key: String) {
        try {
            rtmClient = RtmClient.createInstance(
                mContext,
                key,
                object : RtmClientListenerAdapter() {
                    override fun onConnectionStateChanged(state: Int, reason: Int) {
                        listener?.onConnectionStateChanged(state, reason)
                        // SDK 与 Agora RTM 系统的连接状态发生改变回调。
                        Log.e(TAG, "onConnectionStateChanged state:$state - reason:$reason")
                    }

                    override fun onMessageReceived(rtmMessage: RtmMessage, peerId: String) {
                        if (rtmMessage.isOfflineMessage || listener == null) {
                            // If currently there is no callback to handle this
                            // message, this message is unread yet. Here we also
                            // take it as an offline message.
                            mMessagePool.insertOfflineMessage(rtmMessage, peerId)
                        } else {
                            listener?.onMessageReceived(rtmMessage, peerId)
                        }
                    }

                    override fun onTokenExpired() {
                        listener?.onTokenExpired()
                    }

                    override fun onPeersOnlineStatusChanged(map: Map<String, Int>) {
                        listener?.onPeersOnlineStatusChanged(map)
                    }
                })
            if (BuildConfig.DEBUG) {
                rtmClient?.setParameters("{\"rtm.log_filter\": 65535}")
            }
            val result = rtmClient?.setLogFilter(RtmClient.LOG_FILTER_OFF)
            //            String logPath = XLogProxy.getRtmLogPath(0);
//            mRtmClient.setLogFile(logPath);
//            Log.i(TAG, "日志文件路径,rtm => " + logPath);
            Log.i(TAG, "rtmClient.setLogFilter(),result:$result")
        } catch (e: Exception) {
            Log.e(TAG, Log.getStackTraceString(e))
            throw RuntimeException(
                "NEED TO check rtm sdk init fatal error ${
                    Log.getStackTraceString(
                        e
                    )
                }".trimIndent()
            )
        }

        // Global option, mainly used to determine whether
        // to support offline messages now.
        sendMessageOptions = SendMessageOptions()
    }

    fun login(userId: String?, token: String?, resultCallback: ResultCallback<Void?>) {
        if (rtmClient == null) return
        rtmClient!!.login(token, userId, object : ResultCallback<Void?> {
            override fun onSuccess(responseInfo: Void?) {
                Log.i(TAG, "login success")
                resultCallback.onSuccess(responseInfo)
            }

            override fun onFailure(errorInfo: ErrorInfo) {
                Log.i(TAG, "login failed: " + errorInfo.errorCode)
                resultCallback.onFailure(errorInfo)
            }
        })
    }

    // 退出RTM
    fun exitRtm(resultCallback: ResultCallback<Void?>?) {
        if (rtmClient == null) return
        rtmClient!!.logout(resultCallback)
    }

    fun registerListener(listener: RtmClientListener?) {
        if (listener != null) {
            this.listener = listener
        }
    }

    fun unregisterListener() {
        listener = null
    }

    fun getAllOfflineMessages(peerId: String?): List<RtmMessage> {
        return mMessagePool.getAllOfflineMessages(peerId)
    }

    fun removeAllOfflineMessages(peerId: String?) {
        mMessagePool.removeAllOfflineMessages(peerId)
    }

    companion object {
        private const val TAG = "RtmChatManager"
    }
}