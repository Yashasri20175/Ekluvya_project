class Subject {
  final String id;
  final List<String> courseIds;
  final List<ClassInfo> classIds;
  final bool isActive;
  final bool isArchived;
  final int order;
  final String title;
  final String slug;

  Subject({
    required this.id,
    required this.courseIds,
    required this.classIds,
    required this.isActive,
    required this.isArchived,
    required this.order,
    required this.title,
    required this.slug,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['_id'] as String? ?? '',
      courseIds:
          (json['course_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      classIds:
          (json['class_ids'] as List<dynamic>?)
              ?.map((e) => ClassInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isActive: json['is_active'] as bool? ?? false,
      isArchived: json['is_archived'] as bool? ?? false,
      order: json['order'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}

class ClassInfo {
  final String id;
  final int order;
  final String title;

  ClassInfo({required this.id, required this.order, required this.title});

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      id: json['_id'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      title: json['title'] as String? ?? '',
    );
  }
}

class SubjectsResponse {
  final bool error;
  final String message;
  final SubjectsData response;
  final String status;
  final int statusCode;

  SubjectsResponse({
    required this.error,
    required this.message,
    required this.response,
    required this.status,
    required this.statusCode,
  });

  factory SubjectsResponse.fromJson(Map<String, dynamic> json) {
    return SubjectsResponse(
      error: json['error'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      response: SubjectsData.fromJson(json['response'] as Map<String, dynamic>),
      status: json['status'] as String? ?? '',
      statusCode: json['statusCode'] as int? ?? 0,
    );
  }
}

class SubjectsData {
  final List<Subject> data;
  final int total;
  final int recordsPerPage;
  final int currentPage;
  final int totalPages;
  final dynamic previous;
  final dynamic next;

  SubjectsData({
    required this.data,
    required this.total,
    required this.recordsPerPage,
    required this.currentPage,
    required this.totalPages,
    required this.previous,
    required this.next,
  });

  factory SubjectsData.fromJson(Map<String, dynamic> json) {
    return SubjectsData(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => Subject.fromJson(e as Map<String, dynamic>))
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
