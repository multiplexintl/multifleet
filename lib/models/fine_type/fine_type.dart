class FineType {
  String? company;
  int? fineTypeId;
  String? fineType;

  FineType({this.company, this.fineTypeId, this.fineType});

  @override
  String toString() {
    return 'FineType(company: $company, fineTypeId: $fineTypeId, fineType: $fineType)';
  }

  factory FineType.fromJson(Map<String, dynamic> json) => FineType(
        company: json['Company'] as String?,
        fineTypeId: json['FineTypeID'] as int?,
        fineType: json['FineType'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'Company': company,
        'FineTypeID': fineTypeId,
        'FineType': fineType,
      };

  FineType copyWith({
    String? company,
    int? fineTypeId,
    String? fineType,
  }) {
    return FineType(
      company: company ?? this.company,
      fineTypeId: fineTypeId ?? this.fineTypeId,
      fineType: fineType ?? this.fineType,
    );
  }
}
