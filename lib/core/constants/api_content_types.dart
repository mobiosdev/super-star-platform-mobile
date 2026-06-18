/// Values accepted by `POST /content` (backend validation).
abstract final class ApiContentTypes {
  static const String post = 'POST';
  static const String photo = 'PHOTO';
  static const String videoSd = 'VIDEO_SD';
  static const String videoHd = 'VIDEO_HD';
  static const String story = 'STORY';
  static const String audio = 'AUDIO';
  static const String download = 'DOWNLOAD';
  static const String liveAnnouncement = 'LIVE_ANNOUNCEMENT';
  static const String poll = 'POLL';
  static const String merchLink = 'MERCH_LINK';
  static const String fanClubPost = 'FAN_CLUB_POST';

  static const List<String> all = [
    post,
    photo,
    videoSd,
    videoHd,
    story,
    audio,
    download,
    liveAnnouncement,
    poll,
    merchLink,
    fanClubPost,
  ];

  /// For `POST /content/{id}/media` — IMAGE | VIDEO | AUDIO | DOCUMENT
  static String mediaUploadType(String contentType) {
    switch (contentType) {
      case videoSd:
      case videoHd:
      case liveAnnouncement:
        return 'VIDEO';
      case audio:
        return 'AUDIO';
      case download:
        return 'DOCUMENT';
      default:
        return 'IMAGE';
    }
  }

  static String label(String value) {
    switch (value) {
      case post:
        return 'Post';
      case photo:
        return 'Photo';
      case videoSd:
        return 'Video (SD)';
      case videoHd:
        return 'Video (HD)';
      case story:
        return 'Story';
      case audio:
        return 'Audio';
      case download:
        return 'Download';
      case liveAnnouncement:
        return 'Live ann';
      case poll:
        return 'Poll';
      case merchLink:
        return 'Merch link';
      case fanClubPost:
        return 'Fan club post';
      default:
        return value;
    }
  }
}
