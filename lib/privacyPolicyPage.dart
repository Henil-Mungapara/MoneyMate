import 'package:flutter/material.dart';
import 'package:moneymate/signup_page.dart'; // Make sure this path is correct

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  bool _agreeTerms = false;
  bool _agreePrivacy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB8E3E9),
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0B2E33),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("• Your Personal Details: Name, Email, Profile Picture", style: TextStyle(color: Colors.black)),
                    SizedBox(height: 8),
                    Text("• Financial Data: Expenses, Income, Budget Info", style: TextStyle(color: Colors.black)),
                    SizedBox(height: 8),
                    Text("• Device Information: Device Type, OS, Unique IDs", style: TextStyle(color: Colors.black)),
                    SizedBox(height: 8),
                    Text("• Usage Data: How you interact with the app", style: TextStyle(color: Colors.black)),
                    SizedBox(height: 20),
                    Text("✔ Your data is encrypted and stored securely to prevent unauthorized access.", style: TextStyle(color: Colors.black)),
                    SizedBox(height: 8),
                    Text("✔ We do not share your personal data with third parties without your consent.", style: TextStyle(color: Colors.black)),
                    SizedBox(height: 8),
                    Text("✔ You can request data deletion at any time by contacting support.", style: TextStyle(color: Colors.black)),
                    SizedBox(height: 8),
                    Text("✔ We comply with global privacy laws such as GDPR and CCPA.", style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
            ),
            // add code here
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _agreeTerms && _agreePrivacy
                    ? () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpPage()),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0B2E33),
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Get Started",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
