abstract class ChatPracticeRepository {
  Future<void> joinChannel(String channelId);
  Future<void> leaveChannel();
  Future<void> muteLocalAudio(bool isMuted);
  Stream<int> listenToAudioLevels();
  Stream<int> listenToConnectionState();
  Future<void> findMatch(String userId);
  Future<void> cancelMatch(String userId);
  Future<void> enterWaitingRoom(String userId);
}
