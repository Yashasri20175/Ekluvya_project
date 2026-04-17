class ChannelRatingsResponse {
  final bool error;
  final String message;
  final ChannelRatingsData response;
  final String status;
  final int statusCode;

  ChannelRatingsResponse({
    required this.error,
    required this.message,
    required this.response,
    required this.status,
    required this.statusCode,
  });

  factory ChannelRatingsResponse.fromJson(Map<String, dynamic> json) {
    String sv(Object? v) => v?.toString() ?? '';
    return ChannelRatingsResponse(
      error: json['error'] as bool? ?? false,
      message: sv(json['message']),
      response: ChannelRatingsData.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
      status: sv(json['status']),
      statusCode: json['statusCode'] as int? ?? 0,
    );
  }
}

class ChannelRatingsData {
  final List<ChannelRating> channels;
  final int totalChannels;

  ChannelRatingsData({required this.channels, required this.totalChannels});

  factory ChannelRatingsData.fromJson(Map<String, dynamic> json) {
    return ChannelRatingsData(
      channels:
          (json['channels'] as List<dynamic>?)
              ?.map((e) => ChannelRating.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalChannels: json['total_channels'] as int? ?? 0,
    );
  }
}

class ChannelRating {
  final String channelId;
  final String channelSlug;
  final String channelDescription;
  final double averageRating;
  final int totalRatings;
  final int totalContent;
  final int ratedContent;
  final List<StarDistribution> starDistribution;
  final dynamic userRating;

  ChannelRating({
    required this.channelId,
    required this.channelSlug,
    required this.channelDescription,
    required this.averageRating,
    required this.totalRatings,
    required this.totalContent,
    required this.ratedContent,
    required this.starDistribution,
    required this.userRating,
  });

  factory ChannelRating.fromJson(Map<String, dynamic> json) {
    String sv(Object? v) => v?.toString() ?? '';
    return ChannelRating(
      channelId: sv(json['channelId']),
      channelSlug: sv(json['channelSlug']),
      channelDescription: sv(json['channelDescription']),
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: json['total_ratings'] as int? ?? 0,
      totalContent: json['total_content'] as int? ?? 0,
      ratedContent: json['rated_content'] as int? ?? 0,
      starDistribution:
          (json['star_distribution'] as List<dynamic>?)
              ?.map((e) => StarDistribution.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      userRating: json['user_rating'],
    );
  }
}

class StarDistribution {
  final int star;
  final int count;
  final int percentage;

  StarDistribution({
    required this.star,
    required this.count,
    required this.percentage,
  });

  factory StarDistribution.fromJson(Map<String, dynamic> json) {
    return StarDistribution(
      star: json['star'] as int? ?? 0,
      count: json['count'] as int? ?? 0,
      percentage: json['percentage'] as int? ?? 0,
    );
  }
}
