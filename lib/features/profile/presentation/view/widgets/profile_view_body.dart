import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_app/core/theme/colors_manager.dart';
import 'package:graduation_app/core/utils/app_text_styles.dart';
import 'package:graduation_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:graduation_app/features/profile/presentation/cubit/profile_state.dart';
import 'package:graduation_app/features/profile/presentation/view/edit_profile_view.dart';
import 'package:graduation_app/features/profile/presentation/view/help_support_view.dart';
import 'package:graduation_app/features/profile/presentation/view/my_progress_view.dart';
import 'package:graduation_app/features/profile/presentation/view/settings_view.dart';
import 'package:graduation_app/services/user_storage_services.dart';
import 'package:shimmer/shimmer.dart';

class ProfileViewBody extends StatelessWidget {
  ProfileViewBody({super.key});

  final UserStorageService _userStorageService = UserStorageService();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.user == null && !state.isLoading) {
            // User deleted or not found, handled by auth wrapper
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                ),
                const SizedBox(height: 8),
                _buildAvatar(state),
                const SizedBox(height: 20),
                _buildUserInfo(state),
                const SizedBox(height: 32),
                _buildProfileOption(
                  context: context,
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.pushNamed(context, EditProfileView.routeName);
                  },
                ),
                _buildProfileOption(
                  context: context,
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pushNamed(context, SettingsView.routeName);
                  },
                ),
                _buildProfileOption(
                  context: context,
                  icon: Icons.emoji_events_outlined,
                  title: 'My Progress',
                  onTap: () {
                    Navigator.pushNamed(context, MyProgressView.routeName);
                  },
                ),
                _buildProfileOption(
                  context: context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    Navigator.pushNamed(context, HelpSupportView.routeName);
                  },
                ),
                const SizedBox(height: 16),
                _buildProfileOption(
                  context: context,
                  icon: Icons.delete_outline,
                  title: 'Delete Account',
                  color: Colors.red,
                  onTap: () => _showDeleteConfirmation(context),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _userStorageService.clearUser();
                      await FirebaseAuth.instance.signOut();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(ProfileState state) {
    if (state.isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: const CircleAvatar(radius: 60),
      );
    }
    return CircleAvatar(
      radius: 60,
      backgroundColor: ColorsManager.primary.withValues(alpha: 0.1),
      child: Text(
        (state.user?.name ?? 'U')[0].toUpperCase(),
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: ColorsManager.primary,
        ),
      ),
    );
  }

  Widget _buildUserInfo(ProfileState state) {
    if (state.isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          children: [
            Container(width: 120, height: 24, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: 160, height: 16, color: Colors.white),
          ],
        ),
      );
    }
    return Column(
      children: [
        Text(
          state.user?.name ?? 'User',
          style: AppTextStyles.bold25,
        ),
        const SizedBox(height: 6),
        Text(
          state.user?.email ?? '',
          style: AppTextStyles.regular15.copyWith(color: Colors.grey[500]),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: ColorsManager.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Level ${state.user?.level ?? 'A1'}',
            style: AppTextStyles.semiBold11.copyWith(
              color: ColorsManager.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final tileColor = color ?? Colors.black87;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(icon, color: tileColor, size: 24),
              const SizedBox(width: 16),
              Text(
                title,
                style: AppTextStyles.medium15.copyWith(color: tileColor),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final profileCubit = context.read<ProfileCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          BlocProvider.value(
            value: profileCubit,
            child: BlocListener<ProfileCubit, ProfileState>(
              listener: (context, state) {
                if (state.user == null && !state.isDeleting) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              child: TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await profileCubit.deleteAccount();
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
