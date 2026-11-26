import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String? photoURL;
  final String preferredLanguage;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.photoURL,
    this.preferredLanguage = 'en',
    required this.createdAt,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    DateTime parsedDate;
    if (data['createdAt'] is Timestamp) {
      parsedDate = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      parsedDate = DateTime.tryParse(data['createdAt']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return UserModel(
      uid: id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      photoURL: data['photoURL'],
      preferredLanguage: data['preferredLanguage'] ?? 'en',
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'photoURL': photoURL,
      'preferredLanguage': preferredLanguage,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
