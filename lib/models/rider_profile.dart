class RiderProfile {
  const RiderProfile({
    required this.id,
    required this.name,
    required this.vehiclePlate,
    required this.rating,
    required this.completedTrips,
  });

  final String id;
  final String name;
  final String vehiclePlate;
  final double rating;
  final int completedTrips;
}
