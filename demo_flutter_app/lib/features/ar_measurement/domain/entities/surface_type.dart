/// Describes the type of physical surface a measurement point is placed on.
///
/// Inferred automatically from:
///   1. The hit-plane's normal vector Y-component.
///   2. Camera pitch when no plane hit is available.
enum SurfaceType {
  /// Horizontal surface below the camera (normal.y > 0.7)
  floor,

  /// Vertical surface — walls, pillars (|normal.y| ≤ 0.7)
  wall,

  /// Horizontal surface above the camera (normal.y < -0.7)
  ceiling;

  /// Human-readable status hint shown on the AR overlay.
  String get scanHint {
    switch (this) {
      case SurfaceType.floor:
        return 'Scan the floor, then tap to place a point.';
      case SurfaceType.wall:
        return 'Scan the wall, then tap to place a point.';
      case SurfaceType.ceiling:
        return 'Point at the ceiling and tap.';
    }
  }

  /// Typical fallback distance in metres when no plane is detected.
  double get fallbackDistance {
    switch (this) {
      case SurfaceType.floor:
        return 2.0;
      case SurfaceType.wall:
        return 1.5;
      case SurfaceType.ceiling:
        return 3.0;
    }
  }
}
