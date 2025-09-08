import 'dart:typed_data';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:universal_html/html.dart' as html;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PdfService {
  /// ✅ Generate PDF bytes
  static Future<Uint8List> generatePdfBytes({
    required List<Map<String, dynamic>> data,
    required String userId,
  }) async {
    final pdf = pw.Document();
    final df = DateFormat('dd-MM-yyyy');

    // ✅ Fetch username dynamically from users collection
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    final username = userDoc.data()?['fullName'] ?? "Unknown User";

    // ✅ Colors
    const PdfColor primaryColor = PdfColor.fromInt(0xFF0B2E33);
    const PdfColor secondaryColor = PdfColor.fromInt(0xFF4F7C82);

    // ✅ Load clean font
    final font = pw.Font.ttf(await rootBundle.load("assets/fonts/NotoSans-Regular.ttf"));

    // ✅ Load logo
    final logo = await imageFromAssetBundle('assets/images/moneymate.png');

    // ✅ Calculate totals
    double totalIncome = 0;
    double totalExpense = 0;

    for (var item in data) {
      double amount = double.tryParse(item['amount'].toString()) ?? 0;
      if (item['type'].toString().toLowerCase() == 'income') {
        totalIncome += amount;
      } else {
        totalExpense += amount;
      }
    }

    // ✅ Create PDF page
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        build: (context) => [
          // ✅ Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                children: [
                  pw.Image(logo, width: 75, height: 75),
                  pw.SizedBox(width: 5),
                  pw.Text(
                    "MoneyMate",
                    style: pw.TextStyle(
                      font: font,
                      color: primaryColor,
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    username,
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 14,
                      color: PdfColors.black,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    "Date: ${df.format(DateTime.now())}",
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 12,
                      color: PdfColors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 15),

          // ✅ Title
          pw.Center(
            child: pw.Text(
              "Transaction Report",
              style: pw.TextStyle(
                font: font,
                color: secondaryColor,
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 15),

          // ✅ Table or No Data
          if (data.isEmpty)
            pw.Center(
              child: pw.Text(
                "No data available",
                style: pw.TextStyle(font: font, fontSize: 14),
              ),
            )
          else
            pw.Table.fromTextArray(
              headers: ["No.", "Title", "Amount (₹)", "Date", "Type", "Payment Mode"],
              data: List<List<String>>.generate(
                data.length,
                    (i) => [
                  "${i + 1}",
                  data[i]['title'].toString(),
                  "₹${data[i]['amount'].toString()}",
                  df.format(data[i]['createdAt'] as DateTime),
                  data[i]['type'].toString(),
                  data[i]['paymentMode'].toString(),
                ],
              ),
              headerStyle: pw.TextStyle(
                font: font,
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
              headerDecoration: pw.BoxDecoration(
                color: primaryColor,
              ),
              cellStyle: pw.TextStyle(
                font: font,
                fontSize: 11,
                color: PdfColors.black,
              ),
              cellAlignment: pw.Alignment.center,
              columnWidths: {
                0: const pw.FixedColumnWidth(40),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(1.2),
                3: const pw.FlexColumnWidth(1.5),
                4: const pw.FlexColumnWidth(1.2),
                5: const pw.FlexColumnWidth(1.5),
              },
            ),
          pw.SizedBox(height: 12),

          // ✅ Totals Section
          if (data.isNotEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "Total Entries: ${data.length}",
                    style: pw.TextStyle(font: font, fontSize: 13),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    "Total Income: ₹${totalIncome.toStringAsFixed(2)}",
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 13,
                      color: PdfColors.green700,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    "Total Expense: ₹${totalExpense.toStringAsFixed(2)}",
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 13,
                      color: PdfColors.red700,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],

        // ✅ Footer
        footer: (context) => pw.Align(
          alignment: pw.Alignment.center,
          child: pw.Text(
            "Page ${context.pageNumber} of ${context.pagesCount}",
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              color: secondaryColor,
            ),
          ),
        ),
      ),
    );

    return pdf.save();
  }

  /// ✅ Download or share PDF
  static Future<void> downloadOrSharePdf({
    required List<Map<String, dynamic>> data,
    required String userId,
    required String filename,
  }) async {
    final pdfBytes = await generatePdfBytes(data: data, userId: userId);

    if (kIsWeb) {
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = io.File("${dir.path}/$filename");
      await file.writeAsBytes(pdfBytes);
      await OpenFile.open(file.path);
    }
  }
}
