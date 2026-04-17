import 'dart:async' as dart_async;
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ekluvya_app/core/constants/app_constants.dart';
import 'package:ekluvya_app/core/errors/app_exception.dart';
import 'package:ekluvya_app/core/utils/logger.dart';
import 'package:ekluvya_app/models/banner_model.dart';
import 'package:ekluvya_app/models/class_model.dart';
import 'package:ekluvya_app/models/channel_model.dart';
import 'package:ekluvya_app/models/channel_ratings_model.dart';
import 'package:ekluvya_app/models/chapter_badges_model.dart';
import 'package:ekluvya_app/models/chapter_model.dart';
import 'package:ekluvya_app/models/home_stream_model.dart';
import 'package:ekluvya_app/models/language_model.dart';
import 'package:ekluvya_app/models/signed_cookies_model.dart';
import 'package:ekluvya_app/models/subject_model.dart';
import 'package:ekluvya_app/models/watch_history_model.dart';

class ApiService {
  static const _tag = 'ApiService';

  Map<String, String> get _jsonHeaders => {'Content-Type': 'application/json'};

  // ── Error handler ─────────────────────────────────────────────────────────

  Never _handleNetworkError(Object e, StackTrace st, String label) {
    AppLogger.error(_tag, '$label → ${e.runtimeType}: $e', e, st);

    if (e is dart_async.TimeoutException) throw const RequestTimeoutException();
    if (e is IOException) throw const NetworkException();
    if (e is http.ClientException) {
      AppLogger.error(_tag, 'ClientException detail: ${e.message}');
      final msg = e.message.toLowerCase();
      if (msg.contains('lookup') || msg.contains('network')) {
        throw const NetworkException();
      }
      throw ServerException('Connection failed: ${e.message}');
    }
    throw ServerException('Unexpected error: ${e.runtimeType}');
  }

  // ── Response decoder ──────────────────────────────────────────────────────

