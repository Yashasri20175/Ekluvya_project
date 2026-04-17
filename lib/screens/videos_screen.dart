import 'package:ekluvya_app/core/utils/logger.dart';
import 'package:ekluvya_app/models/channel_model.dart';
import 'package:ekluvya_app/models/channel_ratings_model.dart';
import 'package:ekluvya_app/models/chapter_badges_model.dart';
import 'package:ekluvya_app/models/chapter_model.dart';
import 'package:ekluvya_app/screens/video_player_screen.dart';
import 'package:ekluvya_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideosScreen extends StatefulWidget {
  final Chapter chapter;
  final String courseId;
  final String subjectId;
  final String classId;

  const VideosScreen({
    super.key,
    required this.chapter,
    required this.courseId,
    required this.subjectId,
    required this.classId,
  });

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  late Future<ChannelListResponse> _channelsFuture;
  late Future<ChapterBadgesResponse> _badgesFuture;
  late Future<ChannelRatingsResponse> _ratingsFuture;

  @override
  void initState() {
    super.initState();
    _channelsFuture = context.read<ApiService>().fetchChannels(
      courseId: widget.courseId,
      subjectId: widget.subjectId,
      classId: widget.classId,
      chapterId: widget.chapter.id,
    );
    _badgesFuture = context.read<ApiService>().fetchChapterBadges(
      courseId: widget.courseId,
      chapterId: widget.chapter.id,
    );
    _ratingsFuture = context.read<ApiService>().fetchChannelRatings(
      chapterId: widget.chapter.id,
      courseId: widget.courseId,
      subjectId: widget.subjectId,
      classId: widget.classId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapter.title),
        backgroundColor: const Color(0xFFe41468),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_channelsFuture, _badgesFuture, _ratingsFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final error = snapshot.error.toString();
            AppLogger.error('VideosScreen', 'Data fetch error: $error');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load videos',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _channelsFuture = context
                              .read<ApiService>()
                              .fetchChannels(
                                courseId: widget.courseId,
                                subjectId: widget.subjectId,
                                classId: widget.classId,
                                chapterId: widget.chapter.id,
                              );
                          _badgesFuture = context
                              .read<ApiService>()
                              .fetchChapterBadges(
                                courseId: widget.courseId,
                                chapterId: widget.chapter.id,
                              );
                          _ratingsFuture = context
                              .read<ApiService>()
                              .fetchChannelRatings(
                                chapterId: widget.chapter.id,
                                courseId: widget.courseId,
                                subjectId: widget.subjectId,
                                classId: widget.classId,
                              );
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No videos available'));
          }

          final channelsResponse = snapshot.data![0] as ChannelListResponse;
          final badgesResponse = snapshot.data![1] as ChapterBadgesResponse;
          final ratingsResponse = snapshot.data![2] as ChannelRatingsResponse;

          final channels = channelsResponse.response.data;
          if (channels.isEmpty) {
            return const Center(child: Text('No videos available'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: channels.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.chapter.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFe41468),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chapter ${widget.chapter.order} • ${widget.chapter.title}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              }

              final provider = channels[index - 1];
              final rating = ratingsResponse.response.channels.firstWhere(
                (r) => r.channelId == provider.id,
                orElse: () => ChannelRating(
                  channelId: provider.id,
                  channelSlug: '',
                  channelDescription: '',
                  averageRating: 0.0,
                  totalRatings: 0,
                  totalContent: 0,
                  ratedContent: 0,
                  starDistribution: [],
                  userRating: null,
                ),
              );

              return _buildProviderSection(provider, rating, badgesResponse);
            },
          );
        },
      ),
    );
  }

  Widget _buildProviderSection(
    Channel provider,
    ChannelRating rating,
    ChapterBadgesResponse badges,
  ) {
    final providerLanguages = provider.languages
        .where((lang) => lang.trim().isNotEmpty)
        .toList();
    final sectionChildren = <Widget>[
      const SizedBox(width: 12),
      const Icon(Icons.language, size: 16, color: Colors.black54),
      const SizedBox(width: 4),
      Flexible(
        child: Text(
          providerLanguages.join(' • '),
          style: const TextStyle(color: Colors.black54),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                provider.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 18),
            const SizedBox(width: 4),
            Text(
              rating.averageRating.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            Text('(${rating.totalRatings} ratings)'),
            if (providerLanguages.isNotEmpty) ...sectionChildren,
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: provider.data.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final video = provider.data[index];
              return _buildVideoCard(video);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVideoCard(ChannelData video) {
    final thumbnailUrl = () {
      if (video.thumbnailList.isEmpty) return '';
      final firstImage = video.thumbnailList.first.images['default'];
      if (firstImage is Map<String, dynamic>) {
        return firstImage['to'] as String? ?? '';
      }
      return '';
    }();

    final imageUrl = thumbnailUrl.isNotEmpty
        ? context.read<ApiService>().getMediaImageUrl(thumbnailUrl)
        : null;

    return GestureDetector(
      onTap: () {
        final streamUrl = context.read<ApiService>().getHlsUrl(video.hlsPlaylistUrl);
        if (streamUrl.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This video stream is unavailable.')),
          );
          return;
        }

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VideoPlayerScreen(
              title: video.title,
              streamUrl: streamUrl,
            ),
          ),
        );
      },
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.08),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      width: 200,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 200,
                        height: 110,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 36),
                      ),
                    )
                  : Container(
                      width: 200,
                      height: 110,
                      color: Colors.grey[200],
                      child: const Icon(Icons.video_library, size: 36),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${video.videoDuration} sec',
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
