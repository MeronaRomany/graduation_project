import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum VoiceMode { cloud, local }

class VoiceProviderState extends Equatable {
  final VoiceMode mode;

  const VoiceProviderState({required this.mode});

  VoiceProviderState copyWith({VoiceMode? mode}) => VoiceProviderState(
        mode: mode ?? this.mode,
      );

  bool get isCloud => mode == VoiceMode.cloud;
  bool get isLocal => mode == VoiceMode.local;

  @override
  List<Object?> get props => [mode];
}

class VoiceProviderCubit extends Cubit<VoiceProviderState> {
  static const String _key = 'voice_provider_mode';

  VoiceProviderCubit() : super(const VoiceProviderState(mode: VoiceMode.cloud));

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == 'local') {
      emit(const VoiceProviderState(mode: VoiceMode.local));
    } else {
      emit(const VoiceProviderState(mode: VoiceMode.cloud));
    }
  }

  Future<void> setMode(VoiceMode mode) async {
    emit(state.copyWith(mode: mode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  void toggle() {
    final next = state.isCloud ? VoiceMode.local : VoiceMode.cloud;
    setMode(next);
  }
}
