enum JobType { parcel, document, errand }

extension JobTypeLabel on JobType {
  String get label => switch (this) {
        JobType.parcel => 'Parcel',
        JobType.document => 'Document',
        JobType.errand => 'Errand',
      };
}

class GeoPoint {
  const GeoPoint({required this.lat, required this.lng, required this.label});

  final double lat;
  final double lng;
  final String label;
}

class DeliveryJob {
  const DeliveryJob({
    required this.id,
    required this.type,
    required this.fareGhs,
    required this.distanceKm,
    required this.pickup,
    required this.dropoff,
    required this.customerName,
    required this.customerPhone,
    required this.itemInstructions,
    required this.etaMinutes,
  });

  final String id;
  final JobType type;
  final double fareGhs;
  final double distanceKm;
  final GeoPoint pickup;
  final GeoPoint dropoff;
  final String customerName;
  final String customerPhone;
  final String itemInstructions;
  final int etaMinutes;

  double platformCut(double rate) => fareGhs * rate;

  double riderNet(double rate) => fareGhs - platformCut(rate);
}

enum DeliveryPhase {
  navigatingToPickup,
  atPickup,
  navigatingToDropoff,
  proofOfDelivery,
  completed,
}

extension DeliveryPhaseLabel on DeliveryPhase {
  String get title => switch (this) {
        DeliveryPhase.navigatingToPickup => 'Navigating to Pickup',
        DeliveryPhase.atPickup => 'At Pickup',
        DeliveryPhase.navigatingToDropoff => 'Navigating to Drop-off',
        DeliveryPhase.proofOfDelivery => 'Proof of Delivery',
        DeliveryPhase.completed => 'Completed',
      };

  String get swipeLabel => switch (this) {
        DeliveryPhase.navigatingToPickup => 'Swipe to Arrive',
        DeliveryPhase.atPickup => 'Swipe to Confirm Pickup',
        DeliveryPhase.navigatingToDropoff => 'Swipe to Arrive',
        DeliveryPhase.proofOfDelivery => 'Take Photo & Complete',
        DeliveryPhase.completed => 'Done',
      };

  int get stepIndex => switch (this) {
        DeliveryPhase.navigatingToPickup => 0,
        DeliveryPhase.atPickup => 1,
        DeliveryPhase.navigatingToDropoff => 2,
        DeliveryPhase.proofOfDelivery => 3,
        DeliveryPhase.completed => 4,
      };
}

enum RiderOnlineStatus { offline, online, busy }
