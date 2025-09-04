import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String? selectedOption; // default null = "Select Date"
  DateTime? specificDate;
  DateTime? fromDate;
  DateTime? toDate;
  DateTime? allOverDate;

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Report'),
        backgroundColor: const Color(0xFF0B2E33),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Top attractive full-width section
          Container(
            width: double.infinity,
            color: const Color(0xFF0B2E33),
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dropdown
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
                        // reset dates when option changes
                        specificDate = null;
                        fromDate = null;
                        toDate = null;
                        allOverDate = null;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Date pickers in horizontal row
                if (selectedOption == 'Specific Date')
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
                              setState(() {
                                specificDate = date;
                              });
                            });
                          },
                          child: Text(specificDate == null
                              ? 'Select Date'
                              : dateFormat.format(specificDate!)),
                        ),
                      ),
                    ],
                  ),

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
                              setState(() {
                                fromDate = date;
                              });
                            });
                          },
                          child: Text(fromDate == null ? 'From Date' : dateFormat.format(fromDate!)),
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
                              setState(() {
                                toDate = date;
                              });
                            });
                          },
                          child: Text(toDate == null ? 'To Date' : dateFormat.format(toDate!)),
                        ),
                      ),
                    ],
                  ),

                if (selectedOption == 'All Over')
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
                              setState(() {
                                allOverDate = date;
                              });
                            });
                          },
                          child: Text(allOverDate == null ? 'Select Date' : dateFormat.format(allOverDate!)),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
