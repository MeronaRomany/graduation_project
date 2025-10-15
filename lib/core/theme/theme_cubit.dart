import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeState extends Equatable {
  final bool isDarkMode;

  const ThemeState({required this.isDarkMode});

  ThemeState copyWith({bool? isDarkMode}) => ThemeState(
        isDarkMode: isDarkMode ?? this.isDarkMode,
      );

  @override
  List<Object?> get props => [isDarkMode];
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(isDarkMode: false));

  void toggleTheme() => emit(state.copyWith(isDarkMode: !state.isDarkMode));
}
