package com.typing.agora_wrapper.agora_wrapper

import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import android.util.Log
import com.typing.agora_wrapper.agora_wrapper.AgoraWrapper.agoraId
import com.typing.agora_wrapper.agora_wrapper.AgoraWrapper.application
import com.typing.agora_wrapper.agora_wrapper.AgoraWrapper.currentRtmToken
import com.typing.agora_wrapper.agora_wrapper.AgoraWrapper.currentUid
import com.typing.agora_wrapper.agora_wrapper.adapter.RtmChannelListenerAdapter
import com.typing.agora_wrapper.agora_wrapper.adapter.RtmClientListenerAdapter
import io.agora.rtm.ErrorInfo
import io.agora.rtm.ResultCallback
import io.agora.rtm.RtmChannel
import io.agora.rtm.RtmChannelMember
import io.agora.rtm.RtmMessage
import io.agora.rtm.jni.JOIN_CHANNEL_ERR
import io.agora.rtm.jni.LOGIN_ERR_CODE
import io.agora.rtm.jni.LOGOUT_ERR_CODE

class RtmHelper private constructor() {

    companion object {
        // 懒加载单例实例
        val instance: RtmHelper by lazy { RtmHelper() }
    }

    var rtmMsgReceiver: ((String) -> Unit)? = null

    private val rtmChannelListenerAdapter: RtmChannelListenerAdapter =
        object : RtmChannelListenerAdapter() {
            override fun onMessageReceived(
                rtmMessage: RtmMessage,
                rtmChannelMember: RtmChannelMember
            ) {
                super.onMessageReceived(rtmMessage, rtmChannelMember)
                gMainHandle.post {
                    Log.d("RtmChannelListener", rtmMessage.text)
                    rtmMsgReceiver?.invoke(rtmMessage.text)
                }
            }
        }
    private val mClientListener: RtmClientListenerAdapter = object : RtmClientListenerAdapter() {
        override fun onMessageReceived(rtmMessage: RtmMessage, peerId: String) {
            super.onMessageReceived(rtmMessage, peerId)
            gMainHandle.post {
                Log.d("RtmClientListener", rtmMessage.text)
                rtmMsgReceiver?.invoke(rtmMessage.text)
            }
        }
    }


    private val TAG = "RtmHelper"
    private var mChatManager: RtmChatManager? = null
    private var mRtmChannel: RtmChannel? = null
    private var loginRtmSuccess = false
    private var willJoinRoomId = "" //准备加入频道的信息，加入后或者退出频道， 置空
    private var tryNumWhenTimeout = 0 //超时重试次数
    private val gMainHandle = Handler(Looper.getMainLooper())
    val chatManager: RtmChatManager
        get() {
            if (mChatManager == null) {
                mChatManager = RtmChatManager(application)
                mChatManager?.init(agoraId)
            }
            return mChatManager!!
        }

    fun joinRtmChannel(roomId: String, callback: ResultCallback<String>) {
        tryNumWhenTimeout = 0
        willJoinRoomId = roomId
        joinRtmChannel(false, callback)
    }

    /**
     * 再来一次～～～
     * 声网的奇怪方案:
     * 加入频道超时异常，要退出再登录在来一次， 不然会导致后面的加入频道异常失败
     *
     * @param callback
     */
    private fun joinAgain(callback: ResultCallback<String>) {
        if (TextUtils.isEmpty(willJoinRoomId)) {
            infoReport("joinAgain willJoinRoomId null")
            return
        }
        gMainHandle.post {
            infoReport("再来一次 willJoinRoomId: $willJoinRoomId")
            joinRtmChannel(true, callback)
        }
    }

    private fun joinRtmChannel(forceLeaveChannel: Boolean, callback: ResultCallback<String>) {
        if (TextUtils.isEmpty(willJoinRoomId)) {
            infoReport("joinRtmChannel willJoinRoomId null")
            return
        }
        if (!loginRtmSuccess) {
            infoReport("login roomId : $willJoinRoomId, forceLeaveChannel: $forceLeaveChannel")
            val userId = currentUid
            val rtmToken = currentRtmToken
            chatManager.login(userId.toString(), rtmToken, object : ResultCallback<Void?> {
                override fun onSuccess(unused: Void?) {
                    loginRtmSuccess = true
                    infoReport("login onSuccess")
                    joinChannel(willJoinRoomId, forceLeaveChannel, callback)
                }

                override fun onFailure(errorInfo: ErrorInfo) {
                    loginRtmSuccess = false
                    errorReport("login onFailure (" + errorInfo.errorCode + ") error: " + errorInfo.errorDescription + ",userId=" + userId + ",rtmToken=" + rtmToken)
                    tryWhenTimeOut(errorInfo, callback)
                }
            })
        } else {
            joinChannel(willJoinRoomId, forceLeaveChannel, callback)
        }
    }

