import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_app/features/chat_practice/data/repos/chat_practice_repo.dart';
import 'package:graduation_app/features/chat_practice/screens/cubit/chat_practice_state.dart';
import 'package:graduation_app/models/user_model_auth.dart';

class ChatPracticeCubit extends Cubit<ChatPracticeState> {
  final ChatPracticeRepository _repository;
  StreamSubscription? _audioSubscription;
  StreamSubscription? _connectionSubscription;
  Timer? _timer;

  ChatPracticeCubit(this._repository)
      : super(ChatPracticeState(status: CallStatus.initial));

  Future<void> initChat() async {
    if (state.status == CallStatus.loading ||
        state.status == CallStatus.connected) {
      log("initChat already in progress or connected, skipping...");
      return;
    }
    final dummyUser = const UserModel(
        uid: 'dummy_afraym', name: 'Afraym Herz', email: '', level: 'B1');

    emit(state.copyWith(
      status: CallStatus.loading,
      remoteUser: dummyUser,
      sessionStartTime: DateTime.now(),
    ));

    try {
      // Cancel any existing subscriptions to avoid memory leaks or duplicate events
      await _audioSubscription?.cancel();
      await _connectionSubscription?.cancel();
      _connectionSubscription = _repository.listenToConnectionState().listen((stateCode) async {
        CallStatus newStatus = CallStatus.initial;
        switch (stateCode) {
          case 1:
            newStatus = CallStatus.loading;
            break;
          case 2:
            newStatus = CallStatus.connected;
            _startTimer();
            break;
          case 3:
            newStatus = CallStatus.reconnecting;
            break;
          case 4:
            newStatus = CallStatus.failed;
            log("error in failed status  ", error: stateCode.toString());
            break;
          case 5:
            newStatus = CallStatus.ended;
            _stopTimer();
            break;
        }

        emit(state.copyWith(status: newStatus));
      });
      await _repository.findMatch();
      log("after findMatch ");
      _audioSubscription = _repository.listenToAudioLevels().listen((volume) {
        emit(state.copyWith(remoteLevelOfAudio: volume));
      });
      log("after listenToAudioLevels ");

      // await _repository.findMatch(localUserId);
    } catch (e) {
      log("error in init chat  ", error: e);
      emit(state.copyWith(status: CallStatus.failed, errMessage: e.toString()));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      emit(state.copyWith(duration: Duration(seconds: timer.tick)));
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> toggleMute() async {
    final newMuteState = !state.isMuted;
    try {
      await _repository.muteLocalAudio(newMuteState);
      emit(state.copyWith(isMuted: newMuteState));
    } catch (e) {
      log("error in toggle mute  ", error: e);
      emit(state.copyWith(errMessage: 'Failed to mute audio: ${e.toString()}'));
    }
  }

  Future<void> leaveCall(String? localUserId) async {
    _stopTimer();
    await _audioSubscription?.cancel();
    await _connectionSubscription?.cancel();
    _audioSubscription = null;
    _connectionSubscription = null;

    emit(state.copyWith(status: CallStatus.ended));
    try {
      // cancelMatch now only calls leaveChannel in the implementation
      await _repository.cancelMatch();
    } catch (e) {
      log("error in leave call  ", error: e);
      emit(state.copyWith(errMessage: 'Error leaving call: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _stopTimer();
    _audioSubscription?.cancel();
    _connectionSubscription?.cancel();
    _repository.leaveChannel();
    return super.close();
  }

  Future<void> enterWaitingState(String? localUserId) async {
    if (state.status == CallStatus.loading ||
        state.status == CallStatus.connected) {
      log("enterWaitingState already in progress or connected, skipping...");
      return;
    }
    emit(state.copyWith(status: CallStatus.loading));


    try {
      await _audioSubscription?.cancel();
      await _connectionSubscription?.cancel();
      
      _connectionSubscription = _repository.listenToConnectionState().listen((stateCode) async {
        CallStatus newStatus = CallStatus.initial;
        switch (stateCode) {
          case 1: newStatus = CallStatus.loading; break;
          case 2:
            newStatus = CallStatus.connected;
            _startTimer();
            final remoteUser = const UserModel(
                uid: 'remote_wait_id', name: 'Waiting Room', email: '', level: 'A1');
            emit(state.copyWith(remoteUser: remoteUser));
            break;
          case 3: newStatus = CallStatus.reconnecting; break;
          case 4: newStatus = CallStatus.failed; break;
          case 5:
            newStatus = CallStatus.ended;
            _stopTimer();
            break;
        }
        emit(state.copyWith(status: newStatus));
      });
      
      await _repository.enterWaitingRoom();
      
      _audioSubscription = _repository.listenToAudioLevels().listen((volume) {
        emit(state.copyWith(remoteLevelOfAudio: volume));
      });

    } catch (e) {
      log("error in waiting state ", error: e);
      emit(state.copyWith(status: CallStatus.failed, errMessage: e.toString()));
    }
  }
}
