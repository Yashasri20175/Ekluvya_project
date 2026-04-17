class CourseClass {
  final String id;
  final List<String> courseIds;
  final bool isActive;
  final bool isArchived;
  final int order;
  final String title;
  final String slug;

  CourseClass({
    required this.id,
    required this.courseIds,
    required this.isActive,
    required this.isArchived,
    required this.order,
    required this.title,
    required this.slug,
  });

  factory CourseClass.fromJson(Map<String, dynamic> json) {
    return CourseClass(
      id: json['_id'] as String? ?? '',
      courseIds:
          (json['course_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
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

class ClassesResponse {
  final int statusCode;
  final String status;
  final bool error;
  final ClassesData response;

  ClassesResponse({
    required this.statusCode,
    required this.status,
    required this.error,
    required this.response,
  });

  factory ClassesResponse.fromJson(Map<String, dynamic> json) {
    return ClassesResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      error: json['error'] as bool? ?? false,
      response: ClassesData.fromJson(
        json['response'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class ClassesData {
  final List<CourseClass> data;
  final int total;

  ClassesData({required this.data, required this.total});

  factory ClassesData.fromJson(Map<String, dynamic> json) {
    return ClassesData(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => CourseClass.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
    );
  }
}
