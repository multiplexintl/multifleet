import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:multifleet/models/maintenance.dart';
import 'package:multifleet/models/maintenance_master.dart';

import 'retry_helper.dart';

/// MaintenanceRepository handles all maintenance-related API calls
class MaintenanceRepo {
  // singleton
  static final MaintenanceRepo _instance = MaintenanceRepo._internal();
  factory MaintenanceRepo() => _instance;
  MaintenanceRepo._internal();

  final String _url = GlobalConfiguration().getValue('api_base_url');

  // ============================================================
  // MAINTENANCE TYPES MASTER
  // ============================================================

  /// Fetch all maintenance type masters
  /// GET Master/GetMaintenanceMaster?query=
  Future<Either<String, List<MaintenanceMaster>>>
      getAllMaintenanceTypes() async {
    return await RetryHelper.retry<Either<String, List<MaintenanceMaster>>>(
      apiCall: () async {
        final Uri url = Uri.parse('${_url}Master/GetMaintenanceMaster?query=');
        final client = http.Client();
        log(url.toString());
        final response = await client.get(url);
        log("Response Code: ${response.statusCode}");

        if (response.statusCode == 200) {
          List<dynamic> responseBody = jsonDecode(response.body);
          var data = responseBody
              .map((element) => MaintenanceMaster.fromJson(element))
              .toList();
          return Right(data);
        } else {
          return Left(response.body);
        }
      },
      defaultValue: const Left("Retry failed"),
      maxRetries: 3,
      shouldRetry: (result) =>
          result.fold((l) => l == "Retry failed", (_) => false),
    );
  }

  // ============================================================
  // MAINTENANCE RECORDS
  // ============================================================

  /// Fetch maintenance records for a company (with optional filters)
  /// GET Master/GetVehicleMaintenance?Company=EPIC01&vehicleNo=&fromDt=&toDt=&status=
  /// company is mandatory, all other params are optional
  Future<Either<String, List<MaintenanceRecord>>> getVehicleMaintenance({
    required String company,
    String? vehicleNo,
    String? fromDt,
    String? toDt,
    String? status,
  }) async {
    return await RetryHelper.retry<Either<String, List<MaintenanceRecord>>>(
      apiCall: () async {
        final params = {
          'Company': company,
          if (vehicleNo != null && vehicleNo.isNotEmpty) 'vehicleNo': vehicleNo,
          if (fromDt != null && fromDt.isNotEmpty) 'fromDt': fromDt,
          if (toDt != null && toDt.isNotEmpty) 'toDt': toDt,
          if (status != null && status.isNotEmpty) 'status': status,
        };

        final uri = Uri.parse('${_url}Master/GetVehicleMaintenance')
            .replace(queryParameters: params);
        final client = http.Client();
        log(uri.toString());
        final response = await client.get(uri);
        log("Response Code: ${response.statusCode}");

        if (response.statusCode == 200) {
          List<dynamic> responseBody = jsonDecode(response.body);
          var data = responseBody
              .map((element) => MaintenanceRecord.fromJson(element))
              .toList();
          return Right(data);
        } else {
          return Left(response.body);
        }
      },
      defaultValue: const Left("Retry failed"),
      maxRetries: 3,
      shouldRetry: (result) =>
          result.fold((l) => l == "Retry failed", (_) => false),
    );
  }

  /// Save maintenance record (add or update)
  /// POST Vehicle/VehicleMaintenance
  /// SlNo = 0 for new, existing SlNo for update
  Future<Either<String, MaintenanceRecord>> saveMaintenanceRecord(
      MaintenanceRecord record) async {
    return await RetryHelper.retry<Either<String, MaintenanceRecord>>(
      apiCall: () async {
        final Uri url = Uri.parse('${_url}Vehicle/VehicleMaintenance');
        final client = http.Client();
        final body = jsonEncode(record.toJson());
        log('POST ${url.toString()} body: $body');

        final response = await client.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );
        log("Response Code: ${response.statusCode}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          // API may return the saved record or just a success status
          try {
            final responseBody = jsonDecode(response.body);
            if (responseBody is Map<String, dynamic>) {
              return Right(MaintenanceRecord.fromJson(responseBody));
            }
            // If no full record returned, return our record with SlNo from response if available
            return Right(record);
          } catch (_) {
            return Right(record);
          }
        } else {
          return Left(response.body);
        }
      },
      defaultValue: const Left("Retry failed"),
      maxRetries: 3,
      shouldRetry: (result) =>
          result.fold((l) => l == "Retry failed", (_) => false),
    );
  }
}
