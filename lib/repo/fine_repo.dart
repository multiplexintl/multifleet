import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:multifleet/models/fine.dart';

import '../models/vehicle_assignment_model.dart';
import 'retry_helper.dart';

class FineRepo {
  final String _url = GlobalConfiguration().getValue('api_base_url');

  /// Get all fines for a company, optionally filtered by vehicle number
  Future<Either<String, List<Fine>>> getFines({
    required String company,
    String? vehicleNo,
  }) async {
    return await RetryHelper.retry<Either<String, List<Fine>>>(
      apiCall: () async {
        final Uri url = Uri.parse(
            '${_url}Master/GetFines?Company=$company&VehicleNo=$vehicleNo');
        final client = http.Client();
        log('[FineRepo] GET: $url');

        try {
          final response = await client.get(url);
          log('[FineRepo] Response Code: ${response.statusCode}');

          if (response.statusCode == 200) {
            List<dynamic> responseBody = jsonDecode(response.body);
            var fines =
                responseBody.map((element) => Fine.fromJson(element)).toList();
            log('[FineRepo] Fetched ${fines.length} fines');
            return Right(fines);
          } else {
            log('[FineRepo] Error: ${response.body}');
            return Left(response.body);
          }
        } finally {
          client.close();
        }
      },
      defaultValue: const Left("Failed to fetch fines. Please try again."),
      maxRetries: 3,
      shouldRetry: (result) =>
          result.fold((l) => l.contains("Retry"), (_) => false),
    );
  }

  /// Get a single fine by ID
  Future<Either<String, Fine>> getFineById({
    required String company,
    required int fineId,
  }) async {
    return await RetryHelper.retry<Either<String, Fine>>(
      apiCall: () async {
        final Uri url = Uri.parse(
          '${_url}Master/GetFine?Company=$company&FineID=$fineId',
        );
        final client = http.Client();
        log('[FineRepo] GET: $url');

        try {
          final response = await client.get(url);
          log('[FineRepo] Response Code: ${response.statusCode}');

          if (response.statusCode == 200) {
            final responseBody = jsonDecode(response.body);
            return Right(Fine.fromJson(responseBody));
          } else {
            return Left(response.body);
          }
        } finally {
          client.close();
        }
      },
      defaultValue: const Left("Failed to fetch fine details."),
      maxRetries: 3,
      shouldRetry: (result) =>
          result.fold((l) => l.contains("Retry"), (_) => false),
    );
  }

