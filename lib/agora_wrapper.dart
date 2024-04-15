
import 'agora_wrapper_platform_interface.dart';

class AgoraWrapper {
  Future<String?> getPlatformVersion() {
    return AgoraWrapperPlatform.instance.getPlatformVersion();
  }
}
