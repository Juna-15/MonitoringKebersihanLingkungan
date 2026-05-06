import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report.dart';

class DatabaseService {
  static final _db = FirebaseFirestore.instance;
  static final _reports = _db.collection('reports');

  static bool checkIsAdmin(String? email) {
    if (email == null) return false;

    // Daftar email spesifik yang diberikan akses Administrator
    final List<String> adminEmails = [
      "muhammadjndi@gmail.com",
      "admin@ecoclean.com",
    ];

    return adminEmails.contains(email.toLowerCase().trim());
  }

  static Future<void> addReport(Report report) async {
    await _reports.add(report.toDocument());
  }

  static Stream<List<Report>> getReports() {
    return _reports
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) => Report.fromDocument(doc)).toList(),
        );
  }

  static Future<void> toggleFavorite(
    String reportId,
    String userId,
    bool isAdding,
  ) async {
    await _reports.doc(reportId).update({
      'favorite_by': isAdding
          ? FieldValue.arrayUnion([userId])
          : FieldValue.arrayRemove([userId]),
    });
  }

  static Future<void> addComment(
    String reportId,
    String name,
    String text,
  ) async {
    await _reports.doc(reportId).collection('comments').add({
      'userName': name,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> getComments(String reportId) {
    return _reports
        .doc(reportId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
