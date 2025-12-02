import 'package:flutter/material.dart';
import 'package:moneymate/Bottom_Navigation_Page.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyQRPage extends StatefulWidget {
  const MyQRPage({Key? key}) : super(key: key);

  @override
  State<MyQRPage> createState() => _MyQRPageState();
}

class _MyQRPageState extends State<MyQRPage> {
  String? upiId;
  String? name;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = snapshot.data();

    setState(() {
      name = (data != null && data['name'] != null)
          ? data['name'] as String
          : "Unknown User";

      upiId = (data != null && data['upi'] != null)
          ? data['upi'] as String
          : "${user.uid}@razorpaytest";

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // QR contains dynamic UPI ID and real name
    final qrData =
        "upi://pay?pa=$upiId&pn=${Uri.encodeComponent(name!)}&cu=INR";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My QR Code",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0B2E33),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Navigate to the bottom navigation page instead of popping
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BottomNavigationPage()), // Replace with your bottom page widget
            );
          },
        ),
      ),


      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 250.0,
            ),
            const SizedBox(height: 20),
            Text(
              "Scan to send test money to $name",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text(
              "(Test Mode — No real payment happens)",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
