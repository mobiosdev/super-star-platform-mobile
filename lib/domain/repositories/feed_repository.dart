import '../entities/feed_post.dart';

abstract class FeedRepository {
  Future<List<FeedPost>> fetchFeed({required int page, int limit = 10});
}
