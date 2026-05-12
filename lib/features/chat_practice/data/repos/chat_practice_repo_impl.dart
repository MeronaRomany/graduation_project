import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:graduation_app/features/chat_practice/data/repos/chat_practice_repo.dart';
import 'package:graduation_app/services/agora_service.dart';
import 'package:graduation_app/services/firestore_service.dart';

class ChatPracticeRepositoryImpl implements ChatPracticeRepository {
  final AgoraService _agoraService;
  final FireStoreService _fireStoreService;
  
  

  ChatPracticeRepositoryImpl({AgoraService? agoraService, required FireStoreService fireStoreService})
      : _fireStoreService = fireStoreService, _agoraService = agoraService ?? AgoraService();
  
  @override
  Future<void> joinChannel(String channelId) async {
    await _agoraService.initializeAndJoin(channelId: channelId);
  }

  @override
  Future<void> leaveChannel() async {
    await _agoraService.leaveChannel();
  }

  @override
  Future<void> muteLocalAudio(bool isMuted) async {
    await _agoraService.muteLocalAudio(isMuted);
  }

  @override
  Stream<int> listenToAudioLevels() {
    return _agoraService.audioLevelStream;
  }

  @override
  Stream<int> listenToConnectionState() {
    return _agoraService.connectionStateStream.map((state) {
      switch (state) {
        case ConnectionStateType.connectionStateConnecting:
          return 1; // loading
        case ConnectionStateType.connectionStateConnected:
          return 2; // connected
        case ConnectionStateType.connectionStateReconnecting:
          return 3; // reconnecting
        case ConnectionStateType.connectionStateFailed:
          return 4; // failed
        case ConnectionStateType.connectionStateDisconnected:
          return 5; // ended
      }
    });
  }

  @override
  Future<void> findMatch() async {
    // Simple matching logic using Firestore queue
    // 1. Check if anyone is waiting
    String? channelId = await _fireStoreService.findMatch();

    await joinChannel(channelId ?? "testgroup1");
  }

  @override
  Future<void> cancelMatch() async {
    await _fireStoreService.removeFromQueue();
    await leaveChannel();
  }

  @override
  Future<void> enterWaitingRoom() async {
    await _fireStoreService.addToQueue("testgroup1");
    await _agoraService.initializeAndUseWaitingRoom();
  }
}
