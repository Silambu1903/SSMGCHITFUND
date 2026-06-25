class GuarantorModel {
  final String id;
  final String memberId;
  final String name;
  final String relationship;
  final String mobile;
  final String? address;
  final String? photoUrl;
  final String? aadhaarNumber;
  final DateTime? createdAt;

  const GuarantorModel({
    required this.id,
    required this.memberId,
    required this.name,
    required this.relationship,
    required this.mobile,
    this.address,
    this.photoUrl,
    this.aadhaarNumber,
    this.createdAt,
  });

  factory GuarantorModel.fromJson(Map<String, dynamic> json) =>
      GuarantorModel(
        id: json['id'] as String,
        memberId: json['member_id'] as String,
        name: json['name'] as String,
        relationship: json['relationship'] as String,
        mobile: json['mobile'] as String,
        address: json['address'] as String?,
        photoUrl: json['photo_url'] as String?,
        aadhaarNumber: json['aadhaar_number'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );
}
