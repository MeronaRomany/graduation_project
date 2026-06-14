import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_app/features/profile/presentation/cubit/profile_state.dart';
import 'package:graduation_app/services/firestore_service.dart';
import 'package:graduation_app/services/user_storage_services.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final FireStoreService _fireStoreService;
  final UserStorageService _userStorageService;

  ProfileCubit({
    FireStoreService? fireStoreService,
    UserStorageService? userStorageService,
  })  : _fireStoreService = fireStoreService ?? FireStoreService(),
        _userStorageService = userStorageService ?? UserStorageService(),
        super(const ProfileState());

  Future<void> loadUserProfile() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final user = await _fireStoreService.getUserFromFireStore(uid);
      if (user != null) {
        emit(state.copyWith(user: user, isLoading: false));
      } else {
        emit(state.copyWith(
            isLoading: false, errorMessage: 'User profile not found'));
      }
    } catch (e) {
      log('Error loading profile', error: e);
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> updateUserName(String newName) async {
    if (newName.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Name cannot be empty'));
      return;
    }
    emit(state.copyWith(isUpdating: true, clearError: true));
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await _fireStoreService.updateUser(uid, name: newName.trim());
      await _userStorageService.saveUser(
        uid: uid,
        name: newName.trim(),
        email: state.user?.email ?? '',
        level: state.user?.level ?? 'A1',
      );
      final updatedUser = state.user?.copyWith(name: newName.trim());
      emit(state.copyWith(
        user: updatedUser,
        isUpdating: false,
        successMessage: 'Profile updated successfully',
      ));
    } catch (e) {
      log('Error updating profile', error: e);
      emit(state.copyWith(isUpdating: false, errorMessage: e.toString()));
    }
  }

  Future<void> deleteAccount() async {
    emit(state.copyWith(isDeleting: true, clearError: true));
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(state.copyWith(
            isDeleting: false, errorMessage: 'No user logged in'));
        return;
      }
      await _fireStoreService.deleteUser(user.uid);
      await _userStorageService.clearUser();
      await user.delete();
      emit(state.copyWith(isDeleting: false));
    } catch (e) {
      log('Error deleting account', error: e);
      emit(state.copyWith(isDeleting: false, errorMessage: e.toString()));
    }
  }
}
