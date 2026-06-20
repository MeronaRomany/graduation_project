import 'package:graduation_app/models/user_model_auth.dart';

class ChatPracticeState {
  ChatPracticeState(
    {this.status = CallStatus.initial , 
    this.remoteUser , 
    this.localUser ,
    this.isMuted = false ,
    this.duration = Duration.zero ,
    this.remoteLevelOfAudio = 0 ,
    this.errMessage,
    this.sessionStartTime,
    this.isRemoteUserSpeaking = false,
    this.peerConnectionQuality = 5 }
  );

  final CallStatus status;
  final UserModel? remoteUser, localUser;
  final bool isMuted;
  final Duration duration;
  final int remoteLevelOfAudio;
  final String? errMessage;
  final DateTime? sessionStartTime;
  final bool isRemoteUserSpeaking;
  final int peerConnectionQuality;

  ChatPracticeState copyWith({
    CallStatus? status,
    UserModel? remoteUser,
    UserModel? localUser,
    bool? isMuted,
    Duration? duration,
    int? remoteLevelOfAudio,
    String? errMessage,
    DateTime? sessionStartTime,
    bool? isRemoteUserSpeaking,
    int? peerConnectionQuality,
  }) {
    return ChatPracticeState(
      status: status ?? this.status,
      remoteUser: remoteUser ?? this.remoteUser,
      localUser: localUser ?? this.localUser,
      isMuted: isMuted ?? this.isMuted,
      duration: duration ?? this.duration,
      remoteLevelOfAudio: remoteLevelOfAudio ?? this.remoteLevelOfAudio,
      errMessage: errMessage ?? this.errMessage,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      isRemoteUserSpeaking: isRemoteUserSpeaking ?? this.isRemoteUserSpeaking,
      peerConnectionQuality: peerConnectionQuality ?? this.peerConnectionQuality,
    );
  }
}

enum CallStatus {
  initial,
  loading,
  connected,
  reconnecting,
  failed,
  ended,
}
