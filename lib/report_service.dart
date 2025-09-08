import 'package:cloud_firestore/cloud_firestore.dart';

class ReportService {
  static Stream<QuerySnapshot<Map<String, dynamic>>> getReportStream({
    required String reportType,
    required String userId,
    DateTime? specificDate,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    final entryCollection = FirebaseFirestore.instance
        .collection('transactions')
        .doc(userId)
        .collection('entry');

    Query<Map<String, dynamic>> query = entryCollection;

    // Specific Date Filter
    if (reportType == 'Specific Date' && specificDate != null) {
      final start = DateTime(specificDate.year, specificDate.month, specificDate.day, 0, 0, 0);
      final end = DateTime(specificDate.year, specificDate.month, specificDate.day, 23, 59, 59);

      query = query
          .where('createdAt', isGreaterThanOrEqualTo: start)
          .where('createdAt', isLessThanOrEqualTo: end);
    }
    // Custom Date Range Filter
    else if (reportType == 'Custom Date' && fromDate != null && toDate != null) {
      final start = DateTime(fromDate.year, fromDate.month, fromDate.day, 0, 0, 0);
      final end = DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59);

      query = query
          .where('createdAt', isGreaterThanOrEqualTo: start)
          .where('createdAt', isLessThanOrEqualTo: end);
    }

    // All Over → No date filters
    return query.orderBy('createdAt', descending: true).snapshots();
  }
}
