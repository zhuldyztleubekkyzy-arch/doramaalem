import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String? dramaTitle;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
    this.dramaTitle,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  YoutubePlayerController? _youtubeController;
  late WebViewController _webViewController;
  bool _isYouTube = false;
  bool _isLoading = true;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _setFullScreen(true);
  }

  void _setFullScreen(bool fullScreen) {
    setState(() => _isFullScreen = fullScreen);
    
    if (fullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  void _initializePlayer() {
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    
    if (videoId != null) {
      setState(() => _isYouTube = true);
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: true,
          hideThumbnail: true,
          showLiveFullscreenButton: true,
        ),
      )..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    } else {
      setState(() => _isYouTube = false);
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              if (progress == 100) {
                setState(() => _isLoading = false);
              }
            },
            onPageStarted: (String url) {
              setState(() => _isLoading = true);
            },
            onPageFinished: (String url) {
              setState(() => _isLoading = false);
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.videoUrl));
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _setFullScreen(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isFullScreen) {
          _setFullScreen(false);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    children: [
                      if (_isYouTube && _youtubeController != null)
                        YoutubePlayer(
                          controller: _youtubeController!,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: Colors.purple,
                          progressColors: const ProgressBarColors(
                            playedColor: Colors.purple,
                            handleColor: Colors.purpleAccent,
                          ),
                          onReady: () {
                            setState(() => _isLoading = false);
                          },
                        )
                      else
                        WebViewWidget(controller: _webViewController),
                      
                      if (_isLoading)
                        Container(
                          color: Colors.black54,
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              if (!_isFullScreen)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black87,
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.dramaTitle != null)
                                Text(
                                  widget.dramaTitle!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: _showQualitySettings,
                        ),
                      ],
                    ),
                  ),
                ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black87,
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10, color: Colors.white),
                        iconSize: 35,
                        onPressed: () {
                          if (_isYouTube && _youtubeController != null) {
                            final currentTime = _youtubeController!.value.position.inSeconds;
                            _youtubeController!.seekTo(
                              Duration(seconds: currentTime - 10),
                            );
                          }
                        },
                      ),
                      
                      IconButton(
                        icon: Icon(
                          _isYouTube && _youtubeController != null
                              ? (_youtubeController!.value.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled)
                              : Icons.play_circle_filled,
                          color: Colors.white,
                        ),
                        iconSize: 60,
                        onPressed: () {
                          if (_isYouTube && _youtubeController != null) {
                            if (_youtubeController!.value.isPlaying) {
                              _youtubeController!.pause();
                            } else {
                              _youtubeController!.play();
                            }
                            setState(() {});
                          }
                        },
                      ),
                      
                      IconButton(
                        icon: const Icon(Icons.forward_10, color: Colors.white),
                        iconSize: 35,
                        onPressed: () {
                          if (_isYouTube && _youtubeController != null) {
                            final currentTime = _youtubeController!.value.position.inSeconds;
                            _youtubeController!.seekTo(
                              Duration(seconds: currentTime + 10),
                            );
                          }
                        },
                      ),
                      
                      // Толық экран
                      IconButton(
                        icon: Icon(
                          _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                          color: Colors.white,
                        ),
                        iconSize: 35,
                        onPressed: () {
                          _setFullScreen(!_isFullScreen);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQualitySettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Баптаулар',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.speed, color: Colors.white),
              title: const Text('Жылдамдық', style: TextStyle(color: Colors.white)),
              subtitle: const Text('1.0x', style: TextStyle(color: Colors.white70)),
              onTap: () {
                Navigator.pop(context);
                _showSpeedOptions();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSpeedOptions() {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ойнату жылдамдығы',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...speeds.map((speed) => ListTile(
              title: Text('${speed}x', style: const TextStyle(color: Colors.white)),
              trailing: speed == 1.0 ? const Icon(Icons.check, color: Colors.purple) : null,
              onTap: () {
                if (_isYouTube && _youtubeController != null) {
                  _youtubeController!.setPlaybackRate(speed);
                }
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }
}