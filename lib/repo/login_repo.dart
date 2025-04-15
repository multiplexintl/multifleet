import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart';
import 'retry_helper.dart';

class LoginRepo {
  final String _url = GlobalConfiguration().getValue('api_base_url');

  Future<Either<String, User>> getEmployee(
      {required String empCode, required String pwd}) async {
    return await RetryHelper.retry<Either<String, User>>(
      apiCall: () async {
        final Uri url =
            Uri.parse('${_url}Master/GetLogin?EmpNo=$empCode&Pwd=$pwd');

        final client = http.Client();
        log(url.toString());
        final response = await client.get(url);
        log("Response Code: ${response.statusCode}");
        log("Response Body: ${response.body}");

        if (response.statusCode == 200) {
          List<dynamic> responseBody = jsonDecode(response.body);

          if (responseBody.isEmpty) {
            return const Left("Employee ID or Password is wrong.");
          } else {
            var user = User.fromJson(responseBody[0]);
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

  Future<Either<String, User>> getEmployeeDio(
      {required String empCode, required String pwd}) async {
    return await RetryHelper.retry<Either<String, User>>(
      apiCall: () async {
        final dio = Dio();
        final String url = '${_url}Master/GetLogin';

        try {
          log('$url?EmpNo=$empCode&Pwd=$pwd');
          final response = await dio.get(
            url,
            queryParameters: {
              'EmpNo': empCode,
              'Pwd': pwd,
            },
            options: Options(
              responseType: ResponseType.json,
              followRedirects: false,
              validateStatus: (status) {
                return status != null && status < 500;
              },
            ),
          );

          log("Response Code: ${response.statusCode}");

          if (response.statusCode == 200) {
            List<dynamic> responseBody = response.data;

            if (responseBody.isEmpty) {
              return const Left("Employee ID or Password is wrong.");
            } else {
              var user = User.fromJson(responseBody[0]);
              return Right(user);
            }
          } else {
            return Left(response.data.toString());
          }
        } on DioException catch (e) {
          log("Dio Error: ${e.message}");
          // Handle different error scenarios
          if (e.type == DioExceptionType.connectionTimeout) {
            return const Left("Connection timed out");
          } else if (e.type == DioExceptionType.receiveTimeout) {
            return const Left("Receive timeout");
          } else if (e.type == DioExceptionType.connectionError) {
            return const Left("No internet connection");
          } else {
            return Left(e.message ?? "Unknown error occurred");
          }
        } catch (e) {
          log("General Error: $e");
          return Left(e.toString());
        } finally {
          // Clean up (Dio handles its own client cleanup)
        }
      },
      defaultValue: const Left("Retry failed"),
      maxRetries: 3,
      shouldRetry: (result) =>
          result.fold((l) => l == "Retry failed", (_) => false),
    );
  }
}
