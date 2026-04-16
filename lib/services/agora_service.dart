import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:graduation_app/core/utils/secrets.dart';
class AgoraService {
  // ✅ Singleton
  static final AgoraService _instance = AgoraService._internal();
  factory AgoraService() => _instance;
  AgoraService._internal();

  RtcEngine? _engine;
  bool _isJoined = false;
  String? _currentChannelId;

  final StreamController<int> _audioLevelController =
      StreamController<int>.broadcast();
  final StreamController<ConnectionStateType> _connectionStateController =
      StreamController<ConnectionStateType>.broadcast();

  Stream<int> get audioLevelStream => _audioLevelController.stream;
  Stream<ConnectionStateType> get connectionStateStream =>
      _connectionStateController.stream;

  Future<void> initializeAndJoin({
    required String channelId,
    String? token,
  }) async {
    if (_engine == null) {
      // ✅ Everything inside the null check
      log("check if equal null ${_engine==null}");
      _engine = createAgoraRtcEngine();
      log("after create Agora ${_engine==null}");
      
      await _engine!.initialize(RtcEngineContext(
        appId: Secrets.agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));
      log("after initialize Agora ${_engine==null}");

      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onConnectionStateChanged: (connection, state, reason) {
            log("connection state changed: $state , reason: $reason");
            _connectionStateController.add(state);
          },
          onAudioVolumeIndication: (connection, speakers, speakerNumber, totalVolume) {
            if (speakers.isNotEmpty) {
              int maxVol = speakers.fold(
                0,
                (max, info) =>
                    info.volume != null && info.volume! > max ? info.volume! : max,
              );
              _audioLevelController.add(maxVol);
            }
          },
        ),
      );

      await _engine!.enableAudio();
      await _engine!.enableAudioVolumeIndication(
        interval: 200,
        smooth: 3,
        reportVad: true,
      );
      log("after enableAudioVolumeIndication Agora ${_engine==null}");
    }


    if (_isJoined && _currentChannelId == channelId) {
      log("Already joined channel: $channelId");
      return;
    }

    int randomUid = math.Random().nextInt(1000000);


    await _engine!.joinChannel(
      token: Secrets.agoraToken,
      channelId: channelId,
      uid: randomUid,
      options: const ChannelMediaOptions(
        autoSubscribeAudio: true,
        autoSubscribeVideo: false,
        publishCameraTrack: false,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
    _isJoined = true;
    _currentChannelId = channelId;
    log("after joinChannel Agora ${_engine == null}");
  }

  Future<void> muteLocalAudio(bool isMuted) async {
    await _engine?.muteLocalAudioStream(isMuted);
  }

  Future<void> leaveChannel() async {
    if (_engine != null) {
      await _engine!.leaveChannel();
      await _engine!.release();
      _engine = null;
      _isJoined = false;
      _currentChannelId = null;
    }
  }

  void dispose() {
    _audioLevelController.close();
    _connectionStateController.close();
  }

  Future<void> initializeAndUseWaitingRoom() async {
    int randomUid = math.Random().nextInt(1000000);
    
    await initializeAndJoin(channelId: "testgroup1", token: Secrets.agoraToken);
  }

}
