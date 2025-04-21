import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:multifleet/models/doc_type.dart';
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
      {required String vehicleNumber, String? query}) async {
    return await RetryHelper.retry<Either<String, List<Tyre>>>(
      apiCall: () async {
        final Uri url = Uri.parse(
            '${_url}Master/GetTyreMaster?VehicleNo=$vehicleNumber&Brand=');
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

  Future<Either<String, List<DocumentType>>> getAllVehicleDocumentMaster(
      {required String company, String? query}) async {
    return await RetryHelper.retry<Either<String, List<DocumentType>>>(
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
            return const Left("DocumentType Not Found!!.");
          } else {
            var vehicle = responseBody
                .map((element) => DocumentType.fromJson(element))
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

  Future<bool> createUpdateVehicle(Vehicle vehicle) async {
    return await RetryHelper.retry<bool>(
      maxRetries: 3,
      defaultValue: false,
      shouldRetry: (response) =>
          response == false, // Fixed this line from "response = false"
      apiCall: () async {
        final Uri url = Uri.parse('${_url}Vehicle/CreateVehicle');
        final client = http.Client();
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
            final responseData = json.decode(response.body);

            // Check if response is a list with at least one element
            if (responseData is List && responseData.isNotEmpty) {
              // Get the first element and check for VehicleNoInserted field
              final firstItem = responseData[0];

              if (firstItem is Map<String, dynamic> &&
                  firstItem.containsKey('VehicleNoInserted')) {
                // Get the inserted vehicle number
                final insertedVehicleNo = firstItem['VehicleNoInserted'];

                // Compare with the vehicle number in the request
                final requestVehicleNo = vehicle.vehicleNo;

                // Return true only if they match
                return insertedVehicleNo == requestVehicleNo;
              }
            }

            // If we reached here, the response format wasn't as expected
            log('Unexpected response format: ${response.body}');
            return false;
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
}
