class HomeStream {
  final String title;
  final int count;
  final int totalVideos;
  final List<CourseCategory> categories;

  HomeStream({
    required this.title,
    required this.count,
    required this.totalVideos,
    required this.categories,
  });

  factory HomeStream.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final categories = <CourseCategory>[];
    if (data is List) {
      categories.addAll(
        data.map(
          (item) => CourseCategory.fromJson(item as Map<String, dynamic>),
        ),
      );
    }

    return HomeStream(
      title: (json['title'] as String?)?.toUpperCase() ?? '',
      count: json['count'] is int
          ? json['count'] as int
          : int.tryParse('${json['count']}') ?? 0,
      totalVideos: json['totalVideos'] is int
          ? json['totalVideos'] as int
          : int.tryParse('${json['totalVideos']}') ?? 0,
      categories: categories,
    );
  }
}

class CourseCategory {
  final String title;
  final String profilePicture;
  final String classTitle;
  final String subjectTitle;

  CourseCategory({
    required this.title,
    required this.profilePicture,
    required this.classTitle,
    required this.subjectTitle,
  });

  factory CourseCategory.fromJson(Map<String, dynamic> json) {
    final classDetails = json['class_details'];
    final subjectTitle = json['subjectTitle'];

    return CourseCategory(
      title: json['title'] as String? ?? '',
      profilePicture: json['profile_picture'] as String? ?? '',
      classTitle: classDetails is Map<String, dynamic>
          ? (classDetails['title'] as String? ?? '')
          : '',
      subjectTitle: subjectTitle is Map<String, dynamic>
          ? (subjectTitle['title'] as String? ?? '')
          : '',
    );
  }
}
