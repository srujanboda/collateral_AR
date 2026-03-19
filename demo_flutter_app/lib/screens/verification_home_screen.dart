import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';
import 'location_sharing_screen.dart';

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
                  child: const Row(
                    children: [
                      Text(
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
                        color: Color(0xFF0055b8),
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
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Follow these simple steps. Our agent will guide you to complete the property inspection and verification remotely.',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: const Column(
                      children: [
                        StepItem(
                          step: 'Step 1',
                          title: 'Allow Location Access',
                          icon: Icons.location_on_outlined,
                        ),
                        Divider(height: 1, indent: 16, endIndent: 16),
                        StepItem(
                          step: 'Step 2',
                          title: 'Allow Camera and Microphone Access',
                          icon: Icons.videocam_outlined,
                        ),
                        Divider(height: 1, indent: 16, endIndent: 16),
                        StepItem(
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
                      activeColor: const Color(0xFF0055b8),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _agreedToTerms = !_agreedToTerms;
                          });
                        },
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(text: 'I hereby agree to the '),
                              TextSpan(
                                text: 'terms and conditions.',
                                style: TextStyle(
                                  color: Color(0xFF0055b8),
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
}
