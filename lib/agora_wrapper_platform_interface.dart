import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'agora_wrapper_method_channel.dart';

abstract class AgoraWrapperPlatform extends PlatformInterface {
  /// Constructs a AgoraWrapperPlatform.
  AgoraWrapperPlatform() : super(token: _token);

  static final Object _token = Object();

  static AgoraWrapperPlatform _instance = MethodChannelAgoraWrapper();

  /// The default instance of [AgoraWrapperPlatform] to use.
  ///
  /// Defaults to [MethodChannelAgoraWrapper].
  static AgoraWrapperPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AgoraWrapperPlatform] when
  /// they register themselves.
  static set instance(AgoraWrapperPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> registerAudioFrameObserver(int engineHandle) {
    throw UnimplementedError('registerAudioFrameObserver() has not been implemented.');
  }

  Future<void> unregisterAudioFrameObserver() {
    throw UnimplementedError('unregisterAudioFrameObserver() has not been implemented.');
  }

  Future<void> registerVideoFrameObserver(int engineHandle) {
    throw UnimplementedError('registerVideoFrameObserver() has not been implemented.');
  }

  Future<void> unregisterVideoFrameObserver() {
    throw UnimplementedError('unregisterVideoFrameObserver() has not been implemented.');
  }
}
