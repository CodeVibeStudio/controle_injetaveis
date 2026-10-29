import 'package:flutter/material.dart';

import 'dose_calculator.dart';

class SyringeVisualizer extends StatelessWidget {
  final SyringeSize syringeSize;
  final double filledUnits;
  final bool hasError;

  const SyringeVisualizer({
    super.key,
    required this.syringeSize,
    required this.filledUnits,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hasError ? Colors.red : Colors.grey.shade300),
      ),
      child: CustomPaint(
        painter: _SyringePainter(
          sizeConfig: syringeSize,
          filledUnits: filledUnits,
          isOverfilled: hasError,
        ),
      ),
    );
  }
}

class _SyringePainter extends CustomPainter {
  final SyringeSize sizeConfig;
  final double filledUnits;
  final bool isOverfilled;

  _SyringePainter({
    required this.sizeConfig,
    required this.filledUnits,
    required this.isOverfilled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double syringeHeight = 40.0;
    final double startY = (size.height - syringeHeight) / 2;

    final paintBody = Paint()
      ..color = Colors.blueGrey.shade100
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final paintLiquid = Paint()
      ..color = isOverfilled
          ? Colors.red.withValues(alpha: 0.7)
          : Colors.amber.shade600.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    double fillPercentage = (filledUnits / sizeConfig.maxUnits);
    if (fillPercentage > 1.0) fillPercentage = 1.0;
    if (fillPercentage < 0.0) fillPercentage = 0.0;

    final liquidRect = Rect.fromLTWH(
      0,
      startY,
      size.width * fillPercentage,
      syringeHeight,
    );
    canvas.drawRect(liquidRect, paintLiquid);

    final bodyRect = Rect.fromLTWH(0, startY, size.width, syringeHeight);
    canvas.drawRect(bodyRect, paintBody);

    // Adaptação da escala visual consoante o tamanho da seringa
    int tickStep;
    if (sizeConfig == SyringeSize.u300 || sizeConfig == SyringeSize.u500) {
      tickStep = 50;
    } else if (sizeConfig == SyringeSize.u100) {
      tickStep = 10;
    } else {
      tickStep = 5;
    }

    for (int i = 0; i <= sizeConfig.maxUnits; i++) {
      double x = (i / sizeConfig.maxUnits) * size.width;

      bool isMajorTick = i % tickStep == 0;
      bool isMediumTick = i % (tickStep / 2) == 0;

      double tickLength = isMajorTick ? 15.0 : (isMediumTick ? 10.0 : 5.0);

      canvas.drawLine(
        Offset(x, startY),
        Offset(x, startY + tickLength),
        Paint()
          ..color = Colors.black87
          ..strokeWidth = isMajorTick ? 1.5 : 1.0,
      );

      if (isMajorTick && i > 0) {
        textPainter.text = TextSpan(
          text: '$i',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - (textPainter.width / 2), startY + 18),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SyringePainter oldDelegate) {
    return oldDelegate.filledUnits != filledUnits ||
        oldDelegate.sizeConfig != sizeConfig ||
        oldDelegate.isOverfilled != isOverfilled;
  }
}
