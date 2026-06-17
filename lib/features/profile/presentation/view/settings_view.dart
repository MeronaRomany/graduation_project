import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_app/core/services/voice_provider.dart';
import 'package:graduation_app/core/theme/colors_manager.dart';
import 'package:graduation_app/core/theme/theme_cubit.dart';
import 'package:graduation_app/core/utils/app_text_styles.dart';

class SettingsView extends StatelessWidget {
  static const String routeName = '/settings';
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildSectionHeader('Appearance'),
              const SizedBox(height: 8),
              _buildSettingsTile(
                icon: themeState.isDarkMode
                    ? Icons.dark_mode
                    : Icons.light_mode,
                title: 'Dark Mode',
                trailing: Switch(
                  value: themeState.isDarkMode,
                  onChanged: (_) {
                    context.read<ThemeCubit>().toggleTheme();
                  },
                  activeThumbColor: ColorsManager.primary,
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Voice Engine'),
              const SizedBox(height: 8),
              BlocBuilder<VoiceProviderCubit, VoiceProviderState>(
                builder: (context, voiceState) {
                  return Column(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.cloud,
                        title: 'Cloud (HF Spaces)',
                        subtitle: 'Online — uses Hugging Face API',
                        trailing: Radio<VoiceMode>(
                          value: VoiceMode.cloud,
                          groupValue: voiceState.mode,
                          onChanged: (mode) {
                            if (mode != null) {
                              context.read<VoiceProviderCubit>().setMode(mode);
                            }
                          },
                          activeColor: ColorsManager.primary,
                        ),
                      ),
                      _buildSettingsTile(
                        icon: Icons.phone_android,
                        title: 'Local (ONNX)',
                        subtitle: 'Offline — on-device models',
                        trailing: Radio<VoiceMode>(
                          value: VoiceMode.local,
                          groupValue: voiceState.mode,
                          onChanged: (mode) {
                            if (mode != null) {
                              context.read<VoiceProviderCubit>().setMode(mode);
                            }
                          },
                          activeColor: ColorsManager.primary,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('About'),
              const SizedBox(height: 8),
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'App Version',
                subtitle: '1.0.0',
              ),
              _buildSettingsTile(
                icon: Icons.school_outlined,
                title: 'Fluentify',
                subtitle: 'AI-powered English learning',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.semiBold13.copyWith(
        color: Colors.grey[500],
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: ColorsManager.primary),
        title: Text(title, style: AppTextStyles.medium15),
        subtitle: subtitle != null
            ? Text(subtitle, style: AppTextStyles.regular13.copyWith(color: Colors.grey[500]))
            : null,
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.grey[50],
      ),
    );
  }
}
