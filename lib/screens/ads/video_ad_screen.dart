import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:async';

class VideoAdScreen extends StatefulWidget {
  const VideoAdScreen({super.key});

  @override
  State<VideoAdScreen> createState() => _VideoAdScreenState();
}

class _VideoAdScreenState extends State<VideoAdScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  Timer? _timer;
  int _secondsRemaining = 10;
  bool _canSkip = false;
  bool _initialized = false;

  // URL de video de ejemplo (Big Buck Bunny es común para pruebas)
  // O podemos usar un asset si tuviéramos uno. Usaremos una URL pública confiable.
  final String _videoUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _startTimer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(_videoUrl));
    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
      showControls: false, // Ocultar controles nativos para forzar la vista
      aspectRatio: _videoPlayerController.value.aspectRatio,
    );

    setState(() {
      _initialized = true;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canSkip = true;
        });
        _timer?.cancel();
      }
    });
  }

  void _skipAd() {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back button
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: _initialized && _chewieController != null
                  ? AspectRatio(
                      aspectRatio: _videoPlayerController.value.aspectRatio,
                      child: Chewie(controller: _chewieController!),
                    )
                  : const CircularProgressIndicator(color: Colors.white),
            ),

            // Ad Label
            Positioned(
              top: 40,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.yellow[700],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'PUBLICIDAD',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // Skip Button / Timer
            Positioned(
              top: 40,
              right: 16,
              child: GestureDetector(
                onTap: _canSkip ? _skipAd : null,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        _canSkip ? Colors.white : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _canSkip
                            ? 'Saltar Video'
                            : 'Saltar en $_secondsRemaining',
                        style: TextStyle(
                          color: _canSkip ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_canSkip)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.arrow_forward,
                              size: 16, color: Colors.black),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