    private fun joinChannel(
        roomId: String,
        forceLeaveChannel: Boolean,
        callback: ResultCallback<String>
    ) {
        if (mRtmChannel != null) {
            val id = mRtmChannel?.id
            if (roomId == id && !forceLeaveChannel) {
                return
            }
            leave()
        }
        val rtmClient = chatManager.rtmClient
        if (rtmClient == null) {
            errorReport("join channel onFailure: rtmClient == null")
            return
        }
        mRtmChannel = rtmClient.createChannel(roomId, rtmChannelListenerAdapter)
        if (mRtmChannel == null) {
            errorReport("join channel onFailure: mRtmChannel == null")
            return
        }
        infoReport("joinChannel roomId : $roomId, forceLeaveChannel: $forceLeaveChannel")
        mRtmChannel?.join(object : ResultCallback<Void?> {
            override fun onSuccess(responseInfo: Void?) {
                infoReport("join channel success")
                willJoinRoomId = ""
                callback.onSuccess(roomId)
                // 监听点对点消息
                chatManager.registerListener(mClientListener)
            }

            override fun onFailure(errorInfo: ErrorInfo) {
                if (errorInfo.errorCode == JOIN_CHANNEL_ERR.JOIN_CHANNEL_ERR_ALREADY_JOINED.swigValue()) {
                    infoReport("channel already joined")
                    willJoinRoomId = ""
                    callback.onSuccess(roomId)
                    // 监听点对点消息
                    chatManager.registerListener(mClientListener)
                } else {
                    errorReport("join channel onFailure (" + errorInfo.errorCode + ") error: " + errorInfo.errorDescription)
                    tryWhenTimeOut(errorInfo, callback)
                }
            }
        })
    }

    /**
     * 尝试超时重试
     *
     * @param errorInfo
     * @param callback
     */
    private fun tryWhenTimeOut(errorInfo: ErrorInfo, callback: ResultCallback<String>) {
        infoReport("检查是否尝试超时重试 willJoinRoomId:$willJoinRoomId, 重试次数：$tryNumWhenTimeout")
        if (tryNumWhenTimeout < 1 && !TextUtils.isEmpty(willJoinRoomId)) {
            if (errorInfo.errorCode == JOIN_CHANNEL_ERR.JOIN_CHANNEL_ERR_USER_NOT_LOGGED_IN.swigValue()) {
                //加入频道时未登录， 直接重新登录->加入频道
                ++tryNumWhenTimeout
                infoReport("登录超时失败 => 重试 willJoinRoomId:$willJoinRoomId, 重试次数：$tryNumWhenTimeout")
                joinAgain(callback)
                return
            } else if (errorInfo.errorCode == JOIN_CHANNEL_ERR.JOIN_CHANNEL_TIMEOUT.swigValue()
                || errorInfo.errorCode == LOGIN_ERR_CODE.LOGIN_ERR_TIMEOUT.swigValue()
            ) {
                //当加入频道超时失败、登录超时， 按声网的方案，先 logout->再登录->加入频道
                ++tryNumWhenTimeout
                infoReport("加入频道超时失败 => 重试 willJoinRoomId:$willJoinRoomId, 重试次数：$tryNumWhenTimeout")
                gMainHandle.post { exitRtm(true, callback) }
                return
            }
        }
        willJoinRoomId = ""
        callback.onFailure(errorInfo)
    }

    fun leave() {
        // 离开频道
        willJoinRoomId = ""
        mRtmChannel?.leave(object : ResultCallback<Void?> {
            override fun onSuccess(aVoid: Void?) {
                chatManager.unregisterListener()
                infoReport("离开频道 onSuccess")
            }

            override fun onFailure(errorInfo: ErrorInfo) {
                errorReport("离开频道 onFailure (" + errorInfo.errorCode + ") error: " + errorInfo.errorDescription)
            }
        })
        mRtmChannel?.release()
        mRtmChannel = null
    }

    fun exitRtm() {
        exitRtm(false, null)
    }

    /**
     * 退出登录
     *
     * @param loginAgain 退出登录后重新再登录
     */
    private fun exitRtm(loginAgain: Boolean, callback: ResultCallback<String>?) {
        rtmMsgReceiver = null
        loginRtmSuccess = false
        if (!loginAgain) {
            willJoinRoomId = ""
        }
        chatManager.exitRtm(object : ResultCallback<Void?> {
            override fun onSuccess(aVoid: Void?) {
                infoReport("退出RTM onSuccess")
                if (loginAgain && callback != null) {
                    //退出后重新登录了exitRtm
                    joinAgain(callback)
                }
            }

            override fun onFailure(errorInfo: ErrorInfo) {
                errorReport("退出RTM onFailure (" + errorInfo.errorCode + ") error: " + errorInfo.errorDescription)
                if (loginAgain && callback != null && errorInfo.errorCode == LOGOUT_ERR_CODE.LOGOUT_ERR_USER_NOT_LOGGED_IN.swigValue()) {
                    //本身不在登录的，导致退出失败， 直接重新登录了
                    joinAgain(callback)
                }
            }
        })
    }

    private fun infoReport(msg: String) {
        Log.i(TAG, msg)
    }

    private fun errorReport(msg: String) {
        Log.e(TAG, msg)
    }

    fun sendChannelMessage(json: String, callback: ResultCallback<Void>) {
        val message = mChatManager?.rtmClient?.createMessage()
        message?.text = json
        mRtmChannel?.sendMessage(message, callback)
    }

}