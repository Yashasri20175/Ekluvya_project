class Chapter {
  final List<String> streamcollectionIds;
  final List<String> courseIds;
  final List<String> classIds;
  final List<String> subjectIds;
  final List<String> subjectid;
  final bool isActive;
  final bool isArchived;
  final String id;
  final int order;
  final String title;
  final String hlsUrl;
  final String slug;

  Chapter({
    required this.streamcollectionIds,
    required this.courseIds,
    required this.classIds,
    required this.subjectIds,
    required this.subjectid,
    required this.isActive,
    required this.isArchived,
    required this.id,
    required this.order,
    required this.title,
    required this.hlsUrl,
    required this.slug,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      streamcollectionIds:
          (json['streamcollection_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      courseIds:
          (json['course_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      classIds:
          (json['class_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      subjectIds:
          (json['subject_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      subjectid:
          (json['subjectid'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isActive: json['is_active'] as bool? ?? false,
      isArchived: json['is_archived'] as bool? ?? false,
      id: json['_id'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      hlsUrl: json['hls_url'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}

class ChapterListResponse {
  final bool error;
  final String message;
  final ChapterListData response;
  final String status;
  final int statusCode;

  ChapterListResponse({
    required this.error,
    required this.message,
    required this.response,
    required this.status,
    required this.statusCode,
  });

  factory ChapterListResponse.fromJson(Map<String, dynamic> json) {
    return ChapterListResponse(
      error: json['error'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      response: ChapterListData.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
      status: json['status'] as String? ?? '',
      statusCode: json['statusCode'] as int? ?? 0,
    );
  }
}

class ChapterListData {
  final List<Chapter> chapterList;

  ChapterListData({required this.chapterList});

  factory ChapterListData.fromJson(Map<String, dynamic> json) {
    return ChapterListData(
      chapterList:
          (json['chapterList'] as List<dynamic>?)
              ?.map((e) => Chapter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
