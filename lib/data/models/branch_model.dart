class BranchModel {
  final String id;
  final String branchName;
  final String branchCode;
  final String? address;
  final String? city;
  final String? district;
  final String? state;
  final String? pincode;
  final String? mobile;
  final String? email;
  final String? managerName;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BranchModel({
    required this.id,
    required this.branchName,
    required this.branchCode,
    this.address,
    this.city,
    this.district,
    this.state,
    this.pincode,
    this.mobile,
    this.email,
    this.managerName,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) => BranchModel(
        id: json['id'] as String,
        branchName: json['branch_name'] as String,
        branchCode: json['branch_code'] as String,
        address: json['address'] as String?,
        city: json['city'] as String?,
        district: json['district'] as String?,
        state: json['state'] as String?,
        pincode: json['pincode'] as String?,
        mobile: json['mobile'] as String?,
        email: json['email'] as String?,
        managerName: json['manager_name'] as String?,
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
        'branch_name': branchName,
        'branch_code': branchCode,
        'address': address,
        'city': city,
        'district': district,
        'state': state,
        'pincode': pincode,
        'mobile': mobile,
        'email': email,
        'manager_name': managerName,
        'status': status,
      };
}
