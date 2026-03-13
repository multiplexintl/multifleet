import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:multifleet/models/vendor.dart';

import 'retry_helper.dart';

class VendorRepo {
  final String _url = GlobalConfiguration().getValue('api_base_url');

  Future<Either<String, List<Vendor>>> getVendorMaster(
      {required String company, String? query}) async {
    return await RetryHelper.retry<Either<String, List<Vendor>>>(
      apiCall: () async {
        final Uri url = Uri.parse(
            '${_url}Master/GetVendorMaster?Company=$company&query=${query ?? ''}');
        final client = http.Client();
        log(url.toString());
        final response = await client.get(url);
        log("Response Code: ${response.statusCode}");

        if (response.statusCode == 200) {
          List<dynamic> responseBody = jsonDecode(response.body);
          var vendors =
              responseBody.map((element) => Vendor.fromJson(element)).toList();
          return Right(vendors);
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
