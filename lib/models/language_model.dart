class Language {
  final String code;
  final String name;
  final bool isDefault;

  Language({required this.code, required this.name, required this.isDefault});

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      code: json['code'] as String,
      name: json['name'] as String,
      isDefault: json['is_default'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'name': name, 'is_default': isDefault};
  }

  @override
  String toString() {
    return 'Language(code: $code, name: $name, isDefault: $isDefault)';
  }
}
