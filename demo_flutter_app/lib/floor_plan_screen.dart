import 'package:flutter/material.dart';
import 'floor_plan_models.dart';

class FloorPlanScreen extends StatefulWidget {
  const FloorPlanScreen({super.key});

  @override
  State<FloorPlanScreen> createState() => _FloorPlanScreenState();
}

class _FloorPlanScreenState extends State<FloorPlanScreen> {
  // Mock data for rooms representing a 2 BHK flat
  final List<RoomPolygon> rooms = [
    RoomPolygon(
      id: "hall",
      name: "Hall",
      points: [
        const Offset(50, 50),
        const Offset(350, 50),
        const Offset(350, 250),
        const Offset(50, 250),
      ],
    ),
    RoomPolygon(
      id: "kitchen",
      name: "Kitchen",
      points: [
        const Offset(350, 50),
        const Offset(500, 50),
        const Offset(500, 150),
        const Offset(350, 150),
      ],
    ),
    RoomPolygon(
      id: "bathroom",
      name: "Bathroom",
      points: [
        const Offset(350, 150),
        const Offset(500, 150),
        const Offset(500, 250),
        const Offset(350, 250),
      ],
    ),
    RoomPolygon(
      id: "bedroom1",
      name: "Bedroom 1",
      points: [
        const Offset(50, 250),
        const Offset(250, 250),
        const Offset(250, 450),
        const Offset(50, 450),
      ],
    ),
    RoomPolygon(
      id: "bedroom2",
      name: "Bedroom 2",
      points: [
        const Offset(250, 250),
        const Offset(500, 250),
        const Offset(500, 450),
        const Offset(250, 450),
      ],
    ),
  ];

  RoomPolygon? selectedRoom;

  void _handleTap(Offset localPosition) {
    // Check which polygon contains the localPosition
    RoomPolygon? tappedRoom;
    for (var room in rooms) {
      final path = Path()..addPolygon(room.points, true);
      if (path.contains(localPosition)) {
        tappedRoom = room;
        break;
      }
    }

    if (tappedRoom != null) {
      setState(() {
        // Deselect currently selected if any and not saved
        for (var room in rooms) {
          if (room.state == RoomState.selected) {
            room.state = RoomState.defaultState;
          }
        }
        
        // Only select if it's not already saved
        if (tappedRoom!.state != RoomState.saved) {
          tappedRoom.state = RoomState.selected;
          selectedRoom = tappedRoom;
        } else {
          selectedRoom = null;
        }
      });
    }
  }

  void _saveMeasurements() {
    if (selectedRoom != null) {
      setState(() {
        selectedRoom!.state = RoomState.saved;
        selectedRoom = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Measurements saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Floor Plan'),
        actions: [
          if (selectedRoom != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: TextButton.icon(
                onPressed: _saveMeasurements,
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.withValues(alpha: 0.1),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tap on a room to select it, then tap Save to mark measurement as complete.',
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: GestureDetector(
                  onTapUp: (details) {
                    _handleTap(details.localPosition);
                  },
                  child: Stack(
                    children: [
                      // Background layer mimicking floor plan image
                      Container(
                        width: 550,
                        height: 500,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.grey.shade400, width: 2),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.image, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'Uploaded Floor Plan Area',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Interactive polygons layer
                      CustomPaint(
                        size: const Size(550, 500),
                        painter: FloorPlanPainter(rooms: rooms),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: selectedRoom != null
          ? FloatingActionButton.extended(
              onPressed: _saveMeasurements,
              icon: const Icon(Icons.save),
              label: const Text('Save Measurements'),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }
}

class FloorPlanPainter extends CustomPainter {
  final List<RoomPolygon> rooms;

  FloorPlanPainter({required this.rooms});

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    for (var room in rooms) {
      final path = Path()..addPolygon(room.points, true);

      // Draw background based on state
      Paint fillPaint = Paint()..style = PaintingStyle.fill;
      switch (room.state) {
        case RoomState.defaultState:
          fillPaint.color = Colors.white.withValues(alpha: 0.5);
          break;
        case RoomState.selected:
          // Blue for selected (Hall turns blue when clicked)
          fillPaint.color = Colors.blue.withValues(alpha: 0.5);
          break;
        case RoomState.saved:
          // Green for saved (Hall turns green when saved)
          fillPaint.color = Colors.green.withValues(alpha: 0.5);
          break;
      }
      
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, borderPaint);

      // Draw text label centered in the polygon bounding box
      final bounds = path.getBounds();
      final textPainter = TextPainter(
        text: TextSpan(
          text: room.name,
          style: TextStyle(
            color: room.state == RoomState.defaultState ? Colors.black87 : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 2,
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          bounds.center.dx - (textPainter.width / 2),
          bounds.center.dy - (textPainter.height / 2),
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant FloorPlanPainter oldDelegate) {
    return true; 
  }
}
