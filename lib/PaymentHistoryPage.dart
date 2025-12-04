import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Paymenthistorypage extends StatelessWidget {
  const Paymenthistorypage({super.key});


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // add code here for showing user not logged in


    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        backgroundColor: const Color(0xFF0B2E33),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFB8E3E9),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rezorpay_payments')
            .doc(user.uid)
            .collection('payments')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No payment history available.",
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          final payments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index].data() as Map<String, dynamic>;
              final status = payment['status'] ?? 'unknown';
              final amount = payment['amount'] ?? 0;
              final createdAt = (payment['created_at'] as Timestamp?)?.toDate();
              final wallet = payment['wallet'];

              return Card(
                color: Colors.white,
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: Icon(
                    status == 'success'
                        ? Icons.check_circle
                        : status == 'failure'
                        ? Icons.cancel
                        : Icons.account_balance_wallet,
                    color: status == 'success'
                        ? Colors.green
                        : status == 'failure'
                        ? Colors.red
                        : Colors.orange,
                  ),
                  title: Text(
                    "₹$amount",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Status: $status",
                        style: const TextStyle(color: Colors.black),
                      ),
                      if (wallet != null)
                        Text(
                          "Wallet: $wallet",
                          style: const TextStyle(color: Colors.black),
                        ),
                      if (createdAt != null)
                        Text(
                          "Date: ${createdAt.toLocal()}",
                          style: const TextStyle(color: Colors.black),
                        ),
                    ],
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
