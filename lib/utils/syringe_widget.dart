// Ficheiro: utils/syringe_widget.dart
import 'package:flutter/material.dart';

import 'dose_calculator.dart';

class SyringeVisualizer extends StatelessWidget {
  final SyringeSize syringeSize;
  final double filledUnits;

  const SyringeVisualizer({
    super.key,
    required this.syringeSize,
    required this.filledUnits,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      color: Colors.white,
      child: CustomPaint(
        painter: _SyringePainter(
          sizeConfig: syringeSize,
          filledUnits: filledUnits,
        ),
      ),
    );
  }
}

class _SyringePainter extends CustomPainter {
  final SyringeSize sizeConfig;
  final double filledUnits;

  _SyringePainter({required this.sizeConfig, required this.filledUnits});

  @override
  void paint(Canvas canvas, Size size) {
    final double syringeHeight = 45.0;
    final double startY = (size.height - syringeHeight) / 2;

    final double needleWidth = 20.0;
    final double plungerWidth = 25.0;
    final double barrelWidth = size.width - needleWidth - plungerWidth;
    final double barrelStartX = needleWidth;

    final paintOutline = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final paintLiquid = Paint()
      ..color = Colors.lightBlueAccent.shade100
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    double fillPercentage = (filledUnits / sizeConfig.maxUnits).clamp(0.0, 1.0);

    // 👇 AJUSTE AQUI: Recuo reduzido de 35.0 para 26.0 para aproximar a escala das letras
    final double liquidStartX = barrelStartX + 26.0;

    final double rightMargin = 12.0;
    // A largura da régua agora acompanha o novo recuo de 26.0
    final double liquidDrawWidth = barrelWidth - 26.0 - rightMargin;

    // 1. Desenhar Líquido
    if (fillPercentage > 0) {
      final liquidRect = Rect.fromLTWH(
        liquidStartX,
        startY,
        liquidDrawWidth * fillPercentage,
        syringeHeight,
      );
      canvas.drawRect(liquidRect, paintLiquid);
    }

    // 2. Desenhar Corpo da Seringa
    final barrelRect = Rect.fromLTWH(
      barrelStartX,
      startY,
      barrelWidth,
      syringeHeight,
    );
    canvas.drawRect(barrelRect, paintOutline);

    // 3. Desenhar Agulha
    canvas.drawRect(
      Rect.fromLTWH(barrelStartX - 8, startY + 12, 8, syringeHeight - 24),
      paintOutline,
    );
    canvas.drawLine(
      Offset(barrelStartX - 8, size.height / 2),
      Offset(0, size.height / 2),
      paintOutline..strokeWidth = 3.0,
    );

    // 4. Desenhar Êmbolo
    canvas.drawRect(
      Rect.fromLTWH(
        barrelStartX + barrelWidth,
        startY + 5,
        8,
        syringeHeight - 10,
      ),
      paintOutline,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        barrelStartX + barrelWidth + 8,
        startY + 15,
        plungerWidth - 12,
        syringeHeight - 30,
      ),
      paintOutline,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width - 6, startY - 2, 6, syringeHeight + 4),
      paintOutline..style = PaintingStyle.fill,
    );

    // 5. Textos Fixos Iniciais (Ajustados para mL e UI)
    _drawText(canvas, textPainter, 'mL:', barrelStartX + 6, startY + 6, 9);
    _drawText(canvas, textPainter, 'UI:', barrelStartX + 6, startY + 28, 9);

    // 6. Desenhar Régua
    int majorTickStep;
    int minorTickStep;

    if (sizeConfig == SyringeSize.u100) {
      majorTickStep = 10;
      minorTickStep = 2;
    } else if (sizeConfig == SyringeSize.u50) {
      majorTickStep = 5;
      minorTickStep = 1;
    } else if (sizeConfig == SyringeSize.u30) {
      majorTickStep = 5;
      minorTickStep = 1;
    } else {
      majorTickStep = 50;
      minorTickStep = 10;
    }

    for (int i = 0; i <= sizeConfig.maxUnits; i++) {
      if (i % minorTickStep != 0 && i % majorTickStep != 0) continue;

      double x = liquidStartX + (i / sizeConfig.maxUnits) * liquidDrawWidth;

      bool isMajorTick = i % majorTickStep == 0;

      // Traços Superiores
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, startY + (isMajorTick ? 8 : 4)),
        paintOutline..strokeWidth = isMajorTick ? 1.5 : 1.0,
      );

      // Traços Inferiores
      canvas.drawLine(
        Offset(x, startY + syringeHeight),
        Offset(x, startY + syringeHeight - (isMajorTick ? 8 : 4)),
        paintOutline..strokeWidth = isMajorTick ? 1.5 : 1.0,
      );

      if (isMajorTick && i > 0) {
        double mlVal = i / 100.0;
        String mlText = mlVal.toStringAsFixed(2).replaceAll('0.', '.');
        if (sizeConfig == SyringeSize.u100) {
          mlText = mlVal.toStringAsFixed(1).replaceAll('0.', '.');
        }

        double textOffsetAdjustment = (i == sizeConfig.maxUnits) ? 8.0 : 6.0;

        _drawText(
          canvas,
          textPainter,
          mlText,
          x - textOffsetAdjustment,
          startY + 10,
          8,
        );
        _drawText(
          canvas,
          textPainter,
          '$i',
          x - textOffsetAdjustment + 2,
          startY + 24,
          8,
        );
      }
    }
  }

  void _drawText(
    Canvas canvas,
    TextPainter painter,
    String text,
    double x,
    double y,
    double fontSize,
  ) {
    painter.text = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.black,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
    painter.layout();
    painter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant _SyringePainter oldDelegate) {
    return oldDelegate.filledUnits != filledUnits ||
        oldDelegate.sizeConfig != sizeConfig;
  }
}
