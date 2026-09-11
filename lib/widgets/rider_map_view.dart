import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../core/theme/rider_colors.dart';
import '../models/delivery_job.dart' as model;

/// Full-bleed Google Map for the rider dashboard.
///
/// Shows the rider's own position (with heading), the pickup and drop-off
/// pins for the current job, and a route line to the stop the rider is
/// heading to. The camera follows the rider while idle and frames the
/// rider + next stop while a job is live.
class RiderMapView extends StatefulWidget {
  const RiderMapView({
    super.key,
    required this.lat,
    required this.lng,
    this.heading,
    this.pickup,
    this.dropoff,
    this.target,
    this.bottomPadding = 0,
    this.statusChip,
  });

  final double lat;
  final double lng;
  final int? heading;
  final model.GeoPoint? pickup;
  final model.GeoPoint? dropoff;

  /// Which stop the rider is currently driving to (drawn as the route end).
  final model.GeoPoint? target;

  /// Height of the bottom panel so the camera frames content above it.
  final double bottomPadding;
  final String? statusChip;

  @override
  State<RiderMapView> createState() => _RiderMapViewState();
}

class _RiderMapViewState extends State<RiderMapView> with SingleTickerProviderStateMixin {
  GoogleMapController? _controller;
  BitmapDescriptor? _riderIcon;
  BitmapDescriptor? _pickupIcon;
  BitmapDescriptor? _dropoffIcon;

  late final AnimationController _glide;
  LatLng _from = const LatLng(0, 0);
  LatLng _to = const LatLng(0, 0);
  LatLng _shown = const LatLng(0, 0);
  String? _framedKey;
  Timer? _frameDebounce;

  @override
  void initState() {
    super.initState();
    _from = _to = _shown = LatLng(widget.lat, widget.lng);
    _glide = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..addListener(() {
        final t = Curves.easeInOut.transform(_glide.value);
        setState(() {
          _shown = LatLng(
            _from.latitude + (_to.latitude - _from.latitude) * t,
            _from.longitude + (_to.longitude - _from.longitude) * t,
          );
        });
      });
    unawaited(_buildIcons());
  }

  @override
  void didUpdateWidget(covariant RiderMapView old) {
    super.didUpdateWidget(old);
    if (old.lat != widget.lat || old.lng != widget.lng) {
      _from = _shown;
      _to = LatLng(widget.lat, widget.lng);
      _glide.forward(from: 0);
    }
    final key = '${widget.target?.lat},${widget.target?.lng},${widget.bottomPadding.round()}';
    if (key != _framedKey) {
      _framedKey = key;
      _scheduleFrame();
    } else if (widget.target == null && (old.lat != widget.lat || old.lng != widget.lng)) {
      _scheduleFrame();
    }
  }

