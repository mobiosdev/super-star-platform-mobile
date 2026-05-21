import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/feed_repository_impl.dart';
import '../../domain/entities/feed_post.dart';
import '../../domain/repositories/feed_repository.dart';

final feedRepositoryProviderRef = feedRepositoryProvider;

class FeedState {
  const FeedState({
    this.posts = const [],
    this.page = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.isRefreshing = false,
  });

  final List<FeedPost> posts;
  final int page;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final bool isRefreshing;

  FeedState copyWith({
    List<FeedPost>? posts,
    int? page,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool? isRefreshing,
    bool clearError = false,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  return FeedNotifier(ref.watch(feedRepositoryProvider));
});

class FeedNotifier extends StateNotifier<FeedState> {
  FeedNotifier(this._repo) : super(const FeedState(isLoading: true)) {
    loadInitial();
  }

  final FeedRepository _repo;

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final posts = await _repo.fetchFeed(page: 1);
      state = FeedState(
        posts: posts,
        page: 2,
        isLoading: false,
        hasMore: posts.isNotEmpty,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, clearError: true);
    try {
      final posts = await _repo.fetchFeed(page: 1);
      state = FeedState(
        posts: posts,
        page: 2,
        isRefreshing: false,
        hasMore: posts.isNotEmpty,
      );
    } catch (e) {
      state = state.copyWith(isRefreshing: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final more = await _repo.fetchFeed(page: state.page);
      state = state.copyWith(
        posts: [...state.posts, ...more],
        page: state.page + 1,
        isLoadingMore: false,
        hasMore: more.isNotEmpty,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }
}
