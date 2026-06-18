import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/bns_music_theme.dart';
import '../../core/widgets/logout_button.dart';
import '../../core/widgets/superstar_app_bar.dart';
import '../../domain/entities/user.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_mode_provider.dart';

/// Account screen with sign-out (calls `POST /auth/logout`).
class AccountProfileScreen extends ConsumerStatefulWidget {
  const AccountProfileScreen({super.key, this.showBack = false});

  final bool showBack;

  @override
  ConsumerState<AccountProfileScreen> createState() => _AccountProfileScreenState();
}

class _AccountProfileScreenState extends ConsumerState<AccountProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SuperstarAppBar(title: 'My Profile', showBack: widget.showBack),
      body: auth.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Could not load profile\n$e')),
        data: (u) => u == null ? _buildSignedOut(context) : _buildProfile(context, u),
      ),
    );
  }

  Widget _buildSignedOut(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => context.go('/login'),
        child: const Text('Go to sign in'),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, AppUser user) {
    final theme = Theme.of(context);
    final darkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BnsMusicTheme.cardDecoration(context),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                backgroundImage:
                    user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                child: user.avatarUrl == null
                    ? Text(
                        user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _RoleChip(label: user.role.displayName),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BnsMusicTheme.cardDecoration(context, withShadow: false),
          child: SwitchListTile(
            value: darkMode,
            onChanged: (value) => ref.read(themeModeProvider.notifier).setDarkMode(value),
            activeColor: AppColors.primary,
            secondary: Icon(
              darkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: AppColors.primary,
            ),
            title: Text(
              'Dark mode',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              darkMode ? 'Using dark BNS theme' : 'Using light BNS theme',
              style: GoogleFonts.roboto(color: theme.textTheme.bodySmall?.color),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const LogoutOutlinedButton(),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}
