import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeState extends Equatable {
  final int counter;

  const HomeState({required this.counter});

  HomeState copyWith({int? counter}) =>
      HomeState(counter: counter ?? this.counter);

  @override
  List<Object?> get props => [counter];
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState(counter: 0));

  void increment() => emit(state.copyWith(counter: state.counter + 1));
}
