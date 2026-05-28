import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/light_blue_theme.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/superstar_app_bar.dart';
import '../../data/api/platform_api.dart';
import '../../data/repositories/superstar_repository_impl.dart';
import '../../presentation/providers/auth_provider.dart';

final _analyticsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return {};
  final superstarId = await ref.read(superstarRepositoryProvider).resolveMySuperstarId(
        userId: user.id,
        superstarId: user.superstarId,
      );
  if (superstarId == null) return {};
  return ref.read(platformApiProvider).getSuperstarAnalytics(superstarId);
});

class CreatorAnalyticsScreen extends ConsumerWidget {
  const CreatorAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_analyticsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SuperstarAppBar(title: 'Analytics', showBack: false),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(title: 'Analytics unavailable', subtitle: '$e', icon: Icons.bar_chart),
        data: (data) {
          if (data.isEmpty) {
            return const EmptyState(
              title: 'No analytics yet',
              subtitle: 'Publish content to see performance metrics.',
              icon: Icons.insights_outlined,
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: data.entries.map((e) => _AnalyticsCard(entry: e)).toList(),
          );
        },
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({required this.entry});

  final MapEntry<String, dynamic> entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: LightBlueTheme.cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              _humanizeKey(entry.key),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              _formatValue(entry.value),
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _humanizeKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .where((s) => s.isNotEmpty)
        .map((s) => s[0].toUpperCase() + s.substring(1))
        .join(' ');
  }

  String _formatValue(dynamic value) {
    if (value == null) return '-';
    if (value is Map) {
      return value.entries.map((e) => '${_humanizeKey(e.key.toString())}: ${e.value}').join('\n');
    }
    if (value is List) {
      if (value.isEmpty) return '-';
      final first = value.first;
      if (first is Map) {
        return first.entries
            .map((e) => '${_humanizeKey(e.key.toString())}: ${e.value}')
            .join('\n');
      }
      return value.join(', ');
    }
    return value.toString();
  }
}
