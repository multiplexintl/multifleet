class ApiResponse {
  int? status;
  String? message;
  dynamic id;

  ApiResponse({this.status, this.message, this.id});

  factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse(
        status: json['Status'] as int?,
        message: json['Message'] as String?,
        id: json['Id'],
      );

  @override
  String toString() {
    return 'ApiResponse{status: $status, message: $message, id: $id}';
  }
}
