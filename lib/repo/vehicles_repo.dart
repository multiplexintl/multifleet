import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:multifleet/models/api_response.dart';
import 'package:multifleet/models/doc_master.dart';
import 'package:multifleet/models/fuel_station/fuel_station.dart';
import 'package:multifleet/models/tyre.dart';
import 'package:multifleet/models/vehicle.dart';
import 'package:multifleet/models/vehicle_docs.dart';
import 'package:multifleet/repo/retry_helper.dart';
import 'package:http/http.dart' as http;

class VehiclesRepo {
  final String _url = GlobalConfiguration().getValue('api_base_url');

  Future<Either<String, List<Vehicle>>> getAllVehicles(
      {required String company, String? query}) async {
    return await RetryHelper.retry<Either<String, List<Vehicle>>>(
      apiCall: () async {
        final Uri url = Uri.parse(
            '${_url}Master/GetVehicleMaster?Company=$company&query=${query ?? ''}');
        final client = http.Client();
        log(url.toString());
        final response = await client.get(url);
        log("Response Code: ${response.statusCode}");

        if (response.statusCode == 200) {
          List<dynamic> responseBody = jsonDecode(response.body);
          var vehicle =
              responseBody.map((element) => Vehicle.fromJson(element)).toList();
          return Right(vehicle);
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

  Future<Either<String, List<VehicleDocument>>> getVehicleDocument(
      {required String company, String? vehicleNo}) async {
    return await RetryHelper.retry<Either<String, List<VehicleDocument>>>(
      apiCall: () async {
        final Uri url = Uri.parse(
            '${_url}Master/GetVehicleDocs?Company=$company&VehicleNo=${vehicleNo ?? ''}');
        final client = http.Client();
        log(url.toString());
        final response = await client.get(url);
        log("Response Code: ${response.statusCode}");

        if (response.statusCode == 200) {
          List<dynamic> responseBody = jsonDecode(response.body);

          if (responseBody.isEmpty) {
            return const Left("VehicleDocument Not Found!!.");
          } else {
            var vehicle = responseBody
                .map((element) => VehicleDocument.fromJson(element))
                .toList();
            return Right(vehicle);
          }
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

  Future<Either<String, List<Tyre>>> getAllVehicleTyres(
      {required String company, String? vehicleNumber}) async {
    return await RetryHelper.retry<Either<String, List<Tyre>>>(
      apiCall: () async {
        final Uri url = Uri.parse(
            '${_url}Master/GetVehicleTyre?Company=$company&VehicleNo=$vehicleNumber');
        final client = http.Client();
        log(url.toString());
        final response = await client.get(url);
        log("Response Code: ${response.statusCode}");

        if (response.statusCode == 200) {
          List<dynamic> responseBody = jsonDecode(response.body);

          if (responseBody.isEmpty) {
            return const Left("Tyre Not Found!!.");
          } else {
            var vehicle =
                responseBody.map((element) => Tyre.fromJson(element)).toList();
            return Right(vehicle);
          }
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

  Future<Either<String, List<DocumentMaster>>> getAllVehicleDocumentMaster(
      {required String company, String? query}) async {
    return await RetryHelper.retry<Either<String, List<DocumentMaster>>>(
      apiCall: () async {
        final Uri url = Uri.parse(
            '${_url}Master/GetDocumentMaster?Company=$company&query=${query ?? ''}');
        final client = http.Client();
        log(url.toString());
        final response = await client.get(url);
        log("Response Code: ${response.statusCode}");

        if (response.statusCode == 200) {
          List<dynamic> responseBody = jsonDecode(response.body);

          if (responseBody.isEmpty) {
            return const Left("DocumentMaster Not Found!!.");
          } else {
            var vehicle = responseBody
                .map((element) => DocumentMaster.fromJson(element))
                .toList();
            return Right(vehicle);
          }
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

  Future<Either<String?, bool>> createUpdateVehicle(Vehicle vehicle) async {
    return await RetryHelper.retry<Either<String?, bool>>(
      maxRetries: 3,
      defaultValue: const Left("Retry failed"),
      shouldRetry: (result) =>
          // result.isLeft() &&
          result.fold((l) => l == "Retry failed", (_) => false),
      apiCall: () async {
        final Uri url = Uri.parse('${_url}Vehicle/CreateVehicle');
        final client = http.Client();
        ApiResponse apiResponse = ApiResponse();
        var body = json.encode(vehicle.toJson());
        log(body);

        try {
          final response = await client.post(
            url,
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json',
            },
            body: body,
          );

          log(response.statusCode.toString());

          if (response.statusCode == 200) {
            // Parse the response body
            List<dynamic> responseData = json.decode(response.body);

            if (responseData.isNotEmpty) {
              apiResponse = responseData
                  .map((element) => ApiResponse.fromJson(element))
                  .toList()
                  .first;
            }

            if (apiResponse.status == 1 &&
                apiResponse.id == vehicle.vehicleNo) {
              return Right(true);
            } else {
              return Left(apiResponse.message);
            }
          } else {
            // Log the error response for debugging
            log('Error response: ${response.statusCode} - ${response.body}');
            throw Exception(
                "Failed to create/update vehicle: ${response.statusCode}");
          }
        } finally {
          client
              .close(); // Make sure to close the client to prevent resource leaks
        }
      },
    );
  }

  Future<Either<String, List<FuelStation>>> getFuelStation(
      {required String company, String? query}) async {
    return await RetryHelper.retry<Either<String, List<FuelStation>>>(
      apiCall: () async {
        final Uri url = Uri.parse(
            '${_url}Master/GetFuelStationMaster?Company=$company&query=${query ?? ''}');
        final client = http.Client();
        log(url.toString());
        final response = await client.get(url);
        log("Response Code: ${response.statusCode}");

        if (response.statusCode == 200) {
          List<dynamic> responseBody = jsonDecode(response.body);

          if (responseBody.isEmpty) {
            return const Left("FuelStation Not Found!!.");
          } else {
            var stations = responseBody
                .map((element) => FuelStation.fromJson(element))
                .toList();
            return Right(stations);
          }
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
}
