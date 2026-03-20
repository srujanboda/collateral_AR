import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';
import '../widgets/common_widgets.dart';
import '../ar_measurement_screen.dart';
import 'gallery_screen.dart';

enum LocationState { initial, denied, verified }

class LocationSharingScreen extends StatefulWidget {
  final String? perfiosId;
  const LocationSharingScreen({super.key, this.perfiosId});

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
            icon: const Icon(Icons.photo_library_outlined, color: Colors.black54),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GalleryScreen(
                    perfiosId: widget.perfiosId,
                    capturedAddress: _state == LocationState.verified ? _currentAddress : null,
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
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Let's make sure you're at the right property before we start",
                    style: TextStyle(color: Color(0xFF666666), fontSize: 16),
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
                  const BenefitItem(text: 'Verify you are at the same property address'),
                  const BenefitItem(text: 'Ensure accurate documentation'),
                  const BenefitItem(text: 'Comply with verification requirements'),
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
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0055b8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                            builder: (context) => ArMeasurementScreen(
                              perfiosId: widget.perfiosId,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.straighten_rounded, size: 20),
                      label: const Text(
                        'Open AR distance measurement',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0055b8)),
                        foregroundColor: const Color(0xFF0055b8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          subtitle: 'Click the button below and allow us to access your current location.',
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
          subtitle: 'Click the button below and allow us to access your current location.',
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
                child: const Icon(Icons.check_circle, color: Colors.green, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location Verified',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1b4332)),
                    ),
                    const SizedBox(height: 4),
                    Text(_currentAddress, style: const TextStyle(fontSize: 13, color: Color(0xFF2d6a4f))),
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
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 32),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Color(0xFF666666))),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.location_searching, size: 20),
              label: Text(buttonText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0055b8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
