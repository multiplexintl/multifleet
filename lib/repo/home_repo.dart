import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:multifleet/models/vehicle_docs.dart';

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
}
