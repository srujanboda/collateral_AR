import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class ApiService {
  static Future<Map<String, dynamic>?> getApplicationDetails(String perfiosId) async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/api/applications/$perfiosId/'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error fetching application: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception in getApplicationDetails: $e');
      return null;
    }
  }

  static String? getFloorPlanUrl(Map<String, dynamic> applicationData) {
    if (applicationData['documents'] == null) return null;
    
    final documents = applicationData['documents'] as List;
    
    // Step ID "4" is the Building Plan (Floor Plan)
    final floorPlanDoc = documents.firstWhere(
      (doc) => doc['step_id'] == "4",
      orElse: () => null,
    );
    
    if (floorPlanDoc != null && floorPlanDoc['files'] != null && (floorPlanDoc['files'] as List).isNotEmpty) {
      final filePath = floorPlanDoc['files'][0] as String;
      // Convert media/ path to full URL
      return '$apiBaseUrl/media/$filePath';
    }
    
    return null;
  }
}