  Map<String, dynamic> _decode(http.Response res, String label) {
    AppLogger.info(_tag, '$label → ${res.statusCode}');
    AppLogger.info(_tag, 'BODY: ${res.body}'); // ← full body logged

    if (res.body.trimLeft().startsWith('<!')) {
      AppLogger.error(_tag, '$label returned HTML — check URL / headers');
      throw const ParseException();
    }
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const ParseException();
    } on FormatException catch (e) {
      AppLogger.error(_tag, 'JSON parse failed: $e | body: ${res.body}');
      throw const ParseException();
    }
  }

  // ── Generic helpers ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    String? overrideUrl,
    Map<String, String>? headers,
  }) async {
    final url = overrideUrl ?? '${AppConstants.usersBaseUrl}$path';
    AppLogger.info(_tag, 'POST $url | ${jsonEncode(body)}');
    try {
      final res = await http
          .post(
            Uri.parse(url),
            headers: headers ?? _jsonHeaders,
            body: jsonEncode(body),
          )
          .timeout(AppConstants.apiTimeout);
      return _decode(res, url);
    } catch (e, st) {
      if (e is AppException) rethrow;
      _handleNetworkError(e, st, 'POST $url');
    }
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    String? overrideUrl,
    Map<String, String>? headers,
  }) async {
    final url = overrideUrl ?? '${AppConstants.usersBaseUrl}$path';
    AppLogger.info(_tag, 'GET $url');
    try {
      final res = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(AppConstants.apiTimeout);
      return _decode(res, url);
    } catch (e, st) {
      if (e is AppException) rethrow;
      _handleNetworkError(e, st, 'GET $url');
    }
  }

  // ── Token ─────────────────────────────────────────────────────────────────

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  /// Step 1 — identify user (tells us if they're new or existing)
  Future<Map<String, dynamic>> identifyUser(String input) =>
      _post('/auth/identify-user', {'identifier': input});

  /// Step 2a — send OTP
  /// Params as per developer docs: code, to, is_phone_verified
  Future<Map<String, dynamic>> sendOtp(String phone) =>
      _post('/auth/send-newOtp', {
        'code': AppConstants.countryCode, // "+91"
        'to': phone,
        'is_phone_verified': 0,
      });

  /// Step 3a — verify OTP
  /// Params as per developer docs: phone, otp, browsername, deviceDetail,
  /// is_phone_verified
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) =>
      _post('/auth/validate-otp', {
        'phone': phone,
        'otp': otp,
        'browsername': '', // empty string per developer docs
        'deviceDetail': Platform.isIOS ? 'iPhone' : 'Android',
        'is_phone_verified': 1,
      });

  /// Step 4a — phone login (called after OTP is verified)
  /// Uses 'phone' param — confirmed from browser network trace.
  /// Developer docs had copy-paste error (showed sendOtp params instead).
  Future<Map<String, dynamic>> phoneLogin(String phone) =>
      _post('/auth/phone-login', {
        'phone': phone, // ← correct field name
        'is_phone_verified': 1,
        'browsername': '',
        'deviceDetail': Platform.isIOS ? 'iPhone' : 'Android',
      });

  Future<Map<String, dynamic>> googleLogin(String idToken) =>
      _post('/auth/login', {'google_auth_id': idToken});

  /// Password login for student accounts
  Future<Map<String, dynamic>> studentLogin({
    required String username,
    required String password,
  }) async {
    final decoded = await _post('/auth/student-login', {
      'username': username,
      'password': password,
    });
    final ok = decoded['status'] == 'success' || decoded['statusCode'] == 200;
    if (ok) {
      final response = decoded['response'];
      if (response is Map) {
        final devices = response['get_devices'];
        if (devices is List && devices.isNotEmpty && devices[0] is Map) {
          final token = devices[0]['access_token']?.toString();
          if (token != null && token.isNotEmpty) await saveToken(token);
        }
      }
    }
    return decoded;
  }

  // ── Registration ──────────────────────────────────────────────────────────

  /// Params as per developer docs:
  /// first_name, email, phone, login_type, country_code, iso,
  /// is_phone_verified, browsername, deviceDetail
  /// (last_name, gender, dob, preparing_for, profile_picture are optional extras)
  Future<Map<String, dynamic>> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String gender,
    required String preparingFor,
    required DateTime dob,
    File? image,
  }) async {
    final uri = Uri.parse('${AppConstants.usersBaseUrl}/auth/register');
    final request = http.MultipartRequest('POST', uri)
      ..fields.addAll({
        // ── Required fields (from developer docs) ──
        'first_name': firstName,
        'email': email,
        'phone': phone,
        'login_type': 'normal', // required per developer docs
        'country_code': AppConstants.countryCode,
        'iso': 'in', // ISO country code per developer docs
        'is_phone_verified': '1',
        'browsername': '',
        'deviceDetail': Platform.isIOS ? 'iPhone' : 'Android',
        // ── Optional extras (original fields) ──
        'last_name': lastName,
        'gender': gender,
        'preparing_for': preparingFor,
        'dob':
            '${dob.day.toString().padLeft(2, '0')}/'
            '${dob.month.toString().padLeft(2, '0')}/'
            '${dob.year}',
      });

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profile_picture', image.path),
      );
    }

    AppLogger.info(_tag, 'POST register | fields: ${request.fields}');

    try {
      final streamed = await request.send().timeout(AppConstants.apiTimeout);
      final body = await streamed.stream.bytesToString();
      AppLogger.info(_tag, 'register BODY: $body');

      if (body.trimLeft().startsWith('<!')) throw const ParseException();
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const ParseException();
    } catch (e, st) {
      if (e is AppException) rethrow;
      _handleNetworkError(e, st, 'POST register');
    }
  }

  // ── Profile / Media ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    return _get(
      '/profile',
      overrideUrl: '${AppConstants.mediaBaseUrl}/profile',
      headers: {'Authorization': 'Bearer ${token ?? ''}'},
    );
  }

  Future<Map<String, dynamic>> fetchCommonFeatures() =>
      _get('/common', overrideUrl: '${AppConstants.mediaBaseUrl}/common');

  // ── Banners ───────────────────────────────────────────────────────────────

  /// Fetch banner images from the server
  /// API endpoint: /mediaview/api/v1/homebanners/banner-images
  Future<List<Banner>> fetchBanners() async {
    try {
      final response = await _get(
        '/homebanners/banner-images',
        overrideUrl: '${AppConstants.mediaBaseUrl}/homebanners/banner-images',
      );

      AppLogger.info(_tag, 'fetchBanners response: $response');

      // API returns data nested under 'response' key
      final responseData = response['response'] as Map<String, dynamic>? ?? {};
      final data = responseData['data'] as List<dynamic>? ?? [];
      AppLogger.info(_tag, 'fetchBanners data length: ${data.length}');

      final banners = data.map((item) {
        AppLogger.info(_tag, 'Processing banner item: $item');
        return Banner.fromJson(item as Map<String, dynamic>);
      }).toList();

      // Sort by order field
      banners.sort((a, b) => a.order.compareTo(b.order));

      AppLogger.info(_tag, 'fetchBanners returning ${banners.length} banners');
      for (var banner in banners) {
        AppLogger.info(
          _tag,
          'Banner: ${banner.title}, img: ${banner.bannerImg}',
        );
      }

      return banners;
    } catch (e, st) {
      AppLogger.error(_tag, 'fetchBanners failed: $e', e, st);
      rethrow;
    }
  }

  Future<List<HomeStream>> fetchHomeStreams({
    int limit = 5,
    int insideLimit = 12,
  }) async {
    try {
      final response = await _get(
        '/home/gethome-data?limit=$limit&inside_limit=$insideLimit',
        overrideUrl:
            '${AppConstants.mediaBaseUrl}/home/gethome-data?limit=$limit&inside_limit=$insideLimit',
      );

      AppLogger.info(_tag, 'fetchHomeStreams response: $response');

      final responseData = response['response'] as Map<String, dynamic>?;
      final rawData = response['data'] ?? responseData?['data'];
      final dataList = rawData is List ? rawData : <dynamic>[];

      if (dataList.isEmpty) {
        AppLogger.info(
          _tag,
          'fetchHomeStreams found no data in response keys. response["data"]=${response['data']} response["response"]=$responseData',
        );
      }

      final streams = dataList
          .map((item) => HomeStream.fromJson(item as Map<String, dynamic>))
          .toList();

      AppLogger.info(
        _tag,
        'fetchHomeStreams returning ${streams.length} streams',
      );
      return streams;
    } catch (e, st) {
      AppLogger.error(_tag, 'fetchHomeStreams failed: $e', e, st);
      rethrow;
    }
  }

  Future<String> fetchAppLogoUrl() async {
    try {
      final response = await _get(
        '/app-logo',
        overrideUrl: '${AppConstants.mediaBaseUrl}/app-logo',
      );

      AppLogger.info(_tag, 'fetchAppLogoUrl response: $response');
      final responseData = response['response'] as Map<String, dynamic>?;
      final rawData = response['data'] ?? responseData?['data'];
      final logoItems = rawData is List ? rawData : <dynamic>[];
      if (logoItems.isEmpty) {
        throw ServerException('Logo data is empty');
      }

      final firstItem = logoItems.first as Map<String, dynamic>;
      final path = firstItem['path'] as Map<String, dynamic>?;
      final logoPath = path?['light'] as String? ?? path?['dark'] as String?;
      if (logoPath == null || logoPath.isEmpty) {
        throw ServerException('Logo path missing');
      }

      if (logoPath.startsWith('http')) {
        return logoPath;
      }

      final normalizedPath = logoPath.startsWith('/')
          ? logoPath.substring(1)
          : logoPath;
      final fullUrl = '${AppConstants.cloudFrontBaseUrl}/$normalizedPath';
      AppLogger.info(_tag, 'Constructed app logo URL: $fullUrl');
      return fullUrl;
    } catch (e, st) {
      AppLogger.error(_tag, 'fetchAppLogoUrl failed: $e', e, st);
      rethrow;
    }
  }

  /// Fetch supported languages from the server
  /// API endpoint: /mediaview/api/v1/language
  Future<List<Language>> fetchLanguages() async {
    try {
      final response = await _get('/language');

      AppLogger.info(_tag, 'fetchLanguages response: $response');

      // API returns data nested under 'response' key or directly as array
      final responseData = response['response'] as Map<String, dynamic>? ?? {};
      final data =
          responseData['data'] as List<dynamic>? ??
          response['data'] as List<dynamic>? ??
          [];

      if (data.isEmpty) {
        // If response is a single language object, wrap it in a list
        final singleLanguage = Language.fromJson(response);
        return [singleLanguage];
      }

      final languages = data.map((item) {
        AppLogger.info(_tag, 'Processing language item: $item');
        return Language.fromJson(item as Map<String, dynamic>);
      }).toList();

      AppLogger.info(
        _tag,
        'fetchLanguages returning ${languages.length} languages',
      );
      return languages;
    } catch (e, st) {
      AppLogger.error(_tag, 'fetchLanguages failed: $e', e, st);
      rethrow;
    }
  }

  /// Build full CloudFront URL for banner image
  String getBannerImageUrl(String bannerImg) {
    const cloudFrontBaseUrl = 'https://d38zvxejdrf8bt.cloudfront.net/';
    final normalizedPath = bannerImg.startsWith('/')
        ? bannerImg.substring(1)
        : bannerImg;
    final fullUrl = '$cloudFrontBaseUrl$normalizedPath';
    AppLogger.info(_tag, 'Constructed banner URL: $fullUrl');
    return fullUrl;
  }

  /// Resolve an hls_playlist_url to a full URL.
  /// Already-full URLs (e.g. from player.tutorac.org) are returned as-is.
  /// Relative paths are prefixed with the CloudFront base.
  String getHlsUrl(String hlsPath) {
    if (hlsPath.trim().isEmpty) return '';
    if (hlsPath.startsWith('http')) return hlsPath;
    final path = hlsPath.startsWith('/') ? hlsPath.substring(1) : hlsPath;
    return '${AppConstants.cloudFrontBaseUrl}/$path';
  }

  String getMediaImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    final normalizedPath = imagePath.startsWith('/')
        ? imagePath.substring(1)
        : imagePath;

    if (normalizedPath.startsWith('course-images/') ||
        normalizedPath.startsWith('banner-images/')) {
      const cloudFrontBaseUrl = 'https://d38zvxejdrf8bt.cloudfront.net/';
      final fullUrl = '$cloudFrontBaseUrl$normalizedPath';
      AppLogger.info(_tag, 'Constructed CloudFront media URL: $fullUrl');
      return fullUrl;
    }

    const apiPrefix = '/api/v1';
    final baseUrl = AppConstants.mediaBaseUrl.endsWith(apiPrefix)
        ? AppConstants.mediaBaseUrl.replaceFirst(apiPrefix, '')
        : AppConstants.mediaBaseUrl;
    final fullUrl = '$baseUrl/$normalizedPath';
    AppLogger.info(_tag, 'Constructed media image URL: $fullUrl');
    return fullUrl;
  }

  // ── Subjects ───────────────────────────────────────────────────────────────

  /// Fetch subjects for a course and class
  /// API endpoint: /mediaview/api/v1/home/subjects
  Future<SubjectsResponse> fetchSubjects({
    required String courseId,
    required String classId,
    int page = 1,
    int limit = 25,
    bool isPagination = true,
  }) async {
    try {
      final response = await _get(
        '/home/subjects?courseId=$courseId&classId=$classId&page=$page&limit=$limit&is_pagination=$isPagination',
        overrideUrl:
            '${AppConstants.mediaBaseUrl}/home/subjects?courseId=$courseId&classId=$classId&page=$page&limit=$limit&is_pagination=$isPagination',
      );

      AppLogger.info(_tag, 'fetchSubjects response: $response');
      return SubjectsResponse.fromJson(response);
    } catch (e, st) {
      AppLogger.error(_tag, 'fetchSubjects failed: $e', e, st);
      rethrow;
    }
  }

  // ── Classes ────────────────────────────────────────────────────────────────

  Future<ClassesResponse> fetchClasses({
    required String courseId,
    int limit = 15,
  }) async {
    try {
      final response = await _get(
        '/home/classes?courseId=$courseId&page=&limit=$limit&is_pagination=true',
        overrideUrl:
            '${AppConstants.mediaBaseUrl}/home/classes?courseId=$courseId&page=&limit=$limit&is_pagination=true',
      );
      AppLogger.info(_tag, 'fetchClasses response: $response');
      return ClassesResponse.fromJson(response);
    } catch (e, st) {
      AppLogger.error(_tag, 'fetchClasses failed: $e', e, st);
      rethrow;
    }
  }

  // ── Watch History ──────────────────────────────────────────────────────────

  /// Fetch user's watch history
  /// API endpoint: /useractions/api/v1/watch-history
  Future<WatchHistoryResponse> fetchWatchHistory({
    String watchType = 'continue_watch',
    bool isPromo = true,
    required String profileId,
    int limit = 14,
  }) async {
    final token = await getToken();
    try {
      final response = await _get(
        '/watch-history?watch_type=$watchType&is_promo=$isPromo&profile_id=$profileId&limit=$limit',
        overrideUrl:
            'https://stg-ottapi.ekluvya.guru/useractions/api/v1/watch-history?watch_type=$watchType&is_promo=$isPromo&profile_id=$profileId&limit=$limit',
        headers: {'Authorization': 'Bearer ${token ?? ''}'},
      );

      AppLogger.info(_tag, 'fetchWatchHistory response: $response');
      return WatchHistoryResponse.fromJson(response);
    } catch (e, st) {
      AppLogger.error(_tag, 'fetchWatchHistory failed: $e', e, st);
      rethrow;
    }
  }

  // ── Chapters ───────────────────────────────────────────────────────────────

  /// Fetch chapters for a subject
  /// API endpoint: /mediaview/api/v1/home/all/chapterlist
  Future<ChapterListResponse> fetchChapters({
    required String courseId,
    required String subjectId,
    required String classId,
  }) async {
    try {
      final response = await _get(
        '/home/all/chapterlist?courseId=$courseId&subjectId=$subjectId&classId=$classId',
        overrideUrl:
            '${AppConstants.mediaBaseUrl}/home/all/chapterlist?courseId=$courseId&subjectId=$subjectId&classId=$classId',
      );

      AppLogger.info(_tag, 'fetchChapters response: $response');
      return ChapterListResponse.fromJson(response);
    } catch (e, st) {
      AppLogger.error(_tag, 'fetchChapters failed: $e', e, st);
      rethrow;
    }
  }

  // ── Channels ───────────────────────────────────────────────────────────────

  /// Fetch channels/videos for a chapter
  /// API endpoint: /mediaview/api/v1/home/channel-list
  Future<ChannelListResponse> fetchChannels({
    required String courseId,
    required String subjectId,
    required String classId,
    required String chapterId,
    int limit = 20,
    int insideLimit = 12,
  }) async {
    try {
      final response = await _get(
        '/home/channel-list?courseId=$courseId&subjectId=$subjectId&classId=$classId&chapterId=$chapterId&limit=$limit&inside_limit=$insideLimit',
        overrideUrl:
            '${AppConstants.mediaBaseUrl}/home/channel-list?courseId=$courseId&subjectId=$subjectId&classId=$classId&chapterId=$chapterId&limit=$limit&inside_limit=$insideLimit',
      );

      AppLogger.info(_tag, 'fetchChannels response: $response');
      return ChannelListResponse.fromJson(response);
    } catch (e, st) {
      AppLogger.error(_tag, 'fetchChannels failed: $e', e, st);
      rethrow;
    }
  }

  // ── Chapter Badges ─────────────────────────────────────────────────────────

  /// Fetch badges for a chapter
  /// API endpoint: /mediaview/api/v1/badges/chapter-badges
  Future<ChapterBadgesResponse> fetchChapterBadges({
    required String courseId,
    required String chapterId,
  }) async {
    try {
      final response = await _get(
        '/badges/chapter-badges?courseId=$courseId&chapterId=$chapterId',
        overrideUrl:
            '${AppConstants.mediaBaseUrl}/badges/chapter-badges?courseId=$courseId&chapterId=$chapterId',
      );

      AppLogger.info(_tag, 'fetchChapterBadges response: $response');
      return ChapterBadgesResponse.fromJson(response);
    } catch (e, st) {
      AppLogger.error(_tag, 'fetchChapterBadges failed: $e', e, st);
      rethrow;
    }
  }

  // ── Channel Ratings ────────────────────────────────────────────────────────

  /// Fetch ratings for channels in a chapter
  /// API endpoint: /mediaview/api/v1/ratings/channel-ratings
  Future<ChannelRatingsResponse> fetchChannelRatings({
    required String chapterId,
    required String courseId,
    required String subjectId,
    required String classId,
  }) async {
    try {
      final response = await _get(
        '/ratings/channel-ratings?chapterId=$chapterId&courseId=$courseId&subjectId=$subjectId&classId=$classId',
        overrideUrl:
            '${AppConstants.mediaBaseUrl}/ratings/channel-ratings?chapterId=$chapterId&courseId=$courseId&subjectId=$subjectId&classId=$classId',
      );

      AppLogger.info(_tag, 'fetchChannelRatings response: $response');
      return ChannelRatingsResponse.fromJson(response);
    } catch (e, st) {
      AppLogger.error(_tag, 'fetchChannelRatings failed: $e', e, st);
      rethrow;
    }
  }

  // ── Signed Cookies ─────────────────────────────────────────────────────────

  /// Get signed cookies for accessing protected content
  /// API endpoint: /mediaview/api/get-signed-cookies
  Future<SignedCookiesResponse> getSignedCookies() async {
    try {
      final response = await _get(
        '/get-signed-cookies',
        overrideUrl: '${AppConstants.mediaBaseUrl}/get-signed-cookies',
      );

      AppLogger.info(_tag, 'getSignedCookies response: $response');
      return SignedCookiesResponse.fromJson(response);
    } catch (e, st) {
      AppLogger.error(_tag, 'getSignedCookies failed: $e', e, st);
      rethrow;
    }
  }
}