  /// Add a new fine
  Future<Either<String, Fine>> addFine({
    required Fine fine,
  }) async {
    return await RetryHelper.retry<Either<String, Fine>>(
      apiCall: () async {
        final Uri url = Uri.parse('${_url}Vehicle/Fine');
        final client = http.Client();
        log('[FineRepo] POST: $url');
        log('[FineRepo] Body: ${jsonEncode(fine.toCreateJson())}');

        try {
          final response = await client.post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(fine.toCreateJson()),
          );
          log('[FineRepo] Response Code: ${response.statusCode}');
          log('[FineRepo] Response: ${response.body}');

          if (response.statusCode == 200 || response.statusCode == 201) {
            // If API returns the created fine
            if (response.body.isNotEmpty) {
              try {
                final responseBody = jsonDecode(response.body);
                if (responseBody is Map<String, dynamic>) {
                  return Right(Fine.fromJson(responseBody));
                }
              } catch (e) {
                // API might return success message instead of object
              }
            }
            // Return the fine with a success indicator
            return Right(fine);
          } else {
            return Left(_parseErrorMessage(response.body));
          }
        } finally {
          client.close();
        }
      },
      defaultValue: const Left("Failed to add fine. Please try again."),
      maxRetries: 3,
      shouldRetry: (result) =>
          result.fold((l) => l.contains("Retry"), (_) => false),
    );
  }

  // /// Update an existing fine
  // Future<Either<String, Fine>> updateFine({
  //   required Fine fine,
  // }) async {
  //   return await RetryHelper.retry<Either<String, Fine>>(
  //     apiCall: () async {
  //       final Uri url = Uri.parse('${_url}Master/UpdateFine');
  //       final client = http.Client();
  //       log('[FineRepo] PUT: $url');
  //       log('[FineRepo] Body: ${jsonEncode(fine.toJson())}');

  //       try {
  //         final response = await client.put(
  //           url,
  //           headers: {
  //             'Content-Type': 'application/json',
  //             'Accept': 'application/json',
  //           },
  //           body: jsonEncode(fine.toJson()),
  //         );
  //         log('[FineRepo] Response Code: ${response.statusCode}');
  //         log('[FineRepo] Response: ${response.body}');

  //         if (response.statusCode == 200) {
  //           // If API returns the updated fine
  //           if (response.body.isNotEmpty) {
  //             try {
  //               final responseBody = jsonDecode(response.body);
  //               if (responseBody is Map<String, dynamic>) {
  //                 return Right(Fine.fromJson(responseBody));
  //               }
  //             } catch (e) {
  //               // API might return success message
  //             }
  //           }
  //           return Right(fine);
  //         } else {
  //           return Left(_parseErrorMessage(response.body));
  //         }
  //       } finally {
  //         client.close();
  //       }
  //     },
  //     defaultValue: const Left("Failed to update fine. Please try again."),
  //     maxRetries: 3,
  //     shouldRetry: (result) =>
  //         result.fold((l) => l.contains("Retry"), (_) => false),
  //   );
  // }

  // /// Delete a fine
  // Future<Either<String, bool>> deleteFine({
  //   required String company,
  //   required int fineId,
  // }) async {
  //   return await RetryHelper.retry<Either<String, bool>>(
  //     apiCall: () async {
  //       final Uri url = Uri.parse(
  //         '${_url}Master/DeleteFine?Company=$company&FineID=$fineId',
  //       );
  //       final client = http.Client();
  //       log('[FineRepo] DELETE: $url');

  //       try {
  //         final response = await client.delete(url);
  //         log('[FineRepo] Response Code: ${response.statusCode}');

  //         if (response.statusCode == 200) {
  //           return const Right(true);
  //         } else {
  //           return Left(_parseErrorMessage(response.body));
  //         }
  //       } finally {
  //         client.close();
  //       }
  //     },
  //     defaultValue: const Left("Failed to delete fine. Please try again."),
  //     maxRetries: 3,
  //     shouldRetry: (result) =>
  //         result.fold((l) => l.contains("Retry"), (_) => false),
  //   );
  // }

  // /// Update fine status (quick action)
  // Future<Either<String, bool>> updateFineStatus({required Fine fine}) async {
  //   return await RetryHelper.retry<Either<String, bool>>(
  //     apiCall: () async {
  //       final Uri url = Uri.parse('${_url}Master/UpdateFineStatus');
  //       final client = http.Client();
  //       final body = fine.toCreateJson();
  //       log('[FineRepo] POST: $url');
  //       log('[FineRepo] Body: ${jsonEncode(body)}');

  //       try {
  //         final response = await client.post(
  //           url,
  //           headers: {
  //             'Content-Type': 'application/json',
  //             'Accept': 'application/json',
  //           },
  //           body: jsonEncode(body),
  //         );
  //         log('[FineRepo] Response Code: ${response.statusCode}');

  //         if (response.statusCode == 200) {
  //           return const Right(true);
  //         } else {
  //           return Left(_parseErrorMessage(response.body));
  //         }
  //       } finally {
  //         client.close();
  //       }
  //     },
  //     defaultValue: const Left("Failed to update status. Please try again."),
  //     maxRetries: 3,
  //     shouldRetry: (result) =>
  //         result.fold((l) => l.contains("Retry"), (_) => false),
  //   );
  // }

  /// Get vehicle assignment history for a specific vehicle
  /// Used when adding fines to determine which employee was responsible
  Future<Either<String, List<VehicleAssignment>>> getVehicleAssignmentHistory({
    required String company,
    required String vehicleNo,
  }) async {
    return await RetryHelper.retry<Either<String, List<VehicleAssignment>>>(
      apiCall: () async {
        final Uri url = Uri.parse(
          '${_url}Master/GetVehicleAssignment?Company=$company&query=$vehicleNo&isActive=false',
        );
        final client = http.Client();
        log('[FineRepo] GET: $url');

        try {
          final response = await client.get(url);
          log('[FineRepo] Response Code: ${response.statusCode}');

          if (response.statusCode == 200) {
            List<dynamic> responseBody = jsonDecode(response.body);
            var history =
                responseBody.map((e) => VehicleAssignment.fromJson(e)).toList();
            log('[FineRepo] Fetched ${history.length} assignment records');
            return Right(history);
          } else {
            return Left(response.body);
          }
        } finally {
          client.close();
        }
      },
      defaultValue: const Left("Failed to fetch assignment history."),
      maxRetries: 3,
      shouldRetry: (result) =>
          result.fold((l) => l.contains("Retry"), (_) => false),
    );
  }

  /// Get fines summary/statistics for dashboard
  Future<Either<String, Map<String, dynamic>>> getFinesSummary({
    required String company,
  }) async {
    return await RetryHelper.retry<Either<String, Map<String, dynamic>>>(
      apiCall: () async {
        final Uri url = Uri.parse(
          '${_url}Master/GetFinesSummary?Company=$company',
        );
        final client = http.Client();
        log('[FineRepo] GET: $url');

        try {
          final response = await client.get(url);
          log('[FineRepo] Response Code: ${response.statusCode}');

          if (response.statusCode == 200) {
            final responseBody = jsonDecode(response.body);
            return Right(responseBody as Map<String, dynamic>);
          } else {
            return Left(response.body);
          }
        } finally {
          client.close();
        }
      },
      defaultValue: const Left("Failed to fetch fines summary."),
      maxRetries: 3,
      shouldRetry: (result) =>
          result.fold((l) => l.contains("Retry"), (_) => false),
    );
  }

  /// Helper to parse error messages from API response
  String _parseErrorMessage(String responseBody) {
    try {
      final json = jsonDecode(responseBody);
      if (json is Map<String, dynamic>) {
        return json['message'] ?? json['error'] ?? responseBody;
      }
      return responseBody;
    } catch (e) {
      return responseBody.isNotEmpty ? responseBody : 'An error occurred';
    }
  }
}

