import 'package:bts_core/bts_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/rider_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/providers/session_provider.dart';
import '../../../widgets/rider_notice.dart';

class RideHistoryScreen extends ConsumerStatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  ConsumerState<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends ConsumerState<RideHistoryScreen> {
  late Future<List<RiderTrip>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<RiderTrip>> _load() {
    return ref.read(sessionProvider.notifier).core.rider.listHistory();
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() => _future = next);
    try {
      await next;
    } on ApiException catch (error) {
      if (!mounted) return;
      showRiderNotice(context, message: error.message, tone: RiderNoticeTone.error);
    } catch (_) {
      if (!mounted) return;
      showRiderNotice(context, message: 'Could not load your rides.', tone: RiderNoticeTone.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Ride history')),
      body: FutureBuilder<List<RiderTrip>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              itemCount: 6,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, _) => Container(
                height: 76,
                decoration: BoxDecoration(
                  color: RiderColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
              ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1200.ms),
            );
          }
          if (snapshot.hasError) {
            final message = snapshot.error is ApiException
                ? (snapshot.error! as ApiException).message
                : 'Could not load your rides.';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _refresh, child: const Text('Try again')),
                  ],
                ),
              ),
            );
          }
          final trips = snapshot.data ?? const <RiderTrip>[];
          if (trips.isEmpty) {
            return Center(
              child: Text(
                'No rides yet. They show up here after you take a job.',
                style: theme.textTheme.bodyLarge?.copyWith(color: RiderColors.mutedText),
                textAlign: TextAlign.center,
              ),
            );
          }
          return RefreshIndicator(
            color: RiderColors.primary,
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              itemCount: trips.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: RiderColors.border),
              itemBuilder: (context, index) {
                final trip = trips[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip.dropoffAddress.isEmpty ? trip.reference : trip.dropoffAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              trip.pickupAddress.isEmpty ? trip.reference : 'From ${trip.pickupAddress}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(color: RiderColors.mutedText),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_label(trip.status)} · ${_when(trip.createdAt)}',
                              style: theme.textTheme.bodySmall?.copyWith(color: RiderColors.primary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        CurrencyFormatter.ghs(trip.earningsPesewas / 100),
                        style: theme.textTheme.titleMedium?.copyWith(color: RiderColors.primary),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _label(String status) {
    return switch (status) {
      'delivered' => 'Delivered',
      'cancelled' => 'Cancelled',
      'navigating_pickup' => 'To pickup',
      'arrived_pickup' => 'At pickup',
      'navigating_dropoff' => 'To drop-off',
      'arrived_dropoff' => 'At drop-off',
      'assigned' => 'Accepted',
      _ => status,
    };
  }

  String _when(DateTime at) {
    final local = at.toLocal();
    final now = DateTime.now();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    final sameDay = local.year == now.year && local.month == now.month && local.day == now.day;
    if (sameDay) return 'Today $hh:$mm';
    return '${local.day}/${local.month} $hh:$mm';
  }
}
