import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import 'agora_wrapper.dart';

/// @author FanXiuMing
/// @date 2024/4/15 16:16
/// @version
/// @description ()
class RtcManager {
  late AgoraWrapper wrapper;

  /// Currently, the Agora RTC SDK v6.x supports creating only one RtcEngine object for each app.
  RtcEngine globalEngine = createAgoraRtcEngine();

  RtcManager._privateConstructor() {
    wrapper = AgoraWrapper();
  }

  static final RtcManager _instance = RtcManager._privateConstructor();

  static RtcManager get instance => _instance;

  /// 必须在WidgetsFlutterBinding.ensureInitialized();之后执行
  void initEngine(String appId) async {
    await globalEngine.initialize(RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
  }

  Future<void> initRtc(RtcEngineEventHandler handler) async {
    globalEngine.registerEventHandler(handler);
    await globalEngine.enableVideo();
    await globalEngine.startPreview();
    await globalEngine.muteLocalAudioStream(true);
    await globalEngine.muteAllRemoteAudioStreams(true);
  }

  /// 加入频道
  Future<void> joinChannel({
    required String token,
    required String channelId,
    required int uid,
    required ChannelMediaOptions options,
  }) async {
    await globalEngine.joinChannel(
      token: token,
      channelId: channelId,
      uid: uid,
      options: options,
    );
  }

  Future<void> registerFrameObserver() async {
    await globalEngine.setRecordingAudioFrameParameters(
        sampleRate: 48000,
        channel: 2,
        mode: RawAudioFrameOpModeType.rawAudioFrameOpModeReadOnly,
        samplesPerCall: 1024);
    var handle = await globalEngine.getNativeHandle();
    await wrapper.registerAudioFrameObserver(handle);
    await wrapper.registerVideoFrameObserver(handle);
  }

  Future<void> unRegisterFrameObserver() async {
    await wrapper.unregisterAudioFrameObserver();
    await wrapper.unregisterVideoFrameObserver();
    await release();
  }

  Future<void> release() async {
    await globalEngine.release();
  }
}
