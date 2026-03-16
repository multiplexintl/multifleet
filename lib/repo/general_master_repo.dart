import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:multifleet/models/api_response.dart';
import 'package:multifleet/models/fine_type/fine_type.dart';
import 'package:multifleet/models/status_master/status_master.dart';

import 'retry_helper.dart';

class GeneralMasterRepo {
  final String _url = GlobalConfiguration().getValue('api_base_url');

// get vehicle master status
  Future<Either<String, List<StatusMaster>>> getVehicleStatusMaster(
      {String? query}) async {
    return await RetryHelper.retry<Either<String, List<StatusMaster>>>(
      apiCall: () async {
        final Uri url =
            Uri.parse('${_url}Master/GetVehicleStatusMasters?query');
        final client = http.Client();
        log(url.toString());
        final response = await client.get(url);
        log("Response Code: ${response.statusCode}");

        if (response.statusCode == 200) {
          List<dynamic> responseBody = jsonDecode(response.body);
          var result = responseBody
              .map((element) => StatusMaster.fromJson(element))
              .toList();
          return Right(result);
        } else {
          return Left(response.body);
        }
      },
      defaultValue: const Left("Retry failed"),
      maxRetries: 3,
      shouldRetry: (result) =>
          // result.isLeft() &&
          result.fold((l) => l == "Retry failed", (_) => false),
    );
  }

  // get fine statuse
  Future<Either<String, List<StatusMaster>>> getFineStatusMaster(
      {String? query}) async {
    return await RetryHelper.retry<Either<String, List<StatusMaster>>>(
      apiCall: () async {
        final Uri url = Uri.parse('${_url}Master/GetFineStatusMaster?query');
        final client = http.Client();
        log(url.toString());
        final response = await client.get(url);
        log("Response Code: ${response.statusCode}");

        if (response.statusCode == 200) {
          List<dynamic> responseBody = jsonDecode(response.body);
          var result = responseBody
              .map((element) => StatusMaster.fromJson(element))
              .toList();
          return Right(result);
        } else {
          return Left(response.body);
        }
      },
      defaultValue: const Left("Retry failed"),
      maxRetries: 3,
      shouldRetry: (result) =>
          // result.isLeft() &&
          result.fold((l) => l == "Retry failed", (_) => false),
    );
  }

  // get fine type master
  Future<Either<String, List<FineType>>> getFineTypeMaster(
      {required String company}) async {
    return await RetryHelper.retry<Either<String, List<FineType>>>(
      apiCall: () async {
        final Uri url = Uri.parse(
            '${_url}Master/GetFineTypeMasters?Company=$company&query=');
        final client = http.Client();
        log(url.toString());
        final response = await client.get(url);
        log("Response Code: ${response.statusCode}");

        if (response.statusCode == 200) {
          List<dynamic> responseBody = jsonDecode(response.body);
          var result = responseBody
              .map((element) => FineType.fromJson(element))
              .toList();
          return Right(result);
        } else {
          return Left(response.body);
        }
      },
      defaultValue: const Left("Retry failed"),
      maxRetries: 3,
      shouldRetry: (result) =>
          // result.isLeft() &&
          result.fold((l) => l == "Retry failed", (_) => false),
    );
  }

  // get vehicle assignment status
  Future<Either<String, List<StatusMaster>>> getVehicleAssignmentStatusMaster(
      {String? query}) async {
    return await RetryHelper.retry<Either<String, List<StatusMaster>>>(
      apiCall: () async {
        final Uri url =
            Uri.parse('${_url}Master/GetVehicleAssignmentStatusMaster?query');
        final client = http.Client();
        log(url.toString());
        final response = await client.get(url);
        log("Response Code: ${response.statusCode}");

        if (response.statusCode == 200) {
          List<dynamic> responseBody = jsonDecode(response.body);
          var result = responseBody
              .map((element) => StatusMaster.fromJson(element))
              .toList();
          return Right(result);
        } else {
          return Left(response.body);
        }
      },
      defaultValue: const Left("Retry failed"),
      maxRetries: 3,
      shouldRetry: (result) =>
          // result.isLeft() &&
          result.fold((l) => l == "Retry failed", (_) => false),
    );
  }

