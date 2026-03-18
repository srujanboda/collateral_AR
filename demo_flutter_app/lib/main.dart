import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

import 'ar_measurement_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Property Verification',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0055b8)),
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
            fontSize: 24,
          ),
          headlineSmall: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
            fontSize: 20,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF666666),
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ),
      home: const VerificationHomeScreen(),
    );
  }
}

class VerificationHomeScreen extends StatefulWidget {
  const VerificationHomeScreen({super.key});

  @override
  State<VerificationHomeScreen> createState() => _VerificationHomeScreenState();
}

class _VerificationHomeScreenState extends State<VerificationHomeScreen> {
  bool _agreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black54),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFfff8ec),
            child: Row(
              children: [
                const Icon(Icons.security, color: Color(0xFFd4a017), size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Your data is safe & never stored',
                    style: TextStyle(
                      color: Color(0xFF856404),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Learn More',
                        style: TextStyle(
                          color: Color(0xFF0055b8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remote Property Verification',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Follow these simple steps. Our agent will guide you to complete the property inspection and verification remotely.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      children: [
                        _buildStepItem(
                          step: 'Step 1',
                          title: 'Allow Location Access',
                          icon: Icons.location_on_outlined,
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _buildStepItem(
                          step: 'Step 2',
                          title: 'Allow Camera and Microphone Access',
                          icon: Icons.videocam_outlined,
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _buildStepItem(
                          step: 'Step 3',
                          title: 'Connect with Agent for Verification',
                          icon: Icons.person_search_outlined,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreedToTerms = value ?? false;
                        });
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _agreedToTerms = !_agreedToTerms;
                          });
                        },
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                            children: [
                              const TextSpan(text: 'I hereby agree to the '),
                              TextSpan(
                                text: 'terms and conditions.',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _agreedToTerms
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const LocationSharingScreen(),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0055b8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Start Verification',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.chevron_right, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required String step,
    required String title,
    required IconData icon,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0055b8).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF0055b8), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF444444),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum LocationState { initial, denied, verified }

class LocationSharingScreen extends StatefulWidget {
  const LocationSharingScreen({super.key});

  @override
  State<LocationSharingScreen> createState() => _LocationSharingScreenState();
}

class _LocationSharingScreenState extends State<LocationSharingScreen> {
  LocationState _state = LocationState.initial;
  String _currentAddress = 'Fetching location...';
  double? _lat;
  double? _lng;

  Future<void> _fetchLocationAndAddress() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _state = LocationState.denied);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _state = LocationState.denied);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _state = LocationState.denied);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _lat = position.latitude;
      _lng = position.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _state = LocationState.verified;
          _currentAddress =
              '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''} ${place.country ?? ''}'
                  .replaceAll(RegExp(r',\s*,'), ',');
        });
      } else {
        setState(() {
          _state = LocationState.verified;
          _currentAddress =
              'Lat: ${position.latitude}, Lng: ${position.longitude}';
        });
      }
    } catch (e) {
      setState(() {
        _state = LocationState.verified;
        _currentAddress = 'Address could not be fetched. Location verified.';
      });
    }
  }

  Future<void> _takePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null && mounted) {
      try {
        // Save to gallery using gal package
        await Gal.putImage(image.path);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image saved to gallery successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save image: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '“ACME” Would Like To Access Your Location',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your location is used for a secure liveliness check. This ensures accurate verification without storing or sharing your location data.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                const Divider(height: 1),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {
                              _state = LocationState.denied;
                            });
                          },
                          child: const Text(
                            'Don’t Allow',
                            style: TextStyle(
                              fontSize: 17,
                              color: Color(0xFF007AFF),
                            ),
                          ),
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _fetchLocationAndAddress();
                          },
                          child: const Text(
                            'OK',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF007AFF),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black54),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.photo_library_outlined,
              color: Colors.black54,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GalleryScreen(
                    capturedAddress: _state == LocationState.verified
                        ? _currentAddress
                        : null,
                    lat: _lat,
                    lng: _lng,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share your Location',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Let's make sure you're at the right property before we start",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  _buildStateCard(),
                  const SizedBox(height: 40),
                  const Text(
                    'Why we need your location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBenefitItem(
                    'Verify you are at the same property address',
                  ),
                  _buildBenefitItem('Ensure accurate documentation'),
                  _buildBenefitItem('Comply with verification requirements'),
                ],
              ),
            ),
          ),
          if (_state == LocationState.verified)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _takePicture,
                      icon: const Icon(Icons.camera_alt, size: 20),
                      label: const Text(
                        'Click Field Photos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0055b8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ArMeasurementScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.straighten_rounded, size: 20),
                      label: const Text(
                        'Open AR distance measurement',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0055b8)),
                        foregroundColor: const Color(0xFF0055b8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStateCard() {
    switch (_state) {
      case LocationState.initial:
        return _buildActionCard(
          icon: Icons.location_on_outlined,
          title: 'Share Your Current Location',
          subtitle:
              'Click the button below and allow us to access your current location.',
          buttonText: 'Share My Location',
          onPressed: _showPermissionDialog,
          iconColor: const Color(0xFF0055b8),
          bgColor: const Color(0xFFf8faff),
          borderColor: Colors.blue.shade100,
        );
      case LocationState.denied:
        return _buildActionCard(
          icon: Icons.report_problem_outlined,
          title: 'Location Access Needed',
          subtitle:
              'Click the button below and allow us to access your current location.',
          buttonText: 'Share My Location',
          onPressed: _showPermissionDialog,
          iconColor: Colors.red,
          bgColor: const Color(0xFFfff5f5),
          borderColor: Colors.red.shade100,
        );
      case LocationState.verified:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFf0fdf4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location Verified',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1b4332),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentAddress,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2d6a4f),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.location_searching, size: 20),
              label: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0055b8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.green, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF444444),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

  static const String _apiBase = 'http://10.84.153.247:8000';

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
        final List<FileSystemEntity> tempFiles = tempDir.listSync(
          recursive: true,
        );
        for (var file in tempFiles) {
          if (file is File) {
            final String path = file.path.toLowerCase();
            if (path.endsWith('.jpg') ||
                path.endsWith('.png') ||
                path.endsWith('.jpeg')) {
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

    allFiles.sort(
      (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
    );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one photo or video.'),
        ),
      );
      return;
    }

    final emailController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Enter Applicant Email',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFF0055b8),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF0055b8),
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0055b8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed != true || emailController.text.trim().isEmpty) return;

    setState(() => _isUploading = true);
    try {
      final uri = Uri.parse('$_apiBase/api/application/upload-media/');
      final request = http.MultipartRequest('POST', uri);
      request.fields['email'] = emailController.text.trim();
      if (widget.capturedAddress != null) {
        request.fields['submission_address'] = widget.capturedAddress!;
      }
      if (widget.lat != null) {
        request.fields['latitude'] = widget.lat.toString();
      }
      if (widget.lng != null) {
        request.fields['longitude'] = widget.lng.toString();
      }

      for (final path in _selectedPaths) {
        final mimeType = lookupMimeType(path) ?? 'application/octet-stream';
        final parts = mimeType.split('/');
        request.files.add(
          await http.MultipartFile.fromPath(
            'files',
            path,
            contentType: MediaType(parts[0], parts[1]),
          ),
        );
      }

      final response = await request.send();
      if (!mounted) return;
      setState(() => _isUploading = false);

      if (response.statusCode == 201) {
        setState(() => _selectedPaths.clear());
        _showSuccessDialog(_selectedPaths.length);
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

  void _showSuccessDialog(int count) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Submitted Successfully!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1b4332),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your media has been linked to the applicant.',
                style: TextStyle(color: Color(0xFF555555), fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0055b8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = _media;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _selectedPaths.isEmpty
              ? 'Media Gallery'
              : '${_selectedPaths.length} selected',
          style: TextStyle(
            color: _selectedPaths.isEmpty
                ? const Color(0xFF333333)
                : const Color(0xFF0055b8),
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
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF0055b8),
                      ),
                    ),
                  )
                : TextButton.icon(
                    onPressed: _promptAndUpload,
                    icon: const Icon(
                      Icons.cloud_upload_outlined,
                      color: Color(0xFF0055b8),
                    ),
                    label: const Text(
                      'Submit',
                      style: TextStyle(
                        color: Color(0xFF0055b8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                  Icon(
                    Icons.photo_library_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No media captured yet',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use the camera button to click photos',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                if (_selectedPaths.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    color: const Color(0xFFe8f0fe),
                    child: Text(
                      'Tap items to select/deselect. Tap Submit to upload.',
                      style: const TextStyle(
                        color: Color(0xFF0055b8),
                        fontSize: 13,
                      ),
                    ),
                  ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                    itemCount: media.length,
                    itemBuilder: (context, index) {
                      final file = media[index];
                      final isVideo = file.path.toLowerCase().endsWith('.mp4');
                      final isSelected = _selectedPaths.contains(file.path);

                      return GestureDetector(
                        onTap: () => _toggleSelection(file.path),
                        onLongPress: () {
                          if (!isVideo) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => FullScreenImageViewer(
                                  imageFile: File(file.path),
                                ),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    VideoPlayerScreen(file: File(file.path)),
                              ),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: isSelected
                                ? Border.all(
                                    color: const Color(0xFF0055b8),
                                    width: 3,
                                  )
                                : null,
                            color: Colors.grey.shade200,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (!isVideo)
                                Image.file(File(file.path), fit: BoxFit.cover)
                              else
                                Container(
                                  color: Colors.black87,
                                  child: const Center(
                                    child: Icon(
                                      Icons.play_circle_outline,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              if (isSelected)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0055b8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              if (isVideo)
                                Positioned(
                                  bottom: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: const Text(
                                      'VIDEO',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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

class FullScreenImageViewer extends StatelessWidget {
  final File imageFile;

  const FullScreenImageViewer({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: Hero(
          tag: imageFile.path,
          child: InteractiveViewer(child: Image.file(imageFile)),
        ),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final File file;
  const VideoPlayerScreen({super.key, required this.file});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _videoPlayerController = VideoPlayerController.file(widget.file);
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.path.split('/').last),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child:
            _chewieController != null &&
                _chewieController!.videoPlayerController.value.isInitialized
            ? Chewie(controller: _chewieController!)
            : const CircularProgressIndicator(),
      ),
    );
  }
}
