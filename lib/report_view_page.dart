import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'pdf_service.dart';
import 'report_service.dart';

class ReportViewPage extends StatelessWidget {
  final String reportType;
  final String userId;
  final DateTime? specificDate;
  final DateTime? fromDate;
  final DateTime? toDate;

  const ReportViewPage({
    super.key,
    required this.reportType,
    required this.userId,
    this.specificDate,
    this.fromDate,
    this.toDate,
  });

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd-MM-yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Transaction Report",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0B2E33),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              try {
                final snapshot = await ReportService.getReportStream(
                  reportType: reportType,
                  userId: userId,
                  specificDate: specificDate,
                  fromDate: fromDate,
                  toDate: toDate,
                ).first;

                final reports = snapshot.docs.map((doc) {
                  final data = doc.data();
                  return {
                    'title': data['title'] ?? '',
                    'amount': data['amount'] ?? 0,
                    'category': data['category'] ?? '',
                    'createdAt': (data['createdAt'] as Timestamp).toDate(),
                    'type': data['type'] ?? 'N/A',
                    'paymentMode': data['paymentMode'] ?? 'N/A',
                  };
                }).toList();

                // ✅ Now PdfService itself fetches username dynamically
                await PdfService.downloadOrSharePdf(
                  data: reports,
                  userId: userId,
                  filename: "transaction_report.pdf",
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("PDF generated successfully!"),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
            },
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ReportService.getReportStream(
          reportType: reportType,
          userId: userId,
          specificDate: specificDate,
          fromDate: fromDate,
          toDate: toDate,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No data found.'));
          }

          final reports = snapshot.data!.docs.map((doc) => doc.data()).toList();

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              final createdAt = (report['createdAt'] as Timestamp).toDate();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF4F7C82),
                    child: Text(
                      report['title'].toString().isNotEmpty
                          ? report['title'][0].toUpperCase()
                          : "?",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    report['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B2E33),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Category: ${report['category']}"),
                      Text("Type: ${report['type']}"),
                      Text("Payment: ${report['paymentMode']}"),
                      Text("Date: ${df.format(createdAt)}"),
                    ],
                  ),
                  trailing: Text(
                    "₹${report['amount']}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
