import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:moneymate/Entry_page.dart';

class ChartPage extends StatelessWidget {
  const ChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "⚠️ Please log in to view your data",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Charts Analysis'),
        backgroundColor: const Color(0xFF0B2E33),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => EntryPage()),
            );
          },
        ),
      ),
      backgroundColor: const Color(0xFFB8E3E9),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .doc(currentUser.uid)
            .collection('entry')
            .snapshots(),
        builder: (context, snapshot) {
          // Loading indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // No data found
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No data found",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          double income = 0;
          double expense = 0;

          // Calculate totals
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final type = data['type'] ?? '';
            final amount = (data['amount'] as num?)?.toDouble() ?? 0;

            if (type.toLowerCase() == 'income') {
              income += amount;
            } else if (type.toLowerCase() == 'expense') {
              expense += amount;
            }
          }

          double remaining = income - expense;

          // No transactions at all
          if (income == 0 && expense == 0) {
            return const Center(
              child: Text(
                "No transactions available",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            );
          }

          // Chart data for income vs expense
          final List<PieChartSectionData> mainChartData = [
            PieChartSectionData(
              color: const Color(0xFF0B2E33),
              value: income,
              title: "Income\n₹${income.toStringAsFixed(0)}",
              radius: 70,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              color: const Color(0xFF4F7C82),
              value: expense,
              title: "Expense\n₹${expense.toStringAsFixed(0)}",
              radius: 75,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ];

          // Prepare category-wise totals
          final Map<String, double> categoryTotals = {};
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final amount = (data['amount'] as num?)?.toDouble() ?? 0;
            final category = data['category'] ?? 'Others';

            categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
          }

          // Category-wise chart data
          final List<PieChartSectionData> categoryChartData = [];
          categoryTotals.forEach((category, total) {
            categoryChartData.add(
              PieChartSectionData(
                color: const Color(0xFF0B2E33), // ✅ Single color for all slices
                value: total,
                title: "$category\n₹${total.toStringAsFixed(0)}",
                radius: 70,
                titleStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            );
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Your Financial Overview",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // First Chart → Income vs Expense
                SizedBox(
                  height: 280,
                  child: PieChart(
                    PieChartData(
                      sections: mainChartData,
                      centerSpaceRadius: 60,
                      sectionsSpace: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Income, Expense & Remaining
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoCard("Income", income, const Color(0xFF4F7C82)),
                    _buildInfoCard("Expense", expense, const Color(0xFF4F7C82)),
                    _buildInfoCard("Remaining", remaining, const Color(0xFF4F7C82)),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  "Category-wise Analysis",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // Second Chart → Category-wise data
                SizedBox(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sections: categoryChartData,
                      centerSpaceRadius: 60,
                      sectionsSpace: 4,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // List of categories with totals
                ListView.builder(
                  itemCount: categoryTotals.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final category = categoryTotals.keys.elementAt(index);
                    final total = categoryTotals[category]!;
                    return Card(
                      color: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                          color: Color(0xFF0B2E33),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF0B2E33),
                          child: Text(
                            category[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Text(
                          "₹${total.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget to build info cards
  Widget _buildInfoCard(String title, double value, Color color) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color, width: 1),
      ),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "₹${value.toStringAsFixed(0)}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
