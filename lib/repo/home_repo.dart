import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:multifleet/models/notification/notification.dart';
import 'package:multifleet/models/vehicle_docs.dart';
import 'package:multifleet/models/vehicle_maintenance/vehicle_maintenance.dart';

import 'retry_helper.dart';

class HomeRepo {
  final String _url = GlobalConfiguration().getValue('api_base_url');

  Future<Either<String, List<VehicleDocument>>> getVehicleDocs(
      {required String company}) async {
    return await RetryHelper.retry<Either<String, List<VehicleDocument>>>(
      apiCall: () async {
        final Uri url = Uri.parse(
            '${_url}Master/GetVehicleDocs?Company=$company&VehicleNo=');

        final client = http.Client();
        log(url.toString());
        final response = await client.get(url);
        log("Response Code: ${response.statusCode}");
        // log("Response Body: ${response.body}");

        if (response.statusCode == 200) {
          List<dynamic> responseBody = jsonDecode(response.body);

          if (responseBody.isEmpty) {
            return const Left("No Documents found!!");
          } else {
            var user = responseBody
                .map((element) => VehicleDocument.fromJson(element))
                .toList();
            return Right(user);
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

  Future<Either<String, Notification>> getNotifications() async {
    return await RetryHelper.retry<Either<String, Notification>>(
      apiCall: () async {
        final Uri url = Uri.parse('${_url}Dashboard/GetNotification');

        final client = http.Client();
        log(url.toString());
        final response = await client.get(url);
        log("Response Code: ${response.statusCode}");
        log("Response Body: ${response.body}");
        if (response.statusCode == 200) {
          dynamic responseBody = jsonDecode(response.body);

          if (responseBody.isEmpty) {
            return const Left("Not found!!");
          } else {
            var user = Notification.fromJson(responseBody);
            return Right(user);
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

  Future<Either<String, List<VehicleMaintenance>>> getTodaysMaintenanceSchedule(
      {required String company, required String date}) async {
    return await RetryHelper.retry<Either<String, List<VehicleMaintenance>>>(
      apiCall: () async {
        final Uri url = Uri.parse(
            '${_url}Master/GetVehicleMaintenance?Company=$company&vehicleNo&fromDt=$date&toDt=$date&status');

        final client = http.Client();
        log(url.toString());
        final response = await client.get(url);
        log("Response Code: ${response.statusCode}");
        // log("Response Body: ${response.body}");

        if (response.statusCode == 200) {
          List<dynamic> responseBody = jsonDecode(response.body);

          if (responseBody.isEmpty) {
            return const Left("No Maintenance found!!");
          } else {
            var maintenance = responseBody
                .map((element) => VehicleMaintenance.fromJson(element))
                .toList();
            return Right(maintenance);
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