  // get vehicle type master
  Future<Either<String, List<StatusMaster>>> getVehicleTypeStatusMaster(
      {String? query}) async {
    return await RetryHelper.retry<Either<String, List<StatusMaster>>>(
      apiCall: () async {
        final Uri url = Uri.parse('${_url}Master/GetVehicleTypeMasters?query');
        final client = http.Client();
        log(url.toString());
        final response = await client.get(url);
        log("Response Code: ${response.statusCode}");

        if (response.statusCode == 200) {
          List<dynamic> responseBody = jsonDecode(response.body);
          var result = responseBody
              .map((element) => StatusMaster.fromJsonVehicleType(element))
              .toList();
          return Right(result);
        } else {
          return Left(response.body);
        }
      },
      defaultValue: const Left("Retry failed"),
      maxRetries: 3,
      shouldRetry: (result) =>
          // result.isLeft() &&
          result.fold((l) => l == "Retry failed", (_) => false),
    );
  }

  // get vehicle condition master
  Future<Either<String, List<StatusMaster>>> getVehicleConditionStatusMaster(
      {String? query}) async {
    return await RetryHelper.retry<Either<String, List<StatusMaster>>>(
      apiCall: () async {
        final Uri url =
            Uri.parse('${_url}Master/GetVehicleConditionMaster?query');
        final client = http.Client();
        log(url.toString());
        final response = await client.get(url);
        log("Response Code: ${response.statusCode}");

        if (response.statusCode == 200) {
          List<dynamic> responseBody = jsonDecode(response.body);
          var result = responseBody
              .map((element) => StatusMaster.fromJsonVehicleCondition(element))
              .toList();
          return Right(result);
        } else {
          return Left(response.body);
        }
      },
      defaultValue: const Left("Retry failed"),
      maxRetries: 3,
      shouldRetry: (result) =>
          // result.isLeft() &&
          result.fold((l) => l == "Retry failed", (_) => false),
    );
  }

  // fetch tire positon master
  Future<Either<String, List<StatusMaster>>> getVehicleTirePositionMaster(
      {String? query}) async {
    return await RetryHelper.retry<Either<String, List<StatusMaster>>>(
      apiCall: () async {
        final Uri url = Uri.parse('${_url}Master/GetTyrePositionMaster?query=');
        final client = http.Client();
        log(url.toString());
        final response = await client.get(url);
        log("Response Code: ${response.statusCode}");

        if (response.statusCode == 200) {
          List<dynamic> responseBody = jsonDecode(response.body);
          var result = responseBody
              .map((element) =>
                  StatusMaster.fromJsonVehicleTirePosition(element))
              .toList();
          return Right(result);
        } else {
          return Left(response.body);
        }
      },
      defaultValue: const Left("Retry failed"),
      maxRetries: 3,
      shouldRetry: (result) =>
          // result.isLeft() &&
          result.fold((l) => l == "Retry failed", (_) => false),
    );
  }

  // ==================== CREATE / UPDATE METHODS ====================
  // All endpoints return [{Status, Message, Id}] — parsed as ApiResponse.
  // Pass id=0 for new records, existing id for updates.

  Future<Either<String, ApiResponse>> createVehicleType(
          String vehicleType, {int id = 0}) =>
      _postCreate('Master/CreateVehicleType',
          {'VehicleTypeID': id, 'VehicleType': vehicleType});

  Future<Either<String, ApiResponse>> createVehicleCondition(
          String condition, {int id = 0}) =>
      _postCreate('Master/CreateVehicleCondition',
          {'ConditionID': id, 'Condition': condition});

  Future<Either<String, ApiResponse>> createTyrePosition(
          String position, {int id = 0}) =>
      _postCreate('Master/CreateTyrePosition',
          {'PositionID': id, 'Position': position});

