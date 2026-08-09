import '../models/delivery_job.dart';
import 'mock_locations.dart';

abstract final class MockJobs {
  static final List<DeliveryJob> queue = [
    DeliveryJob(
      id: 'job_kumasi_001',
      type: JobType.parcel,
      fareGhs: 24.50,
      distanceKm: 3.2,
      pickup: MockLocations.adum,
      dropoff: MockLocations.knust,
      customerName: 'Ama Serwaa',
      customerPhone: '+233 24 555 0192',
      itemInstructions: 'Small carton — hand to security at Main Gate.',
      etaMinutes: 12,
    ),
    DeliveryJob(
      id: 'job_kumasi_002',
      type: JobType.document,
      fareGhs: 18.00,
      distanceKm: 2.4,
      pickup: MockLocations.asokwa,
      dropoff: MockLocations.airport,
      customerName: 'Kwame Boateng',
      customerPhone: '+233 20 441 8821',
      itemInstructions: 'Sealed envelope — ID check required on delivery.',
      etaMinutes: 9,
    ),
    DeliveryJob(
      id: 'job_kumasi_003',
      type: JobType.errand,
      fareGhs: 32.75,
      distanceKm: 4.8,
      pickup: MockLocations.techJunction,
      dropoff: MockLocations.bangalore,
      customerName: 'Efua Mensah',
      customerPhone: '+233 27 900 3344',
      itemInstructions: 'Pharmacy pickup — keep upright, collect receipt.',
      etaMinutes: 16,
    ),
  ];

  static int _index = 0;

  static DeliveryJob next() {
    final job = queue[_index % queue.length];
    _index++;
    return job;
  }

  static void reset() => _index = 0;
}
