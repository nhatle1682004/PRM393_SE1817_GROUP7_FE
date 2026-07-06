import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class WebCameraDialog extends StatefulWidget {
  final List<CameraDescription> cameras;

  const WebCameraDialog({super.key, required this.cameras});

  @override
  State<WebCameraDialog> createState() => _WebCameraDialogState();
}

class _WebCameraDialogState extends State<WebCameraDialog> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: CameraPreview(_controller),
                      );
                    } else {
                      return const AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
                      );
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: FloatingActionButton(
                    backgroundColor: const Color(0xFF10B981),
                    onPressed: () async {
                      try {
                        await _initializeControllerFuture;
                        final image = await _controller.takePicture();
                        if (mounted) Navigator.pop(context, image);
                      } catch (e) {
                        debugPrint(e.toString());
                      }
                    },
                    child: const Icon(Icons.camera_alt, color: Colors.white),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(backgroundColor: Colors.black26),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: Colors.white,
              child: const Text(
                'Căn chỉnh rác thải vào khung hình',
                style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
