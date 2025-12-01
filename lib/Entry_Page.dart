import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moneymate/Home.dart';
import 'package:moneymate/bottom_navigation_page.dart';

import 'fillupform_page.dart';

class EntryPage extends StatelessWidget {
  const EntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title:const Text('Transaction List'),
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
      backgroundColor:const Color(0xFFB8E3E9),
      body: user == null
          ? const Center(child: Text("User not logged in"))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .doc(user.uid)
            .collection('entry')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No transactions found."));
          }

          final entries = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final data = entry.data() as Map<String, dynamic>;

              final title = data['title'] ?? 'No Title';
              final type = data['type'] ?? 'Unknown';
              final amount = data['amount']?.toString() ?? '0.0';

              return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.teal.shade700,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text("$type • ₹$amount",
                        style: TextStyle(fontSize: 14),
                      ),

                    ),
                    trailing: Wrap(
                      spacing: 5,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF0B2E33),size: 28,),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FillUpFormPage(
                                  existingData: data,
                                  entryId: entry.id,
                                ),
                              ),
                            );
                          },

                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_rounded, color: Color(0xFF0B2E33),size: 28,),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('transactions')
                                .doc(user.uid)
                                .collection('entry')
                                .doc(entry.id)
                                .delete();
                          },
                        ),
                      ],
                    ),
                  )

              );
            },
          );
        },
      ),
    );
  }
}
