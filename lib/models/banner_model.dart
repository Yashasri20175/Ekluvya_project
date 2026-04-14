class Banner {
  final String title;
  final int order;
  final String bannerImg;

  Banner({required this.title, required this.order, required this.bannerImg});

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      title: json['title'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      bannerImg: json['bannerImg'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'order': order, 'bannerImg': bannerImg};
  }
}
