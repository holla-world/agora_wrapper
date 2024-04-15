import 'package:flutter_test/flutter_test.dart';
import 'package:agora_wrapper/agora_wrapper.dart';
import 'package:agora_wrapper/agora_wrapper_platform_interface.dart';
import 'package:agora_wrapper/agora_wrapper_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAgoraWrapperPlatform
    with MockPlatformInterfaceMixin
    implements AgoraWrapperPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> registerAudioFrameObserver(int engineHandle) {
    // TODO: implement registerAudioFrameObserver
    throw UnimplementedError();
  }

  @override
  Future<void> registerVideoFrameObserver(int engineHandle) {
    // TODO: implement registerVideoFrameObserver
    throw UnimplementedError();
  }

  @override
  Future<void> unregisterAudioFrameObserver() {
    // TODO: implement unregisterAudioFrameObserver
    throw UnimplementedError();
  }

  @override
  Future<void> unregisterVideoFrameObserver() {
    // TODO: implement unregisterVideoFrameObserver
    throw UnimplementedError();
  }
}

void main() {
  final AgoraWrapperPlatform initialPlatform = AgoraWrapperPlatform.instance;

  test('$MethodChannelAgoraWrapper is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAgoraWrapper>());
  });

  test('getPlatformVersion', () async {
    AgoraWrapper agoraWrapperPlugin = AgoraWrapper();
    MockAgoraWrapperPlatform fakePlatform = MockAgoraWrapperPlatform();
    AgoraWrapperPlatform.instance = fakePlatform;

    expect(await agoraWrapperPlugin.getPlatformVersion(), '42');
  });
}
