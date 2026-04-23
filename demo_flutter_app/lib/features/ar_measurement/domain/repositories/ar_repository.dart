/// Abstract repository — isolates the domain from concrete data sources.
abstract class ArRepository {
  /// Returns the floor-plan image URL for [perfiosId], or null if unavailable.
  Future<String?> getFloorPlanUrl(String perfiosId);

  /// Uploads a floor-plan image located at [filePath] for [perfiosId].
  /// Returns true on success.
  Future<bool> uploadFloorPlan(String perfiosId, String filePath);
}
