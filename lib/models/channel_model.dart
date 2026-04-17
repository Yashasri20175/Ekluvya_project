class Channel {
  final String id;
  final String title;
  final int type;
  final int rowCount;
  final List<ChannelData> data;
  final List<String> languages;
  final int count;
  final int total;
  final int recordsPerPage;
  final int currentPage;
  final int totalPages;
  final dynamic previous;
  final dynamic next;

  Channel({
    required this.id,
    required this.title,
    required this.type,
    required this.rowCount,
    required this.data,
    required this.languages,
    required this.count,
    required this.total,
    required this.recordsPerPage,
    required this.currentPage,
    required this.totalPages,
    required this.previous,
    required this.next,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    String sv(Object? v) => v?.toString() ?? '';
    return Channel(
      id: sv(json['_id']),
      title: sv(json['title']),
      type: json['type'] as int? ?? 0,
      rowCount: json['row_count'] as int? ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => ChannelData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      languages:
          (json['languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      count: json['count'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      recordsPerPage: json['recordsPerPage'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      previous: json['previous'],
      next: json['next'],
    );
  }
}

class ChannelData {
  final String id;
  final int s3JobStatus;
  final int jobStatus;
  final int transcodePercentage;
  final bool isTranscodeTriggered;
  final bool isTranscoded;
  final int viewCount;
  final bool isActive;
  final bool isArchived;
  final bool isPublished;
  final int watchDuration;
  final bool deletedMp4;
  final bool deletedHls;
  final bool deletedOffline;
  final bool useVideoThumbnailImageInstead;
  final bool isMiscReplace;
  final bool isYellowStrip;
  final String title;
  final String studioId;
  final String masterDetailsId;
  final String status;
  final String seasonId;
  final String hlsPlaylistUrl;
  final String videoDuration;
  final int progress;
  final String slug;
  final String rank;
  final int episodeIndex;
  final List<Thumbnail> thumbnailList;
  final List<dynamic> subtitles;
  final List<dynamic> audioLanguages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;
  final String videoBitrate;
  final String videoFps;
  final Map<String, dynamic> newThumbnailImages;
  final String description;
  final String updatorId;
  final bool isUserSubscribed;
  final bool isSubscription;
  final int monetization;
  final String seriesSlug;
  final String defaultLanguage;
  final List<dynamic> availableSubtitles;

  ChannelData({
    required this.id,
    required this.s3JobStatus,
    required this.jobStatus,
    required this.transcodePercentage,
    required this.isTranscodeTriggered,
    required this.isTranscoded,
    required this.viewCount,
    required this.isActive,
    required this.isArchived,
    required this.isPublished,
    required this.watchDuration,
    required this.deletedMp4,
    required this.deletedHls,
    required this.deletedOffline,
    required this.useVideoThumbnailImageInstead,
    required this.isMiscReplace,
    required this.isYellowStrip,
    required this.title,
    required this.studioId,
    required this.masterDetailsId,
    required this.status,
    required this.seasonId,
    required this.hlsPlaylistUrl,
    required this.videoDuration,
    required this.progress,
    required this.slug,
    required this.rank,
    required this.episodeIndex,
    required this.thumbnailList,
    required this.subtitles,
    required this.audioLanguages,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.videoBitrate,
    required this.videoFps,
    required this.newThumbnailImages,
    required this.description,
    required this.updatorId,
    required this.isUserSubscribed,
    required this.isSubscription,
    required this.monetization,
    required this.seriesSlug,
    required this.defaultLanguage,
    required this.availableSubtitles,
  });

  factory ChannelData.fromJson(Map<String, dynamic> json) {
    String stringValue(Object? value) => value?.toString() ?? '';

    return ChannelData(
      id: stringValue(json['_id']),
      s3JobStatus: json['s3_job_status'] as int? ?? 0,
      jobStatus: json['job_status'] as int? ?? 0,
      transcodePercentage: json['transcode_percentage'] as int? ?? 0,
      isTranscodeTriggered: json['is_transcode_triggered'] as bool? ?? false,
      isTranscoded: json['is_transcoded'] as bool? ?? false,
      viewCount: json['view_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? false,
      isArchived: json['is_archived'] as bool? ?? false,
      isPublished: json['is_published'] as bool? ?? false,
      watchDuration: json['watch_duration'] as int? ?? 0,
      deletedMp4: json['deleted_mp4'] as bool? ?? false,
      deletedHls: json['deleted_hls'] as bool? ?? false,
      deletedOffline: json['deleted_offline'] as bool? ?? false,
      useVideoThumbnailImageInstead:
          json['use_video_thumbnail_image_instead'] as bool? ?? false,
      isMiscReplace: json['is_misc_replace'] as bool? ?? false,
      isYellowStrip: json['is_yellow_strip'] as bool? ?? false,
      title: stringValue(json['title']),
      studioId: stringValue(json['studio_id']),
      masterDetailsId: stringValue(json['master_details_id']),
      status: stringValue(json['status']),
      seasonId: stringValue(json['season_id']),
      hlsPlaylistUrl: stringValue(json['hls_playlist_url']),
      videoDuration: stringValue(json['video_duration']),
      progress: json['progress'] as int? ?? 0,
      slug: stringValue(json['slug']),
      rank: stringValue(json['rank']),
      episodeIndex: json['episode_index'] as int? ?? 0,
      thumbnailList:
          (json['thumbnail_list'] as List<dynamic>?)
              ?.map((e) => Thumbnail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      subtitles: json['subtitles'] as List<dynamic>? ?? [],
      audioLanguages: json['audio_languages'] as List<dynamic>? ?? [],
      createdAt: DateTime.parse(stringValue(json['created_at'])),
      updatedAt: DateTime.parse(stringValue(json['updated_at'])),
      v: json['__v'] as int? ?? 0,
      videoBitrate: stringValue(json['video_bitrate']),
      videoFps: stringValue(json['video_fps']),
      newThumbnailImages: json['new_thumbnail_images'] is Map<String, dynamic>
          ? json['new_thumbnail_images'] as Map<String, dynamic>
          : {},
      description: stringValue(json['description']),
      updatorId: stringValue(json['updator_id']),
      isUserSubscribed: json['is_user_subscribed'] as bool? ?? false,
      isSubscription: json['is_subscription'] as bool? ?? false,
      monetization: json['monetization'] as int? ?? 0,
      seriesSlug: stringValue(json['seriesSlug']),
      defaultLanguage: stringValue(json['default_language']),
      availableSubtitles: json['available_subtitles'] as List<dynamic>? ?? [],
    );
  }
}

class Thumbnail {
  final bool default_;
  final bool isAutoGen;
  final String id;
  final Map<String, dynamic> images;

  Thumbnail({
    required this.default_,
    required this.isAutoGen,
    required this.id,
    required this.images,
  });

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(
      default_: json['default'] as bool? ?? false,
      isAutoGen: json['is_auto_gen'] as bool? ?? false,
      id: json['_id'] as String? ?? '',
      images: json['images'] as Map<String, dynamic>? ?? {},
    );
  }
}

class ChannelListResponse {
  final bool error;
  final String message;
  final ChannelListData response;
  final String status;
  final int statusCode;

  ChannelListResponse({
    required this.error,
    required this.message,
    required this.response,
    required this.status,
    required this.statusCode,
  });

  factory ChannelListResponse.fromJson(Map<String, dynamic> json) {
    String sv(Object? v) => v?.toString() ?? '';
    return ChannelListResponse(
      error: json['error'] as bool? ?? false,
      message: sv(json['message']),
      response: ChannelListData.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
      status: sv(json['status']),
      statusCode: json['statusCode'] as int? ?? 0,
    );
  }
}

class ChannelListData {
  final List<Channel> data;
  final int total;
  final int recordsPerPage;
  final int currentPage;
  final int totalPages;
  final dynamic previous;
  final dynamic next;

  ChannelListData({
    required this.data,
    required this.total,
    required this.recordsPerPage,
    required this.currentPage,
    required this.totalPages,
    required this.previous,
    required this.next,
  });

  factory ChannelListData.fromJson(Map<String, dynamic> json) {
    return ChannelListData(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => Channel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
      recordsPerPage: json['recordsPerPage'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      previous: json['previous'],
      next: json['next'],
    );
  }
}
