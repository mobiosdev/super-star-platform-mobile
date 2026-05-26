import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../network/api_exception.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/feed_provider.dart';

/// Signs out via `POST /auth/logout`, clears session, navigates to login.
Future<void> performLogout(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Sign out?'),
      content: const Text('You will need to sign in again to access your account.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Sign out', style: TextStyle(color: AppColors.error)),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  try {
    await ref.read(authStateProvider.notifier).logout();
    ref.invalidate(feedProvider);
    if (context.mounted) context.go('/login');
  } on ApiException catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}

/// Full-width outlined sign-out button.
class LogoutOutlinedButton extends ConsumerStatefulWidget {
  const LogoutOutlinedButton({super.key});

  @override
  ConsumerState<LogoutOutlinedButton> createState() => _LogoutOutlinedButtonState();
}

class _LogoutOutlinedButtonState extends ConsumerState<LogoutOutlinedButton> {
  bool _loading = false;

  Future<void> _onPressed() async {
    setState(() => _loading = true);
    await performLogout(context, ref);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _loading ? null : _onPressed,
        icon: _loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error),
              )
            : const Icon(Icons.logout_rounded, color: AppColors.error),
        label: Text(
          _loading ? 'Signing out…' : 'Sign out',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.error),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

/// App bar action for quick sign-out.
class LogoutIconButton extends ConsumerWidget {
  const LogoutIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: 'Sign out',
      icon: const Icon(Icons.logout_rounded, color: AppColors.error),
      onPressed: () => performLogout(context, ref),
    );
  }
}
