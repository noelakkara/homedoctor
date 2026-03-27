import 'package:flutter/material.dart';
import 'package:homedoctor/login_page.dart';
import 'package:homedoctor/dashboard_page.dart';
import 'package:homedoctor/doctor_dashboard_page.dart';
import 'package:homedoctor/doctor_verification_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeDoctor',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CheckAuth(),
    );
  }
}

class CheckAuth extends StatefulWidget {
  const CheckAuth({super.key});

  @override
  State<CheckAuth> createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userIdentifier = prefs.getString('userIdentifier') ?? '';
    final isDoctor = prefs.getBool('isDoctor') ?? false;
    final doctorVerified = prefs.getBool('doctorVerified') ?? false;

    if (mounted) {
      if (isLoggedIn) {
        if (isDoctor) {
           if (doctorVerified) {
             Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const DoctorDashboardPage()),
            );
           } else {
             Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const DoctorVerificationPage()),
            );
           }
        } else {
           Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => DashboardPage(email: userIdentifier)),
          );
        }
       
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
