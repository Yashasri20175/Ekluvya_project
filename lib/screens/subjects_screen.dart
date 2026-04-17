import 'package:ekluvya_app/models/channel_model.dart';
import 'package:ekluvya_app/models/chapter_model.dart';
import 'package:ekluvya_app/models/class_model.dart';
import 'package:ekluvya_app/models/home_stream_model.dart';
import 'package:ekluvya_app/models/subject_model.dart';
import 'package:ekluvya_app/screens/video_player_screen.dart';
import 'package:ekluvya_app/screens/videos_screen.dart';
import 'package:ekluvya_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ── Shared dark popup list ────────────────────────────────────────────────────

class _DarkListSheet<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) labelOf;
  final bool Function(T) isSelected;
  final void Function(T) onSelected;

  const _DarkListSheet({
    required this.items,
    required this.labelOf,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  State<_DarkListSheet<T>> createState() => _DarkListSheetState<T>();
}

class _DarkListSheetState<T> extends State<_DarkListSheet<T>> {
  final ScrollController _scrollController = ScrollController();

  // Approximate row height: vertical padding 16+16 = 32, text ~21 ≈ 53px
  static const double _rowHeight = 53.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected() {
    if (!_scrollController.hasClients) return;
    final index = widget.items.indexWhere(widget.isSelected);
    if (index <= 0) return;
    final target = (index * _rowHeight).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: const Color(0xFF111111),
        child: ListView.builder(
          controller: _scrollController,
          shrinkWrap: true,
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            final item = widget.items[index];
            final selected = widget.isSelected(item);
            return InkWell(
              onTap: () => widget.onSelected(item),
              splashColor: Colors.white10,
              highlightColor: Colors.white10,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Text(
                  widget.labelOf(item),
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFFFF0066)
                        : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class SubjectsScreen extends StatefulWidget {
  final CourseCategory course;

  const SubjectsScreen({super.key, required this.course});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  late Future<String> _logoFuture;
  late Future<ClassesResponse> _classesFuture;
  Future<SubjectsResponse>? _subjectsFuture;
  Future<ChapterListResponse>? _chaptersFuture;
  Future<ChannelListResponse>? _channelsFuture;

  CourseClass? _selectedClass;
  Subject? _selectedSubject;
  Chapter? _selectedChapter;

  late final String _courseId;

  @override
  void initState() {
    super.initState();
    _courseId = widget.course.id.isNotEmpty
        ? widget.course.id
        : '682c37587030ad5fa362f3ce';

    _logoFuture = context.read<ApiService>().fetchAppLogoUrl();
    _classesFuture =
        context.read<ApiService>().fetchClasses(courseId: _courseId);

    _classesFuture.then((classesResponse) {
      final classes = classesResponse.response.data;
      if (classes.isNotEmpty && mounted) _onClassSelected(classes.first);
    });
  }

  void _onClassSelected(CourseClass cls) {
    final subjectsFuture = context.read<ApiService>().fetchSubjects(
      courseId: _courseId,
      classId: cls.id,
    );
    setState(() {
      _selectedClass = cls;
      _selectedSubject = null;
      _selectedChapter = null;
      _chaptersFuture = null;
      _channelsFuture = null;
      _subjectsFuture = subjectsFuture;
    });
    subjectsFuture.then((subjectsResponse) {
      final subjects = subjectsResponse.response.data;
      if (subjects.isNotEmpty && mounted) _onSubjectSelected(subjects.first);
    });
  }

  void _onSubjectSelected(Subject subject) {
    final chaptersFuture = context.read<ApiService>().fetchChapters(
      courseId: _courseId,
      subjectId: subject.id,
      classId: _selectedClass?.id ?? '',
    );
    setState(() {
      _selectedSubject = subject;
      _selectedChapter = null;
      _channelsFuture = null;
      _chaptersFuture = chaptersFuture;
    });
    chaptersFuture.then((chaptersResponse) {
      final chapters = [...chaptersResponse.response.chapterList]
        ..sort((a, b) => a.order.compareTo(b.order));
      if (chapters.isNotEmpty && mounted) _onChapterSelected(chapters.first);
    });
  }

  void _onChapterSelected(Chapter chapter) {
    final channelsFuture = context.read<ApiService>().fetchChannels(
      courseId: _courseId,
      subjectId: _selectedSubject?.id ?? '',
      classId: _selectedClass?.id ?? '',
      chapterId: chapter.id,
    );
    setState(() {
      _selectedChapter = chapter;
      _channelsFuture = channelsFuture;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _SubjectsHeader(
            logoFuture: _logoFuture,
            classesFuture: _classesFuture,
            subjectsFuture: _subjectsFuture,
            courseTitle: widget.course.title,
            selectedClass: _selectedClass,
            selectedSubject: _selectedSubject,
            onClassSelected: _onClassSelected,
            onSubjectSelected: _onSubjectSelected,
          ),
          if (_chaptersFuture != null)
            _ChapterDropdownRow(
              chaptersFuture: _chaptersFuture!,
              selectedChapter: _selectedChapter,
              onChapterSelected: _onChapterSelected,
            ),
          if (_channelsFuture != null)
            Expanded(
              child: _ChannelList(
                channelsFuture: _channelsFuture!,
                courseId: _courseId,
                classId: _selectedClass!.id,
                subjectId: _selectedSubject!.id,
                chapter: _selectedChapter!,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Channel list ─────────────────────────────────────────────────────────────

String _thumbnailUrl(ChannelData video) {
  const base = 'https://d38zvxejdrf8bt.cloudfront.net/';
  final def = video.newThumbnailImages['default'] as Map<String, dynamic>?;
  final path = (def?['tm'] ?? def?['to'] ?? '') as String;
  if (path.isEmpty) return '';
  return path.startsWith('http') ? path : '$base$path';
}

String _formatDuration(String seconds) {
  final s = int.tryParse(seconds) ?? 0;
  final m = s ~/ 60;
  final r = s % 60;
  return '$m:${r.toString().padLeft(2, '0')}';
}

class _ChannelList extends StatelessWidget {
  final Future<ChannelListResponse> channelsFuture;
  final String courseId;
  final String classId;
  final String subjectId;
  final Chapter chapter;

  const _ChannelList({
    required this.channelsFuture,
    required this.courseId,
    required this.classId,
    required this.subjectId,
    required this.chapter,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChannelListResponse>(
      future: channelsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Failed to load videos'));
        }

        final channels = snapshot.data!.response.data;
        if (channels.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No videos available for this chapter.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: channels.length,
          itemBuilder: (context, index) => _ChannelSection(
            channel: channels[index],
            courseId: courseId,
            classId: classId,
            subjectId: subjectId,
            chapter: chapter,
          ),
        );
      },
    );
  }
}

class _ChannelSection extends StatelessWidget {
  final Channel channel;
  final String courseId;
  final String classId;
  final String subjectId;
  final Chapter chapter;

  const _ChannelSection({
    required this.channel,
    required this.courseId,
    required this.classId,
    required this.subjectId,
    required this.chapter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Row(
            children: [
              Text(
                channel.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.favorite, color: Color(0xFFFF0066), size: 14),
              const SizedBox(width: 4),
              const Icon(Icons.tv_outlined, color: Colors.black54, size: 14),
              const SizedBox(width: 6),
              Text(
                '${channel.data.length} VIDEOS',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.star, color: Color(0xFFFFBB00), size: 14),
              const Text(
                ' 4.0',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VideosScreen(
                      chapter: chapter,
                      courseId: courseId,
                      subjectId: subjectId,
                      classId: classId,
                    ),
                  ),
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFFFF0066),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        // ── Horizontal video scroll ─────────────────────────────
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: channel.data.length,
            itemBuilder: (context, index) => _VideoCard(
              video: channel.data[index],
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }
}

class _VideoCard extends StatelessWidget {
  final ChannelData video;

  const _VideoCard({required this.video});

  @override
  Widget build(BuildContext context) {
    final thumbUrl = _thumbnailUrl(video);

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
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: thumbUrl.isNotEmpty
                    ? Image.network(
                        thumbUrl,
                        width: 140,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (_, e, s) => _thumbPlaceholder(),
                      )
                    : _thumbPlaceholder(),
              ),
              // Duration badge
              Positioned(
                bottom: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _formatDuration(video.videoDuration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // Bookmark icon
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.bookmark_border,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Title
          Text(
            video.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _thumbPlaceholder() {
    return Container(
      width: 140,
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFFDDDDDD),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.play_circle_outline, color: Colors.white54, size: 32),
    );
  }
}

// ── Chapter dropdown row ──────────────────────────────────────────────────────

class _ChapterDropdownRow extends StatefulWidget {
  final Future<ChapterListResponse> chaptersFuture;
  final Chapter? selectedChapter;
  final void Function(Chapter) onChapterSelected;

  const _ChapterDropdownRow({
    required this.chaptersFuture,
    required this.selectedChapter,
    required this.onChapterSelected,
  });

  @override
  State<_ChapterDropdownRow> createState() => _ChapterDropdownRowState();
}

class _ChapterDropdownRowState extends State<_ChapterDropdownRow> {
  void _showChapterMenu(List<Chapter> chapters, Chapter current) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: _DarkListSheet<Chapter>(
          items: chapters,
          labelOf: (ch) => ch.title.toUpperCase(),
          isSelected: (ch) => ch.id == current.id,
          onSelected: (ch) {
            Navigator.pop(ctx);
            widget.onChapterSelected(ch);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChapterListResponse>(
      future: widget.chaptersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final chapters = ([...?snapshot.data?.response.chapterList])
          ..sort((a, b) => a.order.compareTo(b.order));
        if (chapters.isEmpty) return const SizedBox();

        final current = widget.selectedChapter ?? chapters.first;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
            ),
          ),
          child: Row(
            children: [
              const Text(
                'Chapters',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _showChapterMenu(chapters, current),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.55,
                        ),
                        child: Text(
                          current.title.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 0.4,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _SubjectsHeader extends StatefulWidget {
  final Future<String> logoFuture;
  final Future<ClassesResponse> classesFuture;
  final Future<SubjectsResponse>? subjectsFuture;
  final String courseTitle;
  final CourseClass? selectedClass;
  final Subject? selectedSubject;
  final void Function(CourseClass) onClassSelected;
  final void Function(Subject) onSubjectSelected;

  const _SubjectsHeader({
    required this.logoFuture,
    required this.classesFuture,
    required this.subjectsFuture,
    required this.courseTitle,
    required this.selectedClass,
    required this.selectedSubject,
    required this.onClassSelected,
    required this.onSubjectSelected,
  });

  @override
  State<_SubjectsHeader> createState() => _SubjectsHeaderState();
}

class _SubjectsHeaderState extends State<_SubjectsHeader> {

  final ScrollController _subjectsScrollController = ScrollController();

  bool _canScrollLeft = false;
  bool _canScrollRight = false;
  bool _subjectsArrowsInitialized = false;

  @override
  void initState() {
    super.initState();
    _subjectsScrollController.addListener(_onSubjectsScroll);
  }

  @override
  void didUpdateWidget(_SubjectsHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset arrow state when subjects future changes (new class selected)
    if (oldWidget.subjectsFuture != widget.subjectsFuture) {
      _canScrollLeft = false;
      _canScrollRight = false;
      _subjectsArrowsInitialized = false;
    }
  }

  @override
  void dispose() {
    _subjectsScrollController.removeListener(_onSubjectsScroll);
    _subjectsScrollController.dispose();
    super.dispose();
  }

  void _onSubjectsScroll() {
    if (!_subjectsScrollController.hasClients) return;
    final pos = _subjectsScrollController.position;
    final canLeft = pos.pixels > 0;
    final canRight = pos.pixels < pos.maxScrollExtent;
    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canLeft;
        _canScrollRight = canRight;
      });
    }
  }

  void _initSubjectsArrows() {
    if (_subjectsArrowsInitialized) return;
    _subjectsArrowsInitialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_subjectsScrollController.hasClients && mounted) {
        final pos = _subjectsScrollController.position;
        setState(() {
          _canScrollLeft = pos.pixels > 0;
          _canScrollRight = pos.maxScrollExtent > 0;
        });
      }
    });
  }

  void _scrollSubjectsRight() {
    _subjectsScrollController.animateTo(
      (_subjectsScrollController.offset + 120).clamp(
        0,
        _subjectsScrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollSubjectsLeft() {
    _subjectsScrollController.animateTo(
      (_subjectsScrollController.offset - 120).clamp(
        0,
        _subjectsScrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showClassMenu(List<CourseClass> classes, CourseClass current) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: _DarkListSheet<CourseClass>(
          items: classes,
          labelOf: (cls) => cls.title.toUpperCase(),
          isSelected: (cls) => cls.id == current.id,
          onSelected: (cls) {
            Navigator.pop(ctx);
            widget.onClassSelected(cls);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF0066), Color(0xFFFF5500)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row 1: Centered logo ─────────────────────────────────────
              SizedBox(
                height: 36,
                child: Center(
                  child: FutureBuilder<String>(
                    future: widget.logoFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.hasError) {
                        return const SizedBox(width: 90, height: 30);
                      }
                      return Image.network(
                        snapshot.data!,
                        height: 30,
                        fit: BoxFit.contain,
                        errorBuilder: (_, e, s) =>
                            const SizedBox(width: 90, height: 30),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Row 2: Course title + class dropdown ─────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.courseTitle.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  FutureBuilder<ClassesResponse>(
                    future: widget.classesFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox(
                          width: 90,
                          height: 28,
                          child: Center(
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }

                      final classes = snapshot.data!.response.data;
                      if (classes.isEmpty) return const SizedBox();

                      final current = widget.selectedClass ?? classes.first;

                      return GestureDetector(
                        onTap: () => _showClassMenu(classes, current),
                        child: Container(

                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                current.title.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Row 3: Subject tabs with scroll arrows ───────────────────
              if (widget.subjectsFuture != null)
                FutureBuilder<SubjectsResponse>(
                  future: widget.subjectsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 36,
                        child: Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }

                    final subjects = snapshot.data?.response.data ?? [];
                    if (subjects.isEmpty) return const SizedBox(height: 36);

                    _initSubjectsArrows();

                    final current = widget.selectedSubject ?? subjects.first;

                    return SizedBox(
                      height: 36,
                      child: Stack(
                        children: [
                          ListView.separated(
                            controller: _subjectsScrollController,
                            scrollDirection: Axis.horizontal,
                            itemCount: subjects.length,
                            padding: EdgeInsets.only(
                              left: _canScrollLeft ? 28 : 0,
                              right: _canScrollRight ? 28 : 0,
                            ),
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final subject = subjects[index];
                              final isSelected = current.id == subject.id;
                              return GestureDetector(
                                onTap: () =>
                                    widget.onSubjectSelected(subject),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    subject.title.toUpperCase(),
                                    style: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFFFF0066)
                                          : Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          // Left scroll arrow
                          if (_canScrollLeft)
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: _scrollSubjectsLeft,
                                child: Container(
                                  width: 28,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFFF0066),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.chevron_left,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          // Right scroll arrow
                          if (_canScrollRight)
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: _scrollSubjectsRight,
                                child: Container(
                                  width: 28,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Color(0xFFFF5500),
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.chevron_right,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                )
              else
                const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
