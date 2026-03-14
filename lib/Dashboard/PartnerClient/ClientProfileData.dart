
import '../../Auth/Shared/AuthModels.dart';

class ClientProfileData {
  final String? firstName;
  final String? lastName;
  final String? number;
  final String? wilaya;
  final String? commune;

  const ClientProfileData({
    this.firstName,
    this.lastName,
    this.number,
    this.wilaya,
    this.commune,
  });

  factory ClientProfileData.fromJson(Map<String, dynamic> j) {
    return ClientProfileData(
      firstName: j['first_name']?.toString(),
      lastName: j['last_name']?.toString(),
      number: j['number']?.toString(),
      wilaya: j['wilaya']?.toString(),
      commune: j['commune']?.toString(),
    );
  }

  factory ClientProfileData.fromUser(UserData user) {
    return ClientProfileData(
      firstName: user.firstName,
      lastName: user.lastName,
      number: user.number,
      wilaya: user.wilaya,
      commune: user.commune,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'first_name': firstName,
      'last_name': lastName,
      'number': number,
      'wilaya': wilaya,
      'commune': commune,
    };

    map.removeWhere(
          (k, v) => v == null || (v is String && v.trim().isEmpty),
    );

    return map;
  }

  ClientProfileData copyWith({
    String? firstName,
    String? lastName,
    String? number,
    String? wilaya,
    String? commune,
  }) {
    return ClientProfileData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      number: number ?? this.number,
      wilaya: wilaya ?? this.wilaya,
      commune: commune ?? this.commune,
    );
  }
}