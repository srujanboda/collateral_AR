import 'package:flutter/material.dart';

/// A single icon + label action button used in the bottom control bar.
class ArActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color color;

  const ArActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: enabled ? color : Colors.white24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: enabled ? Colors.white70 : Colors.white10,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom control bar containing Undo / New Line / Clear / Record buttons.
class ArControlBar extends StatelessWidget {
  final bool hasPaths;
  final bool isRecording;
  final VoidCallback onUndo;
  final VoidCallback onNewLine;
  final VoidCallback onClear;
  final VoidCallback onToggleRecord;

  const ArControlBar({
    super.key,
    required this.hasPaths,
    required this.isRecording,
    required this.onUndo,
    required this.onNewLine,
    required this.onClear,
    required this.onToggleRecord,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ArActionButton(
            icon: Icons.undo,
            label: 'Undo',
            onPressed: hasPaths ? onUndo : null,
          ),
          const SizedBox(width: 8),
          ArActionButton(
            icon: Icons.add,
            label: 'New Line',
            color: const Color(0xFF00E5FF),
            onPressed: hasPaths ? onNewLine : null,
          ),
          const SizedBox(width: 8),
          ArActionButton(
            icon: Icons.delete_outline,
            label: 'Clear',
            color: Colors.redAccent,
            onPressed: hasPaths ? onClear : null,
          ),
          const SizedBox(width: 8),
          ArActionButton(
            icon: isRecording ? Icons.stop : Icons.videocam,
            label: isRecording ? 'Stop' : 'Record',
            color: isRecording ? Colors.red : Colors.blue,
            onPressed: onToggleRecord,
          ),
        ],
      ),
    );
  }
}
