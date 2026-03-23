import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import '../constants.dart';

class ApiService {
  static Future<Map<String, dynamic>?> getApplicationDetails(String perfiosId) async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/api/application/$perfiosId/'));
      
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
    
    if (floorPlanDoc != null && floorPlanDoc['files'] != null) {
      final files = floorPlanDoc['files'] as List;
      for (var file in files) {
        final filePath = file as String;
        final ext = p.extension(filePath).toLowerCase();
        
        // Only return if it's an image
        if (['.jpg', '.jpeg', '.png', '.webp'].contains(ext)) {
          return '$apiBaseUrl/media/$filePath';
        }
      }
    }
    
    return null;
  }

  static Future<bool> uploadFloorPlan(String perfiosId, File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiBaseUrl/api/application/upload-document/'),
      );
      
      request.fields['perfios_id'] = perfiosId;
      request.fields['step_id'] = "4"; // Building Plan
      
      final ext = p.extension(imageFile.path).toLowerCase();
      String mimeType = 'image/jpeg';
      if (ext == '.png') mimeType = 'image/png';
      else if (ext == '.webp') mimeType = 'image/webp';

      request.files.add(await http.MultipartFile.fromPath(
        'files',
        imageFile.path,
        contentType: MediaType.parse(mimeType),
      ));

      final response = await request.send();
      return response.statusCode == 201;
    } catch (e) {
      print('Exception in uploadFloorPlan: $e');
      return false;
    }
  }
}
