import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LiveCameraScreen extends StatefulWidget {
  final String streamUrl;

  const LiveCameraScreen({
    super.key,
    required this.streamUrl,
  });

  @override
  State<LiveCameraScreen> createState() => _LiveCameraScreenState();
}

class _LiveCameraScreenState extends State<LiveCameraScreen> {
  Uint8List? _currentFrame;
  StreamSubscription? _subscription;
  http.Client? _client;
  bool _isConnected = false;
  String? _errorMessage;
  bool _isLive = true;

  @override
  void initState() {
    super.initState();
    _startStream();
  }

  @override
  void dispose() {
    _stopStream();
    super.dispose();
  }

  void _stopStream() {
    _subscription?.cancel();
    _subscription = null;
    _client?.close();
    _client = null;
  }

  void _startStream() async {
    _stopStream();
    setState(() {
      _isConnected = false;
      _errorMessage = null;
    });

    try {
      _client = http.Client();
      final request = http.Request('GET', Uri.parse(widget.streamUrl));
      final response = await _client!.send(request).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        throw Exception("HTTP status ${response.statusCode}");
      }

      setState(() {
        _isConnected = true;
      });

      List<int> buffer = [];

      _subscription = response.stream.listen(
        (List<int> chunk) {
          if (!_isLive) return;

          buffer.addAll(chunk);

          // Find JPEG Start of Image (0xFF, 0xD8) and End of Image (0xFF, 0xD9) markers
          int startIndex = -1;
          for (int i = 0; i < buffer.length - 1; i++) {
            if (buffer[i] == 0xFF && buffer[i + 1] == 0xD8) {
              startIndex = i;
              break;
            }
          }

          if (startIndex != -1) {
            int endIndex = -1;
            for (int i = startIndex; i < buffer.length - 1; i++) {
              if (buffer[i] == 0xFF && buffer[i + 1] == 0xD9) {
                endIndex = i + 2;
                break;
              }
            }

            if (endIndex != -1) {
              final frameBytes = Uint8List.fromList(buffer.sublist(startIndex, endIndex));
              buffer = buffer.sublist(endIndex);

              if (mounted) {
                setState(() {
                  _currentFrame = frameBytes;
                });
              }
            }
          }

          // Prevent excessive memory growth if boundary not found
          if (buffer.length > 500000) {
            buffer.clear();
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _isConnected = false;
              _errorMessage = error.toString();
            });
          }
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          "Live Plant Camera",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isLive ? Icons.pause_circle_outline : Icons.play_circle_outline,
              color: const Color(0xFF4CAF50),
            ),
            tooltip: _isLive ? "Pause Stream" : "Resume Stream",
            onPressed: () {
              setState(() {
                _isLive = !_isLive;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            tooltip: "Reconnect Stream",
            onPressed: _startStream,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video Frame Container
            Container(
              height: 340,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isConnected ? const Color(0xFF4CAF50) : Colors.redAccent.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_currentFrame != null)
                    Image.memory(
                      _currentFrame!,
                      gaplessPlayback: true,
                      fit: BoxFit.cover,
                    )
                  else if (_errorMessage != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.videocam_off, color: Colors.redAccent, size: 48),
                            const SizedBox(height: 8),
                            const Text(
                              "Camera Stream Offline",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                              ),
                              icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                              label: const Text("Retry", style: TextStyle(color: Colors.white)),
                              onPressed: _startStream,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF4CAF50)),
                          SizedBox(height: 12),
                          Text(
                            "Connecting to ESP32-CAM stream...",
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                  // Status Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isConnected
                            ? (_isLive ? Colors.redAccent : Colors.grey.shade700)
                            : Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isConnected ? Colors.white : Colors.redAccent,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isConnected ? (_isLive ? "LIVE CAM" : "PAUSED") : "DISCONNECTED",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Hardware & Stream Metadata Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                children: [
                  _buildMetadataRow("Hardware Module", "ESP32-CAM (OV2640)"),
                  const Divider(color: Colors.white10, height: 20),
                  _buildMetadataRow("Stream Target URL", widget.streamUrl),
                  const Divider(color: Colors.white10, height: 20),
                  _buildMetadataRow("Resolution Mode", "VGA (640×480) MJPEG"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}