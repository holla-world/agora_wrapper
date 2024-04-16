import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_wrapper/agora_wrapper.dart';
import 'package:agora_wrapper/rtm_manager.dart';
import 'package:agora_wrapper_example/config/agora.config.dart' as config;
import 'package:faceunity_ui_flutter/faceunity_ui_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'config/agora.config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late RtcEngine engine;
  bool startPreview = false, isJoined = false;
  List<int> remoteUid = [];

  late AgoraWrapper _agoraWrapper;

  @override
  void initState() {
    super.initState();
    AgoraWrapper.login(
      config.uid,
      config.rtmToken,
      config.appId,
    );
    _initEngine();
    _agoraWrapper = AgoraWrapper();
    // 加入rtm
    RtmManager.instance.wrapper.joinRtmChannel(channelId);
  }

  @override
  void dispose() {
    super.dispose();
    _deinitEngine();
  }

  _initEngine() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.microphone, Permission.camera].request();
    }

    engine = createAgoraRtcEngine();
    await engine.initialize(const RtcEngineContext(
        appId: config.appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting));

    engine.registerEventHandler(
      RtcEngineEventHandler(onJoinChannelSuccess:
          (RtcConnection connection, int elapsed) {
        log('[$runtimeType]=>onJoinChannelSuccess connection: ${connection.toJson()} elapsed: $elapsed');
        setState(() {
          isJoined = true;
        });
      }, onUserJoined: (RtcConnection connection, int rUid, int elapsed) {
        log('[$runtimeType]=>onUserJoined connection: ${connection.toJson()} remoteUid: $rUid elapsed: $elapsed');
        setState(() {
          remoteUid.add(rUid);
        });
      }, onUserOffline:
          (RtcConnection connection, int rUid, UserOfflineReasonType reason) {
        log('[$runtimeType]=>onUserOffline connection: ${connection.toJson()} remoteUid: $rUid reason: $reason');
        setState(() {
          remoteUid.remove(rUid);
        });
      }),
    );
    await engine.enableVideo();
    await engine.startPreview();
    await engine.muteLocalAudioStream(true);
    await engine.muteAllRemoteAudioStreams(true);
    setState(() {
      startPreview = true;
    });

    log('[$runtimeType]=>joinChannel ,token=${config.token},channelId=${config.channelId},uid=${config.uid}');
    await engine.joinChannel(
        token: config.token,
        channelId: config.channelId,
        uid: config.uid,
        options: const ChannelMediaOptions(
            clientRoleType: ClientRoleType.clientRoleBroadcaster));
    await engine.setRecordingAudioFrameParameters(
        sampleRate: 48000,
        channel: 2,
        mode: RawAudioFrameOpModeType.rawAudioFrameOpModeReadOnly,
        samplesPerCall: 1024);
    var handle = await engine.getNativeHandle();
    await _agoraWrapper.registerAudioFrameObserver(handle);
    await _agoraWrapper.registerVideoFrameObserver(handle);
  }

  _deinitEngine() async {
    await _agoraWrapper.unregisterAudioFrameObserver();
    await _agoraWrapper.unregisterVideoFrameObserver();
    await engine.release();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Stack(
          children: [
            if (startPreview)
              AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              ),
            Align(
              alignment: Alignment.topLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.of(remoteUid.map(
                    (e) => SizedBox(
                      width: 120,
                      height: 120,
                      child: AgoraVideoView(
                        controller: VideoViewController.remote(
                          rtcEngine: engine,
                          canvas: VideoCanvas(uid: e),
                          connection: const RtcConnection(
                            channelId: config.channelId,
                          ),
                        ),
                      ),
                    ),
                  )),
                ),
              ),
            ),
            //传camera 回调显示 UI，不传不显示
            // FaceunityUI(
            //   cameraCallback: () => engine.switchCamera(),
            // )
            const FaceunityUI()
          ],
        ),
      ),
    );
  }
}
