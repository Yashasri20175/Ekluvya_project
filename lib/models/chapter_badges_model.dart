class ChapterBadgesResponse {
  final bool error;
  final String message;
  final ChapterBadgesData response;
  final String status;
  final int statusCode;

  ChapterBadgesResponse({
    required this.error,
    required this.message,
    required this.response,
    required this.status,
    required this.statusCode,
  });

  factory ChapterBadgesResponse.fromJson(Map<String, dynamic> json) {
    return ChapterBadgesResponse(
      error: json['error'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      response: ChapterBadgesData.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
      status: json['status'] as String? ?? '',
      statusCode: json['statusCode'] as int? ?? 0,
    );
  }
}

class ChapterBadgesData {
  final String chapterId;
  final String courseId;
  final dynamic subjectId;
  final dynamic classId;
  final ChapterWinners winners;

  ChapterBadgesData({
    required this.chapterId,
    required this.courseId,
    required this.subjectId,
    required this.classId,
    required this.winners,
  });

  factory ChapterBadgesData.fromJson(Map<String, dynamic> json) {
    return ChapterBadgesData(
      chapterId: json['chapterId'] as String? ?? '',
      courseId: json['courseId'] as String? ?? '',
      subjectId: json['subjectId'],
      classId: json['classId'],
      winners: ChapterWinners.fromJson(json['winners'] as Map<String, dynamic>),
    );
  }
}

class ChapterWinners {
  final List<StudioBadge> studios;
  final Map<String, String> winners;

  ChapterWinners({required this.studios, required this.winners});

  factory ChapterWinners.fromJson(Map<String, dynamic> json) {
    return ChapterWinners(
      studios:
          (json['studios'] as List<dynamic>?)
              ?.map((e) => StudioBadge.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      winners:
          (json['winners'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as String),
          ) ??
          {},
    );
  }
}

class StudioBadge {
  final String channelId;
  final double mostWatchedScore;
  final double mostLovedScore;
  final List<Badge> badges;

  StudioBadge({
    required this.channelId,
    required this.mostWatchedScore,
    required this.mostLovedScore,
    required this.badges,
  });

  factory StudioBadge.fromJson(Map<String, dynamic> json) {
    return StudioBadge(
      channelId: json['channelId'] as String? ?? '',
      mostWatchedScore: (json['mostWatchedScore'] as num?)?.toDouble() ?? 0.0,
      mostLovedScore: (json['mostLovedScore'] as num?)?.toDouble() ?? 0.0,
      badges:
          (json['badges'] as List<dynamic>?)
              ?.map((e) => Badge.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Badge {
  final String type;
  final String label;
  final double score;
  final bool isWinner;

  Badge({
    required this.type,
    required this.label,
    required this.score,
    required this.isWinner,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      type: json['type'] as String? ?? '',
      label: json['label'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      isWinner: json['isWinner'] as bool? ?? false,
    );
  }
}