  @override
  void dispose() {
    _frameDebounce?.cancel();
    _glide.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _buildIcons() async {
    final ratio = MediaQuery.devicePixelRatioOf(context);
    final rider = await _paint(size: 56, ratio: ratio, draw: _drawRider);
    final pickup = await _paint(size: 40, ratio: ratio, draw: (c, s) => _drawPin(c, s, RiderColors.primary));
    final dropoff = await _paint(size: 40, ratio: ratio, draw: (c, s) => _drawPin(c, s, RiderColors.primaryBlack));
    if (!mounted) return;
    setState(() {
      _riderIcon = rider;
      _pickupIcon = pickup;
      _dropoffIcon = dropoff;
    });
  }

  void _scheduleFrame() {
    _frameDebounce?.cancel();
    _frameDebounce = Timer(const Duration(milliseconds: 250), _frame);
  }

  Future<void> _frame() async {
    final controller = _controller;
    if (controller == null || !mounted) return;
    final me = LatLng(widget.lat, widget.lng);
    final target = widget.target;
    if (target == null) {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: me, zoom: 15.5)),
      );
      return;
    }
    final points = [me, LatLng(target.lat, target.lng)];
    var minLat = points.first.latitude, maxLat = points.first.latitude;
    var minLng = points.first.longitude, maxLng = points.first.longitude;
    for (final p in points) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }
    // Pad the south edge so the bottom sheet does not cover the route.
    final latSpan = math.max(maxLat - minLat, 0.004);
    final screen = MediaQuery.sizeOf(context).height;
    final sheetFraction = (widget.bottomPadding / screen).clamp(0.0, 0.6);
    final southPad = latSpan * (sheetFraction / (1 - sheetFraction)) + latSpan * 0.15;
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - southPad, minLng - 0.002),
          northeast: LatLng(maxLat + latSpan * 0.15, maxLng + 0.002),
        ),
        48,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final me = _shown;
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('me'),
        position: me,
        icon: _riderIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        anchor: const Offset(0.5, 0.5),
        rotation: (widget.heading ?? 0).toDouble(),
        flat: true,
        zIndexInt: 3,
      ),
      if (widget.pickup case final p?)
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(p.lat, p.lng),
          icon: _pickupIcon ?? BitmapDescriptor.defaultMarker,
          anchor: const Offset(0.5, 0.5),
          infoWindow: InfoWindow(title: 'Pickup', snippet: p.label),
        ),
      if (widget.dropoff case final d?)
        Marker(
          markerId: const MarkerId('dropoff'),
          position: LatLng(d.lat, d.lng),
          icon: _dropoffIcon ?? BitmapDescriptor.defaultMarker,
          anchor: const Offset(0.5, 0.5),
          infoWindow: InfoWindow(title: 'Drop-off', snippet: d.label),
        ),
    };

    final polylines = <Polyline>{
      if (widget.target case final t?)
        Polyline(
          polylineId: const PolylineId('leg'),
          points: [me, LatLng(t.lat, t.lng)],
          color: RiderColors.routeLine,
          width: 5,
          geodesic: true,
          patterns: [PatternItem.dash(28), PatternItem.gap(14)],
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      if (widget.pickup case final p?)
        if (widget.dropoff case final d?)
          Polyline(
            polylineId: const PolylineId('job'),
            points: [LatLng(p.lat, p.lng), LatLng(d.lat, d.lng)],
            color: RiderColors.primaryBlack.withValues(alpha: 0.25),
            width: 3,
            geodesic: true,
          ),
    };

    return Stack(
      fit: StackFit.expand,
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(widget.lat, widget.lng), zoom: 15.5),
          onMapCreated: (controller) {
            _controller = controller;
            _scheduleFrame();
          },
          markers: markers,
          polylines: polylines,
          padding: EdgeInsets.only(bottom: widget.bottomPadding),
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          buildingsEnabled: false,
          trafficEnabled: widget.target != null,
        ),
        if (widget.statusChip case final chip?)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 72,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0, -0.4), end: Offset.zero).animate(animation),
                    child: child,
                  ),
                ),
                child: Container(
                  key: ValueKey(chip),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: RiderColors.primaryBlack,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    chip,
                    style: const TextStyle(
                      color: RiderColors.primaryWhite,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Marker rendering (Dart-drawn, so no image assets are needed).
// ---------------------------------------------------------------------------

Future<BitmapDescriptor> _paint({
  required double size,
  required double ratio,
  required void Function(Canvas canvas, double size) draw,
}) async {
  final px = size * ratio;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.scale(ratio);
  draw(canvas, size);
  final image = await recorder.endRecording().toImage(px.ceil(), px.ceil());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.bytes(
    bytes!.buffer.asUint8List(),
    imagePixelRatio: ratio,
    width: size,
    height: size,
  );
}

void _drawRider(Canvas canvas, double size) {
  final c = Offset(size / 2, size / 2);
  canvas.drawCircle(c, size * 0.36, Paint()..color = RiderColors.primary.withValues(alpha: 0.18));
  canvas.drawCircle(c, size * 0.26, Paint()..color = RiderColors.primary);
  canvas.drawCircle(
    c,
    size * 0.26,
    Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.05,
  );
  final wedge = Path()
    ..moveTo(c.dx, c.dy - size * 0.42)
    ..lineTo(c.dx + size * 0.12, c.dy - size * 0.2)
    ..lineTo(c.dx - size * 0.12, c.dy - size * 0.2)
    ..close();
  canvas.drawPath(wedge, Paint()..color = RiderColors.primary);
}

void _drawPin(Canvas canvas, double size, Color color) {
  final c = Offset(size / 2, size / 2);
  canvas.drawCircle(c, size * 0.3, Paint()..color = color);
  canvas.drawCircle(
    c,
    size * 0.3,
    Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.07,
  );
  canvas.drawCircle(c, size * 0.1, Paint()..color = Colors.white);
}
