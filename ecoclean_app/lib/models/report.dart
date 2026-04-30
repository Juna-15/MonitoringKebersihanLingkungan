import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  String? id;
  String? image;
  String? description;
  String? category;
  Timestamp? createdAt;
  String? latitude;
  String? longitude;
  String? userId;
  String? userFullName;
  List<dynamic> favoriteBy;

  Report({
    this.id,
    this.image,
    this.description,
    this.category,
    this.createdAt,
    this.latitude,
    this.longitude,
    this.userId,
    this.userFullName,
    this.favoriteBy = const [],
  });

  factory Report.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Report(
      id: doc.id,
      image: data['image'],
      description: data['description'],
      category: data['category'],
      createdAt: data['created_at'] as Timestamp?,
      latitude: data['latitude'],
      longitude: data['longitude'],
      userId: data['user_id'],
      userFullName: data['user_full_name'],
      favoriteBy: data['favorite_by'] ?? [],
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'image': image,
      'description': description,
      'category': category,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
      'latitude': latitude,
      'longitude': longitude,
      'user_id': userId,
      'user_full_name': userFullName,
      'favorite_by': favoriteBy,
    };
  }
}
