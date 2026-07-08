import 'dart:convert';

class UserModel {
  final String name;
  final double walletBalance;
  final String kycLevel;

  UserModel({
    required this.name,
    required this.walletBalance,
    required this.kycLevel,
  });
  

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'walletBalance': walletBalance,
      'kycLevel': kycLevel,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      walletBalance: map['walletBalance']?.toDouble() ?? 0.0,
      kycLevel: map['kycLevel'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));
}
