import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';


class AudioGalleryViewer extends StatefulWidget {
  final List<String> audioUrls;
  final int initialIndex;
  final bool isOwner;
  final Function(int)? onDelete;

  const AudioGalleryViewer({
    super.key,
    required this.audioUrls,
    this.initialIndex = 0,
    this.isOwner = false,
    this.onDelete,
  });

  @override
  State<AudioGalleryViewer> createState() => _AudioGalleryViewerState();
}

class _AudioGalleryViewerState extends State<AudioGalleryViewer> {
  late AudioPlayer _audioPlayer;
  int _currentIndex = 0;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
    _loadAudio(_currentIndex);
  }

  void _setupAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() => _position = position);
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() => _isPlaying = state == PlayerState.playing);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      // Auto-play next track
      if (_currentIndex < widget.audioUrls.length - 1) {
        _playNext();
      } else {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  Future<void> _loadAudio(int index) async {
    try {
      await _audioPlayer.stop();
      final audioUrl = widget.audioUrls[index];
      print('Loading audio: $audioUrl');
      setState(() {
        _position = Duration.zero;
        _duration = Duration.zero;
      });
    } catch (e) {
      print('Error loading audio: $e');
    }
  }

  Future<void> _playPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (_position == Duration.zero) {
          final audioUrl = widget.audioUrls[_currentIndex];
          final accessible = await _isUrlAccessible(audioUrl);
          if (!accessible) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Unable to access audio. Authentication may be required.',
                  ),
                ),
              );
            }
            return;
          }
          await _audioPlayer.play(UrlSource(audioUrl));
        } else {
          await _audioPlayer.resume();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _playNext() async {
    if (_currentIndex < widget.audioUrls.length - 1) {
      setState(() => _currentIndex++);
      await _loadAudio(_currentIndex);
      await _playPause();
    }
  }

  Future<void> _playPrevious() async {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      await _loadAudio(_currentIndex);
      await _playPause();
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Audio'),
        content: const Text('Are you sure you want to delete this audio file?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (widget.onDelete != null) {
                widget.onDelete!(_currentIndex);
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<bool> _isUrlAccessible(String url) async {
    try {
      final token = await const FlutterSecureStorage().read(key: 'auth_token');
      final headers = <String, String>{};
      if (token != null) headers['Authorization'] = 'Bearer $token';
      final dio = Dio();
      final response = await dio.head(url, options: Options(headers: headers));
      return response.statusCode == 200 || response.statusCode == 206;
    } catch (e) {
      print('Error checking URL accessibility: $e');
      return false;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio ${_currentIndex + 1}/${widget.audioUrls.length}'),
        elevation: 0,
        actions: [
          if (widget.isOwner)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteDialog,
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Album art
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPlaying ? Icons.music_note : Icons.audiotrack,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Track name
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        widget.audioUrls[_currentIndex].split('/').last,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Controls section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Progress bar
                  Column(
                    children: [
                      Slider(
                        value: _position.inSeconds.toDouble(),
                        max: _duration.inSeconds.toDouble() > 0
                            ? _duration.inSeconds.toDouble()
                            : 1.0,
                        onChanged: (value) {
                          _audioPlayer.seek(Duration(seconds: value.toInt()));
                        },
                        activeColor: Theme.of(context).primaryColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_position),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              _formatDuration(_duration),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Playback controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Previous
                      IconButton(
                        onPressed: _currentIndex > 0 ? _playPrevious : null,
                        icon: const Icon(Icons.skip_previous),
                        iconSize: 48,
                        color: _currentIndex > 0
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),

                      // Backward 10s
                      IconButton(
                        onPressed: () {
                          final newPos =
                              _position - const Duration(seconds: 10);
                          _audioPlayer.seek(
                            newPos < Duration.zero ? Duration.zero : newPos,
                          );
                        },
                        icon: const Icon(Icons.replay_10),
                        iconSize: 36,
                        color: Theme.of(context).primaryColor,
                      ),

                      // Play/Pause
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withOpacity(0.8),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _playPause,
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 36,
                          ),
                          color: Colors.white,
                        ),
                      ),

                      // Forward 10s
                      IconButton(
                        onPressed: () {
                          final newPos =
                              _position + const Duration(seconds: 10);
                          _audioPlayer.seek(
                            newPos > _duration ? _duration : newPos,
                          );
                        },
                        icon: const Icon(Icons.forward_10),
                        iconSize: 36,
                        color: Theme.of(context).primaryColor,
                      ),

                      // Next
                      IconButton(
                        onPressed: _currentIndex < widget.audioUrls.length - 1
                            ? _playNext
                            : null,
                        icon: const Icon(Icons.skip_next),
                        iconSize: 48,
                        color: _currentIndex < widget.audioUrls.length - 1
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                    ],
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
