import '../repositories/ar_repository.dart';

/// Use-case: fetch the floor-plan URL for a given application.
class GetFloorPlanUseCase {
  final ArRepository _repository;

  const GetFloorPlanUseCase(this._repository);

  Future<String?> call(String perfiosId) => _repository.getFloorPlanUrl(perfiosId);
}
