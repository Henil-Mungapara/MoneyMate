import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moneymate/PaymentHistoryPage.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'fillupform_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Razorpay _razorpay;
  int _lastPaidAmount = 0;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Payment Success: ${response.paymentId}")),
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final paymentDocRef = FirebaseFirestore.instance
        .collection('rezorpay_payments')
        .doc(user.uid)
        .collection('payments')
        .doc(response.paymentId);

    await paymentDocRef.set({
      'amount': _lastPaidAmount,
      'status': 'success',
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Payment Failed: ${response.message}")),
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final paymentDocRef = FirebaseFirestore.instance
        .collection('rezorpay_payments')
        .doc(user.uid)
        .collection('payments')
        .doc('failed_${DateTime.now().millisecondsSinceEpoch}');

    await paymentDocRef.set({
      'amount': _lastPaidAmount,
      'status': 'failure',
      'reason': response.message ?? 'Unknown error',
      'code': response.code,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("💼 Wallet Payment: ${response.walletName}")),
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final paymentDocRef = FirebaseFirestore.instance
        .collection('rezorpay_payments')
        .doc(user.uid)
        .collection('payments')
        .doc('wallet_${DateTime.now().millisecondsSinceEpoch}');

    await paymentDocRef.set({
      'amount': _lastPaidAmount,
      'status': 'wallet',
      'wallet': response.walletName,
      'created_at': FieldValue.serverTimestamp(),
    });
  }


  void _showAmountDialog() {
    final TextEditingController _amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter Amount"),
        content: TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Enter amount to pay"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = int.tryParse(_amountController.text.trim());

              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("⚠️ Enter valid amount")),
                );
                return;
              }

              Navigator.pop(context);
              _openCheckout(amount);
            },
            child: const Text("Pay Now"),
          ),
        ],
      ),
    );
  }

  void _openCheckout(int amount) {
    _lastPaidAmount = amount;

    var options = {
      'key': 'rzp_test_b1q4VYFIW1Kf0g', // Replace with your key
      'amount': amount * 100,
      'name': 'MoneyMate',
      'description': 'Custom Amount Payment',
      'prefill': {
        'contact': '8888888888',
        'email': 'test@example.com',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    double cardHeight = MediaQuery.of(context).size.height * 0.20;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MoneyMate'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0B2E33),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFB8E3E9),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('transactions')
              .doc(user.uid)
              .collection('entry')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final entries = snapshot.data!.docs;

            int income = 0;
            int expense = 0;

            for (var doc in entries) {
              final data = doc.data() as Map<String, dynamic>;
              final type = data['type'];
              final amount = (data['amount'] as num?)?.toInt() ?? 0;

              if (type == 'Income') {
                income += amount;
              } else if (type == 'Expense') {
                expense += amount;
              }
            }

            int remaining = income - expense;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '💸 Welcome to MoneyMate!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  buildInfoCard(
                    height: cardHeight,
                    image: 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                    title: 'Income',
                    value: '₹$income',
                    subtitle: 'Total earnings',
                    color: const Color(0xFF4F7C82),
                  ),
                  const SizedBox(height: 16),
                  buildInfoCard(
                    height: cardHeight,
                    image: 'https://cdn-icons-png.flaticon.com/512/2331/2331949.png',
                    title: 'Expense',
                    value: '₹$expense',
                    subtitle: 'Total spent',
                    color: const Color(0xFF4F7C82),
                  ),
                  const SizedBox(height: 16),
                  buildInfoCard(
                    height: cardHeight,
                    image: 'https://cdn-icons-png.flaticon.com/512/1578/1578991.png',
                    title: 'Remaining',
                    value: '₹$remaining',
                    subtitle: 'Balance after expenses',
                    color: const Color(0xFF4F7C82),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showAmountDialog,
                icon: const Icon(Icons.payment, color: Colors.white),
                label: const Text("Payment", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B2E33),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // 👉 Navigate to your payment history page (you need to create it)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Paymenthistorypage(), // You need to implement this page
                    ),
                  );
                },
                icon: const Icon(Icons.history, color: Colors.white),
                label: const Text("History", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B2E33),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FillUpFormPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Transection", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B2E33),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }

  Widget buildInfoCard({
    required double height,
    required String image,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Card(
        color: color,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image, size: 40, color: Colors.white70);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
