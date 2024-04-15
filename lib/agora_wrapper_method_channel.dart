import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'agora_wrapper_platform_interface.dart';

/// An implementation of [AgoraWrapperPlatform] that uses method channels.
class MethodChannelAgoraWrapper extends AgoraWrapperPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('agora_rtc_rawdata');

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
}
