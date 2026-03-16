import 'package:flutter/material.dart';

enum RoomState {
  defaultState,
  selected,
  saved,
}

class RoomPolygon {
  final String id;
  final String name;
  final List<Offset> points;
  RoomState state;

  RoomPolygon({
    required this.id,
    required this.name,
    required this.points,
    this.state = RoomState.defaultState,
  });
}
