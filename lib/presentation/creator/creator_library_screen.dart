import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_shimmer.dart';
import '../../core/widgets/superstar_app_bar.dart';
import '../../data/models/content_dto.dart';
import '../../data/repositories/content_repository_impl.dart';
import '../../data/repositories/superstar_repository_impl.dart';
import '../../presentation/providers/auth_provider.dart';

String _getFriendlyErrorMessage(Object? error) {
  log('📍 Content loading error: $error', name: 'CreatorLibrary');
  
  if (error is ApiException) {
    if (error.statusCode == 403) {
      return 'You do not have permission to access this content library. Please contact support if you believe this is an error.';
    }
    return error.message;
  }
  
  final errorStr = error?.toString() ?? 'Unknown error';
  if (errorStr.contains('403')) {
    return 'Permission denied. This account may not have content upload privileges enabled.';
  }
  if (errorStr.contains('401')) {
    return 'Your session has expired. Please log in again.';
  }
  
  return errorStr;
}

final _libraryProvider = FutureProvider.autoDispose<List<ContentDto>>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return [];
  final superstarId = await ref.read(superstarRepositoryProvider).resolveMySuperstarId(
        userId: user.id,
        superstarId: user.superstarId,
      );
  if (superstarId == null) return [];
  return ref.read(contentRepositoryProvider).listForSuperstar(
        superstarId: superstarId,
        limit: 50,
      );
});

class CreatorLibraryScreen extends ConsumerWidget {
  const CreatorLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_libraryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SuperstarAppBar(
        title: 'Content Library',
        showBack: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () => context.push('/creator/upload'),
          ),
        ],
      ),
      body: async.when(
        loading: () => const LoadingShimmer(itemCount: 4),
        error: (error, stackTrace) {
          log('❌ Library provider error: $error\n$stackTrace', name: 'CreatorLibrary');
          return EmptyState(
            title: 'Could not load library',
            subtitle: _getFriendlyErrorMessage(error),
            icon: Icons.error_outline,
            action: () => ref.invalidate(_libraryProvider),
            actionLabel: 'Retry',
          );
        },
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              title: 'No content yet',
              subtitle: 'Upload your first post to share with fans.',
              icon: Icons.folder_open,
              action: () => context.push('/creator/upload'),
              actionLabel: 'Upload',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_libraryProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, i) {
                final item = items[i];
                return ListTile(
                  title: Text(
                    item.title ?? 'Untitled',
                    style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${item.status ?? '—'} · ${item.contentType ?? ''}',
                    style: GoogleFonts.roboto(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () async {
                      await ref.read(contentRepositoryProvider).delete(item.id);
                      ref.invalidate(_libraryProvider);
                    },
                  ),
                  onTap: () => context.push('/content/${item.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
