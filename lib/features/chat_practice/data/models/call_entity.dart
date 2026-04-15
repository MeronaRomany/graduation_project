import 'package:equatable/equatable.dart';

class CallEntity extends Equatable {
  final String callerId;
  final String receiverId;
  final String channelId;
  final CallStatus status;
  final DateTime? matchedAt;

  const CallEntity({
    required this.callerId,
    required this.receiverId,
    required this.channelId,
    required this.status,
    this.matchedAt,
  });

  factory CallEntity.fromJson(Map<String, dynamic> json) {
    return CallEntity(
      callerId: json['callerId'] as String,
      receiverId: json['receiverId'] as String,
      channelId: json['channelId'] as String,
      status: CallStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CallStatus.waiting,
      ),
      matchedAt: json['matchedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['matchedAt'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'callerId': callerId,
      'receiverId': receiverId,
      'channelId': channelId,
      'status': status.name,
      'matchedAt': matchedAt?.millisecondsSinceEpoch,
    };
  }

  CallEntity copyWith({
    String? callerId,
    String? receiverId,
    String? channelId,
    CallStatus? status,
    DateTime? matchedAt,
  }) {
    return CallEntity(
      callerId: callerId ?? this.callerId,
      receiverId: receiverId ?? this.receiverId,
      channelId: channelId ?? this.channelId,
      status: status ?? this.status,
      matchedAt: matchedAt ?? this.matchedAt,
    );
  }

  @override
  List<Object?> get props => [
        callerId,
        receiverId,
        channelId,
        status,
        matchedAt,
      ];
}

enum CallStatus { waiting, matched, finished }
