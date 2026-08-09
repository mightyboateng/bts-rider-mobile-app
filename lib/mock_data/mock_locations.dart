import '../models/delivery_job.dart';

/// Realistic Kumasi landmarks for mock routing.
abstract final class MockLocations {
  static const riderHome = GeoPoint(
    lat: 6.6885,
    lng: -1.6244,
    label: 'Adum Junction, Kumasi',
  );

  static const adum = GeoPoint(
    lat: 6.6900,
    lng: -1.6250,
    label: 'Kejetia Market Gate, Adum',
  );

  static const knust = GeoPoint(
    lat: 6.6745,
    lng: -1.5716,
    label: 'KNUST Campus, Main Gate',
  );

  static const asokwa = GeoPoint(
    lat: 6.6660,
    lng: -1.5980,
    label: 'Asokwa Roundabout',
  );

  static const airport = GeoPoint(
    lat: 6.7146,
    lng: -1.5906,
    label: 'Kumasi Airport Terminal',
  );

  static const techJunction = GeoPoint(
    lat: 6.6788,
    lng: -1.5702,
    label: 'Tech Junction, Ayeduase',
  );

  static const bangalore = GeoPoint(
    lat: 6.6702,
    lng: -1.6165,
    label: 'Bangalore, Santasi',
  );
}
