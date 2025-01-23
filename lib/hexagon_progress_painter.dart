import 'package:flutter/material.dart';

class HexagonProgressPainter extends CustomPainter {
  final double progress; 

  HexagonProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xffffa400)
      ..style = PaintingStyle.fill;

    final hexPath = Path();
    final double width = size.width;
    final double height = size.height;

    // Create a flat hexagon path
    hexPath.moveTo(width * 0.25, 0);
    hexPath.lineTo(width * 0.75, 0); 
    hexPath.lineTo(width, height * 0.5); 
    hexPath.lineTo(width * 0.75, height); 
    hexPath.lineTo(width * 0.25, height); 
    hexPath.lineTo(0, height * 0.5);
    hexPath.close();

    canvas.drawPath(hexPath, Paint()..color = const Color(0xffffee9ae));

    // Clip the hexagon to only draw progress
    canvas.save();
    canvas.clipPath(hexPath);

    // Calculate the width to fill based on progress
    final double fillWidth = width * progress;

    // Draw the progress part of the hexagon
    canvas.drawRect(Rect.fromLTWH(0, 0, fillWidth, height), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}