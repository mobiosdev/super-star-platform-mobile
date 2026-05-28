import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_shimmer.dart';
import '../../core/widgets/sla_timer_badge.dart';
import '../../core/widgets/superstar_app_bar.dart';
import '../../core/widgets/tier_badge.dart';
import '../../domain/entities/moderation_item.dart';
import '../../domain/entities/subscription_tier.dart';
import '../providers/moderation_provider.dart';

class ModerationQueueScreen extends ConsumerStatefulWidget {
  const ModerationQueueScreen({super.key});

  @override
  ConsumerState<ModerationQueueScreen> createState() => _ModerationQueueScreenState();
}

class _ModerationQueueScreenState extends ConsumerState<ModerationQueueScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(moderationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SuperstarAppBar(
        title: 'Moderation Queue',
        showBack: false,
        actions: [
          IconButton(
            icon: Icon(
              state.bulkMode ? Icons.close : Icons.checklist_rounded,
              color: AppColors.secondary,
            ),
            onPressed: () => ref.read(moderationProvider.notifier).toggleBulkMode(),
            tooltip: state.bulkMode ? 'Exit bulk mode' : 'Bulk actions',
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(
            searchController: _searchController,
            tierFilter: state.tierFilter,
            onSearch: (q) => ref.read(moderationProvider.notifier).setSearch(q),
            onTierChanged: (t) => ref.read(moderationProvider.notifier).setTierFilter(t),
          ),
          if (state.bulkMode && state.selectedIds.isNotEmpty)
            _BulkActionBar(
              count: state.selectedIds.length,
              onApprove: () {},
              onReject: () {},
            ),
          Expanded(child: _buildList(context, state)),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, ModerationState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const LoadingShimmer(itemCount: 5);
    }

    if (state.error != null && state.items.isEmpty) {
      return EmptyState(
        title: 'Queue unavailable',
        subtitle: state.error,
        icon: Icons.error_outline,
        action: () => ref.read(moderationProvider.notifier).loadQueue(),
        actionLabel: 'Retry',
      );
    }

    if (state.items.isEmpty) {
      return const EmptyState(
        title: 'Queue is empty',
        subtitle: 'All submissions have been reviewed',
        icon: Icons.verified_outlined,
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(moderationProvider.notifier).refresh(),
      child: ListView.builder(
        padding: Responsive.pagePadding(context),
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final item = state.items[index];
          final selected = state.selectedIds.contains(item.id);
          return _QueueCard(
            item: item,
            bulkMode: state.bulkMode,
            selected: selected,
            onTap: () {
              if (state.bulkMode) {
                ref.read(moderationProvider.notifier).toggleSelection(item.id);
              } else {
                context.push('/admin/review/${item.id}');
              }
            },
            onSelectToggle: () => ref.read(moderationProvider.notifier).toggleSelection(item.id),
          );
        },
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.searchController,
    required this.tierFilter,
    required this.onSearch,
    required this.onTierChanged,
  });

  final TextEditingController searchController;
  final SubscriptionTier? tierFilter;
  final ValueChanged<String> onSearch;
  final ValueChanged<SubscriptionTier?> onTierChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search by Superstar name...',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        onSearch('');
                      },
                    )
                  : null,
            ),
            onSubmitted: onSearch,
            onChanged: (v) {
              if (v.isEmpty) onSearch('');
            },
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All tiers',
                  selected: tierFilter == null,
                  onTap: () => onTierChanged(null),
                ),
                ...SubscriptionTier.values.map(
                  (t) => _FilterChip(
                    label: t.label,
                    selected: tierFilter == t,
                    onTap: () => onTierChanged(t),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.secondary,
        side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      ),
    );
  }
}

class _BulkActionBar extends StatelessWidget {
  const _BulkActionBar({
    required this.count,
    required this.onApprove,
    required this.onReject,
  });

  final int count;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.surface,
      child: Row(
        children: [
          Text('$count selected', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          const Spacer(),
          TextButton(
            onPressed: onApprove,
            child: Text('Approve', style: TextStyle(color: AppColors.success)),
          ),
          TextButton(
            onPressed: onReject,
            child: Text('Reject', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  const _QueueCard({
    required this.item,
    required this.bulkMode,
    required this.selected,
    required this.onTap,
    required this.onSelectToggle,
  });

  final ModerationItem item;
  final bool bulkMode;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onSelectToggle;

  @override
  Widget build(BuildContext context) {
    final modItem = item;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.background,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Accent bar
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (bulkMode)
                          Padding(
                            padding: const EdgeInsets.only(right: 8, top: 0),
                            child: Checkbox(
                              value: selected,
                              onChanged: (_) => onSelectToggle(),
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: modItem.thumbnailUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      modItem.superstarName,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  SlaTimerBadge(duration: modItem.queueDuration),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                modItem.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  TierBadge(tier: modItem.tier, compact: true),
                                  const SizedBox(width: 6),
                                  Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      DateFormat.MMMd().add_jm().format(modItem.submittedAt),
                                      style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right, color: AppColors.primary, size: 20),
                      ],
                    ),
                    // Description preview
                    if (modItem.description != null && modItem.description!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          modItem.description!,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
