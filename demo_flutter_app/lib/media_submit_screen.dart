import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../constants.dart';
import '../widgets/common_widgets.dart';

// ── Perfios ID entry screen ──────────────────────────────────────────────────
class PerfiosIdScreen extends StatefulWidget {
  final String? capturedAddress;
  final double? lat;
  final double? lng;

  const PerfiosIdScreen({super.key, this.capturedAddress, this.lat, this.lng});

  @override
  State<PerfiosIdScreen> createState() => _PerfiosIdScreenState();
}

class _PerfiosIdScreenState extends State<PerfiosIdScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _proceed() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MediaSubmitScreen(
            perfiosId: _controller.text.trim(),
            capturedAddress: widget.capturedAddress,
            lat: widget.lat,
            lng: widget.lng,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Enter Applicant ID',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Link media to an applicant',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter the Perfios ID to associate the photos and videos you capture.',
                style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Perfios ID',
                  hintText: 'e.g. PERF-1234',
                  prefixIcon: const Icon(
                    Icons.badge_outlined,
                    color: Color(0xFF0055b8),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Please enter a Perfios ID'
                    : null,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _proceed,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text(
                    'Proceed to Media Upload',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0055b8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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

// ── Media picker + upload screen ─────────────────────────────────────────────
class MediaSubmitScreen extends StatefulWidget {
  final String perfiosId;
  final String? capturedAddress;
  final double? lat;
  final double? lng;

  const MediaSubmitScreen({
    super.key,
    required this.perfiosId,
    this.capturedAddress,
    this.lat,
    this.lng,
  });

  @override
  State<MediaSubmitScreen> createState() => _MediaSubmitScreenState();
}

class _MediaSubmitScreenState extends State<MediaSubmitScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selected = [];
  bool _isUploading = false;

  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFe8f0fe),
                child: Icon(Icons.photo_library, color: Color(0xFF0055b8)),
              ),
              title: const Text('Pick Photos from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final files = await _picker.pickMultiImage(imageQuality: 80);
                if (files.isNotEmpty) setState(() => _selected.addAll(files));
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFe8f0fe),
                child: Icon(Icons.videocam, color: Color(0xFF0055b8)),
              ),
              title: const Text('Pick a Video from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final file = await _picker.pickVideo(
                  source: ImageSource.gallery,
                );
                if (file != null) setState(() => _selected.add(file));
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFe8f0fe),
                child: Icon(Icons.camera_alt, color: Color(0xFF0055b8)),
              ),
              title: const Text('Take a Photo with Camera'),
              onTap: () async {
                Navigator.pop(context);
                final file = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (file != null) setState(() => _selected.add(file));
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one photo or video.'),
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final uri = Uri.parse('$apiBaseUrl/api/application/upload-media/');
      final request = http.MultipartRequest('POST', uri);
      request.fields['perfios_id'] = widget.perfiosId;
      if (widget.capturedAddress != null) {
        request.fields['submission_address'] = widget.capturedAddress!;
      }
      if (widget.lat != null) {
        request.fields['latitude'] = widget.lat.toString();
      }
      if (widget.lng != null) {
        request.fields['longitude'] = widget.lng.toString();
      }

      for (final file in _selected) {
        final mimeType =
            lookupMimeType(file.path) ?? 'application/octet-stream';
        final parts = mimeType.split('/');
        request.files.add(
          await http.MultipartFile.fromPath(
            'files',
            file.path,
            contentType: MediaType(parts[0], parts[1]),
          ),
        );
      }

      final response = await request.send();

      if (!mounted) return;
      setState(() => _isUploading = false);

      if (response.statusCode == 201) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => SuccessDialog(
            message: '${_selected.length} files uploaded for ${widget.perfiosId}',
            onDone: () {
              Navigator.of(context).pop(); // close dialog
              Navigator.of(context).pop(); // go back to location screen
            },
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Upload failed (${response.statusCode}). Please try again.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _removeFile(int index) => setState(() => _selected.removeAt(index));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit Field Media',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              widget.perfiosId,
              style: const TextStyle(
                color: Color(0xFF0055b8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          if (_selected.isNotEmpty && !_isUploading)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                tooltip: 'Submit',
                icon: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 32,
                ),
                onPressed: _submit,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Info bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFfff8ec),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Color(0xFFd4a017),
                  size: 18,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Select photos/videos, then tap ✓ or the submit button',
                    style: TextStyle(
                      color: Color(0xFF856404),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Grid of selected files
          Expanded(
            child: _selected.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No media selected yet',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap the button below to add photos or videos',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                           crossAxisCount: 3,
                           crossAxisSpacing: 8,
                           mainAxisSpacing: 8,
                        ),
                    itemCount: _selected.length,
                    itemBuilder: (_, i) {
                      final file = _selected[i];
                      final isVideo =
                          file.path.endsWith('.mp4') ||
                          file.path.endsWith('.mov') ||
                          file.path.endsWith('.avi') ||
                          file.path.endsWith('.mkv');
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: isVideo
                                ? Container(
                                    color: Colors.black87,
                                    child: const Center(
                                      child: Icon(
                                        Icons.play_circle_fill,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                  )
                                : Image.file(
                                    File(file.path),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          // Remove button
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeFile(i),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                          // Video badge
                          if (isVideo)
                            Positioned(
                              bottom: 6,
                              left: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'VIDEO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),

          // Bottom action area
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              children: [
                if (_selected.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '${_selected.length} item${_selected.length == 1 ? '' : 's'} selected',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isUploading ? null : _pickMedia,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text(
                          'Add Media',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF0055b8)),
                          foregroundColor: const Color(0xFF0055b8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    if (_selected.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isUploading ? null : _submit,
                          icon: _isUploading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.cloud_upload_outlined),
                          label: Text(
                            _isUploading ? 'Uploading...' : 'Submit',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFF0055b8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
