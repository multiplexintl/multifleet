class DocumentType {
  final String? company;
  final int? docType;
  final String? docDescription;

  DocumentType({
    this.company,
    this.docType,
    this.docDescription,
  });

  // Copy with method
  DocumentType copyWith({
    String? company,
    int? docType,
    String? docDescription,
  }) {
    return DocumentType(
      company: company ?? this.company,
      docType: docType ?? this.docType,
      docDescription: docDescription ?? this.docDescription,
    );
  }

  // From JSON factory constructor
  factory DocumentType.fromJson(Map<String, dynamic> json) {
    return DocumentType(
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

  // toString method
  @override
  String toString() {
    return 'DocumentType{company: $company, docType: $docType, docDescription: $docDescription}';
  }
}