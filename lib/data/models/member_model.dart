class MemberModel {
  final String id;
  final String memberNo;
  final String branchId;
  final String name;
  final String? fatherName;
  final String mobile;
  final String? alternateMobile;
  final String? email;
  final String? aadhaarNumber;
  final String? panNumber;
  final String? address;
  final String? city;
  final String? district;
  final String? state;
  final String? pincode;
  final String? occupation;
  final double? monthlyIncome;
  final String? joiningDate;
  final String? photoUrl;
  final String? signatureUrl;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MemberModel({
    required this.id,
    required this.memberNo,
    required this.branchId,
    required this.name,
    this.fatherName,
    required this.mobile,
    this.alternateMobile,
    this.email,
    this.aadhaarNumber,
    this.panNumber,
    this.address,
    this.city,
    this.district,
    this.state,
    this.pincode,
    this.occupation,
    this.monthlyIncome,
    this.joiningDate,
    this.photoUrl,
    this.signatureUrl,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) => MemberModel(
        id: json['id'] as String,
        memberNo: json['member_no'] as String,
        branchId: json['branch_id'] as String,
        name: json['name'] as String,
        fatherName: json['father_name'] as String?,
        mobile: json['mobile'] as String,
        alternateMobile: json['alternate_mobile'] as String?,
        email: json['email'] as String?,
        aadhaarNumber: json['aadhaar_number'] as String?,
        panNumber: json['pan_number'] as String?,
        address: json['address'] as String?,
        city: json['city'] as String?,
        district: json['district'] as String?,
        state: json['state'] as String?,
        pincode: json['pincode'] as String?,
        occupation: json['occupation'] as String?,
        monthlyIncome:
            (json['monthly_income'] as num?)?.toDouble(),
        joiningDate: json['joining_date'] as String?,
        photoUrl: json['photo_url'] as String?,
        signatureUrl: json['signature_url'] as String?,
        status: json['status'] as String? ?? 'active',
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'member_no': memberNo,
        'branch_id': branchId,
        'name': name,
        'father_name': fatherName,
        'mobile': mobile,
        'alternate_mobile': alternateMobile,
        'email': email,
        'aadhaar_number': aadhaarNumber,
        'pan_number': panNumber,
        'address': address,
        'city': city,
        'occupation': occupation,
        'monthly_income': monthlyIncome,
        'joining_date': joiningDate,
        'status': status,
      };

  MemberModel copyWith({
    String? name,
    String? mobile,
    String? status,
    String? occupation,
    String? photoUrl,
  }) {
    return MemberModel(
      id: id,
      memberNo: memberNo,
      branchId: branchId,
      name: name ?? this.name,
      fatherName: fatherName,
      mobile: mobile ?? this.mobile,
      alternateMobile: alternateMobile,
      email: email,
      aadhaarNumber: aadhaarNumber,
      panNumber: panNumber,
      address: address,
      occupation: occupation ?? this.occupation,
      monthlyIncome: monthlyIncome,
      joiningDate: joiningDate,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
    );
  }
}
