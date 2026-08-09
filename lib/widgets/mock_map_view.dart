import 'package:flutter/material.dart';

import '../core/theme/rider_colors.dart';
import '../models/delivery_job.dart';

/// Stylized full-bleed map mock (no map SDK / API keys).
class MockMapView extends StatelessWidget {
  const MockMapView({
    super.key,
    this.pickup,
    this.dropoff,
    this.showRoute = false,
    this.riderLabel = 'You',
    this.statusChip,
  });

  final GeoPoint? pickup;
  final GeoPoint? dropoff;
  final bool showRoute;
  final String riderLabel;
  final String? statusChip;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _KumasiMapPainter(
            showRoute: showRoute,
            hasPickup: pickup != null,
            hasDropoff: dropoff != null,
          ),
        ),
        if (statusChip != null)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 72,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: RiderColors.primaryBlack,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusChip!,
                  style: const TextStyle(
                    color: RiderColors.primaryWhite,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        // Street labels for outdoor scanning feel
        const Positioned(
          left: 24,
          top: 180,
          child: _StreetLabel('PREMPEH II ST'),
        ),
        const Positioned(
          right: 40,
          top: 260,
          child: _StreetLabel('HARPER RD'),
        ),
        const Positioned(
          left: 48,
          bottom: 220,
          child: _StreetLabel('LAKE RD'),
        ),
      ],
    );
  }
}

class _StreetLabel extends StatelessWidget {
  const _StreetLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: RiderColors.primaryBlack.withValues(alpha: 0.35),
        fontWeight: FontWeight.w700,
        fontSize: 11,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _KumasiMapPainter extends CustomPainter {
  _KumasiMapPainter({
    required this.showRoute,
    required this.hasPickup,
    required this.hasDropoff,
  });

  final bool showRoute;
  final bool hasPickup;
  final bool hasDropoff;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFF5F3EF);
    canvas.drawRect(Offset.zero & size, bg);

    // Parks
    final park = Paint()..color = RiderColors.mapPark;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, size.height * 0.18, 120, 90),
        const Radius.circular(24),
      ),
      park,
    );
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.55), 48, park);

    // Water hint (Owabi / lake feel)
    final water = Paint()..color = RiderColors.mapWater;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.82, size.height * 0.72),
        width: 140,
        height: 70,
      ),
      water,
    );

    final road = Paint()
      ..color = RiderColors.mapRoad
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final arterial = Paint()
      ..color = const Color(0xFFD0D0D0)
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Grid-ish streets
    for (var i = 1; i < 6; i++) {
      final y = size.height * (i / 6);
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 20), road);
    }
    for (var i = 1; i < 5; i++) {
      final x = size.width * (i / 5);
      canvas.drawLine(Offset(x, 0), Offset(x - 30, size.height), road);
    }

    // Main corridor Adum → KNUST-ish diagonal
    final corridor = Path()
      ..moveTo(size.width * 0.18, size.height * 0.62)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.48,
        size.width * 0.72,
        size.height * 0.32,
      );
    canvas.drawPath(corridor, arterial);

    final pickup = Offset(size.width * 0.22, size.height * 0.58);
    final dropoff = Offset(size.width * 0.74, size.height * 0.30);
    final rider = Offset(size.width * 0.40, size.height * 0.48);

    if (showRoute) {
      final routePaint = Paint()
        ..color = RiderColors.primary
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final route = Path()
        ..moveTo(pickup.dx, pickup.dy)
        ..quadraticBezierTo(rider.dx, rider.dy - 20, dropoff.dx, dropoff.dy);
      canvas.drawPath(route, routePaint);
    }

    if (hasPickup) {
      _drawPin(canvas, pickup, RiderColors.primary, Icons.storefront);
    }
    if (hasDropoff) {
      _drawPin(canvas, dropoff, RiderColors.primaryBlack, Icons.flag);
    }

    // Rider marker
    final riderPaint = Paint()..color = RiderColors.primary;
    canvas.drawCircle(rider, 16, riderPaint);
    canvas.drawCircle(rider, 16, Paint()
      ..color = RiderColors.primaryWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3);
    // Direction wedge
    final wedge = Path()
      ..moveTo(rider.dx, rider.dy - 22)
      ..lineTo(rider.dx + 8, rider.dy - 8)
      ..lineTo(rider.dx - 8, rider.dy - 8)
      ..close();
    canvas.drawPath(wedge, riderPaint);
  }

  void _drawPin(Canvas canvas, Offset c, Color color, IconData _) {
    final paint = Paint()..color = color;
    canvas.drawCircle(c, 12, paint);
    canvas.drawCircle(c, 12, Paint()
      ..color = RiderColors.primaryWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3);
    canvas.drawCircle(c, 4, Paint()..color = RiderColors.primaryWhite);
  }

  @override
  bool shouldRepaint(covariant _KumasiMapPainter oldDelegate) {
    return oldDelegate.showRoute != showRoute ||
        oldDelegate.hasPickup != hasPickup ||
        oldDelegate.hasDropoff != hasDropoff;
  }
}
