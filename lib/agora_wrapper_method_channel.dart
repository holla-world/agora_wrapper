import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'agora_wrapper_platform_interface.dart';

/// An implementation of [AgoraWrapperPlatform] that uses method channels.
class MethodChannelAgoraWrapper extends AgoraWrapperPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('agora_wrapper');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
