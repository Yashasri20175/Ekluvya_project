import 'package:ekluvya_app/core/utils/logger.dart';
import 'package:ekluvya_app/models/signed_cookies_model.dart';
import 'package:ekluvya_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String title;
  final String streamUrl;

  const VideoPlayerScreen({
    super.key,
    required this.title,
    required this.streamUrl,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  Future<void>? _initializeFuture;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _setupPlayer();
  }

  Future<void> _setupPlayer() async {
    if (widget.streamUrl.trim().isEmpty) {
      setState(() {
        _loadError = 'This video does not have a valid stream URL.';
      });
      return;
    }

    try {
      final api = context.read<ApiService>();
      final cookiesResponse = await api.getSignedCookies();
      final headers = _buildHeaders(cookiesResponse.cookies);

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.streamUrl),
        httpHeaders: headers,
      );

      controller.setLooping(false);
      controller.setVolume(1.0);

      setState(() {
        _controller = controller;
        _initializeFuture = controller.initialize().then((_) {
          controller.play();
        });
      });
    } catch (e, st) {
      AppLogger.error('VideoPlayerScreen', 'Failed to initialize player', e, st);
      setState(() {
        _loadError = 'Unable to start video playback.';
      });
    }
  }

  Map<String, String> _buildHeaders(SignedCookies cookies) {
    final cookieParts = <String>[
      if (cookies.cloudFrontKeyPairId.isNotEmpty)
        'CloudFront-Key-Pair-Id=${cookies.cloudFrontKeyPairId}',
      if (cookies.cloudFrontPolicy.isNotEmpty)
        'CloudFront-Policy=${cookies.cloudFrontPolicy}',
      if (cookies.cloudFrontSignature.isNotEmpty)
        'CloudFront-Signature=${cookies.cloudFrontSignature}',
    ];

    if (cookieParts.isEmpty) {
      return const {};
    }

    return {'Cookie': cookieParts.join('; ')};
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _loadError != null
              ? Text(
                  _loadError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                )
              : controller == null || _initializeFuture == null
              ? const CircularProgressIndicator(color: Colors.white)
              : FutureBuilder<void>(
                  future: _initializeFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const CircularProgressIndicator(
                        color: Colors.white,
                      );
                    }

                    if (snapshot.hasError || !controller.value.isInitialized) {
                      return const Text(
                        'Unable to play this video.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      );
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AspectRatio(
                          aspectRatio: controller.value.aspectRatio == 0
                              ? 16 / 9
                              : controller.value.aspectRatio,
                          child: VideoPlayer(controller),
                        ),
                        const SizedBox(height: 16),
                        VideoProgressIndicator(
                          controller,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: Color(0xFFe41468),
                            bufferedColor: Colors.white38,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                        const SizedBox(height: 16),
                        IconButton.filled(
                          onPressed: () {
                            setState(() {
                              if (controller.value.isPlaying) {
                                controller.pause();
                              } else {
                                controller.play();
                              }
                            });
                          },
                          icon: Icon(
                            controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}