// import 'dart:convert';
// import 'dart:developer';

// import 'package:dartz/dartz.dart';
// import 'package:global_configuration/global_configuration.dart';
// import 'package:http/http.dart' as http;
// import 'package:multifleet/models/fine.dart';

// import 'retry_helper.dart';

// class FineRepo {
//   final String _url = GlobalConfiguration().getValue('api_base_url');
//   Future<Either<String, List<Fine>>> getFines(
//       {required String company, String? query}) async {
//     return await RetryHelper.retry<Either<String, List<Fine>>>(
//       apiCall: () async {
//         final Uri url = Uri.parse(
//             '${_url}Master/GetFines?Company=$company&VehicleNo=$query');
//         final client = http.Client();
//         log(url.toString());
//         final response = await client.get(url);
//         log("Response Code: ${response.statusCode}");

//         if (response.statusCode == 200) {
//           List<dynamic> responseBody = jsonDecode(response.body);
//           var employees =
//               responseBody.map((element) => Fine.fromJson(element)).toList();
//           return Right(employees);
//         } else {
//           return Left(response.body);
//         }
//       },
//       defaultValue: const Left("Retry failed"),
//       maxRetries: 3,
//       shouldRetry: (result) =>
//           // result.isLeft() &&
//           result.fold((l) => l == "Retry failed", (_) => false),
//     );
//   }
// }
