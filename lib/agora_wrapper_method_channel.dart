import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'agora_wrapper.dart';
import 'agora_wrapper_platform_interface.dart';

/// An implementation of [AgoraWrapperPlatform] that uses method channels.
class MethodChannelAgoraWrapper extends AgoraWrapperPlatform {
  /// The method channel used to interact with the native platform.
  final methodChannel = const MethodChannel('agora_rawdata');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> registerAudioFrameObserver(int engineHandle) {
    return methodChannel.invokeMethod(
        'registerAudioFrameObserver', engineHandle);
  }

  @override
  Future<void> unregisterAudioFrameObserver() {
    return methodChannel.invokeMethod('unregisterAudioFrameObserver');
  }

  @override
  Future<void> registerVideoFrameObserver(int engineHandle) {
    return methodChannel.invokeMethod(
        'registerVideoFrameObserver', engineHandle);
  }

  @override
  Future<void> unregisterVideoFrameObserver() {
    return methodChannel.invokeMethod('unregisterVideoFrameObserver');
  }

  @override
  Future<void> sendMessageChannel(String json) {
    return methodChannel.invokeMethod('unregisterVideoFrameObserver');
  }

  @override
  Future<void> exitRtm() {
    return methodChannel.invokeMethod('exitRtm');
  }

  @override
  Future<void> leaveRtmChannel() {
    return methodChannel.invokeMethod('leaveRtmChannel');
  }

  @override
  Future<String?> joinRtmChannel(String roomId) {
    Map<String, dynamic> map = {'roomId': roomId};
    return methodChannel.invokeMethod('joinRtmChannel', map);
  }

  @override
  Future<void> loginRtm() {
    Map<String, dynamic> map = {
      'agoraId': AgoraWrapper.appId,
      'uid': AgoraWrapper.uid,
      'rtmToken': AgoraWrapper.rtmToken,
    };
    return methodChannel.invokeMethod('loginRtm', map);
  }
}
