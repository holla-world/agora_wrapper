import 'agora_wrapper_platform_interface.dart';

class AgoraWrapper {
  Future<String?> getPlatformVersion() {
    return AgoraWrapperPlatform.instance.getPlatformVersion();
  }

  Future<void> registerAudioFrameObserver(int engineHandle) {
    return AgoraWrapperPlatform.instance
        .registerAudioFrameObserver(engineHandle);
  }

  Future<void> unregisterAudioFrameObserver() {
    return AgoraWrapperPlatform.instance.unregisterAudioFrameObserver();
  }

  Future<void> registerVideoFrameObserver(int engineHandle) {
    return AgoraWrapperPlatform.instance
        .registerVideoFrameObserver(engineHandle);
  }

  Future<void> unregisterVideoFrameObserver() {
    return AgoraWrapperPlatform.instance.unregisterVideoFrameObserver();
  }
}
