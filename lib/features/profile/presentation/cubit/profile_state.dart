import 'package:equatable/equatable.dart';
import 'package:graduation_app/models/user_model_auth.dart';

class ProfileState extends Equatable {
  final UserModel? user;
  final bool isLoading;
  final bool isUpdating;
  final bool isDeleting;
  final String? errorMessage;
  final String? successMessage;

  const ProfileState({
    this.user,
    this.isLoading = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.errorMessage,
    this.successMessage,
  });

  ProfileState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isUpdating,
    bool? isDeleting,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        user,
        isLoading,
        isUpdating,
        isDeleting,
        errorMessage,
        successMessage,
      ];
}
