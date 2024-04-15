import 'package:flutter/services.dart';

import 'agora_wrapper.dart';

/// @author FanXiuMing
/// @date 2024/4/15 17:19
/// @version
/// @description ()
class RtmManager {
  final BasicMessageChannel messageChannel =
      const BasicMessageChannel('rtm_receiver_channel', StandardMessageCodec());

  late AgoraWrapper wrapper;

  RtmManager._privateConstructor() {
    // 初始化rtc
    wrapper = AgoraWrapper();
    messageChannel.setMessageHandler((message) async {
      print('接收rtm消息：message=$message');
      return null;
    });
  }

  static final RtmManager _instance = RtmManager._privateConstructor();

  static RtmManager get instance => _instance;
}
