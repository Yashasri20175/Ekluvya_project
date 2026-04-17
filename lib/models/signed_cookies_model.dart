class SignedCookiesResponse {
  final String message;
  final DateTime expires;
  final bool isProduction;
  final SignedCookies cookies;

  SignedCookiesResponse({
    required this.message,
    required this.expires,
    required this.isProduction,
    required this.cookies,
  });

  factory SignedCookiesResponse.fromJson(Map<String, dynamic> json) {
    return SignedCookiesResponse(
      message: json['message'] as String? ?? '',
      expires: DateTime.parse(json['expires'] as String? ?? ''),
      isProduction: json['isProduction'] as bool? ?? false,
      cookies: SignedCookies.fromJson(json['cookies'] as Map<String, dynamic>),
    );
  }
}

class SignedCookies {
  final String cloudFrontKeyPairId;
  final String cloudFrontPolicy;
  final String cloudFrontSignature;

  SignedCookies({
    required this.cloudFrontKeyPairId,
    required this.cloudFrontPolicy,
    required this.cloudFrontSignature,
  });

  factory SignedCookies.fromJson(Map<String, dynamic> json) {
    return SignedCookies(
      cloudFrontKeyPairId: json['CloudFront-Key-Pair-Id'] as String? ?? '',
      cloudFrontPolicy: json['CloudFront-Policy'] as String? ?? '',
      cloudFrontSignature: json['CloudFront-Signature'] as String? ?? '',
    );
  }
}
