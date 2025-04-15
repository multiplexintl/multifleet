import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:multifleet/models/tire.dart';
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

          if (responseBody.isEmpty) {
            return const Left("Vehicle Not Found!!.");
          } else {
            var vehicle = responseBody
                .map((element) => Vehicle.fromJson(element))
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

  Future<Either<String, List<VehicleDocument>>> getAllVehicleDocument(
      {required String company, String? query}) async {
    return await RetryHelper.retry<Either<String, List<VehicleDocument>>>(
      apiCall: () async {
        final Uri url = Uri.parse(
            '${_url}Master/GetVehicleDocs?Company=$company&VehicleNo=${query ?? ''}');
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

  Future<Either<String, List<Tire>>> getAllVehicleTires(
      {required String vehicleNumber, String? query}) async {
    return await RetryHelper.retry<Either<String, List<Tire>>>(
      apiCall: () async {
        final Uri url =
            Uri.parse('${_url}Master/GetTyreMaster?VehicleNo=D-25501&Brand=');
        final client = http.Client();
        log(url.toString());
        final response = await client.get(url);
        log("Response Code: ${response.statusCode}");

        if (response.statusCode == 200) {
          List<dynamic> responseBody = jsonDecode(response.body);

          if (responseBody.isEmpty) {
            return const Left("Tire Not Found!!.");
          } else {
            var vehicle =
                responseBody.map((element) => Tire.fromJson(element)).toList();
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
}
