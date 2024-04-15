package com.typing.agora_wrapper.agora_wrapper.adapter;

import java.util.List;

import io.agora.rtm.RtmChannelAttribute;
import io.agora.rtm.RtmChannelListener;
import io.agora.rtm.RtmChannelMember;
import io.agora.rtm.RtmMessage;

public class RtmChannelListenerAdapter implements RtmChannelListener {

    /**
     * 频道成员人数更新回调。返回最新频道成员人数。
     * @param i
     */
    @Override
    public void onMemberCountUpdated(int i) {

    }

    /**
     * 频道属性更新回调。返回所在频道的所有属性。
     * @param list
     */
    @Override
    public void onAttributesUpdated(List<RtmChannelAttribute> list) {

    }

    /**
     * 当远端用户调用 sendMessage 方法成功发送频道消息后，在相同频道的本地用户会收到此回调。
     */
    @Override
    public void onMessageReceived(RtmMessage rtmMessage, RtmChannelMember rtmChannelMember) {

    }

    /**
     * 远端用户加入频道回调。
     * 当有远端用户调用 join 方法成功加入频道时，在相同频道的本地用户会收到此回调。
     */
    @Override
    public void onMemberJoined(RtmChannelMember rtmChannelMember) {

    }

    /**
     * 频道成员离开频道回调。
     * 当有频道成员调用 leave 方法成功离开频道时，在相同频道的本地用户会收到此回调。
     */
    @Override
    public void onMemberLeft(RtmChannelMember rtmChannelMember) {

    }
}
