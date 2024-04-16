import 'agora_wrapper_platform_interface.dart';

class AgoraWrapper {
  static num uid = -1;
  static String? rtmToken;
  static String? appId;

  /// 用户登录成功后从业务接口获取
  static void login(num uid, String rtmToken, String appId) {
    AgoraWrapper.uid = uid;
    AgoraWrapper.rtmToken = rtmToken;
    AgoraWrapper.appId = appId;
    AgoraWrapperPlatform.instance.loginRtm();
  }

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

  Future<void> sendMessageChannel(String json) {
    return AgoraWrapperPlatform.instance.sendMessageChannel(json);
  }

  Future<void> exitRtm() {
    return AgoraWrapperPlatform.instance.exitRtm();
  }

  Future<void> leaveRtmChannel() {
    return AgoraWrapperPlatform.instance.leaveRtmChannel();
  }

  /// 原生返回
  /// 加入频道成功返回：{"result":true,"roomId":"$roomId"}
  /// 加入频道失败返回：{"result":false,"error":"$errorMsg"}
  ///
  Future<String?> joinRtmChannel(String roomId) {
    return AgoraWrapperPlatform.instance.joinRtmChannel(roomId);
  }
}
