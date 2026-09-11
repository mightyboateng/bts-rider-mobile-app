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
    this.paymentMethod,
    this.paymentStatus = 'unpaid',
    this.paymentSettled = false,
    this.cashDuePesewas = 0,
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

  /// `cash`, `momo`, or null while the customer has not chosen yet
  /// (payment is chosen when the rider arrives at drop-off).
  final String? paymentMethod;
  final String paymentStatus;

  /// True once the job can be closed: cash chosen, or MoMo confirmed.
  final bool paymentSettled;
  final int cashDuePesewas;

  bool get awaitingPaymentChoice => paymentMethod == null;
  bool get awaitingMomoConfirmation => paymentMethod == 'momo' && !paymentSettled;
  bool get isCash => paymentMethod == 'cash';

  double platformCut(double rate) => fareGhs * rate;

  double riderNet(double rate) => fareGhs - platformCut(rate);

  DeliveryJob copyWith({
    String? paymentMethod,
    String? paymentStatus,
    bool? paymentSettled,
    int? cashDuePesewas,
    bool clearPaymentMethod = false,
  }) {
    return DeliveryJob(
      id: id,
      type: type,
      fareGhs: fareGhs,
      distanceKm: distanceKm,
      pickup: pickup,
      dropoff: dropoff,
      customerName: customerName,
      customerPhone: customerPhone,
      itemInstructions: itemInstructions,
      etaMinutes: etaMinutes,
      paymentMethod: clearPaymentMethod ? null : (paymentMethod ?? this.paymentMethod),
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentSettled: paymentSettled ?? this.paymentSettled,
      cashDuePesewas: cashDuePesewas ?? this.cashDuePesewas,
    );
  }
}

enum DeliveryPhase {
  navigatingToPickup,
  atPickup,
  navigatingToDropoff,

  /// Rider is at the drop-off; the customer is choosing MoMo or cash
  /// (or a MoMo charge is still being confirmed).
  awaitingPayment,
  proofOfDelivery,
  completed,
}

extension DeliveryPhaseLabel on DeliveryPhase {
  String get title => switch (this) {
        DeliveryPhase.navigatingToPickup => 'Navigating to Pickup',
        DeliveryPhase.atPickup => 'At Pickup',
        DeliveryPhase.navigatingToDropoff => 'Navigating to Drop-off',
        DeliveryPhase.awaitingPayment => 'Waiting for Payment',
        DeliveryPhase.proofOfDelivery => 'Proof of Delivery',
        DeliveryPhase.completed => 'Completed',
      };

  String get swipeLabel => switch (this) {
        DeliveryPhase.navigatingToPickup => 'Swipe to Arrive',
        DeliveryPhase.atPickup => 'Swipe to Confirm Pickup',
        DeliveryPhase.navigatingToDropoff => 'Swipe to Arrive',
        DeliveryPhase.awaitingPayment => 'Waiting for customer',
        DeliveryPhase.proofOfDelivery => 'Take Photo & Complete',
        DeliveryPhase.completed => 'Done',
      };

  int get stepIndex => switch (this) {
        DeliveryPhase.navigatingToPickup => 0,
        DeliveryPhase.atPickup => 1,
        DeliveryPhase.navigatingToDropoff => 2,
        DeliveryPhase.awaitingPayment => 3,
        DeliveryPhase.proofOfDelivery => 3,
        DeliveryPhase.completed => 4,
      };
}

enum RiderOnlineStatus { offline, online, busy }
