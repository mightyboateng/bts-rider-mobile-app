import '../models/rider_profile.dart';

abstract final class MockRider {
  static const profile = RiderProfile(
    id: 'rider_bts_042',
    name: 'Kofi Asante',
    vehiclePlate: 'GR 4821-23',
    rating: 4.92,
    completedTrips: 1284,
  );
}
