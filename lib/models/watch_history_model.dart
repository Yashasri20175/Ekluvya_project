class WatchHistoryItem {
  final String id;
  final String mediaId;
  final String profileId;
  final String profilePicture;
  final double videoDuration;
  final double watchedDuration;
  final MasterDetails masterDetails;
  final SeasonDetails seasonDetails;
  final String shoType;
  final String slug;
  final String studioName;
  final String studioSlug;
  final String thumbnailImage;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  WatchHistoryItem({
    required this.id,
    required this.mediaId,
    required this.profileId,
    required this.profilePicture,
    required this.videoDuration,
    required this.watchedDuration,
    required this.masterDetails,
    required this.seasonDetails,
    required this.shoType,
    required this.slug,
    required this.studioName,
    required this.studioSlug,
    required this.thumbnailImage,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory WatchHistoryItem.fromJson(Map<String, dynamic> json) {
    return WatchHistoryItem(
      id: json['_id'] as String? ?? '',
      mediaId: json['media_id'] as String? ?? '',
      profileId: json['profile_id'] as String? ?? '',
      profilePicture: json['profile_picture'] as String? ?? '',
      videoDuration: (json['video_duration'] as num?)?.toDouble() ?? 0.0,
      watchedDuration: (json['watched_duration'] as num?)?.toDouble() ?? 0.0,
      masterDetails: MasterDetails.fromJson(
        json['master_details'] as Map<String, dynamic>,
      ),
      seasonDetails: SeasonDetails.fromJson(
        json['season_details'] as Map<String, dynamic>,
      ),
      shoType: json['sho_type'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      studioName: json['studio_name'] as String? ?? '',
      studioSlug: json['studio_slug'] as String? ?? '',
      thumbnailImage: json['thumbnail_image'] as String? ?? '',
      title: json['title'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String? ?? ''),
      updatedAt: DateTime.parse(json['updated_at'] as String? ?? ''),
      v: json['__v'] as int? ?? 0,
    );
  }
}

class MasterDetails {
  final String id;
  final int isActive;
  final int status;
  final int monetization;
  final bool scheduled;
  final List<dynamic> cinematographyBy;
  final String description;
  final List<dynamic> directedBy;
  final List<dynamic> editingBy;
  final List<String> keywords;
  final String metaDescription;
  final String metaTitle;
  final Map<String, dynamic> metaTypes;
  final List<dynamic> musicBy;
  final Map<String, dynamic> newThumbnailImages;
  final List<dynamic> producedBy;
  final String slug;
  final List<dynamic> starsLeads;
  final String storyPlotSummary;
  final String studioName;
  final String studioSlug;
  final List<String> tags;
  final List<dynamic> thumbnailList;
  final String title;
  final List<dynamic> writingCredits;

  MasterDetails({
    required this.id,
    required this.isActive,
    required this.status,
    required this.monetization,
    required this.scheduled,
    required this.cinematographyBy,
    required this.description,
    required this.directedBy,
    required this.editingBy,
    required this.keywords,
    required this.metaDescription,
    required this.metaTitle,
    required this.metaTypes,
    required this.musicBy,
    required this.newThumbnailImages,
    required this.producedBy,
    required this.slug,
    required this.starsLeads,
    required this.storyPlotSummary,
    required this.studioName,
    required this.studioSlug,
    required this.tags,
    required this.thumbnailList,
    required this.title,
    required this.writingCredits,
  });

  factory MasterDetails.fromJson(Map<String, dynamic> json) {
    return MasterDetails(
      id: json['_id'] as String? ?? '',
      isActive: json['is_active'] as int? ?? 0,
      status: json['status'] as int? ?? 0,
      monetization: json['monetization'] as int? ?? 0,
      scheduled: json['scheduled'] as bool? ?? false,
      cinematographyBy: json['cinematography_by'] as List<dynamic>? ?? [],
      description: json['description'] as String? ?? '',
      directedBy: json['directed_by'] as List<dynamic>? ?? [],
      editingBy: json['editing_by'] as List<dynamic>? ?? [],
      keywords:
          (json['keywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      metaDescription: json['meta_description'] as String? ?? '',
      metaTitle: json['meta_title'] as String? ?? '',
      metaTypes: json['meta_types'] as Map<String, dynamic>? ?? {},
      musicBy: json['music_by'] as List<dynamic>? ?? [],
      newThumbnailImages:
          json['new_thumbnail_images'] as Map<String, dynamic>? ?? {},
      producedBy: json['produced_by'] as List<dynamic>? ?? [],
      slug: json['slug'] as String? ?? '',
      starsLeads: json['stars_leads'] as List<dynamic>? ?? [],
      storyPlotSummary: json['story_plot_summary'] as String? ?? '',
      studioName: json['studio_name'] as String? ?? '',
      studioSlug: json['studio_slug'] as String? ?? '',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      thumbnailList: json['thumbnail_list'] as List<dynamic>? ?? [],
      title: json['title'] as String? ?? '',
      writingCredits: json['writing_credits'] as List<dynamic>? ?? [],
    );
  }
}

class SeasonDetails {
  final String id;
  final bool isActive;
  final bool isArchived;
  final String title;

  SeasonDetails({
    required this.id,
    required this.isActive,
    required this.isArchived,
    required this.title,
  });

  factory SeasonDetails.fromJson(Map<String, dynamic> json) {
    return SeasonDetails(
      id: json['_id'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? false,
      isArchived: json['is_archived'] as bool? ?? false,
      title: json['title'] as String? ?? '',
    );
  }
}

class WatchHistoryResponse {
  final bool error;
  final String message;
  final WatchHistoryData response;
  final String status;
  final int statusCode;

  WatchHistoryResponse({
    required this.error,
    required this.message,
    required this.response,
    required this.status,
    required this.statusCode,
  });

  factory WatchHistoryResponse.fromJson(Map<String, dynamic> json) {
    return WatchHistoryResponse(
      error: json['error'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      response: WatchHistoryData.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
      status: json['status'] as String? ?? '',
      statusCode: json['statusCode'] as int? ?? 0,
    );
  }
}

class WatchHistoryData {
  final List<WatchHistoryItem> data;
  final dynamic nextPage;
  final int recordsPerPage;
  final int total;
  final int totalPages;

  WatchHistoryData({
    required this.data,
    required this.nextPage,
    required this.recordsPerPage,
    required this.total,
    required this.totalPages,
  });

  factory WatchHistoryData.fromJson(Map<String, dynamic> json) {
    return WatchHistoryData(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => WatchHistoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      nextPage: json['nextPage'],
      recordsPerPage: json['recordsPerPage'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }
}
