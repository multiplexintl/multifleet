import 'dart:math';

import '../models/tire.dart';
import '../models/vehicle.dart';

class FakeVehicleData {
  List<Vehicle> generateFakeVehicles({int count = 10}) {
    return List.generate(count, (index) {
      final random = Random();
      final randomDays = random.nextInt(71) + 20;
      return Vehicle(
        company: 'EPIC${(index % 3) + 1}',
        vehicleNo: 'DUB-${1000 + index}',
        brand: index % 2 == 0 ? 'Toyota' : 'Nissan',
        type: index % 2 == 0 ? 'SUV' : 'Truck',
        model: 'Model-${String.fromCharCode(65 + index % 26)}',
        vYear: (2015 + index % 10),
        initialOdo: 10000 + (index * 500),
        imagePath1: 'assets/images/vehicle1.jpg',
        imagePath2: 'assets/images/vehicle2.jpg',
        chassisNo: 'CHS1234$index',
        traficFileNo: 'TFN5678$index',
        // insuranceType: 'Full Coverage',
        // insuranceExpiry: DateTime.now()
        //     .add(Duration(days: randomDays + 30))
        //     .toIso8601String(),
        // mulkiyaExpiry:
        //     DateTime.now().add(Duration(days: randomDays)).toIso8601String(),
        // city: 'Dubai',
        // currentOdo: (10000 + index * 700).toString(),
        // fuelStation: index % 2 == 0 ? 'ENOC' : 'ADNOC',
        // condition: 'Good',
        // status: index % 3 == 0 ? 'Active' : 'Inactive',
        // tires: List.generate(4, (tireIndex) {
        //   return Tire(
        //     brand: 'Michelin',
        //     model: 'MX-${tireIndex + 1}',
        //     km: '${5000 + tireIndex * 1000}',
        //   );
        // }),
      );
    });
  }

  Vehicle? findVehicleByPlateNumber(String plateNumber) {
    try {
      return generateFakeVehicles().firstWhere((vehicle) =>
          vehicle.vehicleNo?.toLowerCase() == plateNumber.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  static bool isVehicleAssigned(String plateNumber) {
    // In a real app, this would check a database for assignments
    // For demo purposes, let's say ABC123 is already assigned
    return plateNumber.toLowerCase() == '11908-AA';
  }

  static PaginatedResult<Map<String, dynamic>> getVehicleAssignments(
      String plateNumber, int page, int pageSize) {
    // Generate fake assignment data
    final List<Map<String, dynamic>> allAssignments =
        List.generate(50, (index) {
      return {
        'id': index + 1,
        'employeeName': 'Employee ${index + 1}',
        'designation': index % 3 == 0 ? 'Driver' : 'Technician',
        'startDate': DateTime.now().subtract(Duration(days: (index + 1) * 10)),
        'endDate': DateTime.now().subtract(Duration(days: (index + 1) * 5)),
        'status': (index % 4 == 0)
            ? 'Active'
            : (index % 3 == 0)
                ? 'Resigned'
                : 'Terminated',
        'fines': List.generate(
          (index % 3 == 0)
              ? 3
              : (index % 2 == 0)
                  ? 2
                  : 1,
          (fineIndex) => {
            'fineDate': DateTime.now()
                .subtract(Duration(days: (index + fineIndex) * 4)),
            'fineAmount': (fineIndex + 1) * 100.0,
            'fineNumber': 'F-${(index + 1) * 1000 + fineIndex}',
            'fineLocation':
                (fineIndex % 2 == 0) ? 'Downtown' : 'Industrial Area',
            'paid': fineIndex % 2 == 0,
          },
        ),
      };
    });

    // Calculate pagination
    final int startIndex = (page - 1) * pageSize;
    final int endIndex = startIndex + pageSize > allAssignments.length
        ? allAssignments.length
        : startIndex + pageSize;

    // Return only the items for the requested page
    final List<Map<String, dynamic>> pageItems =
        startIndex < allAssignments.length
            ? allAssignments.sublist(startIndex, endIndex)
            : [];

    // Return paginated result
    return PaginatedResult<Map<String, dynamic>>(
        items: pageItems,
        total: allAssignments.length,
        currentPage: page,
        pageSize: pageSize);
  }
}

// Simple class to handle paginated results
class PaginatedResult<T> {
  final List<T> items;
  final int total;
  final int currentPage;
  final int pageSize;

  PaginatedResult({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.pageSize,
  });

  bool get hasMore => currentPage * pageSize < total;
  int get totalPages => (total / pageSize).ceil();
}
