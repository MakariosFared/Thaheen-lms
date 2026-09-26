import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../application/lesson_player/lesson_player_cubit.dart';
import '../../application/lesson_player/lesson_player_state.dart';
import '../../data/repositories/course_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../theme/app_theme.dart';

class LessonPlayerScreen extends StatelessWidget {
  final String lessonId;

  const LessonPlayerScreen({
    super.key,
    required this.lessonId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LessonPlayerCubit(
        courseRepository: context.read<ICourseRepository>(),
        progressRepository: context.read<IProgressRepository>(),
      )..initialize(lessonId),
      child: _LessonPlayerView(lessonId: lessonId),
    );
  }
}

class _LessonPlayerView extends StatefulWidget {
  final String lessonId;

  const _LessonPlayerView({required this.lessonId});

  @override
  State<_LessonPlayerView> createState() => _LessonPlayerViewState();
}

class _LessonPlayerViewState extends State<_LessonPlayerView> {
  VideoPlayerController? _controller;
  bool _isControllerInitialized = false;
  bool _hasVideoError = false;
  String? _videoErrorMessage;
  bool _showControls = true;
  Timer? _hideControlsTimer;
  bool _isFullscreen = false;

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }

  void _setupController(LessonPlayerState state) async {
    if (state.lesson == null) return;

    final videoPath = state.lesson!.video;

    try {
      final controller = VideoPlayerController.asset(videoPath);
      _controller = controller;

      await controller.initialize();

      if (!mounted) return;

      // Set playback speed
      await controller.setPlaybackSpeed(state.playbackSpeed);

      // Resume from saved position if any
      if (state.initialPositionSec > 0 &&
          state.initialPositionSec < controller.value.duration.inSeconds) {
        await controller.seekTo(Duration(seconds: state.initialPositionSec));
      }

      controller.addListener(_videoListener);

      setState(() {
        _isControllerInitialized = true;
        _hasVideoError = false;
      });

      // Start playing
      await controller.play();
      if (mounted) {
        context.read<LessonPlayerCubit>().setPlaying(true);
        _startHideControlsTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasVideoError = true;
          _videoErrorMessage = 'تعذر تشغيل الفيديو: ${e.toString()}';
        });
      }
    }
  }

  void _videoListener() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final position = _controller!.value.position.inSeconds;
    final duration = _controller!.value.duration.inSeconds;
    final isPlaying = _controller!.value.isPlaying;

    context.read<LessonPlayerCubit>().setPlaying(isPlaying);
    context.read<LessonPlayerCubit>().onPositionChanged(position, duration);
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _controller != null && _controller!.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideControlsTimer();
    }
  }

  void _togglePlayPause() {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
      setState(() {
        _showControls = true;
      });
      _hideControlsTimer?.cancel();
    } else {
      _controller!.play();
      _startHideControlsTimer();
    }
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _changeSpeed(double speed) async {
    if (_controller != null) {
      await _controller!.setPlaybackSpeed(speed);
    }
    if (mounted) {
      context.read<LessonPlayerCubit>().setPlaybackSpeed(speed);
    }
  }

  String _formatDuration(Duration duration) {
    final mins = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: _isFullscreen ? Colors.black : theme.scaffoldBackgroundColor,
      body: BlocConsumer<LessonPlayerCubit, LessonPlayerState>(
        listener: (context, state) {
          if (state.status == PlayerStatus.ready && !_isControllerInitialized && !_hasVideoError) {
            _setupController(state);
          }
        },
        builder: (context, state) {
          if (state.status == PlayerStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == PlayerStatus.error || _hasVideoError) {
            return Scaffold(
              appBar: AppBar(title: const Text('خطأ في المشغل')),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.videocam_off_rounded, size: 64, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(
                        _videoErrorMessage ?? state.errorMessage ?? 'تعذر تحميل الفيديو',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => context.pop(),
                        child: const Text('الرجوع للمقرر'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final lesson = state.lesson;
          final course = state.course;
          final nextLesson = state.nextLesson;
          final isCompleted = state.isCompleted;

          if (lesson == null || course == null) {
            return const SizedBox.shrink();
          }

          final videoWidget = AspectRatio(
            aspectRatio: _controller?.value.aspectRatio ?? (16 / 9),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isControllerInitialized && _controller != null)
                  VideoPlayer(_controller!)
                else
                  Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),

                // Controls Overlay
                GestureDetector(
                  onTap: _toggleControls,
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedOpacity(
                    opacity: _showControls ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      color: Colors.black45,
                      child: Stack(
                        children: [
                          // Top bar
                          PositionedDirectional(
                            top: MediaQuery.of(context).padding.top + 8,
                            start: 8,
                            end: 8,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (_isFullscreen) {
                                      _toggleFullscreen();
                                    } else {
                                      context.pop();
                                    }
                                  },
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    lesson.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // Playback Speed Menu
                                PopupMenuButton<double>(
                                  initialValue: state.playbackSpeed,
                                  tooltip: 'سرعة التشغيل',
                                  icon: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${state.playbackSpeed}x',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  onSelected: _changeSpeed,
                                  itemBuilder: (context) => [
                                    for (final speed in [0.75, 1.0, 1.25, 1.5, 2.0])
                                      PopupMenuItem(
                                        value: speed,
                                        child: Text(
                                          '${speed}x ${speed == 1.0 ? "(عادي)" : ""}',
                                          textDirection: TextDirection.ltr,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Center Play / Pause button
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  iconSize: 32,
                                  color: Colors.white,
                                  icon: const Icon(Icons.forward_10_rounded),
                                  onPressed: () {
                                    if (_controller != null) {
                                      final newPos = _controller!.value.position - const Duration(seconds: 10);
                                      _controller!.seekTo(newPos > Duration.zero ? newPos : Duration.zero);
                                    }
                                  },
                                ),
                                const SizedBox(width: 20),
                                IconButton(
                                  iconSize: 64,
                                  color: Colors.white,
                                  icon: Icon(
                                    state.isPlaying
                                        ? Icons.pause_circle_filled_rounded
                                        : Icons.play_circle_filled_rounded,
                                  ),
                                  onPressed: _togglePlayPause,
                                ),
                                const SizedBox(width: 20),
                                IconButton(
                                  iconSize: 32,
                                  color: Colors.white,
                                  icon: const Icon(Icons.replay_10_rounded),
                                  onPressed: () {
                                    if (_controller != null) {
                                      final newPos = _controller!.value.position + const Duration(seconds: 10);
                                      _controller!.seekTo(newPos);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),

                          // Bottom Seek Bar & Timers
                          PositionedDirectional(
                            bottom: 8,
                            start: 12,
                            end: 12,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _formatDuration(
                                        _controller?.value.position ?? Duration.zero,
                                      ),
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                    Expanded(
                                      child: SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                          trackHeight: 3,
                                          activeTrackColor: AppColors.primary,
                                          inactiveTrackColor: Colors.white30,
                                          thumbColor: AppColors.primary,
                                        ),
                                        child: Slider(
                                          value: _controller?.value.position.inMilliseconds.toDouble() ?? 0.0,
                                          min: 0.0,
                                          max: (_controller?.value.duration.inMilliseconds.toDouble() ?? 1.0).clamp(1.0, double.infinity),
                                          onChanged: (val) {
                                            _controller?.seekTo(Duration(milliseconds: val.toInt()));
                                          },
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(
                                        _controller?.value.duration ?? Duration.zero,
                                      ),
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        _isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                                        color: Colors.white,
                                      ),
                                      onPressed: _toggleFullscreen,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );

          if (_isFullscreen) {
            return Center(child: videoWidget);
          }

          return SafeArea(
            child: Column(
              children: [
                videoWidget,
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Completion Banner
                      if (isCompleted) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF064E3B) : AppColors.successLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.5),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'أحسنت! تم إكمال هذا الدرس بنجاح ويمكنك الانتقال للدرس التالي 🎯',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Lesson Header Info
                      Text(
                        lesson.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 16,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            course.title,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Next Lesson Card / Action
                      if (nextLesson != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.skip_next_rounded, color: AppColors.primary),
                                  SizedBox(width: 8),
                                  Text(
                                    'الدرس التالي في هذا المقرر',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                nextLesson.title,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isCompleted ? AppColors.primary : AppColors.locked,
                                  ),
                                  onPressed: isCompleted
                                      ? () {
                                          context.pushReplacement('/lesson/${nextLesson.id}');
                                        }
                                      : null,
                                  icon: Icon(isCompleted ? Icons.play_arrow_rounded : Icons.lock_rounded),
                                  label: Text(
                                    isCompleted ? 'بدء الدرس التالي' : 'يكتمل الدرس الحالي أولاً لفتحه',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              '🎉 تهانينا! هذا هو الدرس الأخير في هذا المقرر.',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
