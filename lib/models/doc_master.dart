class DocumentMaster {
  final String? company;
  final int? docType;
  final String? docDescription;

  DocumentMaster({
    this.company,
    this.docType,
    this.docDescription,
  });

  // Copy with method
  DocumentMaster copyWith({
    String? company,
    int? docType,
    String? docDescription,
  }) {
    return DocumentMaster(
      company: company ?? this.company,
      docType: docType ?? this.docType,
      docDescription: docDescription ?? this.docDescription,
    );
  }

  // From JSON factory constructor
  factory DocumentMaster.fromJson(Map<String, dynamic> json) {
    return DocumentMaster(
      company: json['Company'],
      docType: json['DocType'],
      docDescription: json['DocDescription'],
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'Company': company,
      'DocType': docType,
      'DocDescription': docDescription,
    };
  }

  // Override == operator for proper value comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DocumentMaster &&
        other.company == company &&
        other.docType == docType &&
        other.docDescription == docDescription;
  }

  // Always override hashCode when overriding ==
  @override
  int get hashCode => Object.hash(company, docType, docDescription);

  // toString method
  @override
  String toString() {
    return 'DocumentMaster{company: $company, docType: $docType, docDescription: $docDescription}';
  }
}
