import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/moderation_repository_impl.dart';
import '../../domain/entities/moderation_item.dart';
import '../../domain/entities/subscription_tier.dart';
import '../../domain/repositories/moderation_repository.dart';

class ModerationState {
  const ModerationState({
    this.items = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.searchQuery = '',
    this.tierFilter,
    this.selectedIds = const {},
    this.bulkMode = false,
    this.page = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  final List<ModerationItem> items;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final String searchQuery;
  final SubscriptionTier? tierFilter;
  final Set<String> selectedIds;
  final bool bulkMode;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  ModerationState copyWith({
    List<ModerationItem>? items,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    String? searchQuery,
    SubscriptionTier? tierFilter,
    Set<String>? selectedIds,
    bool? bulkMode,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    bool clearTierFilter = false,
    bool clearError = false,
  }) {
    return ModerationState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
      tierFilter: clearTierFilter ? null : (tierFilter ?? this.tierFilter),
      selectedIds: selectedIds ?? this.selectedIds,
      bulkMode: bulkMode ?? this.bulkMode,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final moderationProvider = StateNotifierProvider<ModerationNotifier, ModerationState>((ref) {
  return ModerationNotifier(ref.watch(moderationRepositoryProvider));
});

class ModerationNotifier extends StateNotifier<ModerationState> {
  ModerationNotifier(this._repo) : super(const ModerationState(isLoading: true)) {
    loadQueue();
  }

  final ModerationRepository _repo;

  Future<void> loadQueue() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _repo.fetchQueue(
        page: 1,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
        tierFilter: state.tierFilter,
      );
      state = state.copyWith(
        items: items,
        isLoading: false,
        page: 2,
        hasMore: items.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, page: 1, clearError: true);
    try {
      final items = await _repo.fetchQueue(
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
        tierFilter: state.tierFilter,
      );
      state = state.copyWith(
        items: items,
        isRefreshing: false,
        page: 2,
        hasMore: items.length >= 20,
        selectedIds: {},
      );
    } catch (e) {
      state = state.copyWith(isRefreshing: false, error: e.toString());
    }
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
    loadQueue();
  }

  void setTierFilter(SubscriptionTier? tier) {
    state = state.copyWith(
      tierFilter: tier,
      clearTierFilter: tier == null,
    );
    loadQueue();
  }

  void toggleBulkMode() {
    state = state.copyWith(
      bulkMode: !state.bulkMode,
      selectedIds: {},
    );
  }

  void toggleSelection(String id) {
    final next = Set<String>.from(state.selectedIds);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = state.copyWith(selectedIds: next);
  }

  Future<void> approve(String id) async {
    await _repo.approve(id);
    await refresh();
  }

  Future<void> reject(String id) async {
    await _repo.reject(id);
    await refresh();
  }

  Future<void> escalate(String id) async {
    await _repo.escalate(id);
    await refresh();
  }
}
