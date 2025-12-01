import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moneymate/admin/AdminDashboardPage.dart';
import 'package:moneymate/root_admin/RootAdminDashboardPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:moneymate/getstarted_page.dart';
import 'package:moneymate/login_page.dart';
import 'package:moneymate/bottom_navigation_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool isFirstInstall = prefs.getBool('isFirstInstall') ?? true;
    bool isLoggedOut = prefs.getBool('isLoggedOut') ?? false;
    String? userRole = prefs.getString('userRole'); // ✅ saved role: 'admin' or 'user'

    await Future.delayed(const Duration(milliseconds: 2700));

    if (isFirstInstall) {
      await prefs.setBool('isFirstInstall', false);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GetStartedPage()),
      );
    } else if (isLoggedOut || userRole == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      if (!mounted) return;
      if (!isLoggedOut  && userRole == 'rootadmin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RootAdminDashboardPage()),
        );
      } else if (userRole == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BottomNavigationPage()),
        );
      }


    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB8E3E9),
      body: Align(
        alignment: Alignment.centerLeft, // 👈 Start from left
        child: Padding(
          padding: const EdgeInsets.only(left: 0.0),
          child: Lottie.asset(
            'assets/animation/cE3LWBl78L.json',
            height: 310,
            width: 320,
            repeat: true,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
