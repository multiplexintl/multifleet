import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:multifleet/models/employee.dart';

import 'retry_helper.dart';

class EmployeeRepo {
  final String _url = GlobalConfiguration().getValue('api_base_url');

  Future<Either<String, List<Employee>>> getAllEmployees() async {
    return await RetryHelper.retry<Either<String, List<Employee>>>(
      apiCall: () async {
        final Uri url =
            Uri.parse('${_url}Master/GetEmployeeMaster?Company=&query=');
        final client = http.Client();
        log(url.toString());
        final response = await client.get(url);
        log("Response Code: ${response.statusCode}");

        if (response.statusCode == 200) {
          List<dynamic> responseBody = jsonDecode(response.body);
          var employees = responseBody
              .map((element) => Employee.fromJson(element))
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

  Future<Either<String, Employee>> saveEmployee({
    required Employee employee,
  }) async {
    return await RetryHelper.retry<Either<String, Employee>>(
      apiCall: () async {
        final Uri url = Uri.parse('${_url}Master/SaveEmployeeMaster');
        final client = http.Client();
        log('[EmployeeRepo] POST: $url');
        log('[EmployeeRepo] Body: ${jsonEncode(employee.toJson())}');
        try {
          final response = await client.post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(employee.toJson()),
          );
          log('[EmployeeRepo] Response Code: ${response.statusCode}');
          log('[EmployeeRepo] Response: ${response.body}');
          if (response.statusCode == 200 || response.statusCode == 201) {
            return Right(employee);
          } else {
            return Left(response.body.isNotEmpty
                ? response.body
                : 'Failed to save employee');
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

  Future<Either<String, List<Employee>>> getAllEmployeesByCompany(
      {required String company, String? query}) async {
    return await RetryHelper.retry<Either<String, List<Employee>>>(
      apiCall: () async {
        final Uri url = Uri.parse(
            '${_url}Master/GetEmployeeMaster?Company=$company&query=${query ?? ''}');
        final client = http.Client();
        log(url.toString());
        final response = await client.get(url);
        log("Response Code: ${response.statusCode}");

        if (response.statusCode == 200) {
          List<dynamic> responseBody = jsonDecode(response.body);
          var employees = responseBody
              .map((element) => Employee.fromJson(element))
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
}
