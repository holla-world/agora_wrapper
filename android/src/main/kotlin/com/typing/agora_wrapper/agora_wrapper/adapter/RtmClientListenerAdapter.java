package com.typing.agora_wrapper.agora_wrapper.adapter;

import java.util.Map;

import io.agora.rtm.RtmClientListener;
import io.agora.rtm.RtmMessage;

public class RtmClientListenerAdapter implements RtmClientListener {
    /**
     * SDK 与 Agora RTM 系统的连接状态发生改变回调。
     */
    /*
     *  1 -> CONNECTION_STATE_DISCONNECTED
     *          初始状态。SDK 未连接到 Agora RTM 系统。App 调用方法 loginAndJoinChannel 时，SDK 开始登录 Agora RTM 系统，
     *          触发回调 onConnectionStateChanged，并切换到 CONNECTION_STATE_CONNECTING 状态。
     *  2 -> CONNECTION_STATE_CONNECTING
     *          SDK 正在登录 Agora RTM 系统。
     *  3 -> CONNECTION_STATE_CONNECTED
     *          SDK 已登录 Agora RTM 系统。
     *  4 -> CONNECTION_STATE_RECONNECTING
     *          SDK 与 Agora RTM 系统连接由于网络原因出现中断，SDK 正在尝试自动重连 Agora RTM 系统。
     *          (如果 SDK 重新登录 Agora RTM 系统成功，会触发回调 onConnectionStateChanged，并切换到 CONNECTION_STATE_CONNECTED 状态。
     *                  SDK 会自动加入中断时用户所在频道，并自动将本地用户属性同步到服务端。
     *           如果 SDK 重新登录 Agora RTM 系统失败，会保持 CONNECTION_STATE_RECONNECTING 状态。)
     *  5 -> CONNECTION_STATE_ABORTED
     *          SDK 停止登录 Agora RTM 系统。
     *          可能原因：另一实例已经以同一用户 ID 登录 Agora RTM 系统。
     *          请在调用方法 logout 后，视情况调用方法 loginAndJoinChannel 重新登录 Agora RTM 系统。
     */
    @Override
    public void onConnectionStateChanged(int state, int reason) {

    }

    /**
     * 收到点对点消息回调。
     */
    @Override
    public void onMessageReceived(RtmMessage rtmMessage, String peerId) {

    }


    /**
     * 当前使用的 RTM Token 已超过 24 小时的签发有效期。
     * 该回调在 Token 签发有效期过期时触发。收到该回调时，
     * 请尽快在你的业务服务端生成新的 Token 并调用 renewToken 方法把新的 Token 传给 Token 验证服务器。
     */
    @Override
    public void onTokenExpired() {

    }

    @Override
    public void onTokenPrivilegeWillExpire() {

    }

    /**
     * 被订阅用户在线状态改变回调。
     *
     * 首次订阅在线状态成功时，SDK 也会返回本回调，显示所有被订阅用户的在线状态。
     * 每当被订阅用户的在线状态发生改变，SDK 都会通过该回调通知订阅方。
     * 如果 SDK 在断线重连过程中有被订阅用户的在线状态发生改变，SDK 会在重连成功时通过该回调通知订阅方。
     */
    @Override
    public void onPeersOnlineStatusChanged(Map<String, Integer> map) {

    }

}
