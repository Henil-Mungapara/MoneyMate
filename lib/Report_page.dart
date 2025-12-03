import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moneymate/Chart_page.dart';
import 'package:moneymate/Bottom_Navigation_Page.dart';
import 'report_view_page.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String? selectedOption;
  DateTime? specificDate;
  DateTime? fromDate;
  DateTime? toDate;
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');

  Future<void> pickDate(BuildContext context, Function(DateTime) onPicked) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid; // ✅ Dynamic user ID

    return Scaffold(
      backgroundColor: const Color(0xFFB8E3E9),
      appBar: AppBar(
        title: const Text('Report Analysis'),
        backgroundColor: const Color(0xFF0B2E33),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BottomNavigationPage()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF0B2E33),
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectedOption,
                    hint: const Text(
                      'Select Date',
                      style: TextStyle(color: Colors.black),
                    ),
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'Specific Date', child: Text('Specific Date')),
                      DropdownMenuItem(value: 'Custom Date', child: Text('Custom Date')),
                      DropdownMenuItem(value: 'All Over', child: Text('All Over')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value;
                        specificDate = null;
                        fromDate = null;
                        toDate = null;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Specific Date
                if (selectedOption == 'Specific Date')
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0B2E33),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      pickDate(context, (date) {
                        setState(() => specificDate = date);
                      });
                    },
                    child: Text(specificDate == null
                        ? 'Select Date'
                        : dateFormat.format(specificDate!)),
                  ),

                // Custom Date Range
                if (selectedOption == 'Custom Date')
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0B2E33),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            pickDate(context, (date) {
                              setState(() => fromDate = date);
                            });
                          },
                          child: Text(fromDate == null
                              ? 'From Date'
                              : dateFormat.format(fromDate!)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0B2E33),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            pickDate(context, (date) {
                              setState(() => toDate = date);
                            });
                          },
                          child: Text(toDate == null
                              ? 'To Date'
                              : dateFormat.format(toDate!)),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                // View Report Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    if (selectedOption == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select a report type")),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportViewPage(
                          reportType: selectedOption!,
                          userId: userId, // ✅ Dynamic User ID
                          specificDate: specificDate,
                          fromDate: fromDate,
                          toDate: toDate,
                        ),
                      ),
                    );
                  },
                  child: const Text("View Report"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}