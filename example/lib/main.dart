import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_wrapper/agora_wrapper.dart';
import 'package:agora_wrapper/rtc_manager.dart';
import 'package:agora_wrapper/rtm_manager.dart';
import 'package:agora_wrapper_example/config/agora.config.dart' as config;
import 'package:faceunity_ui_flutter/faceunity_ui_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'config/agora.config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  RtcManager.instance.initEngine(config.appId);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool startPreview = false, isJoined = false;
  List<int> remoteUid = [];

  @override
  void initState() {
    super.initState();
    AgoraWrapper.login(
      config.uid,
      config.rtmToken,
      config.appId,
    );
    _initEngine();
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

    var rtcEngineEventHandler = RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        log('[$runtimeType]=>onJoinChannelSuccess connection: ${connection.toJson()} elapsed: $elapsed');
        setState(() {
          isJoined = true;
        });
      },
      onUserJoined: (RtcConnection connection, int rUid, int elapsed) {
        log('[$runtimeType]=>onUserJoined connection: ${connection.toJson()} remoteUid: $rUid elapsed: $elapsed');
        setState(() {
          remoteUid.add(rUid);
        });
      },
      onUserOffline:
          (RtcConnection connection, int rUid, UserOfflineReasonType reason) {
        log('[$runtimeType]=>onUserOffline connection: ${connection.toJson()} remoteUid: $rUid reason: $reason');
        setState(() {
          remoteUid.remove(rUid);
        });
      },
      onError: (error, msg) {
        log('[$runtimeType]=>joinChannelError,msg=$msg,error=$error');
      },
    );
    await RtcManager.instance.initRtc(rtcEngineEventHandler);
    setState(() {
      startPreview = true;
    });

    log('[$runtimeType]=>joinChannel ,token=${config.token},channelId=${config.channelId},uid=${config.uid}');
    await RtcManager.instance.joinChannel(
        token: config.token,
        channelId: config.channelId,
        uid: config.uid,
        options: const ChannelMediaOptions(
            clientRoleType: ClientRoleType.clientRoleBroadcaster));

    await RtcManager.instance.registerFrameObserver();
  }

  _deinitEngine() async {
    RtcManager.instance.unRegisterFrameObserver();
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
                  rtcEngine: RtcManager.instance.globalEngine,
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
                          rtcEngine: RtcManager.instance.globalEngine,
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
