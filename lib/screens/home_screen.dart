import 'package:flutter/material.dart' hide Banner;
import 'package:provider/provider.dart';

import '../core/utils/logger.dart';
import '../models/banner_model.dart';
import '../models/home_stream_model.dart';
import '../models/language_model.dart';
import '../services/api_service.dart';
import '../widgets/banner_carousel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Banner>> _bannersFuture;
  late Future<List<HomeStream>> _homeStreamsFuture;
  late Future<List<Language>> _languagesFuture;

  @override
  void initState() {
    super.initState();
    _bannersFuture = context.read<ApiService>().fetchBanners();
    _homeStreamsFuture = context.read<ApiService>().fetchHomeStreams();
    _languagesFuture = context.read<ApiService>().fetchLanguages();
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<ApiService>().clearToken();
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder(
              future: _bannersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  final error = snapshot.error.toString();
                  AppLogger.error('HomeScreen', 'Banner fetch error: $error');
                  return Container(
                    height: 200,
                    color: Colors.red[100],
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(height: 8),
                            Text(
                              'Failed to load banners',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red[800]),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _bannersFuture = context
                                      .read<ApiService>()
                                      .fetchBanners();
                                });
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Text(
                        'No banners available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                final banners = snapshot.data!;
                final bannerUrls = banners.map((banner) {
                  // Check if bannerImg is already a full URL
                  if (banner.bannerImg.startsWith('http')) {
                    return banner.bannerImg;
                  } else {
                    return context.read<ApiService>().getBannerImageUrl(
                      banner.bannerImg,
                    );
                  }
                }).toList();

                AppLogger.info('HomeScreen', 'Banner URLs: $bannerUrls');

                // Calculate responsive banner height based on screen width
                final screenWidth = MediaQuery.of(context).size.width;
                final bannerHeight = screenWidth * 0.45; // 45% of screen width

                return Padding(
                  padding: const EdgeInsets.only(top: 80.0),
                  child: BannerCarousel(
                    bannerUrls: bannerUrls,
                    height: bannerHeight,
                    autoPlay: true,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<HomeStream>>(
              future: _homeStreamsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  AppLogger.error(
                    'HomeScreen',
                    'Stream fetch error: ${snapshot.error}',
                  );
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(child: Text('Unable to load streams')),
                  );
                }

                final streams = snapshot.data ?? [];
                if (streams.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(child: Text('No streams available')),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: streams
                      .map((stream) => _StreamSection(stream: stream))
                      .toList(),
                );
              },
            ),
            // Languages future - called when page opens
            FutureBuilder<List<Language>>(
              future: _languagesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  final languages = snapshot.data!;
                  AppLogger.info(
                    'HomeScreen',
                    'Fetched ${languages.length} languages',
                  );
                  for (var lang in languages) {
                    AppLogger.info(
                      'HomeScreen',
                      'Language: ${lang.name} (${lang.code}) - Default: ${lang.isDefault}',
                    );
                  }
                }
                // Don't show anything in UI, just ensure the API is called
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StreamSection extends StatelessWidget {
  final HomeStream stream;

  const _StreamSection({required this.stream});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stream.title,
                  style: const TextStyle(
                    color: Color(0xFFe41468),
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _InfoChip(
                      text: '${stream.count} COURSES',
                      backgroundColor: const Color(0xFFe41468),
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      text: '${stream.totalVideos} VIDEOS',
                      backgroundColor: Colors.black,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              scrollDirection: Axis.horizontal,
              itemCount: stream.categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _CourseCategoryCard(category: stream.categories[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseCategoryCard extends StatelessWidget {
  final CourseCategory category;

  const _CourseCategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final imageUrl = context.read<ApiService>().getMediaImageUrl(
      category.profilePicture,
    );

    return SizedBox(
      width: 170,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            const BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.16),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(0, 0, 0, 0.05),
                      Color.fromRGBO(0, 0, 0, 0.85),
                    ],
                    stops: [0.45, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(0, 0, 0, 0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      category.title.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;
  final Color backgroundColor;

  const _InfoChip({required this.text, this.backgroundColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
