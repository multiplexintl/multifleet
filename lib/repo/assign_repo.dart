import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:multifleet/models/api_response.dart';

import 'package:multifleet/models/vehicle_assignment_model.dart';

import 'retry_helper.dart';

class AssignRepo {
  final String _url = GlobalConfiguration().getValue('api_base_url');

  Future<Either<String, List<VehicleAssignment>>> getAllAssignmets(
      {required String company, String? query, bool? isActive}) async {
    return await RetryHelper.retry<Either<String, List<VehicleAssignment>>>(
      apiCall: () async {
        final Uri url = Uri.parse(
            '${_url}Master/GetVehicleAssignment?Company=$company&query=$query&isActive=${isActive ?? 'false'}');
        final client = http.Client();
        log(url.toString());
        final response = await client.get(url);
        log("Response Code: ${response.statusCode}");

        if (response.statusCode == 200) {
          List<dynamic> responseBody = jsonDecode(response.body);
          var employees = responseBody
              .map((element) => VehicleAssignment.fromJson(element))
              .toList();
          return Right(employees);
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

  Future<Either<bool, ApiResponse>> createEditAssignment(
      {required VehicleAssignment assignment, required bool isAssign}) async {
    return await RetryHelper.retry<Either<bool, ApiResponse>>(
      maxRetries: 3,
      defaultValue: Left(false),
      shouldRetry: (response) => response.fold((l) => l == false, (_) => false),
      apiCall: () async {
        final Uri url = Uri.parse(
            '${_url}Vehicle/VehicleAssignment?operation=${isAssign ? 'INSERT' : 'UPDATE'}');
        final client = http.Client();
        ApiResponse apiResponse = ApiResponse();
        var body = json.encode(assignment.toJsonAssignUpdate());
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
                apiResponse.id == assignment.vehicleNo) {
              return Left(true);
            } else {
              return Right(apiResponse);
            }
          } else {
            // Log the error response for debugging
            log('Error response: ${response.statusCode} - ${response.body}');
            return Left(false);
          }
        } catch (e) {
          throw Exception("Failed to create/update vehicle: ${e.toString()}");
        } finally {
          client
              .close(); // Make sure to close the client to prevent resource leaks
        }
      },
    );
  }
}