  Future<Either<String, ApiResponse>> createMaintenanceType(
          String maintenanceType, {int id = 0}) =>
      _postCreate('Master/CreateMaintenanceType',
          {'MaintenanceID': id, 'MaintenanceType': maintenanceType});

  Future<Either<String, ApiResponse>> createFineType(
          {required String company, required String fineType, int id = 0}) =>
      _postCreate('Master/CreateFineType',
          {'Company': company, 'FineTypeID': id, 'FineType': fineType});

  Future<Either<String, ApiResponse>> createCity(
          {required String company, required String city, int id = 0}) =>
      _postCreate('Master/CreateCity',
          {'Company': company, 'CityID': id, 'City': city});

  Future<Either<String, ApiResponse>> createDocumentType(
          {required String company,
          required String docDescription,
          int id = 0}) =>
      _postCreate('Master/CreateDocumentType', {
        'Company': company,
        'DocType': id,
        'DocDescription': docDescription,
      });

  Future<Either<String, ApiResponse>> createFuelStation(
          {required String company,
          required String fuelStation,
          int id = 0}) =>
      _postCreate('Master/CreateFuelStation', {
        'Company': company,
        'FuelStationID': id,
        'FuelStation': fuelStation,
      });

  Future<Either<String, ApiResponse>> createVendor({
    required String company,
    required String vendorName,
    int id = 0,
    String? address,
    int? cityId,
    String? contactNo,
    String? contactPerson,
  }) =>
      _postCreate('Master/CreateVendor', {
        'Company': company,
        'VendorID': id,
        'VendorName': vendorName,
        'Address': address ?? '',
        'City': cityId ?? 0,
        'ContactNo': contactNo ?? '',
        'ContactPerson': contactPerson ?? '',
      });

  Future<Either<String, ApiResponse>> createEmployee({
    required String company,
    required String empNo,
    required String empName,
    String? designation,
    String? department,
    String? phone,
    String? email,
    String? licenseNo,
    String? licenseExpiry,
    String? nationality,
    String? remarks,
    String? stat,
  }) =>
      _postCreate('Master/CreateEmployee', {
        'Company': company,
        'EmpNo': empNo,
        'EmpName': empName,
        'Designation': designation ?? '',
        'Department': department ?? '',
        'Phone': phone ?? '',
        'Email': email ?? '',
        'LicenseNo': licenseNo ?? '',
        'LicenseExpiry': licenseExpiry ?? '',
        'Nationality': nationality ?? '',
        'Remarks': remarks ?? '',
        'Stat': stat ?? 'A',
      });

  // Generic POST helper — all create APIs return [{Status, Message, Id}]
  Future<Either<String, ApiResponse>> _postCreate(
      String path, Map<String, dynamic> body) async {
    return await RetryHelper.retry<Either<String, ApiResponse>>(
      apiCall: () async {
        final Uri url = Uri.parse('$_url$path');
        final client = http.Client();
        log('[GeneralMasterRepo] POST $path: ${jsonEncode(body)}');
        try {
          final response = await client.post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          );
          log('[GeneralMasterRepo] Response: ${response.statusCode} ${response.body}');
          if (response.statusCode == 200 || response.statusCode == 201) {
            final decoded = jsonDecode(response.body);
            // API returns a list with one object: [{Status, Message, Id}]
            final map = decoded is List
                ? (decoded.first as Map<String, dynamic>)
                : (decoded as Map<String, dynamic>);
            final apiResp = ApiResponse.fromJson(map);
            if (apiResp.status == 1) {
              return Right(apiResp);
            } else {
              return Left(apiResp.message ?? 'Operation failed');
            }
          } else {
            return Left(
                response.body.isNotEmpty ? response.body : 'Request failed');
          }
        } finally {
          client.close();
        }
      },
      defaultValue: const Left('Retry failed'),
      maxRetries: 3,
      shouldRetry: (result) =>
          result.fold((l) => l == 'Retry failed', (_) => false),
    );
  }
}
