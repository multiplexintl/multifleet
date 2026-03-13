import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:multifleet/models/fine.dart';
import 'package:multifleet/models/maintenance.dart';
import 'package:multifleet/models/vehicle.dart';
import 'package:multifleet/models/vehicle_assignment_model.dart';
import 'package:multifleet/models/vehicle_docs.dart';

import 'retry_helper.dart';

/// DashboardRepo — real API calls only.
/// Stats/KPIs are computed in DashboardController from these raw lists.
class DashboardRepo {
  final String _url = GlobalConfiguration().getValue('api_base_url');

  // ============================================================
  // VEHICLES
  // ============================================================

  /// GET Master/GetVehicleMaster?Company=&query=
  Future<Either<String, List<Vehicle>>> getVehicles(
      {required String company}) async {
    return await RetryHelper.retry<Either<String, List<Vehicle>>>(
      apiCall: () async {
        final uri = Uri.parse(
            '${_url}Master/GetVehicleMaster?Company=$company&query=');
        log('[DashboardRepo] GET $uri');
        final response = await http.Client().get(uri);
        log('[DashboardRepo] Vehicles ${response.statusCode}');
        if (response.statusCode == 200) {
          final list = jsonDecode(response.body) as List<dynamic>;
          return Right(list.map((e) => Vehicle.fromJson(e)).toList());
        }
        return Left(response.body);
      },
      defaultValue: const Left('Retry failed'),
      maxRetries: 3,
      shouldRetry: (r) => r.fold((l) => l == 'Retry failed', (_) => false),
    );
  }

  // ============================================================
  // VEHICLE DOCUMENTS (expiry)
  // ============================================================

  /// GET Master/GetVehicleDocs?Company=&VehicleNo=
  /// Passing empty VehicleNo fetches all docs for the company.
  Future<Either<String, List<VehicleDocument>>> getAllDocuments(
      {required String company}) async {
    return await RetryHelper.retry<Either<String, List<VehicleDocument>>>(
      apiCall: () async {
        final uri = Uri.parse(
            '${_url}Master/GetVehicleDocs?Company=$company&VehicleNo=');
        log('[DashboardRepo] GET $uri');
        final response = await http.Client().get(uri);
        log('[DashboardRepo] Docs ${response.statusCode}');
        if (response.statusCode == 200) {
          final list = jsonDecode(response.body) as List<dynamic>;
          return Right(list.map((e) => VehicleDocument.fromJson(e)).toList());
        }
        return Left(response.body);
      },
      defaultValue: const Left('Retry failed'),
      maxRetries: 3,
      shouldRetry: (r) => r.fold((l) => l == 'Retry failed', (_) => false),
    );
  }

  // ============================================================
  // FINES
  // ============================================================

  /// GET Master/GetFines?Company=&VehicleNo=
  Future<Either<String, List<Fine>>> getFines(
      {required String company}) async {
    return await RetryHelper.retry<Either<String, List<Fine>>>(
      apiCall: () async {
        final uri =
            Uri.parse('${_url}Master/GetFines?Company=$company&VehicleNo=');
        log('[DashboardRepo] GET $uri');
        final response = await http.Client().get(uri);
        log('[DashboardRepo] Fines ${response.statusCode}');
        if (response.statusCode == 200) {
          final list = jsonDecode(response.body) as List<dynamic>;
          return Right(list.map((e) => Fine.fromJson(e)).toList());
        }
        return Left(response.body);
      },
      defaultValue: const Left('Retry failed'),
      maxRetries: 3,
      shouldRetry: (r) => r.fold((l) => l == 'Retry failed', (_) => false),
    );
  }

  // ============================================================
  // ASSIGNMENTS
  // ============================================================

  /// GET Master/GetVehicleAssignment?Company=&query=&isActive=false
  Future<Either<String, List<VehicleAssignment>>> getAssignments(
      {required String company}) async {
    return await RetryHelper.retry<Either<String, List<VehicleAssignment>>>(
      apiCall: () async {
        final uri = Uri.parse(
            '${_url}Master/GetVehicleAssignment?Company=$company&query=&isActive=false');
        log('[DashboardRepo] GET $uri');
        final response = await http.Client().get(uri);
        log('[DashboardRepo] Assignments ${response.statusCode}');
        if (response.statusCode == 200) {
          final list = jsonDecode(response.body) as List<dynamic>;
          return Right(
              list.map((e) => VehicleAssignment.fromJson(e)).toList());
        }
        return Left(response.body);
      },
      defaultValue: const Left('Retry failed'),
      maxRetries: 3,
      shouldRetry: (r) => r.fold((l) => l == 'Retry failed', (_) => false),
    );
  }

  // ============================================================
  // MAINTENANCE
  // ============================================================

  /// GET Master/GetVehicleMaintenance?Company=
  Future<Either<String, List<MaintenanceRecord>>> getMaintenance(
      {required String company}) async {
    return await RetryHelper.retry<Either<String, List<MaintenanceRecord>>>(
      apiCall: () async {
        final uri = Uri.parse(
            '${_url}Master/GetVehicleMaintenance?Company=$company');
        log('[DashboardRepo] GET $uri');
        final response = await http.Client().get(uri);
        log('[DashboardRepo] Maintenance ${response.statusCode}');
        if (response.statusCode == 200) {
          final list = jsonDecode(response.body) as List<dynamic>;
          return Right(
              list.map((e) => MaintenanceRecord.fromJson(e)).toList());
        }
        return Left(response.body);
      },
      defaultValue: const Left('Retry failed'),
      maxRetries: 3,
      shouldRetry: (r) => r.fold((l) => l == 'Retry failed', (_) => false),
    );
  }
}
