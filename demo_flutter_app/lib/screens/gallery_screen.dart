import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../widgets/media_viewer.dart';
import '../widgets/common_widgets.dart';
import '../constants.dart';

class GalleryScreen extends StatefulWidget {
  final String? capturedAddress;
  final double? lat;
  final double? lng;

  const GalleryScreen({super.key, this.capturedAddress, this.lat, this.lng});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final Set<String> _selectedPaths = {};
  bool _isUploading = false;
  List<FileSystemEntity>? _media;

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    final tempDir = await getTemporaryDirectory();
    final externalDir = await getExternalStorageDirectory();
    List<FileSystemEntity> allFiles = [];

    if (await tempDir.exists()) {
      try {
        final List<FileSystemEntity> tempFiles = tempDir.listSync(recursive: true);
        for (var file in tempFiles) {
          if (file is File) {
            final String path = file.path.toLowerCase();
            if (path.endsWith('.jpg') || path.endsWith('.png') || path.endsWith('.jpeg')) {
              if (await file.length() > 0) allFiles.add(file);
            }
          }
        }
      } catch (e) {
        debugPrint('Error loading temp files: $e');
      }
    }

    if (externalDir != null) {
      final recordingsDir = Directory('${externalDir.path}/Recordings');
      if (await recordingsDir.exists()) {
        try {
          final List<FileSystemEntity> videoFiles = recordingsDir.listSync();
          for (var file in videoFiles) {
            if (file is File && file.path.toLowerCase().endsWith('.mp4')) {
              if (await file.length() > 0) allFiles.add(file);
            }
          }
        } catch (e) {
          debugPrint('Error loading video files: $e');
        }
      }
    }

    allFiles.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    if (mounted) setState(() => _media = allFiles);
  }

  void _toggleSelection(String path) {
    setState(() {
      if (_selectedPaths.contains(path)) {
        _selectedPaths.remove(path);
      } else {
        _selectedPaths.add(path);
      }
    });
  }

  Future<void> _promptAndUpload() async {
    if (_selectedPaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one photo or video.')));
      return;
    }

    final emailController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Enter Applicant Email', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the email address associated with the applicant to link this media submission.',
              style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'applicant@example.com',
                prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF0055b8)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0055b8), foregroundColor: Colors.white),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed != true || emailController.text.trim().isEmpty) return;

    setState(() => _isUploading = true);
    try {
      final uri = Uri.parse('$apiBaseUrl/api/application/upload-media/');
      final request = http.MultipartRequest('POST', uri);
      request.fields['email'] = emailController.text.trim();
      if (widget.capturedAddress != null) request.fields['submission_address'] = widget.capturedAddress!;
      if (widget.lat != null) request.fields['latitude'] = widget.lat.toString();
      if (widget.lng != null) request.fields['longitude'] = widget.lng.toString();

      for (final path in _selectedPaths) {
        final mimeType = lookupMimeType(path) ?? 'application/octet-stream';
        final parts = mimeType.split('/');
        request.files.add(
          await http.MultipartFile.fromPath('files', path, contentType: MediaType(parts[0], parts[1])),
        );
      }

      final response = await request.send();
      if (!mounted) return;
      setState(() => _isUploading = false);

      if (response.statusCode == 201) {
        final count = _selectedPaths.length;
        setState(() => _selectedPaths.clear());
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => SuccessDialog(
            message: '$count media item${count == 1 ? '' : 's'} linked successfully!',
            subMessage: 'The applicant will be updated with these field documents.',
            onDone: () => Navigator.of(context).pop(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed (${response.statusCode}). Please try again.')));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = _media;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _selectedPaths.isEmpty ? 'Media Gallery' : '${_selectedPaths.length} selected',
          style: TextStyle(
            color: _selectedPaths.isEmpty ? const Color(0xFF333333) : const Color(0xFF0055b8),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_selectedPaths.isNotEmpty)
            _isUploading
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0055b8))),
                )
              : TextButton.icon(
                  onPressed: _promptAndUpload,
                  icon: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF0055b8)),
                  label: const Text('Submit', style: TextStyle(color: Color(0xFF0055b8), fontWeight: FontWeight.bold)),
                ),
        ],
      ),
      body: media == null
          ? const Center(child: CircularProgressIndicator())
          : media.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No media captured yet', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Use the camera button to click photos', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                ],
              ),
            )
          : Column(
              children: [
                if (_selectedPaths.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    color: const Color(0xFFe8f0fe),
                    child: const Text(
                      'Tap items to select/deselect. Tap Submit to upload.',
                      style: TextStyle(color: Color(0xFF0055b8), fontSize: 13),
                    ),
                  ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
                    itemCount: media.length,
                    itemBuilder: (context, index) {
                      final file = media[index];
                      final isVideo = file.path.toLowerCase().endsWith('.mp4');
                      final isSelected = _selectedPaths.contains(file.path);

                      return GestureDetector(
                        onTap: () => _toggleSelection(file.path),
                        onLongPress: () {
                          if (!isVideo) {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => FullScreenImageViewer(imageFile: File(file.path))));
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => VideoPlayerScreen(file: File(file.path))));
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: isSelected ? Border.all(color: const Color(0xFF0055b8), width: 3) : null,
                            color: Colors.grey.shade200,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (!isVideo) Image.file(File(file.path), fit: BoxFit.cover)
                              else Container(color: Colors.black87, child: const Center(child: Icon(Icons.play_circle_outline, color: Colors.white, size: 40))),
                              if (isSelected)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(color: Color(0xFF0055b8), shape: BoxShape.circle),
                                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                                  ),
                                ),
                              if (isVideo)
                                Positioned(
                                  bottom: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(3)),
                                    child: const Text('VIDEO', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
