import 'agora_wrapper.dart';

/// @author FanXiuMing
/// @date 2024/4/15 16:16
/// @version
/// @description ()
class RtcManager {
  late AgoraWrapper wrapper;

  RtcManager._privateConstructor() {
    wrapper = AgoraWrapper();
  }

  static final RtcManager _instance = RtcManager._privateConstructor();

  static RtcManager get instance => _instance;
}
