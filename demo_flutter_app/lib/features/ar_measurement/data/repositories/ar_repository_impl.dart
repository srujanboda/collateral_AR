import 'dart:io';
import '../../../../services/api_service.dart';
import '../../domain/repositories/ar_repository.dart';

/// Concrete implementation of [ArRepository] backed by [ApiService].
class ArRepositoryImpl implements ArRepository {
  const ArRepositoryImpl();

  @override
  Future<String?> getFloorPlanUrl(String perfiosId) async {
    final data = await ApiService.getApplicationDetails(perfiosId);
    if (data == null) return null;
    return ApiService.getFloorPlanUrl(data);
  }

  @override
  Future<bool> uploadFloorPlan(String perfiosId, String filePath) =>
      ApiService.uploadFloorPlan(perfiosId, File(filePath));
}
