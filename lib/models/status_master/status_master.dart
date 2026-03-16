class StatusMaster {
  int? statusId;
  String? status;

  StatusMaster({this.statusId, this.status});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatusMaster &&
          runtimeType == other.runtimeType &&
          statusId == other.statusId;

  @override
  int get hashCode => statusId.hashCode;

  @override
  String toString() => 'StatusMaster(statusId: $statusId, status: $status)';

  factory StatusMaster.fromJson(Map<String, dynamic> json) => StatusMaster(
        statusId: json['StatusID'] as int?,
        status: json['Status'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'StatusID': statusId,
        'Status': status,
      };
  factory StatusMaster.fromJsonVehicleType(Map<String, dynamic> json) =>
      StatusMaster(
        statusId: json['VehicleTypeID'] as int?,
        status: json['VehicleType'] as String?,
      );

  Map<String, dynamic> toJsonVehicleType() => {
        'VehicleTypeID': statusId,
        'VehicleType': status,
      };

  factory StatusMaster.fromJsonVehicleCondition(Map<String, dynamic> json) =>
      StatusMaster(
        statusId: json['ConditionID'] as int?,
        status: json['Condition'] as String?,
      );

  Map<String, dynamic> toJsonVehicleCondition() => {
        'ConditionID': statusId,
        'Condition': status,
      };

  factory StatusMaster.fromJsonVehicleTirePosition(Map<String, dynamic> json) =>
      StatusMaster(
        statusId: json['PositionID'] as int?,
        status: json['Position'] as String?,
      );

  Map<String, dynamic> toJsonVehicleTirePosition() => {
        'PositionID': statusId,
        'Position': status,
      };

  StatusMaster copyWith({
    int? statusId,
    String? status,
  }) {
    return StatusMaster(
      statusId: statusId ?? this.statusId,
      status: status ?? this.status,
    );
  }
}
